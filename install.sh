#!/bin/bash

git_server_sudo_setup() {
  # ----------
  # Allow sudo without password for the current user, for convenience.
  #
  # NOTE: If you don't want this convenience, you can comment out the
  # lines below, and then you'll need to type the sudo password sometimes
  # when maybe it would be better to not have to do that, so things
  # can happen more automatically.
  
  # Try to grant sudo permission and exit if unavailable.
  echo ""
  echo "Setting up sudo..."
  echo ""

  sudo cat /dev/null
  res=$?
  if [ $res -ne 0 ]; then
    echo ""
    echo "error: Failed getting sudo permission. You can grant passwordless sudo"
    echo "if you want by running a command similar to the following example:"
    echo ""
    echo "  .gc/new-git-server.sh -s git1 git2 gitlab"
    echo ""
    exit $?
  fi

  sudo cat /etc/sudoers.d/*_$USER-nopasswd 2>/dev/null | grep 'ALL=(ALL) NOPASSWD: ALL' >/dev/null
  if [ $? -ne 0 ]; then
    sudo mkdir /etc/sudoers.d/ 2>/dev/null && \
    sudo chmod 750 /etc/sudoers.d/
    
    echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/010_$USER-nopasswd >/dev/null 2>&1 && \
    sudo chmod 440 /etc/sudoers.d/010_$USER-nopasswd
  fi
  # ----------
}

git_server_install_routine() {
  # ----------
  # Do some minimal git config setup to make some annoying yellow warning text stop 
  # showing on newer versions of git.

  # When doing "git pull", merge by default instead of rebase.
  git config --global pull.rebase >/dev/null 2>&1 || \
  git config --global pull.rebase false >/dev/null 2>&1

  # When doing "git init", use "master" for the default branch name.
  git config --global init.defaultBranch >/dev/null 2>&1 || \
  git config --global init.defaultBranch master >/dev/null 2>&1
  # ----------

  git pull 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "" && \
    echo "Fetching git-server git repo..." && \
    echo "" && \
    cd ~

    if [ ! -d "git-server" ]; then
      git clone https://gitlab.com/defcronyke/git-server.git 2>/dev/null

      git_server_sudo_setup

      sudo apt-get update && \
      sudo apt-get install -y git && \
      git clone https://gitlab.com/defcronyke/git-server.git 2>/dev/null
      cd git-server
    else
      cd git-server && \
      git pull

      git_server_sudo_setup
    fi
  else
    git_server_sudo_setup
  fi

  ./install-main.sh
}

git_server_install_routine $@
