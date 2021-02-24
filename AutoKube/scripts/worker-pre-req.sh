POD_CIDR=$1

sudo sed -i 's/^\/dev\/mapper\/vgvagrant-swap_1/#\/dev\/mapper\/vgvagrant-swap_1/' /etc/fstab
sudo swapoff /dev/mapper/vgvagrant-swap_1
sudo systemctl stop ufw
sudo systemctl disable ufw

############ containerd installation

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

sudo apt-get update && sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default > /etc/containerd/config.toml
sudo systemctl restart containerd

##########install kube*

sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

########### join the cluster

sh /vagrant_data/join.sh

########### correct internal ip for the kubelet
ETH0=$(ip -f inet addr show eth1 | grep -Po 'inet \K[\d.]+')
sudo sed -i "s/^ExecStart=\/usr\/bin\/kubelet.*/&  --node-ip $ETH0/"  /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl daemon-reload && sudo systemctl restart kubelet
