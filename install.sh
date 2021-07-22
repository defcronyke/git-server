#!/bin/bash

git_server_install_routine() {
  # ----------
  # Allow sudo without password for the current user, for convenience.
  #
  # NOTE: If you don't want this convenience, you can comment out the
  # lines below, and then you'll need to type the sudo password sometimes
  # when maybe it would be better to not have to do that, so things
  # can happen more automatically.
  sudo cat /etc/sudoers.d/*-nopasswd 2>/dev/null | grep 'ALL=(ALL) NOPASSWD: ALL' >/dev/null
  if [ $? -ne 0 ]; then
    sudo mkdir /etc/sudoers.d/ 2>/dev/null && \
    sudo chmod 750 /etc/sudoers.d/
    
    echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/010_$USER-nopasswd >/dev/null 2>&1 && \
    sudo chmod 440 /etc/sudoers.d/010_$USER-nopasswd
  fi
  # ----------

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
      git clone https://gitlab.com/defcronyke/git-server.git 2>/dev/null || \
      sudo apt-get update && \
      sudo apt-get install -y git && \
      git clone https://gitlab.com/defcronyke/git-server.git 2>/dev/null
      cd git-server
    else
      cd git-server && \
      git pull
    fi
  fi

  ./install-main.sh
}

git_server_install_routine; \
exit $?
