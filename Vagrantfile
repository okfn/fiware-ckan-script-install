# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  # config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.vm.hostname = 'default.ckanhosted.dev'
  config.vm.network :private_network, ip: '192.168.42.42'

  config.vm.network "forwarded_port", guest: 8983, host: 8983
  config.vm.network "forwarded_port", guest: 5000, host: 5000  # paster server (development)

    config.vm.provider "virtualbox" do |vb|
      # Customize the amount of memory on the VM:
      vb.memory = "1024"
    end

    config.vm.provision "file", source: "data.tgz", destination: "/tmp/data.tgz"
    move_data = "mv /tmp/data.tgz /home/ubuntu/data.tgz"
    config.vm.provision :shell, :inline => move_data
    config.vm.provision "shell", path: "ckan2.6_install.sh"

  end
