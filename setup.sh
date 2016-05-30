#!/bin/bash

# Global defined colors
ERROR=1
SUCCESS=2
NOTICE=3
OTHER=4
# Helper function that prints with color
function echo_color() {
  echo "$(tput setaf $1)$2$(tput sgr0)"
}

# Helper function that determines if OS is Mac or (Debian) Linux
function os {
  if [ "$(uname)" == "Darwin" ]; then
    echo 0 # 0 is Mac
  else
    echo 1 # 1 is Linux
  fi
}

function install_rbenv {
  os=$(os)
  command -v rbenv >/dev/null 2>&1 || {
    if [ $os == "0" ]; then
      brew install rbenv
    else
      # TODO for ubuntu desktop bash_profile with bashrc
      sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev
      cd
      git clone git://github.com/sstephenson/rbenv.git .rbenv
      echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
      echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

      git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
      echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bash_profile
      source ~/.bash_profile
    fi
    return
  }
  echo_color $ERROR "rbenv already installed"
}

function install_rvm {
  command -v rvm >/dev/null 2>&1 || {
    echo_color $NOTICE "Installing rvm"
    \curl -sSL https://get.rvm.io | bash -s stable
    echo_color $SUCCESS "rvm installed"
    return
  }
  echo_color $ERROR "rvm already installed"
}

function install_rails {
  echo_color $NOTICE "Installing Rails"
  gem update
  gem install bundler
  gem install rails
  echo_color $SUCCESS "Rails installed"
}

# Git should already be installed on all systems but this is just to be completely sure.
function install_git {
  os=$(os)
  command -v git >/dev/null 2>&1 || {
    echo_color $NOTICE "Installing git"
    if [ $os == "0" ]; then
      brew install git
    else
      sudo apt-get install git
    fi
    echo_color $SUCCESS "git installed"
  }
  echo_color $ERROR "git already installed"
}

# brew
function install_brew {
  os=$(os)
  if [ $os != "0" ]; then # If Linux exit
    return
  fi
  command -v brew >/dev/null 2>&1 || {
    echo_color $NOTICE "Installing brew ..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    echo_color $SUCCESS "brew installed"
    brew update
    return
  }
  echo_color $ERROR "brew already installed"
}

# Postgres
function install_psql {
  os=$(os)
  command -v psql >/dev/null 2>&1 || {
    echo "Installing Postgres ..."
    if [[ $os == "0" ]]; then
      brew install psql
    else
      sudo apt-get install postgresql postgresql-contrib
      service postgresql start
      createuser --interactive
    fi
    echo_color $SUCCESS "Postgres installed"
    return
  }
  echo_color $ERROR "Postgres already installed"
}

# Install pip
function install_pip {
  os=$(os)
  command -v pip >/dev/null 2>&1 || { # Pip not installed
    echo_color $NOTICE "Installing pip"
    if [[ $os == "0" ]]; then
      brew install python
    else
      sudo apt-get install python-pip
    fi
    echo_color $SUCCESS "pip installed"
    return
  }
  echo_color $ERROR "Pip already installed"
}

# Install Django.
function install_django {
  echo_color $NOTICE "Installing django"
  pip install Django
  if [[ $os == "1" ]]; then
    sudo apt install python-django-common
  fi
  echo_color $SUCCESS "Django installation finished (check for errors though)"
  return
}

# Install Heroku Toolbelt
function install_heroku_toolbelt {
  command -v heroku >/dev/null 2>&1 || {
    echo_color $NOTICE "Installing heroku toolbelt"
    wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh
    echo_color $SUCCESS "Heroku toolbelt installed"
    heroku # Initiate first time email/password stuff
    return
  }
  echo_color $ERROR "Heroku toolbelt already installed"
}

function install_mysql {
  os=$(os)
  check_mysql=$(mysql --version)
  command -v mysql >/dev/null 2>&1 || {
    if [ $os == "0" ]; then
      brew install mysql
      mysql_secure_installation
      ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents
      launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
    else
      sudo apt-get install mysql-server mysql-client libmysqlclient-dev
    fi
    echo_color $SUCCESS "MySQL installed"
    return
  }
  echo_color $ERROR "MySQL already installed"
}

function clt {
  os=$(os)
  if [ $os == "0" ]; then
    output=$(xcode-select --install)
    if [[ $output != *"command line tools are already installed"* ]]; then
      echo_color $ERROR "Please re-run after installing Xcode clt"
      return
    fi
  fi
}

clt
echo_color $NOTICE "Starting to install ... be prepared to enter your password if necessary"
# Needed for everything else
install_git
install_brew
# Python stuff
echo_color $NOTICE "Install pip and django? [y/n]"
read input
if [[ $input == 'y' ]]; then
  install_pip
  install_django
else
  echo_color $OTHER "pip and django were not installed"
fi

echo_color $NOTICE "Install ruby-related stuff [rvm/rbenv, rails]? [y/n]"
read input
if [[ $input == 'y' ]]; then
  echo_color $NOTICE "Enter 'rbenv' to install rbenv, 'rvm' for rvm: "
  read input
  if [[ $input == 'rbenv' ]]; then
    install_rbenv
    install_rails
  elif [[ $input == 'rvm' ]]; then
    install_rvm
    install_rails
  fi
else
  echo_color $OTHER "Ruby stuff was not installed"
fi

echo_color $NOTICE "Install Postgres? [y/n]"
read input
if [[ $input == 'y' ]]; then
  install_psql
else
  echo_color $OTHER "Postgres was not installed"
fi
echo_color $NOTICE "Install MySQL? [y/n]"
read input
if [[ $input == 'y' ]]; then
  install_mysql
else
  echo_color $OTHER "MySQL was not installed"
fi

echo_color $NOTICE "Install Heroku Toolbelt? [y/n]"
read input
if [[ $input == 'y' ]]; then
  install_heroku_toolbelt
else
  echo_color $OTHER "Heroku Toolbelt was not installed"
fi

echo_color $SUCCESS "Done installing everything!"
