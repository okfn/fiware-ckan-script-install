#!/bin/bash -ex


# Install chef
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -q
# Install git and curl
sudo apt-get -y install git-core curl
sudo apt-get -y install zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev

# Get ruby source and install
wget http://ftp.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz
tar -xzvf ruby-2.2.3.tar.gz
cd ruby-2.2.3/
./configure
make
sudo make install

# Install chef
gem install chef --no-ri --no-rdoc

# create node.json
cat << EOF > /tmp/node.json
{
  "run_list": [ "recipe[ckan::2.5_install]" ]
}
EOF

# Run recipe
chef-solo -r /tmp/cookbooks.tgz -j /tmp/node.json
