## loader pod yaml
Theee is a env `MAX_RANGE` in pod spec which defines the number of iteration for loop to generate logs. It will run the `/scripts.run.sh` file
``` 
apiVersion: v1
kind: Pod
metadata:
  name: load-test-pod
  namespace: demo
spec:
  containers:
    - name: load-test
      image: hremon331046/load-tester:latest
      imagePullPolicy: IfNotPresent
      env:
        - name: MAX_RANGE
          value: "50000"
  restartPolicy: Never
```
## build docker image
cd inside  `load-tester` sub-directory.
``` 
cd load-tester
make build
```

## push docker image
cd inside  `load-tester` sub-directory. this will push docker image into remote registry
``` 
cd load-tester
make push
```

## push to kind docker image
cd inside  `load-tester` sub-directory. this will not push docker image into remote registry. It will only load image inside `kind cluster`.
``` 
cd load-tester
make build
```