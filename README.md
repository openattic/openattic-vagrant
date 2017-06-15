vagrant-openattic-docker
========================

This repository contains configuration files that simplify the setup of the development environment to work on
[openATTIC](http://openattic.org) with a [ceph](https://ceph.com/) cluster managed by
[DeepSea](https://github.com/SUSE/DeepSea).

Vagrant will instantiate four VMs using an `opensuse/openSUSE-42.2-x86_64` box:

| VM      | IP              | Roles                              | Description                                                                                                              |
|---------|-----------------|------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| `salt`  | 192.168.100.200 | **master**, **admin**              | Run [openattic-docker](https://github.com/openattic/openattic-docker) container or openattic (salt-master + salt-minion) |
| `node1` | 192.168.100.201 | **mon**, **igw**, **rgw**, **osd** | Run ceph (salt-minion)                                                                                                   |
| `node2` | 192.168.100.202 | **rgw**, **igw**, **osd**          | Run ceph (salt-minion)                                                                                                   |

Requirements
------------

-   [Vagrant](https://www.vagrantup.com/)
-   Local copy of the [openATTIC repository](https://bitbucket.org/openattic/openattic)
-   Local copy of the [DeepSea repository](https://github.com/SUSE/DeepSea)

Setup
-----

Configuration resides in the `settings.yml` file that contains the custom configuration to spin up the cluster. See
[`settings.sample.yml`](settings.sample.yml) for an example of the `settings.yml` that you must create.

**This setup is optimized for systems with 8 GB of memory.**

### settings.yml

| Option                         | Type        | Default                                             | Description                                                                  |
|--------------------------------|-------------|-----------------------------------------------------|------------------------------------------------------------------------------|
| `openattic_repo`               | string      | `~/openattic`                                       | Path to the local copy of the openATTIC repository                           |
| `deepsea_repo`                 | string      | `~/DeepSea`                                         | Path to the local copy of the DeepSea repository                             |
| `openattic_docker_repo`        | string      | `https://github.com/openattic/openattic-docker.git` | openattic-docker git url                                                     |
| `openattic_docker_branch`      | string      | `master`                                            | openattic-docker git branch                                                  |
| `libvirt_host`                 | IP address  | none                                                |                                                                              |
| `libvirt_user`                 | string      | none                                                |                                                                              |
| `libvirt_use_ssl`              | boolean     | none                                                |                                                                              |
| `vm_memory`                    | integer     | `4096`                                              | VM memory                                                                    |
| `vm_cpus`                      | integer     | `2`                                                 | VM CPUs                                                                      |
| `vm_storage_pool`              | string      | none                                                | VM storage pool                                                              |
| `vm_num_volumes`               | integer     | `2`                                                 | VM volumes number                                                            |
| `vm_volume_size`               | binary size | `8G`                                                | VM volume size                                                               |
| `nfs_auto_export`              | boolean     | `true`                                              | Enables/disables vagrant from changing the contents of `/etc/exports`        |
| `build_openattic_docker_image` | boolean     | `false`                                             | Enables/disables the build of the openattic docker image during provisioning |

### Spin up cluster

-   Run `vagrant up` and wait a few minutes
-   Connect to salt VM: `vagrant ssh salt`
-   Now you should choose if you want to use docker (1) or not (2)

1)  **Using docker**
    -   Start openattic-docker: `oa-docker-run.sh`
    -   Access openATTIC at: <http://192.168.100.200/openattic> 
    
> You can execute `oa-docker-bash.sh` on `salt` VM to access openATTIC docker container 
> Use `oa-docker-log.sh` on `salt` VM to follow the openattic.log (with colors)

2)  **Without using docker**
    -   Install openattic: `sudo bin/oa-install.sh`
    -   Activate virtual env: `. env/bin/activate`
    -   Run server: `python openattic/backend/manage.py runserver 0.0.0.0:8001`
    -   Access openATTIC at: <http://192.168.100.200:8001>

Running tests
-------------

### E2E tests

This development environment is ready to run all ceph e2e tests. Follow the [openATTIC Web UI Tests - E2E Test
Suite](http://docs.openattic.org/2.0/developer_docs/dev_e2e.html) documentation to install `protractor`and use the
following `configs.js` file to run e2e tests:

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

Other settings
--------------

### NFS sharing when running libvirt in a remote host

When using Vagrant to spin up a VM running in a remote libvirt host, Vagrant will have trouble exporting the NFS shared
folders to the VM due to the way it changes the `/etc/exports` file.

In this case the best approach is for you to manually edit the `/etc/exports` file, and put the following lines:

    "/home/vagrant-openattic-docker/openattic" *(rw,no_subtree_check,all_squash,insecure,anonuid=UID,anongid=GID)
    "/home/vagrant-openattic-docker/DeepSea" *(rw,no_subtree_check,all_squash,insecure,anonuid=UID,anongid=GID)

Where `UID` and `GID` should be substituted by the values of the `id -u` and `id -g` commands respectively, and change
the path of the directories to match your environment.

After manually edit the `/etc/exports` file, restart the nfs service, and change the option `nfs_auto_export` in your
`settings.yml` to `false`.

Now you're ready to do `vagrant up`, and the openATTIC and DeepSea directories will be successfully shared inside your
VMs.
