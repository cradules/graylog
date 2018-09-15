# Graylog Kubernetes


This document is covering running graylog on Kubernetes

Requirements:
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl)
- [Kubernetes cluster](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)
- [Kompose](https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/#before-you-begin)
- [Helm](https://docs.helm.sh/using_helm/#installing-helm)

## Pre-install

Before we begin make sure you did fully understand how to run graylog inside docker. 
Running graylog on kubernetes is based on `docker-compose`, section that has been cover [here](/docker)

### Converting docker compose to kubernetes

- Build your docker-compose based on examples on [docker section](/docker).
- Run kompose up to make sure your file is valid and the services are running.
```bash
kompose -f ../docker/docker-compose-general-example-persistent-data.yml up
INFO Successfully deleted Service: elasticsearch
INFO We are going to create Kubernetes Deployments, Services and PersistentVolumeClaims for your Dockerized application. If you need different kind of resources, use the 'kompose convert' and 'kubectl create -f' commands instead.

INFO Deploying application in "default" namespace
INFO Successfully created Service: elasticsearch
INFO Successfully created Service: graylog
INFO Successfully created Service: mongodb
INFO Successfully created Deployment: elasticsearch
INFO Successfully created PersistentVolumeClaim: docker-es-data of size 100Mi. If your cluster has dynamic storage provisioning, you don't have to do anything. Otherwise you have to create PersistentVolume to make PVC work
INFO Successfully created Deployment: graylog
INFO Successfully created PersistentVolumeClaim: docker-graylog-journal of size 100Mi. If your cluster has dynamic storage provisioning, you don't have to do anything. Otherwise you have to create PersistentVolume to make PVC work
INFO Successfully created Deployment: mongodb
INFO Successfully created PersistentVolumeClaim: docker-mongo-data of size 100Mi. If your cluster has dynamic storage provisioning, you don't have to do anything. Otherwise you have to create PersistentVolume to make PVC work
Your application has been deployed to Kubernetes. You can run 'kubectl get deployment,svc,pods,pvc' for details.
```
- For customizing the deployments on kubernetes convert docker-compose.yml to kubernetes files
```bash
kompose -f ../docker/docker-compose-general-example-persistent-data.yml convert
WARN Unsupported root level volumes key - ignoring
WARN Unsupported depends_on key - ignoring
WARN Unsupported ulimits key - ignoring
INFO Kubernetes file "elasticsearch-service.yaml" created
INFO Kubernetes file "graylog-service.yaml" created
INFO Kubernetes file "mongodb-service.yaml" created
INFO Kubernetes file "elasticsearch-deployment.yaml" created
INFO Kubernetes file "docker-es-data-persistentvolumeclaim.yaml" created
INFO Kubernetes file "graylog-deployment.yaml" created
INFO Kubernetes file "docker-graylog-journal-persistentvolumeclaim.yaml" created
INFO Kubernetes file "mongodb-deployment.yaml" created
INFO Kubernetes file "docker-mongo-data-persistentvolumeclaim.yaml" created
```

- For using helm convert `docker-compose.yml` to helm chart
```bash
kompose -f ../docker/docker-compose-general-example-persistent-data.yml convert -c
WARN Unsupported root level volumes key - ignoring
WARN Unsupported ulimits key - ignoring
WARN Unsupported depends_on key - ignoring
INFO Kubernetes file "elasticsearch-service.yaml" created
INFO Kubernetes file "graylog-service.yaml" created
INFO Kubernetes file "mongodb-service.yaml" created
INFO Kubernetes file "elasticsearch-deployment.yaml" created
INFO Kubernetes file "docker-es-data-persistentvolumeclaim.yaml" created
INFO Kubernetes file "graylog-deployment.yaml" created
INFO Kubernetes file "docker-graylog-journal-persistentvolumeclaim.yaml" created
INFO Kubernetes file "mongodb-deployment.yaml" created
INFO Kubernetes file "docker-mongo-data-persistentvolumeclaim.yaml" created
INFO chart created in "./../docker/docker-compose-general-example-persistent-data/"
```
### Install services using helm
- In case you did not initialize helm run:
```bash
helm init
```
- Install services using helm
```bash
helm install ./docker-compose-general-example-persistent-data/
NAME:   invisible-cat
LAST DEPLOYED: Sat Sep 15 21:33:16 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Pod(related)
NAME                            READY  STATUS   RESTARTS  AGE
elasticsearch-68c9dc8d64-dxpd2  0/1    Pending  0         0s
graylog-5576d986d4-lqjbc        0/1    Pending  0         0s
mongodb-85fbc84cf5-ndffw        0/1    Pending  0         0s

==> v1/PersistentVolumeClaim

NAME                    AGE
docker-es-data          0s
docker-graylog-journal  0s
docker-mongo-data       0s

==> v1/Service
elasticsearch  0s
graylog        0s
mongodb        0s

==> v1beta1/Deployment
elasticsearch  0s
graylog        0s
mongodb        0s

```
### Create helm package and save them on git repo
- Create a new repo on git helm-repo
- Clone helm-repo 
```bash
git clone https://github.com/cradules/helm-repo.git
```
- Create a folder named graylog in root path of helm-repo
- Copy the content of the helm chart to the new created folder
```bash
 rsync -aP../graylog/helm/docker-compose-general-example-persistent-data/ ./graylog/
```

- Edit the chart to correspond to the new location
```yaml
name: graylog
description: A generated Helm Chart for graylog from Skippbox Kompose
version: 0.0.1
keywords:
  - graylog
sources:
home:
```
 - Create package 
 ```bash
 helm package graylog/
 Successfully packaged chart and saved it to: /mnt/e/Projects/helm-repo/graylog-0.0.1.tgz
```
- Delete the chart directory for a clean repo
```bash
 rm -rf graylog/
```
- Create helm repo index
```bash
helm repo index .
```
- Add file to git, commit and push them
- Add new help repo to you kubernetes cluster:
```bash
 helm repo add git 'https://raw.githubusercontent.com/cradules/helm-repo/master/'
"git" has been added to your repositories\

helm repo update
Hang tight while we grab the latest from your chart repositories...
...Skip local chart repository
...Successfully got an update from the "git" chart repository
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈ Happy Helming!⎈
 
helm repo list
NAME    URL
stable  https://kubernetes-charts.storage.googleapis.com
local   http://127.0.0.1:8879/charts
git     https://raw.githubusercontent.com/cradules/helm-repo/master/

helm search graylog
NAME            CHART VERSION   APP VERSION     DESCRIPTION
git/graylog     0.0.1                           A generated Helm Chart for graylog from Skippbox Kompose
local/graylog   0.0.1                           A generated Helm Chart for graylog from Skippbox Kompose

```
- Install graylog via helm

```bash
 helm install git/graylog
NAME:   ignorant-kudu
LAST DEPLOYED: Sat Sep 15 22:36:36 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1beta1/Deployment
NAME           AGE
elasticsearch  0s
graylog        0s
mongodb        0s

==> v1/Pod(related)

NAME                            READY  STATUS   RESTARTS  AGE
elasticsearch-68c9dc8d64-kzsj9  0/1    Pending  0         0s
graylog-5576d986d4-lwxwz        0/1    Pending  0         0s
mongodb-85fbc84cf5-w5j94        0/1    Pending  0         0s

==> v1/PersistentVolumeClaim

NAME                    AGE
docker-es-data          0s
docker-graylog-journal  0s
docker-mongo-data       0s

==> v1/Service
elasticsearch  0s
graylog        0s
mongodb        0s

```