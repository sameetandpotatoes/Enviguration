#!/bin/bash

# Global defined colors
ERROR=1
SUCCESS=2
NOTICE=3
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


# Git should already be installed on all systems but this is just to be completely sure.
function install_git {
  os=$(os)
  check_git=$(git --version)
  if [[ $check_git != *"command not found"* ]]; then
    echo_color $ERROR "git already installed"
    return
  fi
  echo_color $NOTICE "Installing git"
  if [ $os == "0" ]; then
    brew install git
  else
    sudo apt-get install git
  fi
  echo_color $SUCCESS "git installed"
}

# brew
function install_brew {
  os=$(os)
  if [ $os != "0" ]; then # If Linux exit
    return
  fi
  check_brew=$(brew --version)
  if [[ "$check_brew" != *"command not found"* ]]; then
    echo_color $ERROR "brew already installed"
    return
  fi
  echo_color $NOTICE "Installing brew..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo_color $SUCCESS "brew installed"
  brew update
}

# psql
function install_psql {
  os=$(os)
  check_psql=$(psql --version)
  if [[ $check_psql != *"command not found"* ]]; then
    echo_color $ERROR "Postgres already installed"
    return
  fi
  echo "Installing Postgres..."
  if [ $os == "0"; ]; then
    brew install psql
    echo_color $SUCCESS "Postgres installed"
  else
    sudo apt-get install postgresql postgresql-contrib
    service postgresql start
    createuser --interactive
  fi
}

# Installs pip. Pretty straightforward.
function install_pip {
  os=$(os)
  check_pip=$(pip --version)
  if [[ $check_pip != *"command not found"* ]]; then
    echo_color $ERROR "Pip already installed"
    return
  fi
  echo_color $NOTICE "Installing pip"
  if [ $os == "0"]; then
    brew install python
  else
    sudo apt-get install python-setuptools python-dev build-essential
    sudo easy_install pip
    echo_color $SUCCESS "pip installed"
  fi
}

# Install Django.
function install_django {
  check_django=$(python -c "import django; print(django.get_version())")
  if [[ $check_django != *"No module named django"* ]]; then
    echo_color $ERROR "$(tput setaf 1)Django already installed $(tput sgr0)"
    return
  fi
  echo_color $NOTICE "Installing django"
  pip install Django
  echo_color $SUCCESS "Django installed"
}

# Install Heroku Toolbelt
function install_heroku_toolbelt {
  check_heroku=$(heroku --version)
  if [[ $check_heroku != *"command not found"* ]]; then
    echo_color $ERROR "Heroku toolbelt already installed"
    return
  fi
  echo_color $NOTICE "Installing heroku toolbelt"
  wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh
  echo_color $SUCCESS "Heroku toolbelt installed"
}

function clt {
  os=$(os)
  if [ $os == "0" ]; then
    output=$(xcode-select --install)
    if [[ $output == *"command line tools are already installed"* ]]; then
      echo_color $ERROR "Please re-run after installing Xcode clt"
      return
    fi
  fi
  echo_color $NOTICE "Starting to install ... be prepared to enter your password if necessary"
  install_git
  install_brew
  install_psql
  install_pip
  install_django
  install_heroku_toolbelt
}

clt