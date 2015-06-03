#!/bin/bash
# This script is intended to be run in Fedora.
# Run this script when someone has submitted a PR you need but their branch is
# out of date compared to trunk. Modify the repo and branch below to reflect
# the desired defaults.
# Args:
#   1=pr branch name
#   2=pr branch repo
#   3=official (upstream) kubernetes repo.
#
export PR=${1:-pv_panic_fix}
export PR_REPO=${2:-https://github.com/markturansky/kubernetes.git}
export REPO=${3:-https://github.com/GoogleCloudPlatform/kubernetes}

echo
echo "Building PR \"$PR\" from $PR_REPO onto $REPO..."
echo
sleep 3

# Build Setup
echo
echo "*** yum install -y go git mercurial..."
yum install -y go git mercurial

export GOPATH=/opt/go/
mkdir -p $GOPATH/src/github.com/GoogleCloudPlatform/
cd $GOPATH/src/github.com/GoogleCloudPlatform/

# Clone the Official Upstream Kubernetes Repo
echo
echo "*** git clone $REPO..."
rm -rf kubernetes
git clone $REPO
cd kubernetes

# Add the remote pr repo
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

# Build !
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
