#!/bin/bash

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

git_server_install_routine
