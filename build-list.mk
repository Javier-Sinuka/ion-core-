SHELL := /usr/bin/env bash
#
# Build list for ION-core 4.1.3
#
BUILD_LIST_INCLUDED = YES

################## 
# Architecture & OS
##################

# Set OS-specific and HW flags

# linux 64 bits (tested)
OS_FLAGS := -Dlinux -DSPACE_ORDER=3 -fno-strict-aliasing

# linux 32 bits
#OS_FLAGS := -Dlinux -DSPACE_ORDER=2 -fno-strict-aliasing

# mac 64 bits
#OS_FLAGS := -Dunix -Ddarwin -DSPACE_ORDER=3 -m64 

# mac 32 bits
#OS_FLAGS := -Dunix -Ddarwin -DSPACE_ORDER=3 -m64

# freebsd 64 bits
#OS_FLAGS := -Dfreebsd -DSPACE_ORDER=3 -m64

# freebsd 32 bits
#OS_FLAGS := -Dfreebsd -DSPACE_ORDER=2 -m32

##################
# FLAGS for Extension for Locally Sourced Bundles
#
# PBN_EXT : Previous Node Extension Block
# BPQ_EXT : Bundle Protocol QoS Extension Block
# BAE_EXT : Bundle Age Extension Block
# SNW_EXT : Spray and Wait Permit Extension Block
# IMC_EXT : IMC Multicast Extension Block

#EXT_FLAGS = -DPNB_EXT 
EXT_FLAGS += -DBPQ_EXT 
#EXT_FLAGS += -DBAE_EXT 
#EXT_FLAGS += -DSNW_EXT 
EXT_FLAGS += -DIMC_EXT

##################

##################
# PART I: Mandatory Functions (do not edit)
#

## ICI
PROGRAMS := ionadmin ionwarn rfxclock ionrestart 

## BPv7
PROGRAMS += bpadmin bpclm bpclock bptransit ipnadmin ipnadminep ipnfw

## Utility Programs
PROGRAMS += bpsink bpsource bpecho bping bpstats bptrace 

##################

##################
# PART II: Optional Feature List
#
# This list can be modified. At least one CLA must be included.

## ICI utilities
PROGRAMS += psmwatch sdrwatch 

## BPv7 utilities
PROGRAMS += bpversion 

## Load-and-Go Command
PROGRAMS += lgagent lgsend

## CLA: must include at least one of STCP, UDP, or LTP
### STCP CLA
PROGRAMS += stcpcli stcpclo 

### UDP CLA
PROGRAMS += udpcli udpclo 

### LTP CLA
PROGRAMS += ltpcli ltpclo udplsi udplso ltpclock ltpdeliv ltpmeter ltpadmin

## CFDP Class 1
PROGRAMS += bputa cfdpclock cfdptest cfdpadmin 

# Utility Programs
PROGRAMS += bprecvfile bpsendfile 
PROGRAMS += bpchat 
PROGRAMS += bpcounter bpdriver
PROGRAMS += bplist bpcancel
PROGRAMS += owltsim
# To Do: add bpcp feature for 4.1.3s
# PROGRAMS += bpcp bpcpd

#
# PART III: PLATFORM & BP Extension
#
# Work-in-progress

#
# PART IV: Testing Mapping
#
# Specify test list on build-list options
# Left side of ":" is a list of programs, joined by '+'
# Right side of ":" is a list of tests to execute, joined by '+'
# Each test on the right side should appear only once.
# TO DO: add bench-udp once it is improved for 4.1.4.
COMBINATION_TESTS := \
	cfdpadmin+ltpcli+owltsim:bench-cfdp/ \
	stcpcli:bench-stcp/ \
	ltpcli:bench-ltp/ \
  bptrace+bpsink+ltpcli:bptrace_terminal_test/ \
  bping+bpecho+udpcli:bping/
