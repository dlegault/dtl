#!/bin/bash

# This relies on iTerm2, and also having created a color profile in iTerm2 called "Prod"
# When selecting a production kubeconfig (as defined below), it will change the iTerm2 profile to "Prod"
# making it easy to distinguish if you're on production or not!

# funciton to set iterm profile from cli
function it2prof() {
    echo -e "\033]50;SetProfile=$1\a"
}

# function to set kubernetes kubeconfig, kops state store, and change prompt
function setkube() {
   echo "Which kubeconfig do you want?"

   PS3="Select or type 'none' to quit: "

   select filename in ~/.kube/kube*
   do
    if [[ "$REPLY" == none ]]; then break; fi

    if [[ "$filename" == "" ]]
    then
        echo "'$REPLY' is not valid"
        continue
    fi

    echo "kubeconfig set to $filename"
    export KUBECONFIG=$filename

    #SET PROMPT BASED ON KUBECONFIG
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    NC='\033[0m' # No Color
    if [[ $KUBECONFIG == *'kubeconfig.prd2' ]] ; then
        printf "kubeconfig is ${RED}prod2${NC}.\n"
        export KOPS_STATE_STORE=s3://prd2-wayupint-com-state-store
        export PS1="\[\e[0;31m\](⎈ prod) \[\033[00m\]:\W$ "
        it2prof prod
    elif [[ $KUBECONFIG == *'kubeconfig.stg2' ]] ; then
        printf "kubeconfig is ${GREEN}not prod${NC}.\n"
        export KOPS_STATE_STORE=s3://stg2-wayupint-com-state-store
        export PS1="\[\e[1;32m\](⎈ stage2) \[\033[00m\]:\W$ "
        it2prof Default
    elif [[ $KUBECONFIG == *'kubeconfig.local' ]] ; then
        printf "kubeconfig is ${YELLOW}local${NC}.\n"
        export KOPS_STATE_STORE=""
        export PS1="\[\e[1;33m\](⎈ local) \[\033[00m\]:\W$ "
        it2prof Default
    else
        echo "kubeconfig is something elese!!!!!!"
        export KOPS_STATE_STORE=""
        export PS1=":\W$ "
        it2prof Default
    fi

    break
  done

}

export -f setkube
