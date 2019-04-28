package corporation

import (
	"params"
	"time"
)

// addingMacihne takes two arguments, adds them and then it returns result of adding
// machineID is id of machine
// taskStream is channel for adding new tasks for machine
func addingMachine(machineID int, taskStream <-chan taskForMachine) {
	for {
		// Holder for task from stream
		task := <-taskStream
		// Holder for worker's task
		workerTask := task.taskFromWorker
		time.Sleep(params.AddingMachineDelay)

		val := workerTask.operation(workerTask.firstArg, workerTask.secondArg)
		workerTask.result = val

		// Send machine id as response when task is done
		task.machineID <- machineID
	}
}

// multiplyingMachine takes two arguments, multiplyies them then it returns result of multiplying
// machineID is id of machine
// taskStream is channel for adding new tasks for machine
func multiplyingMachine(machineID int, taskStream <-chan taskForMachine) {
	for {
		// Holder for task from stream
		task := <-taskStream

		// Holder for worker's task
		workerTask := task.taskFromWorker

		time.Sleep(params.MultiplyingMachineDelay)

		// Send machine id as response when task is done
		task.machineID <- machineID

		val := workerTask.operation(workerTask.firstArg, workerTask.secondArg)
		workerTask.result = val
	}
}

// createAddingMachines creates adding machines
func createAddingMachines() []chan taskForMachine {
	channels := make([]chan taskForMachine, params.NumOfAddingMachines)

	for i := 0; i < len(channels); i++ {
		channels[i] = make(chan taskForMachine)
		go addingMachine(i, channels[i])
	}

	return channels
}

// createMultiplyingMachines creates adding machines
func createMultiplyingMachines() []chan taskForMachine {
	channels := make([]chan taskForMachine, params.NumOfMultiplyingMachines)

	for i := 0; i < len(channels); i++ {
		channels[i] = make(chan taskForMachine)
		go multiplyingMachine(i, channels[i])
	}

	return channels
}
