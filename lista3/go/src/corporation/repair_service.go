package corporation

// reapirService sends tasks for repairers
func reapirService(reports <-chan breakdownReport, repairs <-chan repairRequest) {
	machinesToRepair := make([]breakdownReport, 0)
	for {
		select {
		case r := <-reports:
			if !contains(r, machinesToRepair) {
				machinesToRepair = append(machinesToRepair, r)
			}
		case r := <-repairs:
			// if there are broken machines send task for repairer
			if len(machinesToRepair) != 0 {
				machine := machinesToRepair[0]
				response := repairTask{machine.machineID, machine.machineType}

				r.response <- response
				machinesToRepair = machinesToRepair[1:]
			} else {
				response := repairTask{-1, '/'}
				r.response <- response
			}
		}
	}
}

func contains(report breakdownReport, arr []breakdownReport) bool {
	for _, item := range arr {
		if item.machineID == report.machineID && item.machineType == report.machineType {
			return true
		}
	}

	return false
}
