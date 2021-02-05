
// Copyright 2016, VMware, Inc. All Rights Reserved

//
// VMware vRealize Orchestrator action sample
// Reboots a vSphere VM and waits for the guest OS to be
// back on the network
//
// Requires VMtools to be functional in the guest OS.
//

//Action Inputs:
// vm                        - VC:VirtualMachine
// guestRebootTimeoutMinutes - number
//
//Return type: void

vm.rebootGuest();

System.log("Rebooting vm '" + vm.name + "'");
System.log("Waiting for upto " + guestRebootTimeoutMinutes + " minutes for VMtools to stop...");

var now = new Date();
var endTime = new Date(now.getTime() + guestRebootTimeoutMinutes * 60 * 1000);

var timedOut = false;
System.log("VM = '" + vm.name + "', Tools Status = '" + vm.guest.toolsStatus.value + "'");

if (vm.guest.toolsStatus.value === VcVirtualMachineToolsStatus._toolsNotInstalled) {
    throw("VM tools is not installed on guest of VM: "+vm.name+".  Will not beable to determine the reboot status of the guest");
}


// wait until the vm is offline
while (true) {
    now = new Date();
    if (now > endTime) {
        timedOut = true;
        break;
    }
    System.log("_toolsNotRunning: "+"toolsNotRunning")
    System.log("vmTools: "+vm.guest.toolsStatus.value)
    if (vm.guest.toolsStatus.value == "toolsNotRunning") {
        System.log("VM = '" + vm.name + "', Tools Status = '" + vm.guest.toolsStatus.value + "'");
        break;
    }
    // check every 5 seconds
    System.sleep(5000);
}

// wait until the vm is back up
while (true) {
    now = new Date();
    if (now > endTime) {
        timedOut = true;
        break;
    }
    System.log("toolsOk: "+"toolsOk")
    System.log("vmTools: "+vm.guest.toolsStatus.value)
    if (vm.guest.toolsStatus.value == "toolsOk") {
        System.log("VM = '" + vm.name + "', Tools Status = '" + vm.guest.toolsStatus.value + "'");
        break;
    }
    // check every 5 seconds
    System.sleep(5000);
}

if (timedOut) {
    errorCode = "Timed out! Host '" + vm.name + "' is still not running after " + guestRebootTimeoutMinutes + " minutes!";
    throw errorCode;
}

//wait until vm is back online
System.getModule("com.vmware.library.vc.vm.tools").vim3WaitForPrincipalIP(vm, guestRebootTimeoutMinutes, 5);
