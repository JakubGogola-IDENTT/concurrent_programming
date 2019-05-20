package corporation

// reapirService sends tasks for repairers
func reapirService(reports <-chan breakdownReport, repairs <-chan repairRequest, confirm <-chan repairConfirmation) {
	machinesToRepair := make([]breakdownReport, 0)
	machinesInRepair := make([]breakdownReport, 0)

	for {
		select {
		case r := <-reports:
			if !contains(r.machineID, r.machineType, machinesToRepair) && !contains(r.machineID, r.machineType, machinesInRepair) {
				machinesToRepair = append(machinesToRepair, r)
			}
		case r := <-repairs:
			// if there are broken machines send task for repairer
			if len(machinesToRepair) != 0 {
				machine := machinesToRepair[0]
				response := repairTask{machine.machineID, machine.machineType}

				r.response <- response
				machinesToRepair = machinesToRepair[1:]
				machinesInRepair = append(machinesInRepair, machine)

			} else {
				response := repairTask{-1, '/'}
				r.response <- response
			}
		case c := <-confirm:
			for i, m := range machinesInRepair {
				if m.machineID == c.machineID && m.machineType == c.machineType {
					machinesInRepair = append(machinesInRepair[:i], machinesInRepair[i+1:]...)
				}
			}
		}
	}
}

func contains(machineID int, machineType byte, arr []breakdownReport) bool {
	for _, item := range arr {
		if item.machineID == machineID && item.machineType == machineType {
			return true
		}
	}

	return false
}
