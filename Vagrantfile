# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

raise Vagrant::Errors::VagrantError.new,
  "'settings.yml' file not found.\n\n" \
  "Please define your 'settings.yml'. " \
  "See 'settings.sample.yml' for an example." unless File.exist?("settings.yml")

settings = YAML.load_file('settings.yml')

openattic_repo = settings.has_key?('openattic_repo') ?
                 settings['openattic_repo'] : "~/openattic"

deepsea_repo = settings.has_key?('deepsea_repo') ?
                 settings['deepsea_repo'] : "~/DeepSea"

num_volumes = settings.has_key?('vm_num_volumes') ?
              settings['vm_num_volumes'] : 2

volume_size = settings.has_key?('vm_volume_size') ?
              settings['vm_volume_size'] : '8G'

Vagrant.configure("2") do |config|
  config.vm.box = "opensuse/openSUSE-42.1-x86_64"

  config.vm.provider "libvirt" do |lv|
    if settings.has_key?('libvirt_host') then
      lv.host = settings['libvirt_host']
    end
    if settings.has_key?('libvirt_user') then
      lv.username = settings['libvirt_user']
    end
    if settings.has_key?('libvirt_use_ssl') then
      lv.connect_via_ssh = true
    end

    lv.memory = settings.has_key?('vm_memory') ? settings['vm_memory'] : 4096
    lv.cpus = settings.has_key?('vm_cpus') ? settings['vm_cpus'] : 2
    if settings.has_key?('vm_storage_pool') then
      lv.storage_pool_name = settings['vm_storage_pool']
    end

  end

  config.vm.define :salt do |salt|
    salt.vm.hostname = "salt"
    salt.vm.network :private_network, ip: "192.168.100.200"

    salt.vm.provision "file", source: "keys/id_rsa",
                              destination:".ssh/id_rsa"
    salt.vm.provision "file", source: "keys/id_rsa.pub",
                              destination:".ssh/id_rsa.pub"

    salt.vm.synced_folder openattic_repo, '/home/vagrant/openattic', type: 'nfs',
                            :mount_options => ['nolock,vers=3,udp,noatime,actimeo=1']

    salt.vm.synced_folder deepsea_repo, '/home/vagrant/DeepSea', type: 'nfs',
                            :mount_options => ['nolock,vers=3,udp,noatime,actimeo=1']

    salt.vm.provision "shell", inline: <<-SHELL
      echo "192.168.100.200 salt" >> /etc/hosts
      echo "192.168.100.201 node1" >> /etc/hosts
      echo "192.168.100.202 node2" >> /etc/hosts
      echo "192.168.100.203 node3" >> /etc/hosts
      cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
      mkdir /root/.ssh
      chmod 600 /home/vagrant/.ssh/id_rsa
      cp /home/vagrant/.ssh/id_rsa* /root/.ssh/
      cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

      zypper ar http://download.opensuse.org/repositories/filesystems:/ceph:/jewel/openSUSE_Leap_42.1/filesystems:ceph:jewel.repo
      zypper ar http://download.opensuse.org/repositories/home:/swiftgist/openSUSE_Leap_42.1/home:swiftgist.repo
      zypper --gpg-auto-import-keys ref
      zypper ar \
        https://yum.dockerproject.org/repo/main/opensuse/13.2/ \
        docker-main
      zypper --no-gpg-checks ref
      zypper -n --no-gpg-checks install docker-engine
      zypper rr docker-main

      systemctl enable docker
      systemctl restart docker

      git clone https://github.com/openattic/openattic-docker.git
      cd openattic-docker
      git checkout wip-deepsea
      cd openattic-dev/opensuse_leap_42.2
      docker build -t openattic-dev .
    SHELL
  end

  config.vm.define :node1 do |node|
    node.vm.hostname = "node1"
    node.vm.network :private_network, ip: "192.168.100.201"

    node.vm.provision "file", source: "keys/id_rsa",
                              destination:".ssh/id_rsa"
    node.vm.provision "file", source: "keys/id_rsa.pub",
                              destination:".ssh/id_rsa.pub"

    node.vm.provider "libvirt" do |lv|
      (1..num_volumes).each do |d|
        lv.storage :file, size: volume_size, type: 'raw'
      end
    end

    node.vm.provision "shell", inline: <<-SHELL
      echo "192.168.100.200 salt" >> /etc/hosts
      echo "192.168.100.201 node1" >> /etc/hosts
      echo "192.168.100.202 node2" >> /etc/hosts
      echo "192.168.100.203 node3" >> /etc/hosts
      cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
      mkdir /root/.ssh
      chmod 600 /home/vagrant/.ssh/id_rsa
      cp /home/vagrant/.ssh/id_rsa* /root/.ssh/
      cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

      zypper ar http://download.opensuse.org/repositories/filesystems:/ceph:/jewel/openSUSE_Leap_42.1/filesystems:ceph:jewel.repo
      zypper ar http://download.opensuse.org/repositories/home:/swiftgist/openSUSE_Leap_42.1/home:swiftgist.repo 
      zypper --gpg-auto-import-keys ref

      zypper -n up
      zypper -n install salt-minion
    SHELL
  end

  config.vm.define :node2 do |node|
    node.vm.hostname = "node2"
    node.vm.network :private_network, ip: "192.168.100.202"

    node.vm.provision "file", source: "keys/id_rsa",
                              destination:".ssh/id_rsa"
    node.vm.provision "file", source: "keys/id_rsa.pub",
                              destination:".ssh/id_rsa.pub"

    node.vm.provider "libvirt" do |lv|
      (1..num_volumes).each do |d|
        lv.storage :file, size: volume_size, type: 'raw'
      end
    end

    node.vm.provision "shell", inline: <<-SHELL
      echo "192.168.100.200 salt" >> /etc/hosts
      echo "192.168.100.201 node1" >> /etc/hosts
      echo "192.168.100.202 node2" >> /etc/hosts
      echo "192.168.100.203 node3" >> /etc/hosts
      cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
      mkdir /root/.ssh
      chmod 600 /home/vagrant/.ssh/id_rsa
      cp /home/vagrant/.ssh/id_rsa* /root/.ssh/
      cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

      ssh-keyscan -H salt >> ~/.ssh/known_hosts
      ssh-keyscan -H node1 >> ~/.ssh/known_hosts
      ssh-keyscan -H node3 >> ~/.ssh/known_hosts

      zypper ar http://download.opensuse.org/repositories/filesystems:/ceph:/jewel/openSUSE_Leap_42.1/filesystems:ceph:jewel.repo
      zypper ar http://download.opensuse.org/repositories/home:/swiftgist/openSUSE_Leap_42.1/home:swiftgist.repo
      zypper --gpg-auto-import-keys ref

      zypper -n up
      zypper -n install salt-minion
    SHELL
  end

  config.vm.define :node3 do |node|
    node.vm.hostname = "node3"
    node.vm.network :private_network, ip: "192.168.100.203"

    node.vm.provision "file", source: "keys/id_rsa",
                              destination:".ssh/id_rsa"
    node.vm.provision "file", source: "keys/id_rsa.pub",
                              destination:".ssh/id_rsa.pub"

    node.vm.provider "libvirt" do |lv|
      (1..num_volumes).each do |d|
        lv.storage :file, size: volume_size, type: 'raw'
      end
    end

    node.vm.provision "shell", inline: <<-SHELL
      echo "192.168.100.200 salt" >> /etc/hosts
      echo "192.168.100.201 node1" >> /etc/hosts
      echo "192.168.100.202 node2" >> /etc/hosts
      echo "192.168.100.203 node3" >> /etc/hosts
      cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
      mkdir /root/.ssh
      chmod 600 /home/vagrant/.ssh/id_rsa
      cp /home/vagrant/.ssh/id_rsa* /root/.ssh/
      cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

      ssh-keyscan -H salt >> ~/.ssh/known_hosts
      ssh-keyscan -H node1 >> ~/.ssh/known_hosts
      ssh-keyscan -H node2 >> ~/.ssh/known_hosts

      zypper ar http://download.opensuse.org/repositories/filesystems:/ceph:/jewel/openSUSE_Leap_42.1/filesystems:ceph:jewel.repo
      zypper ar http://download.opensuse.org/repositories/home:/swiftgist/openSUSE_Leap_42.1/home:swiftgist.repo 
      zypper --gpg-auto-import-keys ref

      zypper -n up
      zypper -n install salt-minion
    SHELL
  end

end
