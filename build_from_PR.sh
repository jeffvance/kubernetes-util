#!/bin/bash
# This script is intended to be run in Fedoraand is based on a similar script
# written by Steve Watt. Builds a local copy of kubernetes based on the
# supplied pull-request, the PR repo url and the official kube repo url.
# Args:
#   1=pr branch name -- prompted for if absent
#   2=pr branch repo -- prompted for if absent
#   3=official (upstream) kubernetes repo.
#
PR="$1"
PR_REPO="$2"
REPO=${3:-https://github.com/GoogleCloudPlatform/kubernetes}

# prompt for missing args
if [[ -z "$PR" ]]; then
  read -p "Pull-request branch name: " PR
  [[ -z "$PR" ]] && exit
fi

if [[ -z "$PR_REPO" ]]; then
  read -p "Pull-request's repo url: " PR_REPO
  [[ -z "$PR_REPO" ]] && exit
fi

echo
echo "Building PR \"$PR\" from $PR_REPO onto $REPO..."
echo "(Expects the user to have the capability of doing a yum install)"
sleep 3

echo
echo "*** yum install -y go git mercurial..."
yum install -y go git mercurial

export GOPATH=/opt/go/
mkdir -p $GOPATH/src/github.com/GoogleCloudPlatform/
cd $GOPATH/src/github.com/GoogleCloudPlatform/

# clone the upstream kubernetes repo
echo
echo "*** git clone $REPO..."
rm -rf kubernetes
git clone $REPO
cd kubernetes

# add the remote pr repo
echo
echo "*** git remote add prbranch $PR_REPO..."
git remote add prbranch $PR_REPO

# checkout a new branch
echo
echo "*** git checkout -b $PR..."
git checkout -b $PR

echo
echo "*** git pull --rebase prbranch $PR..."
git pull --rebase prbranch $PR

# do the build
echo
echo "*** build..."
go get github.com/tools/godep
export PATH=$PATH:$GOPATH/bin
cd $GOPATH/src/github.com/GoogleCloudPlatform/kubernetes

echo
echo "*** godep restore..."
godep restore

echo
echo "*** make..."
make
