# kubernetes v1.23.5 高可用集群自动部署 (offline)
>### Ubuntu 系统

### 1、准备一台ansible操作服务器
```
apt -y install ansible
```
### 2、git clone
```
git clone git@github.com:Asvex/binary-ansible-k8s.git
mv binary-ansible-k8s kubernetes
```
### 3、ansible-playbook
```
ansible-playbook -i ~/hosts ~/k8s.yaml 
```

### 4、k8s.yaml
```
# dir=/root/kubernetes/roles

# create certificate
> ### $dir/cert.sh send to $dir/{etcd,master,node}/files/
- name: create cert 
  gather_facts: false
  hosts: operater
  roles:
    - certificate
  tags: certificate
  
# create components
> ### tar *.tar.gz kube{ctl,-apiserver,-controller-manager,-scheduler} send to $dir/master/files/
> ### tar *.tar.gz etcd{,ctl} send to $dir/etcd/files/
> ### tar *.tar.gz kube{let,-proxy} send to $dir/node/files/
> ### create token.csv send to $dir/master/files/
- name: create token.csv kube{ctl,let,-apiserver,-controller-manager,-scheduler,-proxy}
  gather_facts: false
  hosts: operater
  roles:
    - common
  tags: common

# set up etcd cluster 
> ### tags:certificate:  $dir/etcd/files/ca*.pem etcd*.pem
> ### tags:common:  $dir/etcd/files/etcd{,ctl}
- name: etcd service
  gather_facts: false
  hosts: etcd
  roles:
    - etcd
  tags: etcd

# set up kubernetes components 
> ### tags:certificate:  $dir/master/files/ca*.pem admin*.pem kube{ctl,-apiserver,-controller-manager,-scheduler}*.pem
> ### tags:common:  $dir/master/files/token.csv kube{ctl,-apiserver,-controller-manager,-scheduler} 
- name: master
  gather_facts: false
  hosts: master
  roles:
    - master
  tags: master

# set up api
> ### kubecatl apply -f *.yaml
- name: kubernetes-kubelet api
  gather_facts: false
  hosts: master[0]
  roles:
    - api
  tags: api
  ```
