# coding: utf-8
$update_channel = "alpha"
$image_version = "current"

Vagrant.configure("2") do |config|

   config.vm.provision "shell", inline: <<-SHELL
     echo '192.168.8.101 bootstrapper' >> /etc/hosts
     echo "search k8s.baifendian.com" >> /etc/resolv.conf
   SHELL

  #定义boostrapper虚拟机
  config.vm.define "bootstrapper" do |bs|
    bs.vm.box = "coreos-stable"
    bs.vm.box_url = "https://storage.googleapis.com/stable.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % [$update_channel, $image_version]
    bs.vm.hostname = "bootstrapper"
    bs.vm.network "private_network", ip: "192.168.8.101",virtualbox__intnet: true
    bs.vm.provision "shell", path: "provision_bootstrapper_vm.sh"
    bs.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = "2048"
    end
  end

   # 定义k8s master虚拟机
   config.vm.define "master" do |master|
      master.vm.box ="c33s/empty"
      master.ssh.insert_key = false
      master.vm.network  "private_network", type: "dhcp", virtualbox__intnet: true, :mac => "0800274a2da1", :adapter=>1, auto_config: false
      master.vm.provider "virtualbox" do |ms|
         ms.gui = true
    	 ms.memory = "1024"
    	 ms.customize ["modifyvm", :id, "--boot1", "disk", "--boot2", "net"]
      end
   end

   #定义worker虚拟机
   config.vm.define "worker" do |worker|
      worker.vm.box ="c33s/empty"
      worker.ssh.insert_key = false
      worker.vm.network  "private_network", type: "dhcp", virtualbox__intnet: true, :adapter=>1, auto_config: false
      worker.vm.provider "virtualbox" do |wk|
         wk.gui = true
         wk.memory = "1024"
         wk.customize ["modifyvm", :id, "--boot1", "disk", "--boot2", "net", "--macaddress1", "auto"]
      end
   end
end
