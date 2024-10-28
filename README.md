# ION-Core for Linux (and WSL) & MacOS

- [ION-Core for Linux (and WSL) \& MacOS](#ion-core-for-linux-and-wsl--macos)
  - [Preliminary Notes](#preliminary-notes)
  - [Build \& Install](#build--install)
    - [Alternative: Automated download of ION Open Source Code _without commit history_](#alternative-automated-download-of-ion-open-source-code-without-commit-history)
  - [Selecting ION-core Features to Build](#selecting-ion-core-features-to-build)
    - [Extension Blocks Build Options](#extension-blocks-build-options)
  - [Man Page Installation](#man-page-installation)
  - [Creating ION configuration (".rc") files for a two-node setup](#creating-ion-configuration-rc-files-for-a-two-node-setup)
  - [Post-installation Test](#post-installation-test)
  - [Clean up process](#clean-up-process)
  - [Automated Script to Build, Install, and Test Ion-core on Two Hosts](#automated-script-to-build-install-and-test-ion-core-on-two-hosts)
  - [Adjusting Pre-Allocation of Memory/Storage Space for ION](#adjusting-pre-allocation-of-memorystorage-space-for-ion)
  - [Tuning LTP Performance](#tuning-ltp-performance)
  - [Building static and dynamic library](#building-static-and-dynamic-library)
  - [Prototype: macOS Build](#prototype-macos-build)
  - [Contributing Code](#contributing-code)
  - [WSL2 Networking Issue](#wsl2-networking-issue)
  - [Release Notes](#release-notes)
      - [Tag: `4.1.3`](#tag-413)
      - [Tag: `4.1.2b`](#tag-412b)
      - [Tag: `4.1.2a`](#tag-412a)
      - [Tag: `4.1.2`](#tag-412)

## Preliminary Notes

Ion-core assumes the typical Linux OS installation location for `make` and `gcc`. 

Each ion-core version is designed to work with the corresponding version of ION Open Source release, e.g., ion-core 4.1.2 uses the ION open-source release version 4.1.2 as its sources.

Ion-core creates absolute path symbolic links to source files from the ION-DTN repo specified by the user. If you move the ION-DTN repo or the ion-core repo, you will need to update the symbolic links by re-running the `extract.sh` script and point to the new location.

As part of the build process, the extract script will modify two ION source files (`bpsec_policy_rule.c`,`bpextension.c`) and place copies inside the `src` folder in ion-core. The original source files in the ION open source repo will not be modified. The modifications are very minor and only to the extend needed to allow ion-core build to turn-on/off selected extension blocks; they do not alter the behavior of extension block handling.

## Build & Install

Be sure you have the tools installed:
```bash
sudo apt update
sudo apt install make gcc
```

Clone the ION open source code repo:
```bash
cd <ion-source-codee-folder>
git clone https://github.com/nasa-jpl/ION-DTN.git
```

Get ion-core and build:
```bash
git clone https://github.com/nasa-jpl/ion-core.git
cd ion-core
git checkout tags/4.1.3
# clean out previous build
make clean
sudo make uninstall
# build
./scripts/extract.sh <your-ion-source-code-folder>/ion-dtn
make
sudo make install
sudo ldconfig
```

### Alternative: Automated download of ION Open Source Code _without commit history_

You can run `./scripts/extract.sh` without supplying the path to an existing ION source code repo. In that case, the script will automatically download the appropriate ION open source code version the `tmp` folder under the ion-core directory.

Then you can run `make` and `sudo make install` to install the code.

The disadvantage of this approach is that you will not have the commit history of the ION open source code and not able to submit pull requests. This is provided as a convenience for conducting quick testing.

## Selecting ION-core Features to Build

You can select the features you want to include in ion-core build by updating the `build-list.mk` file. See the `build-list.mk` file for the list of features.

At least one CLA must be selected. All necessary programs/daemons associated with a feature or a CLA are listed on one line, so when commenting/uncommenting features, please do so at the "line level", not the individual program.

You can select build for either 32-bit or 64-bit Operating Systems.

You can also select which bundle protocol extension blocks to include for locally sourced bundles.

Save the changes to the `build-list.mk`, remove the old installation by running `make clean`, `sudo make uninstall`, and then rebuild ion-core.

### Extension Blocks Build Options

As of ion-core 4.1.3, the `build-list.mk` file enables toggling which extension blocks will be added to locally created bundle. Here are some of the limitations:

1. Support for all extension blocks types, however, remains mandatory:
    * `PBN_EXT` : Previous Node Extension Block
    * `BPQ_EXT` : Bundle Protocol QoS Extension Block
    * `BAE_EXT` : Bundle Age Extension Block
    * `SNW_EXT` : Spray and Wait Permit Extension Block
    * `IMC_EXT` : IMC Multicast Extension Block
2. There is not yet control available, through `build-list.mk` to set whether each locally created extension block should use CRC16, CRC32, or none applied. The default value is `noCRC` in the `./scripts/bpextension-ion-core.c`.
3. The file `./scripts/bpextension-ion-core.c` is manually derived from the ION open-source; it is modified to support the toggling of which extension blocks to include in locally created bundle.
4. __This is the only ION source file modified by ion-core release. This modification is manually performed by the ion-core development team right now. This file is re-evaluated for each ion-core release to make sure it is taylored for the most likely use case for users. The user of ion-core can further modify it to suite their deployment/testing needs.__

## Man Page Installation

Run:

`sudo make man`

## Creating ION configuration (".rc") files for a two-node setup

`./scripts/host.sh <IP-this-host> <IP-the-other-host>`

For example:

`./scripts/host.sh 192.168.254.192 192.168.254.194`

Makes the config file `host192.rc` and places it inside the folder `host192_testdir`. You can run lauch ION by cd into the directory `cd host192_testdir` and run `ionstart -I host192.rc`.

For the other host, run the same command with the order of IP addresses reversed.

The default protocol stack is BP/LTP but you can select the UDP or STCP CLAs if they are included in the `build-list.mk`.

To generate configuration files using either UDP or the STCP CLA, add either `udp` or `stcp` as the third argument to `host.sh`. For example,  to generate configuration using STCP, run 

`./scripts/host.sh 192.168.254.192 192.168.254.194` stcp

Similar syntax goes for udp.

To use other convergence layers such as UDP or STCP, you will need to modify the .rc files. See the ION documentation for more information. For example, you may consult the [ION Configuration Tutorials and Configuration Templates.](https://nasa-jpl.github.io/ION-DTN/Basic-Configuration-File-Tutorial/)

## Post-installation Test

After installation, you can run the following command to test the installation for each of the CLAs included in the build:

```bash
make test
```

The result of the test will be captured in a file called `progress` under the `tests` directory.

## Clean up process

To remove executables and libraries installed in the host, run: `sudo make clean`
To clean up the compilation artifacts, run: `make clean`
To remove all complication artifacts, as well as all ION source and test files extracted from the ION open source code, run: `make distclean`

## Automated Script to Build, Install, and Test Ion-core on Two Hosts

To streamline the process, we have created two bash scripts that can automate the build, installation, and testing of ion-core.

To build and install ion-core, run:

`./scripts/build-install.sh`

To run a bping test between two nodes. On host A, run
`./scripts/bping-send.sh <IP Address of Host A> <IP Address of the Host B> <opt: udp or stcp>`

On host B, run

`./scripts/bping-echo.sh <IP Address of Host B> <IP Address of the Host A> <opt: udp or stcp>`

Note:
* This script will automatically create the ION configuration files needed and launch a `bping` test using BP and LTP CLA.
* To ensure that all bping messages will be received by the peer DTN node, it is recommended that you run bping-echo on the second host first, and then run bping-send on the first host.
* Both `bping-send.sh` and `bping-echo.sh` takes an optional 3rd argument to specify either the `udp` or `stcp` CLAs. But they must be the same on both hosts to ensure compatibility.

On `bping` side, you will see ION starting and then bping launched automatically with output similar to the following:

```bash
... Wait 10 seconds for the other side to start ION...

run bping...
64 bytes from ipn:12.2  seq=0 time=0.003641 s
64 bytes from ipn:12.2  seq=1 time=0.001756 s
64 bytes from ipn:12.2  seq=2 time=0.001767 s
64 bytes from ipn:12.2  seq=3 time=0.001590 s
64 bytes from ipn:12.2  seq=4 time=0.001676 s
64 bytes from ipn:12.2  seq=5 time=0.001711 s
64 bytes from ipn:12.2  seq=6 time=0.001766 s
64 bytes from ipn:12.2  seq=7 time=0.001742 s
64 bytes from ipn:12.2  seq=8 time=0.001675 s
64 bytes from ipn:12.2  seq=9 time=0.001663 s
10 bundles transmitted, 10 bundles received, 0.00% bundle loss, time 19.003910 s
rtt min/avg/max/sdev = 1.590/1.898/3.641/0.585 ms

bping SUCCESS!
```

On the receiving (echo) side, you will likely see:

```bash
Start bpecho...., Ctrl-C to stop.
..........
```
Each `.` indicates that an 'echo' message has been sent back to acknowledge the reception of a 'bping' messages.

The test will end once the bping recieved echos for all ping messages.

At this point, ION will be running on both hosts and you may continue to run different applications until you stop ION by executing the `ionstop` script, which is globally installed for execution.

This test also generates two directories that you can use as template for future ION testing:

* `hostxx_testdir` - this directory contains the ION configuration files for host A, whose IP address ends in `xx`.
* `hostyy_testdir` - this directory contains the ION configuration files for host A, whose IP address ends in `yy`.

Within in each folder, you will find the ION log file `ion.log` which records the main events during previous runs and also, if present, current/on-going running instance of ION.

To launch ION manually, you will need to enter into the directory and execute the command `ionstart -I hostxx.rc`

Using the generated ION configuration folder, you can only launch one ION instance per host. To ability to run multiple ION instances in one host is utilized in automated regression testing (recall `make test`) and is a advanced topic described in the [ION online documentation](https://nasa-jpl.github.io/ION-DTN/).

## Adjusting Pre-Allocation of Memory/Storage Space for ION

ION is designed to run within a pre-allocated memory space. If, while running ION, you encounter errors due to a lack of working memory or SDR heap space, you can increase the pre-allocated allocation by modifying the `host.ionconfig` file and then regenerate configuration files using the `./scripts/host.sh` command. The current default ION SDR and working memory allocation is as follows:

```
configFlags 1
heapWords 15000000
sdrWmSize 15000000
wmSize 15000000
```

The `configFlags` value of 1 creates a Simple Data Recorder (SDR) instance in DRAM. The SDR provides the primary data storage for ION. The 'heap' space, where user data are buffered, is set to 15 mega words, each word is 64 bits (or 8 bytes) for a 64-bit platform. The `sdrWmSize` specifies the SDR's internal working memory space measured in bytes; the `wmSize` specifies the general ION working memory in bytes.

These values can be adjusted to control how much storage ION is allowed to consume in the host system. The proper setting requires some insight into the host system's capabilities, the traffic load ION is expected to handle as impacted by locally generated DTN traffic, and the average and peak inbound and outbound data rates of the network.

Pleaser consult the `ionconfig` manual page for a detailed explanation of the full set of configuration parameters.

## Tuning LTP Performance

Actual throughput of LTP link protocol depends significantly on the underlying radio communication or wired network speed and reliability, the host system's processing speed, the frequency of communication contact, the size of the bundles being sent, the round trip delay between the two hosts, and also on the LTP configuration. Check the `ltprc` manual page entry for details on how to adjust LTP settings to maximize throughput.

In the ION source code's root directory, there is an Excel file named `ION-LTP-configuration_tool.xlsm` which can be used to generate recommended LTP settings for your configuration to maximize the throughput of your system.

## Building static and dynamic library

To build and install static linking library for ION, execute the following command:

```bash
# build the static library
make static

# build the dynamic library
make shared

# install the libraries
sudo make install-lib

# uninstall the libraries
sudo make uninstall-lib
```

## Prototype: macOS Build

The process for building ion-core on macOS follows the same steps as the Linux build process. However, there are some differences that need to be addressed:

1. The `ldconfig` command is not available on macOS, and not necessary.
2. Although ion-core can be build on macOS as it is, exerpimentation showed that several default kernel parameters that control shared memory and UDP datagram sizes should be modified in order to support basic ION operations and UDP traffic. Without these modification, ION will not function properly or at all due to resource limitations.
3. __Minimum Recommended Setting:__ Under the `scripts/macOS` directory, there is a `sysctl_script.sh` script that checks whether these parameters meet or exceed certain minimum, recommended values, as follows:

    ```bash
    kern.sysv.shmmax = 83886080
    kern.sysv.shmseg = 32
    kern.sysv.shmall = 32768
    net.inet.udp.maxdgram = 32000
    ```

This set of minimum values are sufficient to pass the regression tests under the `tests` folder in the ION Open Source repository.

4. While the minimum recommended values can support basic ION operations, they are not sufficient to support the more intenstive bench tests under the `demos` folder in the ION Open Source repository. Therefore a more generous configuration is as follows:
  
    ```bash
    kern.sysv.shmmax=2147483648
    kern.sysv.shmseg=32  
    kern.sysv.shmall=1048576 
    net.inet.udp.maxdgram=655360 
    ``` 
5. This higher recommended setting, for your convenience, can be implemented using the `install_macos_sysctl.sh` script so that it will persist through shutdown and reboot. After executing this script, make sure you reboot the system for the changes to take effect.
  * Note: the `net.inet.udp.maxdgram` value is set to 655360 (640KB), 10 times larger than the maximum UDP datagram 65535 (64KB). For reasons not clear at this point, setting this much larger value actually enables smoother handling of UDP datagrams pass them through `localhost`.
6. In the end, we recommend you experiment and adjust these kernel parameters to fit the specific needs of your application. These scripts provide the basic template on what paramters to check and adjust and how to implement them.






## Contributing Code

Please see the file `developer_notes.txt` for more information.

## WSL2 Networking Issue

WLS2 is known to have issues with VPN connection. One approach is to downgrade to WSL1:

In Windows Powershell get your name/version:

`wsl -l -v`

Set it to version 1:

`wsl --set-version Ubuntu-22.04 1`

Alternative approach is to use the WSL Vpnkit to provide VPN connection:

https://github.com/sakai135/wsl-vpnkit



--------------------------

## Release Notes

Latest Release

#### Tag: `4.1.3`

9/24/2024
* Update codebase to ION open source verion 4.1.3
* Add regression test for each available CLA
* Add target to build static and shared libraries

#### Tag: `4.1.2b`

Added ability to select/exclude certain features from build

#### Tag: `4.1.2a`

2/01/2024
* Added STCP CLA to ver 4.1.2

#### Tag: `4.1.2`

11/30/2023
* Based on ION Open Source 4.1.2
* Initial public release of ion-core (prototype)
* Basic features:
  * BPv7
  * CGR
  * LTP
  * UDPCL
  * IPN Nameing Scheme
  * Load-n-Go Command


