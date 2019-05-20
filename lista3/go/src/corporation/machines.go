package corporation

import (
	"math/rand"
	"params"
	"time"
)

// addingMacihne takes two arguments, adds them and then it returns result of adding
// machineID is id of machine
// taskStream is channel for adding new tasks for machine
func addingMachine(machineID int, taskStream <-chan taskForMachine, accept <-chan acceptRequest, repair <-chan struct{}) {
	// flag if machine is broken
	isBroken := false

	rand.Seed(time.Now().UnixNano())

	for {
		select {
		case request := <-accept:
			// give access to worker
			request.response <- struct{}{}

			waitAndDoTask(machineID, taskStream, params.AddingMachineDelay, isBroken)

			r := rand.Float32()
			if r <= params.BreakdownProbability {
				isBroken = true
			}

		case <-repair:
			isBroken = false
		}
	}
}

// multiplyingMachine takes two arguments, multiplyies them then it returns result of multiplying
// machineID is id of machine
// taskStream is channel for adding new tasks for machine
func multiplyingMachine(machineID int, taskStream <-chan taskForMachine, accept <-chan acceptRequest, repair <-chan struct{}) {
	// flag if machine is broken
	isBroken := false

	rand.Seed(time.Now().UnixNano())

	for {
		select {
		case request := <-accept:
			// give access to worker
			request.response <- struct{}{}

			waitAndDoTask(machineID, taskStream, params.MultiplyingMachineDelay, isBroken)

			r := rand.Float32()
			if r <= params.BreakdownProbability {
				isBroken = true
			}

		case <-repair:
			isBroken = false
		}
	}
}

func waitAndDoTask(machineID int, taskStream <-chan taskForMachine, delay time.Duration, isBroken bool) {
	select {
	case task := <-taskStream:
		workerTask := task.taskFromWorker

		time.Sleep(delay)

		if !isBroken {
			val := workerTask.operation(workerTask.firstArg, workerTask.secondArg)
			workerTask.result = val
		}

		task.machineID <- machineID
	case <-time.After(params.MachineWaitingTime):
		break
	}
}

// createAddingMachines creates adding machines
func createAddingMachines() ([]chan taskForMachine, []chan acceptRequest, []chan struct{}) {
	channels := make([]chan taskForMachine, params.NumOfAddingMachines)
	acceptChannels := make([]chan acceptRequest, params.NumOfAddingMachines)
	repairChannels := make([]chan struct{}, params.NumOfAddingMachines)

	for i := 0; i < len(channels); i++ {
		channels[i] = make(chan taskForMachine)
		acceptChannels[i] = make(chan acceptRequest, 1)
		repairChannels[i] = make(chan struct{})
		go addingMachine(i, channels[i], acceptChannels[i], repairChannels[i])
	}

	return channels, acceptChannels, repairChannels
}

// createMultiplyingMachines creates adding machines
func createMultiplyingMachines() ([]chan taskForMachine, []chan acceptRequest, []chan struct{}) {
	channels := make([]chan taskForMachine, params.NumOfMultiplyingMachines)
	acceptChannels := make([]chan acceptRequest, params.NumOfMultiplyingMachines)
	repairChannels := make([]chan struct{}, params.NumOfMultiplyingMachines)

	for i := 0; i < len(channels); i++ {
		channels[i] = make(chan taskForMachine)
		acceptChannels[i] = make(chan acceptRequest, 1)
		repairChannels[i] = make(chan struct{})
		go addingMachine(i, channels[i], acceptChannels[i], repairChannels[i])
	}

	return channels, acceptChannels, repairChannels
}
