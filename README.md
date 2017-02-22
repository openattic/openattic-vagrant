# vagrant-openattic-docker

This repository contains configuration files that simplify the setup of the development environment to work on [openATTIC](http://openattic.org) with a [ceph](https://ceph.com/) cluster managed by [DeepSea](https://github.com/SUSE/DeepSea).

Vagrant will instantiate four VMs using an `opensuse/openSUSE-42.1-x86_64` box:

| VM  |  IP | Description |
|----------| ----------|----------|
| `salt` | 192.168.100.200 | This VM will run [openattic-docker](https://github.com/openattic/openattic-docker) container (salt-master + salt-minion)|
| `node1` | 192.168.100.201 | This VM will run ceph (salt-minion) |
| `node2` | 192.168.100.202 | This VM will run ceph (salt-minion) |
| `node3` | 192.168.100.203 | This VM will run ceph (salt-minion) |

## Requirements

* [Vagrant](https://www.vagrantup.com/)
* Local copy of the [openATTIC repository](https://bitbucket.org/openattic/openattic)
* Local copy of the [DeepSea repository](https://github.com/SUSE/DeepSea)

## Setting up configuration

Configuration resides in the `settings.yml` file that contains the custom configuration to spin up the cluster. See [`settings.sample.yml`](settings.sample.yml) for an example of the `settings.yml` that you must create.

### Settings options:

| Option |  Type    | Default | Description |
|----------| ----------| --------| --------|
| `openattic_repo` | string | `~/openattic` | Path to the local copy of the openATTIC repository |
| `deepsea_repo` | string | `~/DeepSea` | Path to the local copy of the DeepSea repository |
| `libvirt_host` | IP address | none | TODO |
| `libvirt_user` | string | none | TODO |
| `libvirt_use_ssl` | boolean | none | TODO |
| `vm_memory` | integer |  `4096` | TODO |
| `vm_cpus`| integer |  `2` | TODO |
| `vm_storage_pool` | string | none | TODO |
| `vm_num_volumes` | integer |  `2`| TODO |
| `vm_volume_size` |  binary size | `8G`| TODO |
| `nfs_auto_export` | boolean | `true` | enables/disables vagrant from changing the contents of `/etc/exports`

## Spin up cluster

* Run `vagrant up` and wait a few minutes
* Connect to salt VM: `vagrant ssh salt`
* Start openattic-docker: `run-openattic-docker.sh`
* Access openATTIC at: [http://192.168.100.200/openattic](http://192.168.100.200/openattic)

> You can connect to any VM via SSH using vagrant ssh (e.g.: `vagrant ssh node1`).

## NFS sharing when running libvirt in a remote host

When using Vagrant to spin up a VM running in a remote libvirt host, Vagrant
will have trouble exporting the NFS shared folders to the VM due to the way
it changes the `/etc/exports` file.

In this case the best approach is for you to manually edit the `/etc/exports`
file, and put the following lines:

```
"/home/vagrant-openattic-docker/openattic" *(rw,no_subtree_check,all_squash,insecure,anonuid=UID,anongid=GID)
"/home/vagrant-openattic-docker/DeepSea" *(rw,no_subtree_check,all_squash,insecure,anonuid=UID,anongid=GID)
```

Where `UID` and `GID` should be substituted by the values of the `id -u` and
`id -g` commands respectively, and change the path of the directories to match
your environment.

After manually edit the `/etc/exports` file, restart the nfs service, and
change the option `nfs_auto_export` in your `settings.yml` to `false`.

Now you're ready to do `vagrant up`, and the openATTIC and DeepSea directories
will be successfully shared inside your VMs.

