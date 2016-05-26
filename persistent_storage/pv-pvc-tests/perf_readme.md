Jump to [Results](#performance-results)

## Overview
Here are the results of informal performance testing of various verisons of kubernetes.
Unfortunately the k8s version id was not captured for some of the tests runs.
The tests call a script which creates one or more PVs (presistent volumes) and one or more PVCs (claims).
The script used is [full-test](full-test).

**Note:**
  1. the `LOG_LEVEL` variable needs to be set to 5 or greater in order to capture the number of calls to _syncClaim()_ and
to _syncVolume()_. This is done by the script.
  2. the `CLAIM_BINDER_SYNC_PERIOD` variable needs to be set to _10m_ (current default), or to _30s_, or whatever value is
of interest, and this needs to be exported by the user.

The method used to measure binding performance is simple (maybe too simple?). **full-test** does the following:
+ starts an all-in-one cluster via _hack/local-up-cluster.sh_. This is needed because I was not able to delete k8s log files,
in particular _/tmp/kube-controller-manager.log_, without causing k8s to stop logging to this file all together. The only way
to get a fresh log file was to stop and restart _local-up-cluster_. A fresh log file is needed in order to count occurences
of entering _syncClaim()_ and _syncVolume()_.
+ _full-test_ invokes _pv_test_ to create various combinations of PVs and PVCs. Sometimes the PVs are created first and
other times the claims are created first (which always takes longer).
+ the elapsed time of each _pv-test_ run is recorded.
+ the number of times that _syncClaim()_ and _syncVolume() are called is updated.
+ the total time to run _full-test_ is recorded and displayed.
+ _full_test_ was run against different versions of k8s and with two CLAIM_BINDER_SYNC_PERIOD values
(**10m**, which is the default, and **30s**).

# Performance Results

### k8s master with Jan's controller refactor changes merged
```
Client Version: version.Info{Major:"1", Minor:"3+", GitVersion:"v1.3.0-alpha.4.450+e1dcf2066861a0-dirty", GitCommit:"e1dcf2066861a0d2c7301a798bf66246c164c158", GitTreeState:"dirty", BuildDate:"2016-05-24T22:37:08Z", GoVersion:"go1.6.1", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"3+", GitVersion:"v1.3.0-alpha.4.450+e1dcf2066861a0-dirty", GitCommit:"e1dcf2066861a0d2c7301a798bf66246c164c158", GitTreeState:"dirty", BuildDate:"2016-05-24T22:37:08Z", GoVersion:"go1.6.1", Compiler:"gc", Platform:"linux/amd64"}
```
#### _PVs always created before claims (9 tests):_
| 10m claim sync period | 30s claim sync period |
| --- | --- |
| Errors: 9* | Errors: 7* |
| Elapsed: 211.74s | Elapsed: 188.71s |
| syncVolume calls: 156 | syncVolume calls: 180 |
| syncClaim calls: 37 | syncClaim calls: 47 |

#### _Claims created before PVs ~50% of the time (17 tests):_

| 10m claim sync period | 30s claim sync period |
| --- | --- |
| Errors: 14* | Errors: 12* |
| Elapsed: 5275.15s | Elapsed: 1619.32s |
| syncVolume calls: 296 | syncVolume calls: 696 |
| syncClaim calls: 83 | syncClaim calls: 214 |


### k8s master prior to Jan's controller refactor
(version not recorded, but latest prior to Jan's merge)

#### _PVs always created before claims (9 tests):_
| 10m claim sync period | 30s claim sync period |
| --- | --- |
| Errors: 13* | Errors: 8* |
| Elapsed: 234.19s | Elapsed: 320.12s |
| syncVolume calls: 90 | syncVolume calls: 58 |
| syncClaim calls: 40 | syncClaim calls: 27 |

#### _Claims created before PVs ~50% of the time (17 tests):_

| 10m claim sync period | 30s claim sync period |
| --- | --- |
| Errors: 26* | Errors: 17* |
| Elapsed: 5791.11s | Elapsed: 3509.54s |
| syncVolume calls: 128 | syncVolume calls: 316 |
| syncClaim calls: 87 | syncClaim calls: 324 |

\* the number of errors needs to be taken with a grain of salt since some of the errors are a result of binding races.
Also, the number of errors in the _PV-always-create-first_ tests cannot be compared to the errors in the _Claim-created-first_ tests.
