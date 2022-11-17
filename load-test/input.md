## loader pod yaml
Theee is a env `MAX_RANGE` in pod spec which defines the number of iteration for loop to generate logs. It will run the `/scripts.run.sh` file
``` 
apiVersion: v1
kind: Pod
metadata:
  name: load-gen-test
  namespace: demo
spec:
  containers:
    - name: load-gen
      image: hremon331046/load-gen:latest
      imagePullPolicy: IfNotPresent
      env:
        - name: MAX_RANGE
          value: "50000"
  restartPolicy: Never
```
## build docker image
cd inside  `load-test` sub-directory.
``` 
cd load-test
make build
```

## push docker image
cd inside  `load-test` sub-directory. this will push docker image into remote registry
``` 
cd load-test
make push
```

## push to kind docker image
cd inside  `load-test` sub-directory. this will not push docker image into remote registry. It will only load image inside `kind cluster`.
``` 
cd load-test
make build
```