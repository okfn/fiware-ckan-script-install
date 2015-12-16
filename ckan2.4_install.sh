#!/bin/bash -ex


# Install chef
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -q
# Install git and curl
sudo apt-get -y install git-core curl
# Get rvm and ruby
sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
sudo \curl --silent -L https://get.rvm.io | bash -s stable --ruby=2.2.3
source /usr/local/rvm/scripts/rvm
rvm use 2.2.3 --default
# Install chef
gem install chef --no-ri --no-rdoc

# create node.json
cat << EOF > /tmp/node.json
{
  "run_list": [ "recipe[ckan::2.4_install]" ]
}
EOF

# Run recipe
chef-solo -r /tmp/cookbooks.tgz -j /tmp/node.json
