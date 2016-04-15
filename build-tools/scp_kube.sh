#!/bin/bash
# scp the (presumable new) kube* files to the supplied nodes. Expected that
# the k8 processes have been stopped and will be restarted after the script
# completes.
# $@= list of nodes to scp kube* files to

nodes="$@"

# newly created kube* binaries dir
DIR='/opt/go/src/github.com/GoogleCloudPlatform/kubernetes/_output/local/bin/linux/amd64'
# existing kube* binaries dir
OLD='/usr/bin'

[[ -z "$nodes" ]] && {
  echo "No k8 nodes specified so simply coping new kube* files to $OLD";
  nodes='localhost'; }

echo
echo "Copy new kube* files from \"$DIR\" to \"$OLD\" on nodes: $nodes"
echo "(Enter node password if prompted [avoided with passwordless-ssh])"
echo
echo "The k8 processes, eg kube-apiserver, kubelet, etc. should be stopped..."
echo "Restart the k8 processes after this script completes."
echo
sleep 3

# begin scp process per node...
for node in $nodes; do
   echo
   echo "  on node $node..."
   ssh $node "
       if stat -t $OLD/kube* >& /dev/null ; then # files exist
         mkdir -p /tmp/kube
         mv $OLD/kube* /tmp/kube
         (( $? != 0 )) && {
           echo \"$node: ERROR moving existing $OLD/kube* files to /tmp/kube/\";
           exit 1; }
       fi
   "
   scp $DIR/kube* $node:/$OLD/
   (( $? != 0 )) && {
     echo "$node: ERROR copying new $DIR/kube* files to $OLD/";
     exit 1; }
done
echo
echo "Don't forget to restart the k8 processes on each node"
