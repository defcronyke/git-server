#!/bin/bash

git_server_init_routine() {
  cd ~

	if [ -d "git-server" ]; then
		echo
		echo "This device has already been initialized. (Re-)Installing..."
		echo
		echo "  cd git-server; ./install.sh; cd .."
		echo

    cd git-server && \
    ./install.sh

    return $?
	fi

	curl -sL https://gitlab.com/defcronyke/git-server/-/archive/master/git-server-master.tar.gz | tar zxvf - && cd git-server-master && ./install.sh
}

git_server_init_routine
