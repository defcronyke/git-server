#!/bin/bash

curl -sL https://gitlab.com/defcronyke/git-server/-/archive/master/git-server-master.tar.gz | tar zxvf - && mv git-server-master git-server && cd git-server && ./install.sh

