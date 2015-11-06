# -*- mode: ruby -*-
# vi: set ft=ruby :

PACKAGES = {
  ubuntu: {
    common: %w{software-properties-common python-software-properties build-essential git nginx curl},
    rails: %w{rake libxml2 libxml2-dev libxslt-dev zlib1g-dev},
    pg: %w{zlib1g-dev postgresql postgresql-contrib libpq-dev},
    mysql: %w{libmysqlclient-dev},

    nagira: %w{nagios3}
  }
}

STD_RUBY_VERSION="2.0"
DOTFILES= "https://github.com/dmytro/dotfiles.git"

SETUP_ENVIRONMENT = {
  ubuntu: <<-SCRIPT,
  DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get remove -qq --assume-yes pico nano
  apt-get install --assume-yes -qq #{PACKAGES[:ubuntu][:common].join(' ')}

  apt-get remove -qq --assume-yes pico nano
  apt-get install -qq -y git zsh curl ruby#{STD_RUBY_VERSION} ruby#{STD_RUBY_VERSION}-dev

  update-alternatives --remove ruby /usr/bin/ruby#{STD_RUBY_VERSION}
  update-alternatives --remove irb /usr/bin/irb#{STD_RUBY_VERSION}
  update-alternatives --remove gem /usr/bin/gem#{STD_RUBY_VERSION}

  update-alternatives \
    --install /usr/bin/ruby ruby /usr/bin/ruby#{STD_RUBY_VERSION} 50 \
    --slave /usr/bin/irb irb /usr/bin/irb#{STD_RUBY_VERSION} \
    --slave /usr/bin/rake rake /usr/bin/rake#{STD_RUBY_VERSION} \
    --slave /usr/bin/gem gem /usr/bin/gem#{STD_RUBY_VERSION} \
    --slave /usr/bin/rdoc rdoc /usr/bin/rdoc#{STD_RUBY_VERSION} \
    --slave /usr/bin/testrb testrb /usr/bin/testrb#{STD_RUBY_VERSION} \
    --slave /usr/bin/erb erb /usr/bin/erb#{STD_RUBY_VERSION} \
    --slave /usr/bin/ri ri /usr/bin/ri#{STD_RUBY_VERSION}

  update-alternatives --config ruby
  update-alternatives --display ruby
  gem install bundler

  test -d ~vagrant/dotfiles || su vagrant -c "git clone #{DOTFILES} && cd ~/dotfiles && rake install "
  chsh -s /bin/zsh vagrant
  echo 'cd /vagrant' >> ~/.zshrc
SCRIPT

  nagira: <<-NAGIRA
  DEBIAN_FRONTEND=noninteractive
  apt-get install --assume-yes -qq #{PACKAGES[:ubuntu][:nagira].join(' ')}
  cd /vagrant && bundle install
NAGIRA
  }

Vagrant.configure(2) do |config|

  config.vm.usable_port_range = 2200..2250

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
  end

  config.vm.provider "virtualbox" do |v|
    v.gui = false
    v.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
  end


  config.vm.define :centos do |nagira|
    nagira.vm.box = " puphpet/centos65-x64"
    nagira.vm.host_name = 'nagira.centos.local'
    nagira.vm.network :forwarded_port, guest: 4567, host: 3002, id: "rails"
  end

  config.vm.define :ubuntu do |nagira|
    nagira.vm.box = "ubuntu/trusty64"
    nagira.vm.host_name = 'nagira.ubuntu.local'
    nagira.vm.network :forwarded_port, guest: 4567, host: 4567, id: "sinatra"
    config.vm.provision "shell", inline: SETUP_ENVIRONMENT[:ubuntu]
    config.vm.provision "shell", inline: SETUP_ENVIRONMENT[:nagira]
  end

end
