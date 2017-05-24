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

openattic_docker_repo = settings.has_key?('openattic_docker_repo') ?
                        settings['openattic_docker_repo'] :
                        'https://github.com/openattic/openattic-docker.git'

openattic_docker_branch = settings.has_key?('openattic_docker_branch') ?
                          settings['openattic_docker_branch'] : 'master'

num_volumes = settings.has_key?('vm_num_volumes') ?
              settings['vm_num_volumes'] : 2

volume_size = settings.has_key?('vm_volume_size') ?
              settings['vm_volume_size'] : '8G'

nfs_auto_export = settings.has_key?('nfs_auto_export') ?
                  settings['nfs_auto_export'] : true

build_openattic_docker_image = settings.has_key?('build_openattic_docker_image') ?
                               settings['build_openattic_docker_image'] : false

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false

  config.vm.box = "opensuse/openSUSE-42.2-x86_64"

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
  config.vm.provider :virtualbox do |vb|
    vb.memory = settings.has_key?('vm_memory') ? settings['vm_memory'] : 4096
    vb.cpus = settings.has_key?('vm_cpus') ? settings['vm_cpus'] : 2
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
    node.vm.provider :virtualbox do |vb|
      for i in 1..num_volumes do
        file_to_disk = "./disks/#{node.vm.hostname}-disk#{i}.vmdk"
        unless File.exist?(file_to_disk)
          vb.customize ['createmedium', 'disk', '--filename', file_to_disk,
            '--size', volume_size]
          vb.customize ['storageattach', :id,
            '--storagectl', 'SATA Controller',
            '--port', i, '--device', 0,
            '--type', 'hdd', '--medium', file_to_disk]
        end
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
      hostname node1

      zypper ar http://download.opensuse.org/repositories/filesystems:/ceph:/jewel/openSUSE_Leap_42.2/filesystems:ceph:jewel.repo
      zypper ar http://download.opensuse.org/repositories/home:/swiftgist/openSUSE_Leap_42.1/home:swiftgist.repo
      zypper --gpg-auto-import-keys ref

      SuSEfirewall2 off

      zypper -n install ntp
      zypper -n install salt-minion
      systemctl enable salt-minion
      systemctl start salt-minion

      touch /tmp/ready
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
    node.vm.provider :virtualbox do |vb|
      for i in 1..num_volumes do
        file_to_disk = "./disks/#{node.vm.hostname}-disk#{i}.vmdk"
        unless File.exist?(file_to_disk)
          vb.customize ['createmedium', 'disk', '--filename', file_to_disk,
            '--size', volume_size]
          vb.customize ['storageattach', :id,
            '--storagectl', 'SATA Controller',
            '--port', i, '--device', 0,
            '--type', 'hdd', '--medium', file_to_disk]
        end
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
      hostname node2

      ssh-keyscan -H salt >> ~/.ssh/known_hosts
      ssh-keyscan -H node1 >> ~/.ssh/known_hosts
      ssh-keyscan -H node3 >> ~/.ssh/known_hosts

      zypper ar http://download.opensuse.org/repositories/filesystems:/ceph:/jewel/openSUSE_Leap_42.2/filesystems:ceph:jewel.repo
      zypper ar http://download.opensuse.org/repositories/home:/swiftgist/openSUSE_Leap_42.1/home:swiftgist.repo
      zypper --gpg-auto-import-keys ref

      SuSEfirewall2 off

      zypper -n install ntp
      zypper -n install salt-minion
      systemctl enable salt-minion
      systemctl start salt-minion

      touch /tmp/ready
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
    node.vm.provider :virtualbox do |vb|
      for i in 1..num_volumes do
        file_to_disk = "./disks/#{node.vm.hostname}-disk#{i}.vmdk"
        unless File.exist?(file_to_disk)
          vb.customize ['createmedium', 'disk', '--filename', file_to_disk,
            '--size', volume_size]
          vb.customize ['storageattach', :id,
            '--storagectl', 'SATA Controller',
            '--port', i, '--device', 0,
            '--type', 'hdd', '--medium', file_to_disk]
        end
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

      zypper ar http://download.opensuse.org/repositories/filesystems:/ceph:/jewel/openSUSE_Leap_42.2/filesystems:ceph:jewel.repo
      zypper ar http://download.opensuse.org/repositories/home:/swiftgist/openSUSE_Leap_42.1/home:swiftgist.repo
      zypper --gpg-auto-import-keys ref
      hostname node3

      SuSEfirewall2 off

      zypper -n install ntp
      zypper -n install salt-minion
      systemctl enable salt-minion
      systemctl start salt-minion

      touch /tmp/ready
    SHELL
  end

  config.vm.define :salt do |salt|
    salt.vm.hostname = "salt"
    salt.vm.network :private_network, ip: "192.168.100.200"

    salt.vm.provision "file", source: "keys/id_rsa",
                              destination:".ssh/id_rsa"
    salt.vm.provision "file", source: "keys/id_rsa.pub",
                              destination:".ssh/id_rsa.pub"

    salt.vm.provision "file", source: "bin",
                              destination:"."

    salt.vm.synced_folder openattic_repo, '/home/vagrant/openattic', type: 'nfs',
                            :nfs_export => nfs_auto_export,
                            :mount_options => ['nolock,vers=3,udp,noatime,actimeo=1'],
                            :linux__nfs_options => ['rw','no_subtree_check','all_squash','insecure']

    salt.vm.synced_folder deepsea_repo, '/home/vagrant/DeepSea', type: 'nfs',
                            :nfs_export => nfs_auto_export,
                            :mount_options => ['nolock,vers=3,udp,noatime,actimeo=1'],
                            :linux__nfs_options => ['rw','no_subtree_check','all_squash','insecure']

    config.vm.synced_folder ".", "/vagrant", disabled: true

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
      hostname salt

      chmod 755 -R bin/

      zypper ar http://download.opensuse.org/repositories/filesystems:/ceph:/jewel/openSUSE_Leap_42.2/filesystems:ceph:jewel.repo
      zypper ar http://download.opensuse.org/repositories/home:/swiftgist/openSUSE_Leap_42.1/home:swiftgist.repo
      zypper --gpg-auto-import-keys ref
      zypper ar https://yum.dockerproject.org/repo/main/opensuse/13.2/ docker-main
      zypper --no-gpg-checks ref
      zypper -n --no-gpg-checks install docker-engine
      zypper rr docker-main

      systemctl enable docker
      systemctl restart docker

      zypper -n install ntp salt-minion salt-master
      systemctl enable ntpd
      systemctl start ntpd

      systemctl enable salt-master
      systemctl start salt-master
      sleep 5
      systemctl enable salt-minion
      systemctl start salt-minion


      git clone #{openattic_docker_repo} openattic-docker
      cd openattic-docker
      git checkout #{openattic_docker_branch}
      cd openattic-dev/opensuse_leap_42.2
      [[ "#{build_openattic_docker_image}" == "true" ]] && docker build -t openattic-dev .

      SuSEfirewall2 off

      while : ; do
        PROVISIONED_NODES=`ls -l /tmp/ready-* 2>/dev/null | wc -l`
        echo "waiting for node1, node2 and node3 (${PROVISIONED_NODES}/3)";
        [[ "${PROVISIONED_NODES}" != "3" ]] || break
        sleep 2;
        scp -o StrictHostKeyChecking=no node2:/tmp/ready /tmp/ready-node1;
        scp -o StrictHostKeyChecking=no node2:/tmp/ready /tmp/ready-node2;
        scp -o StrictHostKeyChecking=no node3:/tmp/ready /tmp/ready-node3;
      done

      sleep 5
      salt-key -Ay

      cd /home/vagrant/DeepSea
      if [[ -e Makefile ]]; then
        make install

        cat > /srv/salt/ceph/updates/default_my.sls <<EOF
dummy command:
  test.nop
EOF
        cp /srv/salt/ceph/updates/default_my.sls /srv/salt/ceph/updates/restart
        sed -i 's/default/default_my/g' /srv/salt/ceph/updates/init.sls
        sed -i 's/default/default_my/g' /srv/salt/ceph/updates/restart/init.sls
        cp /srv/salt/ceph/updates/default_my.sls /srv/salt/ceph/time
        sed -i 's/default/default_my/g' /srv/salt/ceph/time/init.sls

        chown -R salt:salt /srv/pillar
        systemctl restart salt-master
        sleep 10
        echo "[DeepSea] Stage 0 - prep"
        salt-run state.orch ceph.stage.prep

        sleep 10
        echo "[DeepSea] Installing and Activating Salt-API"
        salt-call state.apply ceph.salt-api

        sleep 10
        echo "[DeepSea] Stage 1 - discovery"
        salt-run state.orch ceph.stage.discovery
        cat > /srv/pillar/ceph/proposals/policy.cfg <<EOF
# Cluster assignment
cluster-ceph/cluster/*.sls
# Hardware Profile
profile-*-1/cluster/*.sls
profile-*-1/stack/default/ceph/minions/*yml
# Common configuration
config/stack/default/global.yml
config/stack/default/ceph/cluster.yml
# Role assignment
role-master/cluster/salt.sls
role-admin/cluster/salt.sls
role-mon/cluster/node*.sls
role-igw/cluster/node[12]*.sls
role-rgw/cluster/node[13]*.sls
role-mon/stack/default/ceph/minions/node*.yml
EOF
        chown salt:salt /srv/pillar/ceph/proposals/policy.cfg
        cat > /srv/pillar/ceph/rgw.sls <<EOF
rgw_configurations:
  rgw:
    users:
      - { uid: "admin", name: "Admin", email: "admin@demo.nil", system: True }
EOF
        chown salt:salt /srv/pillar/ceph/rgw.sls
        sleep 2
        echo "[DeepSea] Stage 2 - configure"
        salt-run state.orch ceph.stage.configure
        sleep 5
        echo "[DeepSea] Stage 3 - deploy"
        DEV_ENV='true' salt-run state.orch ceph.stage.deploy

        chmod 644 /etc/ceph/ceph.client.admin.keyring
      fi
    SHELL
  end
  
end
