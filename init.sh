#!/bin/bash

if [ -d "git-server" ]; then
	echo
	echo "This device has already been initialized. To reinstall, enter the following command instead:"
	echo
	echo "  cd git-server; ./install.sh; cd .."
	echo
fi

curl -sL https://gitlab.com/defcronyke/git-server/-/archive/master/git-server-master.tar.gz | tar zxvf - && mv git-server-master git-server && cd git-server && ./install.sh

