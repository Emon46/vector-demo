## Useful References:
https://github.com/vectordotdev/vector-k8s-examples/tree/master/helm

## install vector
```
helm install vector vector/vector-agent --devel --values config.yaml --namespace vector
```


## to build docker image
- need to update the `setting.yaml` file
```
cd src/py && python3 push_logminer.py -op build
```
## push docker image to docker hub and kind
```
docker push docker.io/hremon331046/test-consumer:latest
kind load docker-image docker.io/hremon331046/test-consumer:latest
```

## for installing kafka 
- https://strimzi.io/quickstarts/

## to find out consumer groups exec into kafka broker pod
```
/opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --all-groups
```

## event producers for kafka
```
kubectl -n kafka run kafka-producer -ti --image=quay.io/strimzi/kafka:0.31.1-kafka-3.2.3 --rm=true --restart=Never -- bin/kafka-console-producer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic my-topic
```

## install logminer
```
cd deploy/helm/logminer
helm install -n logminer test-consumer .
```



https://github.com/vectordotdev/vector-test-harness