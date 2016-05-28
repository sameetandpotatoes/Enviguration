#!/bin/bash

function os {
  if [ "$(uname)" == "Darwin" ]; then
    echo 0 # 0 is Mac
  else
    echo 1 # 1 is Linux
  fi
}

# git
function install_git {
  os=$(os)
  check_git=$(git --version)
  if [[ $check_git != *"command not found"* ]]; then
    echo "git already installed"
    return
  fi
  echo "Installing git"
  if [ $os == "0" ]; then
    brew install git
    echo "git installed"
  else
    sudo apt-get install git
  fi
}

# brew
function install_brew {
  os=$(os)
  if [ $os != "0" ]; then # If Linux exit
    return
  fi
  check_brew=$(brew --version)
  if [[ "$check_brew" != *"command not found"* ]]; then
    echo "brew already installed"
    return
  fi
  echo "Installing brew..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo "brew installed"
  brew update
}

# psql
function install_psql {
  os=$(os)
  check_psql=$(psql --version)
  if [[ $check_psql != *"command not found"* ]]; then
    echo "Postgres already installed"
    return
  fi
  echo "Installing Postgres..."
  if [ $os == "0"; ]; then
    brew install psql
    echo "Postgres installed"
  else
    sudo apt-get install postgresql postgresql-contrib
    service postgresql start
    createuser --interactive
  fi
}

function install_pip {
  os=$(os)
  check_pip=$(pip --version)
  if [[ $check_pip != *"command not found"* ]]; then
    echo "Pip already installed"
    return
  fi
  echo "Installing pip"
  if [ $os == "0"]; then
    brew install python
  else
    sudo apt-get install python-setuptools python-dev build-essential
    sudo easy_install pip
    echo "Pip installed"
  fi
}

function install_django {
  check_django=$(python -c "import django; print(django.get_version())")
  if [[ $check_django != *"No module named django"* ]]; then
    echo "Django already installed"
    return
  fi
  echo "Installing django"
  pip install Django
  echo "Django installed"
}

function install_heroku_toolbelt {
  check_heroku=$(heroku --version)
  if [[ $check_heroku != *"command not found"* ]]; then
    echo "Heroku toolbelt already installed"
    return
  fi
  echo "Installing heroku toolbelt"
  wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh
  echo "Heroku toolbelt installed"
}

function clt {
  os=$(os)
  if [ $os == "0" ]; then
    output=$(xcode-select --install)
    if [[ $output == *"command line tools are already installed"* ]]; then
      echo "Please re-run after installing Xcode clt"
      return
    fi
  fi
  echo "Starting to install ... be prepared to enter your password if necessary"
  install_git
  install_brew
  install_psql
  install_pip
  install_django
  install_heroku_toolbelt
}

clt