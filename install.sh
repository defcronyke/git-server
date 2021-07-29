#!/usr/bin/env bash

git_server_install_routine() {
  # Set up sudo for non-interactive operation.
  # ./install-sudo-setup.sh $@
  # install_sudo_res=$?

  # if [ $install_sudo_res -ne 0 ] && [ $install_sudo_res -ne 19 ] &&

  # ./install-sudo-setup.sh $@ || \
  #   return $?

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

  git pull origin master 2>/dev/null
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
      cd git-server || \
      cd git-server-master
      # git_server_sudo_setup
    else
      cd git-server && \
      git pull origin master

      # git_server_sudo_setup
    fi
  # else
    # git_server_sudo_setup
  fi

  ./install-main.sh $@
}

git_server_install_routine $@
