# k8sobservability

Basic deployment to k8s to monitorize vm servers

## Initial prerrequisites

Review k8s_setup.sh

```
Step 5: Join Worker Node to Cluster
Repeat the following steps on each worker node to create a cluster:

1. Stop and disable AppArmor:

sudo systemctl stop apparmor && sudo systemctl disable apparmor

2. Restart containerd:

sudo systemctl restart containerd.service

3. Apply the kubeadm join command from Step 3 on worker nodes to connect them to the master node. Prefix the command with sudo:

sudo kubeadm join [master-node-ip]:6443 --token [token] --discovery-token-ca-cert-hash sha256:[hash]

Replace [master-node-ip], [token], and [hash] with the values from the kubeadm join command output.

4. After a few minutes, switch to the master server and enter the following command to check the status of the nodes:

kubectl get nodes
```
