# kubernetes-util
Utility tools/scripts to make it easier to use kubernetes.

*build_from_PR.sh*
###Usage:
*./build_from_PR.sh pv_panic_fix \
      https://github.com/markturansky/kubernetes.git*

This script builds a version of kubernetes by merging the PR into the upstream master branch. All args are optional, but typically the first two args should be supplied. If no args are provided the script will prompt for the first two.

The newly merged kubernetes git repo is located here: /opt/go/src/github.com/GoogleCloudPlatform/kubernetes/.

The new kubernetes binaries will be found in /opt/go/src/github.com/GoogleCloudPlatform/kubernetes/_output/local/bin/linux/amd64.

###Arguments:
* pull-request branch name (prompted for if not provided)
* pull-request branch repo url (prompted for if not provided)
* the official kubernetes upstream repo url (default is https://github.com/GoogleCloudPlatform/kubernetes).

##Issues/Questions:
* is my git "workflow" reasonable, or acceptably good? I am not a git expert by any means.
* I'd likle to be able to create kubernetes merging in several PRs. Suggestions?

*scp_kube.sh*
###Usage###
*./scp_kube.sh k-mstr.vm k-min1.vm k-min2.vm*

This script copies the kubernetes binaries from the location they are built in the above script to /usr/bin in the supplied kubernetes nodes. There is no distinction made between a kube master vs. kube minion node.

###Arguments:
* a list of kubernetes hosts where the kube binaries will be copied to.
