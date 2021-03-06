# AutoKube

## Fully Automated Kubernetes Cluster Setup, with one master and N workers.

This will install:

- The lastest Kubernetes version (currently 1.20)
- Containerd as a runtime
- Calico as a CNI.

## Requirements

You have to install:
- [Vagrant](https://www.vagrantup.com/) 
- and [VirtualBox](https://www.virtualbox.org/)

## How To Use It

```bash
# git clone https://github.com/vNugget/Kubernetes.git
```

```bash
# cd Kubernetes/AutoKube
```

```bash
# vagrant up
```
```bash
# vagrant ssh master-1
```
After this stage you can use kubectl

## Videos are better!

[![Watch the video](https://img.youtube.com/vi/dNL6w-Ym_nE/maxresdefault.jpg)](https://youtu.be/dNL6w-Ym_nE)
