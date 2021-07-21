#!/bin/bash

git_server_init_routine() {
	if [ -d "git-server" ]; then
		echo
		echo "This device has already been initialized. (Re-)Installing..."
		echo
		echo "  cd git-server; ./install.sh; cd .."
		echo

    current_dir="$PWD"
    cd git-server 2>/dev/null

    ./install.sh

    res=$?

    cd "$current_dir"
		
		return $res
	fi

	curl -sL https://gitlab.com/defcronyke/git-server/-/archive/master/git-server-master.tar.gz | tar zxvf - && mv git-server-master git-server && cd git-server && ./install.sh
}

git_server_init_routine
