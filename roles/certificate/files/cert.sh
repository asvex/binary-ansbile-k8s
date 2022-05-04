#!/bin/bash
root_dir=/root/kubernetes
etcd_dir=$root_dir/roles/etcd/files/
master_dir=$root_dir/roles/master/files/
node_dir=$root_dir/roles/node/files/

cfssl gencert -initca ca-csr.json | cfssljson -bare ca
for i in $etcd_dir  $master_dir $node_dir;do cp -arp ca*.pem $i;done

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes etcd-csr.json | cfssljson -bare etcd
cp etcd*.pem $etcd_dir

for i in kube-apiserver admin kube-controller-manager kube-scheduler
  do
    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes $i-csr.json | cfssljson -bare $i
    cp $i.pem $i-key.pem ${master_dir}
done

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy
cp kube-proxy*.pem $node_dir
