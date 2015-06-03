# kubernetes-util
utility tools/scripts to make it easier to use kubernetes

**build_from_PR.sh**
###Usage:
 ./build_from_PR.sh pv_panic_fix \
      https://github.com/markturansky/kubernetes.git

This script builds a version of kubernetes based on merging the PR into the upstream master branch. All args are optional, but typically the first two args should be supplied.

Usage:

Arguments:
* pull-request branch name (default is pv_panic_fix), 
* pull-request branch repo url (default is https://github.com/markturansky/kubernetes.git), 
* the official kubernetes upstream repo url (default is https://github.com/GoogleCloudPlatform/kubernetes).

##Issues/Questions:
* is my git "workflow" reasonable, or acceptably good? I am not a git expert by any means.
* I'd likle to be able to create kubernetes merging in several PRs. Suggestions?

**scp_kube.sh**: copies kubernetes binaries from the location they are built in the above script to /usr/bin in the supplied kubernetes nodes. There is no distinction made between a kube master vs. kube minion node.
