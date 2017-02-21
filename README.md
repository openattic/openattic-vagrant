# vagrant-openattic-docker

This repo contains configuration files that simplify the setup of the development environment to work on [openATTIC](http://openattic.org).

Vagrant will instantiate four VMs using an `opensuse/openSUSE-42.1-x86_64` box:

| VM  |  Description |
|----------| ----------|
| `salt` | This VM will run [openattic-docker](https://github.com/openattic/openattic-docker) |
| `node1` | This VM will run salt-minion |
| `node2` | This VM will run salt-minion |
| `node3` | This VM will run salt-minion |

## Setting up configuration

Configuration resides in the `settings.yml` file that contains the custom configuration to spin up the cluster. See [`settings.sample.yml`](settings.sample.yml) for an example of the `settings.yml` that you must create.

### Settings options:

| Option |  Type    | Default | Description |
|----------| ----------| --------| --------|
| `openattic_repo` | string | `~/openattic` | TODO |
| `deepsea_repo` | string | `~/DeepSea` | TODO |
| `libvirt_host` | IP address | none | TODO |
| `libvirt_user` | string | none | TODO |
| `libvirt_use_ssl` | boolean | none | TODO |
| `vm_memory` | integer |  `4096` | TODO |
| `vm_cpus`| integer |  `2` | TODO |
| `vm_storage_pool` | string | none | TODO |
| `vm_num_volumes` | integer |  `2`| TODO |
| `vm_volume_size` |  binary size | `8G`| TODO |

## Spin up cluster

Just run `vagrant up` and wait a few minutes.

You can connecto to any VM via SSH using vagrant ssh (e.g.: `vagrant ssh salt`).
