https://enterprise-support.nvidia.com/s/article/Using-mlxconfig-to-Query-SPLIT-PORT-Settings-on-Quantum-2-Switches-with-MFT-4-34-1-10

Problem Description

After upgrading to MFT 4.34.1-10, querying the split-port configuration using the legacy parameter fails:

#mlxconfig -d /dev/mst/SW_MT54002_Quantum-2_Mellanox_Technologies_lid-0x0003 q SPLIT_PORT

Observed Error:

-E- Failed to find Param / TLV with name 'SPLIT_PORT' port 0 module -1

Observed Behavior

    Querying all parameters succeeds: 

#mlxconfig -d /dev/mst/<device> -e q

    The expanded output still displays split-port information: 

SPLIT_PORT Array[1..64]

                                                                 Split-Port and Related Configuration (Quantum-2)
 

 

    Querying other individual parameters works as expected.

    Only direct query using SPLIT_PORT fail. 

Reverting the MFT package to version 4.33.0 restores the ability to query SPLIT_PORT directly.

Root Cause

Starting with MFT 4.34.1-10, the previously used SPLIT_PORT parameter is no longer supported for direct query.

The generic SPLIT_PORT TLV has been replaced with port-range–specific TLVs, which is why queries using SPLIT_PORT are no longer found.

This is not an expected change in MFT behavior.

TLV Changes in MFT 4.34.1-10

In MFT 4.34.1-10, split-port configuration is exposed using the following TLVs:

    SPLIT_PORT_32_1

    SPLIT_PORT_64_33

    SPLIT_PORT_96_65 

Each TLV represents a fixed port range and supports querying individual ports or ranges using zero-based indexing.

Correct Query Method (MFT 4.34.1-10)

For a 64-port Quantum-2 switch, use the following supported syntax.
Ports 1–32

    Query split configuration for ports 1–32 

#mlxconfig -d /dev/mst/<device> q SPLIT_PORT_32_1

    Query a specific port (zero-based index) 

#mlxconfig -d /dev/mst/<device> q SPLIT_PORT_32_1[X]

    Query a range of ports 

#mlxconfig -d /dev/mst/<device> q SPLIT_PORT_32_1[X..Y]
Ports 33–64

    Query split configuration for ports 33–64 

#mlxconfig -d /dev/mst/<device> q SPLIT_PORT_64_33

    Query a specific port (zero-based index) 

#mlxconfig -d /dev/mst/<device> q SPLIT_PORT_64_33[X]

    Query a range of ports 

#mlxconfig -d /dev/mst/<device> q SPLIT_PORT_64_33[X..Y]


Validation

This query syntax has been validated on an x86-64 Ubuntu host connected to a Quantum-2 switch using MFT 4.34.1-10 LTS and is working as expected.
