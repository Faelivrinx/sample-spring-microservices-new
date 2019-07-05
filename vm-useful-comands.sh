
#setup VM

vi /etc/hosts
192.168.57.20 kubemaster microservices.info
192.168.57.21 kubeslave1

vi /etc/sysconfig/network-scripts/ifcfg-enp0s8
systemctl restart network


yum update
yum install wget
hostnamectl set-hostname kubemaster
systemctl disable firewalld && systemctl stop firewalld


setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
echo '1' > /proc/sys/net/ipv4/ip_forward

swapoff -a
vi /etc/fstab

yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubelet kubeadm kubectl
sudo reboot
systemctl start docker && systemctl enable docker
systemctl start kubelet && systemctl enable kubelet

docker info | grep -i cgroup
find / -name "10-kubeadm.conf"

sed -i 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/g' <up line output>
systemctl daemon-reload
systemctl restart kubeleta

kubeadm init --apiserver-advertise-address=192.168.57.20
kubectl create clusterrolebinding admin --clusterrole=cluster-admin --serviceaccount=default:default

#On worker
ip route add 10.96.0.0/16 dev enp0s8 src 192.168.57.21

#install wave
sysctl net.bridge.bridge-nf-call-iptables=1
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl taint nodes --all node-role.kubernetes.io/master-

#delete wave
kubectl -n kube-system delete -f https://git.io/weave-kube-1.6

#search commends
kubectl get pods --all-namespaces
kubectl describe pods -n kube-system weave-net-pm6xp
    kubectl logs -n kube-system -p <pod>
kubectl get svc --all-namespaces
kubectl delete daemonsets,replicasets,services,deployments,pods,rc -n ingress-nginx
#set static ip
#ifcfg-enp0s3
ONBOOT=yes
USERCTL=no

#ifcfg-enp0s8
BOOTPROTO=none
ONBOOT=yes
IPADDR=192.168.56.141
PREFIX=24












