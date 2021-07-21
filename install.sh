#!/bin/bash

git pull
if [ $? -ne 0 ]; then
  echo "" && \
  echo "Fetching git-server git repo..." && \
  echo "" && \
  cd ~

  if [ ! -d "git-server" ]; then
    git clone https://gitlab.com/defcronyke/git-server.git || \
    sudo apt-get update && \
    sudo apt-get install -y git && \
    git clone https://gitlab.com/defcronyke/git-server.git
    cd git-server
  else
    cd git-server
    git pull
  fi
fi

./install-main.sh
