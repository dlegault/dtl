# aliases
alias sshvpn='ssh -i ~/.ssh/prod-master-key.pem openvpn.wayupint.com -lopenvpnas'
alias clearhostcache='sudo dscacheutil -flushcache'
alias pyserve="workon pycharm; cd /Users/dtl/PycharmProjects/TCJ/TCJ; python manage.py runserver 0.0.0.0:8000"
alias gruntserve="cd /Users/dtl/PycharmProjects/TCJ/TCJ/frontend-dev; grunt serve"
alias ktl="kubectl"
alias ecrlogin='$(aws ecr get-login --no-include-email --region us-east-1)'
alias s="spotify"
alias weather="curl wttr.in/NewYork?u"
alias awslogin='$(aws ecr get-login --no-include-email --region us-east-1)'
alias testhelm='helm lint . -f values-production.yaml --set deploying.gitSha=fake-sha'
alias helmtemp='helm template -f values-production.yaml --set deploying.gitSha=fake-sha'
alias sshbk='ssh wayup@104.209.189.118 -i ~/.ssh/prod-master-key.pem'
alias sshbk01='ssh ubuntu@bk01.wayupint.com -i ~/.ssh/prod-master-key.pem'

# Set env
export DOCKER_REGISTRY=588548118012.dkr.ecr.us-east-1.amazonaws.com
export VAULT_ADDR=https://vault.wayup.com

set -o vi

## "gl" shortcut for a graphical representation of git log
gl() {
  if [[ -n "$1" ]]; then
    git log --oneline --graph --decorate "$1"
  else
    git log --oneline --graph --decorate --all
  fi
}


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

function checkTag() {
  if [[ -n "$1" ]]; then
     for i in `ktl get po -n $1 |awk '{print $1}'`; do  echo "Image for pod: $i"; kubectl describe pod $i -n $1 |grep "Image: " |grep tcj |grep -v NAME; echo ""; done
  else
     echo "Usage: checkTag <staging || production>"
  fi
}

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# Update vault keys by passing in JSON objects
# usage: vault_update_key secret/tcj/staging '{"SECRET_TOKEN": "ABCDEFG", "ANOTHER": "KEY"}'
vault_update_key () {
    local key=$1
    shift 1

    echo "$(vault read -format=json "$key" | jq '.data') $@" | jq -s add | vault write "$key" -
}

# Usage: vault_delete_key secret/tcj/staging SECRET_TOKEN
vault_delete_key () {
    local path=$1
    vault read -format=json "$path" | jq -r ".data | del(.$2)" | vault write "$path" -
}
