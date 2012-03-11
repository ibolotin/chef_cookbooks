#!/bin/bash -x

# Usage: ./deploy.sh
#
# It infers the target for the deploy by the files under deploy_target_dir (see below).
# For each host you want to deploy to, put a file in there. Eg, for deploying to "alpha", put alpha.json in.
#
# ls ./deploy_targets
# => alpha.json
# ./deploy.sh
# => (deploys to alpha using alpha.json)

host="${1:-ubuntu@172.16.8.174}"

# The host key might change when we instantiate a new VM, so
# we remove (-R) the old host key from known_hosts
#ssh-keygen -R "${host#*@}" 2> /dev/null

gnutar cj . | ssh -i /Users/ibolotin/sandbox-igor.pem -o 'StrictHostKeyChecking no' "$host" 'sudo rm -rf ~/chef && mkdir ~/chef && cd ~/chef && tar xj  && sudo bash install.sh'

