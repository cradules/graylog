# Graylog with local kubernetes storage persistence and LoadBalancer

This documentation is covering the way how you can build LoadBalancer services on a "bare-metal" kubernetes cluster and also using local persistent storage

Cluster specification:

Hosts: VM machine on VMware ESXI Hypervisory
Cluster is formed of master and two nodes:


```text
NAME       STATUS    ROLES     AGE       VERSION
k8master   Ready     master    5h        v1.11.3
k8node01   Ready     <none>    5h        v1.11.3
k8node02   Ready     <none>    5h        v1.11.3
```

### Requirements:
- [Kubernetes Cluster](https://kubernetes.io/docs/setup/scratch/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [PfSense](https://www.pfsense.org/)


For achieving SVC (LoadBalancer) services on a "bare-metal" kubernetes cluster you need to install [MetalLB](https://metallb.universe.tf/tutorial/minikube/) on your kubernetes cluster.
The setup is also covering local persistent storage.

### Install MetalLB with BGP routing

- Install MetalLB by applying the manifest:
```bash
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.7.3/manifests/metallb.yaml
```
This manifest creates a bunch of resources. Most of them are related to access control, so that MetalLB can read and write the Kubernetes objects it needs to do its job.
```bash
kubectl get pods -n metallb-system
NAME                        READY     STATUS    RESTARTS   AGE
controller-9c57dbd4-j2thk   1/1       Running   0          4h
speaker-cljkx               1/1       Running   0          4h
speaker-csblz               1/1       Running   0          4h
```

### Configure MetalLB
Here is a sample MetalLB configuration
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    peers:
    - peer-address: 192.168.0.1
      peer-asn: 64500
      my-asn: 64501
    address-pools:
    - name: default
      protocol: bgp
      avoid-buggy-ips: true
      addresses:
      - 192.168.12.0/24
```

MetalLB’s configuration is a standard Kubernetes ConfigMap, config under the metallb-system namespace. It contains two pieces of information: who MetalLB should talk to, and what IP addresses it’s allowed to hand out.

Apply above configuration after you have update it with the information of your local setup.

### PfSense OpneBGPD setup

- Go to "Package Manager" and install OpenBGPD
- After install go to Services: OpenBGPD and provide the information according wih your local setup. 

![alt-text](/misc/openbgpd-pfsense.PNG)

Note: The only way I could create a succefully BGP connection was to provide the setup directly on the "raw config" as fallow
```text
AS 64500
fib-update yes
listen on 0.0.0.0
router-id 192.168.0.1
network 192.168.0.1/24
neighbor 192.168.0.4 { 
	remote-as 64501 
	descr "Kubernetes-Node01" 
}
neighbor 192.168.0.8 { 
	remote-as 64501 
	descr "Kubernetes-Node02" 
}
#deny from any
#deny to any
```

If the setup is successfully you should be able to see on "OpenBGPD/Status":
````text
OpenBGPD Summary
Neighbor                   AS    MsgRcvd    MsgSent  OutQ Up/Down  State/PrfRcvd
Kubernetes-Node02       64501        362        352     0 02:54:35      1
Kubernetes-Node01       64501        362        352     0 02:54:35      1
````
```text
OpenBGPD Neighbors
BGP neighbor is 192.168.0.8, remote AS 64501
 Description: Kubernetes-Node02
  BGP version 4, remote router-id 192.168.0.8
  BGP state = Established, up for 02:54:35
  Last read 00:00:05, holdtime 90s, keepalive interval 30s
  Neighbor capabilities:
    Multiprotocol extensions: IPv4 unicast, IPv6 unicast
    4-byte AS numbers
    .....
```





