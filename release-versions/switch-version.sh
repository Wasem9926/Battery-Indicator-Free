#!/bin/bash

#
# Constants
#

NORMAL_DIR='normal-icons-pre-v11'
V11_DIR='black-square-icons-v11'

NORMAL_ARG='normal'
V11_ARG='v11'
SWAP_ARG='swap'

NORMAL_MIN_API='3'
V11_MIN_API='11'

#
# Functions
#

function swap_current {
    pushd $wd >/dev/null

    if [ $current = $NORMAL_DIR ]
    then
        ln -sfn $V11_DIR current
    else
        ln -sfn $NORMAL_DIR current
    fi

    current=`basename \`realpath current\``
    popd >/dev/null
}

function set_cur_to_req {
    pushd $wd >/dev/null

    ln -sfn $req_dir current

    current=`basename \`realpath current\``
    popd >/dev/null
}

function rm_cur {
    cd current

    for f in */*
    do
        rm ../../res/$f
    done

    for d in *
    do
        rmdir --ignore-fail-on-non-empty $d
    done

    cd ..
}

function cp_cur {
    cd current

    for d in *
    do
        mkdir $d 2> /dev/null
    done

    for f in */*
    do
        cp $f ../../res/$f
    done

    cd ..
}

#
# Main entry point
#

# Get working directory

wd=`dirname \`realpath $0\``
cd $wd

# Get current

current=`basename \`realpath current 2> /dev/null\` 2> /dev/null`

if [ $? -ne 0 ]
then
    current='none'
fi

# Get goal from arg 1 or assume goal is to swap

if [ $# -gt 0 ]
then
    if [ $1 = $NORMAL_ARG ]
    then
        req_dir=$NORMAL_DIR
    elif [ $1 = $V11_ARG ]
    then
        req_dir=$V11_DIR
    else
        echo "Error: '$1' not valid; please choose '$NORMAL_ARG' or '$V11_ARG', or leave off to swap."
        exit
    fi
else
    if [ $current = 'none' ]
    then
        echo "Please choose '$NORMAL_ARG' or '$V11_ARG' to set initial version."
        exit
    fi

    req_dir=$SWAP_ARG
fi

# Quit if we're done

if [ $req_dir = $current ]
then
    echo "Already set to $current"
    exit
fi

# Set current; removing old files if necessary

if [ $current = 'none' ]
then
    set_cur_to_req
else
    rm_cur
    swap_current
fi

# Copy files

cp_cur

# Set up manifest

cd $wd/..
manifest="AndroidManifest.xml"

if [ $current = $NORMAL_DIR ]
then
    old_api=$V11_MIN_API
    new_api=$NORMAL_MIN_API
else
    old_api=$NORMAL_MIN_API
    new_api=$V11_MIN_API
fi

old_api_long=`printf "%03d" $old_api`
new_api_long=`printf "%03d" $new_api`

old_vc="versionCode=\\\"$old_api_long"
new_vc="versionCode=\\\"$new_api_long"

old_mv="minSdkVersion=\\\"$old_api\\\""
new_mv="minSdkVersion=\\\"$new_api\\\""

sed -i -e"s/$old_vc/$new_vc/" $manifest
sed -i -e"s/$old_mv/$new_mv/" $manifest