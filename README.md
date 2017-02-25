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

## Setup 

Configuration resides in the `settings.yml` file that contains the custom configuration to spin up the cluster. See 
[`settings.sample.yml`](settings.sample.yml) for an example of the `settings.yml` that you must create.

### settings.yml

| Option |  Type    | Default | Description |
|----------| ----------| --------| --------|
| `openattic_repo` | string | `~/openattic` | Path to the local copy of the openATTIC repository |
| `deepsea_repo` | string | `~/DeepSea` | Path to the local copy of the DeepSea repository |
| `libvirt_host` | IP address | none |  |
| `libvirt_user` | string | none |  |
| `libvirt_use_ssl` | boolean | none |  |
| `vm_memory` | integer |  `4096` | VM memory |
| `vm_cpus`| integer |  `2` | VM CPUs |
| `vm_storage_pool` | string | none | VM storage pool |
| `vm_num_volumes` | integer |  `2`| VM volumes number |
| `vm_volume_size` |  binary size | `8G`| VM volume size |
| `nfs_auto_export` | boolean | `true` | Enables/disables vagrant from changing the contents of `/etc/exports`

### Spin up cluster

* Run `vagrant up && vagrant halt salt && vagrant up salt` and wait a few minutes
* Connect to salt VM: `vagrant ssh salt`
* Start openattic-docker: `oa-docker-run.sh`
* Access openATTIC at: [http://192.168.100.200/openattic](http://192.168.100.200/openattic)

> You can execute `oa-docker-bash.sh` on `salt` VM to access openATTIC docker container

## Running tests

### E2E tests
This development environment is ready to run all ceph e2e tests.
Follow the [openATTIC Web UI Tests - E2E Test Suite](http://docs.openattic.org/2.0/developer_docs/dev_e2e.html) documentation 
to install `protractor`and use the following `configs.js` file to run e2e tests:

```
'use strict';
(function(){
  module.exports = {
    url     : 'http://192.168.100.200/openattic/#/login',
    username: 'openattic',
    password: 'openattic',
    sleep   : 2000,
    outDir: '/tmp',
    cephCluster: {
      cluster1: {
        name: 'ceph',
        pools: {
          cephPool1: {
            name    : 'rbd',
            size    : '5.91',
            unit    : 'GB',
            writable: true
          }
        }
      }
    }
  };
}());
```
> TODO : Add suport to run all e2e tests...

## Other settings

### NFS sharing when running libvirt in a remote host

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

