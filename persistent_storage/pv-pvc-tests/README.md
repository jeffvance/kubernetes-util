# PV/PVC (with pre-binding) Tests
These scripts test PV/PVC creation and pre-binding.  

###full-test
[full-test driver](full-test)

This bash script runs many combinations of creating PVs first, or PVCs first, and tests binding. The tests happen to use the NFS plugin but the point is to test PV binding.  PV pre-binding is defined as the pv spec containing a `claimRef`. PVC pre-binding is defined as the pvc spec containing `volumeName`.

Binding is much slower when claims are created before PVs and thus there is the `-x` option which skips all tests that create claims first. `-x` is the only argument and the default is to not skip any tests.

`full-test` logs to _/tmp/pv-test.log_

####Example
_./full-test_

###pv-test
[core pv-test](pv-test)

This bash script does the actual pv/pvc testing. The NFS plugin is referenced but the point is to test PV/PVC binding. `pv-test` is called multiple times by the `full-test` script. The log filename and the location of the various pv/pvc yaml files are hard-coded in the script, but easy to change.

####Arguments
* **-c**, if supplied causes PVCs to be created before PVs. PV binding is **considerably** slower when PVCs are created first. The default is to create the PVs before the PVCs. If _-c_ is used it must appear before the lists below.
* list of 1 or more yaml PV spec files, separated by a comma. The yaml extension is omitted from the filenames. Each PV name must match its filename. PVs always appear before PVCs, indpendent of the _-c_ option.
* list of 1 or more yaml PVC spec files, separated by a comma. The yaml extension is omitted from the filenames. Each PVC name must match its filename. PVCs always appear after PVs.

####Example
_./pv-test nfs-pv1,nfs-pv3, nfs-claim3,nfs-claim2_

### various nfs pv/pvc yaml files
Only two of the spec files define pre-binding:

* _nfs-pv3_ uses `claimRef` to pre-bind to _nfs_claim3_
* _nfs-claim2_ defines `volumeName` to pre-bind to _nfs-pv2_.
