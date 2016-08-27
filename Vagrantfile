# References:
#  1. Private network: https://github.com/k8sp/auto-install/issues/102#issuecomment-238005425
#  2. Install Docker: https://docs.docker.com/engine/installation/linux/ubuntulinux/
Vagrant.configure("2") do |config|
  
#   config.vm.box = "ubuntu/trusty64"

#   config.vm.synced_folder "~/work", "/work"


#   # Install Docker on both VMs.
#   config.vm.provision "shell", inline: <<-SHELL
# apt-get update
# apt-get install -y apt-transport-https ca-certificates
# apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
# touch /etc/apt/sources.list.d/docker.list
# chown vagrant /etc/apt/sources.list.d/docker.list
# echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' >> /etc/apt/sources.list.d/docker.list
# apt-get update
# apt-get install -y linux-image-extra-$(uname -r)
# apt-get install -y docker-engine
# service docker start
# groupadd docker
# usermod -aG docker vagrant
# echo '192.168.50.4 bootstrapper' >> /etc/hosts
#   SHELL

  config.vm.define "bootstrapper" do |bs|
    bs.vm.box = "coreos-stable"
    bs.vm.box_url = "https://storage.googleapis.com/stable.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % [$update_channel, $image_version]
    
    bs.vm.network "private_network", ip: "192.168.50.4", name: "vboxnet0"

    bs.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = "2048"
    end
  end

  # config.vm.define "node" do |nd|
  #   nd.vm.network "private_network", ip: "192.168.50.5", name: "vboxnet0"
  # end
end
