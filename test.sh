
#!/bin/bash
x=1
while [ $x -le 5 ]
do
  echo "level = error, find me and fix me $x"
  echo "level = info, wow! i have been executed successful $x"
  echo "level = debug, i am a helper for developer $x"
  echo "level = no_tag, i am a invisible $x"
  x=$(( $x + 1 ))
done

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
# for Intel Macs
[ $(uname -m) = x86_64 ]&& curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-darwin-amd64
# for M1 / ARM Macs
[ $(uname -m) = arm64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-darwin-arm64
chmod +x ./kind
mv ./kind /some-dir-in-your-PATH/kind
