#!/bin/bash

git_server_init_routine() {
	if [ -d "git-server" ]; then
		echo
		echo "This device has already been initialized. To reinstall, enter the following command instead:"
		echo
		echo "  cd git-server; ./install.sh; cd .."
		echo
		
		return 1
	fi

	curl -sL https://gitlab.com/defcronyke/git-server/-/archive/master/git-server-master.tar.gz | tar zxvf - && mv git-server-master git-server && cd git-server && ./install.sh
}

git_server_init_routine

