# Create kubernetes cluster
I have created a kubernetes cluster in my local machine with [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
``` 
kind create cluster
```
# Here is the Flow Diagram
<img src='./pipeline.jpeg'/>

# Install vector-telemetry-agent as Daemonset
``` 
helm repo add vector https://helm.vector.dev
helm upgrade -i vector vector/vector-agent --devel --values telemetry-agent/config.yaml --create-namespace --namespace vector
```

`config.yaml` file refers the `config` with which `vector-telemetry-agent` is going to run.
```
image:
  repository: timberio/vector
  pullPolicy: IfNotPresent
  tag: "nightly-2022-10-23-debian"
service:
  # Whether to create service resource or not.
  enabled: true
  annotations: {}
  type: ClusterIP
  topologyKeys: {}
  ports:
    - name: api
      port: 8686
      protocol: TCP
      targetPort: 8686
    - name: vector-port
      port: 9000
      protocol: TCP
      targetPort: 9000
    
customConfig:
  data_dir: "/vector-data-dir"
  sources:
    vector_agent_source:
      address: 0.0.0.0:9000
      type: vector
      version: "2"

  sinks:
    filtered_vector_log:
      compression: none
      encoding:
        codec: json
      inputs:
        - vector_agent_source
      path: /tmp/vector-statefulSet-logs-%Y-%m-%d.log
      type: file

```



# Install vector Dataplane
here we are going to create a couple of things
- statefulSet for vector-data-plane
- create service to connect with `vector-data-plane`. exposed `9000` port.
- create configmap which is mount inside `vector-data-plane` pods. this is the config with which vector-data-plane will run.
- Create RBAC to give the proper permission to our DataPlane StatefulSet
here is the config:
```
    data_dir: /vector-data-dir
    sources:
      k8s_logs_source:
        type: kubernetes_logs
        extra_field_selector: metadata.name==load-test-pod
      internal_log_source:
        type: internal_logs
    
    transforms:
      filter_k8s_logs:
        type: filter
        inputs:
          - k8s_logs_source
        condition: contains(string(.message) ?? "", "no_tag") != true
    
    sinks:
      k8s_logs_sink:
        compression: none
        encoding:
          codec: json
        inputs:
        - filter_k8s_logs
        path: /tmp/vector-demo-logs-%Y-%m-%d.log
        type: file
      vector_dataplane_sink:
        type: vector
        inputs:
          - internal_log_source
        address: http://vector-agent:9000
```

in `sink`, we have added `vector` type which pass this `vector-data-plane` pod's logs
to another `vector-telemetry-agent`'s  `source`. In the telemetry agent, we have exposed a receiver server in port 9000 which will take these logs as input.
Here We have mentioned the `service name` of our `vector telemetry agent` in `spec.address` of `vector_dataplane_sink`.

Let's apply the configmap, service, statefulset
``` 
kubectl apply -f data-plane/rbac.yaml
kubectl apply -f data-plane/vector-dp-sts.yaml
kubectl apply -f data-plane/data-plane-config.yaml
kubectl apply -f data-plane/service.yaml
```
here is the yamls file:

### rbac.yaml
``` 
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: vector-data-plane
rules:
- apiGroups:
  - ""
  resources:
  - namespaces
  - pods
  - nodes
  verbs:
  - watch
  - get
  - list
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: vector-data-plane
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: vector-data-plane
subjects:
- kind: ServiceAccount
  name: vector-data-plane
  namespace: vector
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vector-data-plane
  namespace: vector

```

### service.yaml
```
apiVersion: v1
kind: Service
metadata:
  name: vector-data-plane
  namespace: vector
spec:
  ports:
  - port: 9000
  selector:
    app: vector-dp
  clusterIP: None
``` 
### ConfigMap.yaml
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: vector-data-plane-config
  namespace: vector
data:
  vector.yaml: |
    data_dir: /vector-data-dir
    sources:
      k8s_logs_source:
        type: kubernetes_logs
        extra_field_selector: metadata.name==load-test-pod
      internal_log_source:
        type: internal_logs
    
    transforms:
      filter_k8s_logs:
        type: filter
        inputs:
          - k8s_logs_source
        condition: contains(string(.message) ?? "", "no_tag") != true
    
    sinks:
      k8s_logs_sink:
        compression: none
        encoding:
          codec: json
        inputs:
        - filter_k8s_logs
        path: /tmp/vector-demo-logs-%Y-%m-%d.log
        type: file
      vector_agent_sink:
        type: vector
        inputs:
          - internal_log_source
        address: http://vector-agent:9000

```
### StatefulSet.yaml

```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: vector-data-plane
  namespace: vector
spec:
  serviceName: vector-data-plane
  selector:
    matchLabels:
      app: vector-dp
  template:
    metadata:
      labels:
        app: vector-dp
    spec:
      serviceAccountName: "vector-data-plane"
      containers:
      - args:
        - --config-dir
        - /etc/vector/
        env:
        - name: VECTOR_SELF_NODE_NAME
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: spec.nodeName
        - name: VECTOR_SELF_POD_NAME
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.name
        - name: VECTOR_SELF_POD_NAMESPACE
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
        - name: PROCFS_ROOT
          value: /host/proc
        - name: SYSFS_ROOT
          value: /host/sys
        image: timberio/vector:nightly-2022-10-23-debian
        imagePullPolicy: IfNotPresent
        name: vector
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /var/log/
          name: var-log
          readOnly: true
        - mountPath: /var/lib
          name: var-lib
          readOnly: true
        - mountPath: /vector-data-dir
          name: data-dir
        - mountPath: /etc/vector
          name: config-dir
          readOnly: true
        - mountPath: /host/proc
          name: procfs
          readOnly: true
        - mountPath: /host/sys
          name: sysfs
          readOnly: true
      volumes:
      - hostPath:
          path: /var/log/
          type: ""
        name: var-log
      - hostPath:
          path: /var/lib/
          type: ""
        name: var-lib
      - hostPath:
          path: /var/lib/vector/
          type: ""
        name: data-dir
      - name: config-dir
        projected:
          defaultMode: 420
          sources:
          - configMap:
              name: vector-data-plane-config
      - hostPath:
          path: /proc
          type: ""
        name: procfs
      - hostPath:
          path: /sys
          type: ""
        name: sysfs

```

# AutoScaling StatefulSet
Now we want to autoscale our vector dataplane statefulSet.

Before Doing autoscaling, we need to make sure that we have installed [`metrics-server`](https://github.com/kubernetes-sigs/metrics-server#installation). This will help us to compute the resources like: `CPU`, `Memory`, etc.

To work the metrics-server-api properly in our local `kind` cluster, we need to add the flag `--kubelet-insecure-tls` in `args`.
``` 
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/

helm upgrade -i metrics-server metrics-server/metrics-server --devel --set args[0]=--kubelet-insecure-tls --create-namespace  --namespace kube-metric
```
now let's deploy the `HorizontalPodAutoscaler`.

```
kubectl apply -f data-plane/horizontal-auto-scaling.yaml
```

```
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: vector-dp-auto-scale
  namespace: vector
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: StatefulSet
    name: vector-data-plane
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50

```