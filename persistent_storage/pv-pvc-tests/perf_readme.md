Jump to:
+ [Results](#performance-results)
+ [Archive Results](#archive-results)

## Overview
Here are the results of informal performance testing of various verisons of kubernetes.
Unfortunately the k8s version id was not captured for some of the older tests runs.
The tests call a script which creates one or more PVs (presistent volumes) and one or more PVCs (claims).
The script used is [full-test](full-test).

**Note:**
  (_full-test_ replaces the [previous](old_full-test) script, and is more consistent in capturing the differences between creating PVs before claims versus creating claims before PVs)

  1. the `LOG_LEVEL` variable is set to 5 in order to capture the number of calls to _syncClaim()_ and
to _syncVolume()_. This is hard-coded in the script. 
  2. the user running the test needs to export the `CLAIM_BINDER_SYNC_PERIOD` variable to _10m_ (old default), _30s_, 15s (new default -- see PR #26414), or _10s_ to match the tables below.

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
+ _full_test_ was run against different versions of k8s and with various CLAIM_BINDER_SYNC_PERIOD values.

# Performance Results
(unexpected or poor results are in **bold**)

### "Latest" kubernetes
+ **2016-05-31 v1.3.0-alpha.4.869**
```
Client Version: version.Info{Major:"1", Minor:"3+", GitVersion:"v1.3.0-alpha.4.869+c1c0567e37b699-dirty", GitCommit:"c1c0567e37b6990a2ad4d6662dbaf3e3c5d2fd36", GitTreeState:"dirty", BuildDate:"2016-05-31T23:04:23Z", GoVersion:"go1.6.1", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"3+", GitVersion:"v1.3.0-alpha.4.869+c1c0567e37b699-dirty", GitCommit:"c1c0567e37b6990a2ad4d6662dbaf3e3c5d2fd36", GitTreeState:"dirty", BuildDate:"2016-05-31T23:04:23Z", GoVersion:"go1.6.1", Compiler:"gc", Platform:"linux/amd64"}
```
#### _PVs created before claims_ (14 tests):
| 10m claim sync period | 30s claim sync period | 15s claim sync period | 10s claim sync period |
| --- | --- | --- | --- |
| Errors: 39* | Errors: 12* | Errors: 6* | Errors: 5* |
| Elapsed: 615.02s | Elapsed: 522.71s | Elapsed: 306.87s | Elapsed:  253.10s |
| syncVolume calls: 112 | syncVolume calls: 322 | syncVolume calls: 386 | syncVolume calls: 380 |
| syncClaim calls: 13 | syncClaim calls: 49 | syncClaim calls: 65 | syncClaim calls: 63  |

#### _Claims created before PVs_ (14 tests):
| 10m claim sync period | 30s claim sync period | 15s claim sync period | 10s claim sync period |
| --- | --- | --- | --- |
| Errors: 32* | Errors: 3* | Errors: 7* | Errors: 2* |
| Elapsed: 2690.17s | Elapsed: 682.91s | Elapsed: 422.54s | Elapsed: 412.02s |
| syncVolume calls: 68 | syncVolume calls: 378 | syncVolume calls: 398 | syncVolume calls: 474 |
| syncClaim calls: 1 | syncClaim calls: 60 | syncClaim calls: 66 | syncClaim calls: 95 |


+ **2016-05-26 v1.3.0-alpha.4.581**
```
Client Version: version.Info{Major:"1", Minor:"3+", GitVersion:"v1.3.0-alpha.4.581+cd700ee3eb58e8-dirty", GitCommit:"cd700ee3eb58e8cef9f098a8c75746a30f0c6961", GitTreeState:"dirty", BuildDate:"2016-05-27T06:55:19Z", GoVersion:"go1.6.1", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"3+", GitVersion:"v1.3.0-alpha.4.581+cd700ee3eb58e8-dirty", GitCommit:"cd700ee3eb58e8cef9f098a8c75746a30f0c6961", GitTreeState:"dirty", BuildDate:"2016-05-27T06:55:19Z", GoVersion:"go1.6.1", Compiler:"gc", Platform:"linux/amd64"}
```
#### _PVs created before claims_ (14 tests):
| 10m claim sync period | 30s claim sync period | 10s claim sync period |
| --- | --- | --- |
| Errors: 32* | Errors: 11* | Errors: 6* |
| Elapsed: **613.10**s | Elapsed: 452.94s | Elapsed: 269.81s |
| syncVolume calls: 68 | syncVolume calls: 332 | syncVolume calls: 400 |
| syncClaim calls: 12 | syncClaim calls: 88 | syncClaim calls: 108 |

#### _Claims created before PVs_ (14 tests):
| 10m claim sync period | 30s claim sync period | 10s claim sync period |
| --- | --- | --- |
| Errors: 31* | Errors: 6* | Errors: 3* |
| Elapsed: 2891.32s | Elapsed: 713.32s | Elapsed: 402.14s |
| syncVolume calls: 80 | syncVolume calls: 388 | syncVolume calls: 500 |
| syncClaim calls: 16 | syncClaim calls: 102 | syncClaim calls: 136 |


+ **2016-05-20 v1.3.0-alpha.4.450**
```
Client Version: version.Info{Major:"1", Minor:"3+", GitVersion:"v1.3.0-alpha.4.450+e1dcf2066861a0-dirty", GitCommit:"e1dcf2066861a0d2c7301a798bf66246c164c158", GitTreeState:"dirty", BuildDate:"2016-05-24T22:37:08Z", GoVersion:"go1.6.1", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"3+", GitVersion:"v1.3.0-alpha.4.450+e1dcf2066861a0-dirty", GitCommit:"e1dcf2066861a0d2c7301a798bf66246c164c158", GitTreeState:"dirty", BuildDate:"2016-05-24T22:37:08Z", GoVersion:"go1.6.1", Compiler:"gc", Platform:"linux/amd64"}
```

#### _PVs created before claims_ (14 tests):
| 10m claim sync period | 30s claim sync period | 10s claim sync period |
| --- | --- | --- |
| Errors: 16* | Errors: 16* | Errors: 14* |
| Elapsed: 306.66s | Elapsed: **344.73**s | Elapsed: 276.38s |
| syncVolume calls: 212 | syncVolume calls: 336 | syncVolume calls: 436 |
| syncClaim calls: 55 | syncClaim calls: 91 | syncClaim calls: 124 |

#### _Claims created before PVs_ (14 tests):
| 10m claim sync period | 30s claim sync period | 10s claim sync period |
| --- | --- | --- |
| Errors: 34* | Errors: 13* | Errors: 11* |
| Elapsed: **2910.15**s | Elapsed: **1366.03**s | Elapsed: **1005.4**s |
| syncVolume calls: 116 | syncVolume calls: 552 | syncVolume calls: **1000** |
| syncClaim calls: 25 | syncClaim calls: 162 | syncClaim calls: 302 |


## Archive Results
(using [`old-full-test`](old-full-test) instead of [`full-test`](full-test))

### k8s master with Jan's controller refactor changes merged

+ Version: **1.3.0-alpha.4.450**
```
Client Version: version.Info{Major:"1", Minor:"3+", GitVersion:"v1.3.0-alpha.4.450+e1dcf2066861a0-dirty", GitCommit:"e1dcf2066861a0d2c7301a798bf66246c164c158", GitTreeState:"dirty", BuildDate:"2016-05-24T22:37:08Z", GoVersion:"go1.6.1", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"3+", GitVersion:"v1.3.0-alpha.4.450+e1dcf2066861a0-dirty", GitCommit:"e1dcf2066861a0d2c7301a798bf66246c164c158", GitTreeState:"dirty", BuildDate:"2016-05-24T22:37:08Z", GoVersion:"go1.6.1", Compiler:"gc", Platform:"linux/amd64"}
```

#### _PVs always created before claims_ (9 tests):
| 10m claim sync period | 30s claim sync period |
| --- | --- |
| Errors: 9* | Errors: 7* |
| Elapsed: 211.74s | Elapsed: 188.71s |
| syncVolume calls: 156 | syncVolume calls: 180 |
| syncClaim calls: 37 | syncClaim calls: 47 |

#### _Claims created before PVs ~50% of the time_ (17 tests):

| 10m claim sync period | 30s claim sync period |
| --- | --- |
| Errors: 14* | Errors: 12* |
| Elapsed: 5275.15s | Elapsed: 1619.32s |
| syncVolume calls: 296 | syncVolume calls: 696 |
| syncClaim calls: 83 | syncClaim calls: 214 |


### k8s master prior to Jan's controller refactor

+ (version not recorded, but latest prior to Jan's merge)

#### _PVs always created before claims_ (9 tests):

| 10m claim sync period | 30s claim sync period |
| --- | --- |
| Errors: 13* | Errors: 8* |
| Elapsed: 234.19s | Elapsed: 320.12s |
| syncVolume calls: 90 | syncVolume calls: 58 |
| syncClaim calls: 40 | syncClaim calls: 27 |

#### _Claims created before PVs ~50% of the time_ (17 tests):

| 10m claim sync period | 30s claim sync period |
| --- | --- |
| Errors: 26* | Errors: 17* |
| Elapsed: 5791.11s | Elapsed: 3509.54s |
| syncVolume calls: 128 | syncVolume calls: 316 |
| syncClaim calls: 87 | syncClaim calls: 324 |

\* the number of errors needs to be taken with a grain of salt since some of the errors are a result of binding races.
Also, the number of errors in the _PV-create-first_ tests cannot be compared to the errors in the _Claim-created-first_ tests.
