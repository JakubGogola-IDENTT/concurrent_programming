package corporation

import (
	"fmt"
	"params"
	"time"
)

// repairer reapirs machines (really intelligent description)
func repiarer(repairerID int, reapir chan<- repairRequest, addRepairChannels []chan struct{}, multiplyRepairChannels []chan struct{}) {
	for {
		// send request for repair
		responseChannel := make(chan repairTask)
		request := repairRequest{responseChannel}
		reapir <- request

		// wait for resposnse from repair service
		response := <-responseChannel

		if response.machineID != -1 {
			time.Sleep(params.RepairerDelay)

			if response.machineType == '+' {
				addRepairChannels[response.machineID] <- struct{}{}
			} else {
				multiplyRepairChannels[response.machineID] <- struct{}{}
			}

			if params.IsVerboseModeOn {
				fmt.Printf("\u001b[35mRepairer\u001b[0m %d repaired %c machine with id %d\n", repairerID, response.machineType, response.machineID)
			}

		} else {
			continue
		}

	}
}
