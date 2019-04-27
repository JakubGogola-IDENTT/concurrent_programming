package corporation

import (
	"fmt"
	"math/rand"
	"params"
	"time"
)

// worker represents corporation worker which is used like gorutine
// workerId is id of current worker
// tasks is channel with task to do.
// products is channel where final product is sended.
func worker(workerID int, taskRequests chan<- taskRequest, products chan<- product, ouputChannels machineChannels, info <-chan struct{}) {
	// Worker type
	var workerType params.WorkerType
	var workerMode func(*task, int, []chan taskForMachine) int

	// Get a worker type
	// Could be patient (waits until machine finish task) or impatien (changes machine when waits to long)
	rand.Seed(time.Now().UnixNano())
	r := rand.Intn(2)

	if r == 0 {
		workerType = params.PATIENT
		workerMode = patientMode
	} else {
		workerType = params.IMPATIENT
		workerMode = impatientMode
	}

	// Number of done tasks
	tasksDone := 0

	// Infinite loop of worker
	for {
		select {
		case <-info:
			fmt.Printf("\u001b[32mWorker\u001b[0m %d which is %s has already done %d tasks\n", workerID, workerType, tasksDone)
		default:
		}

		// Prepare and send new request
		request := taskRequest{response: make(chan task)}
		taskRequests <- request

		// Check response
		taskToDo := <-request.response
		if taskToDo.operation == nil {
			continue
		}

		var val int
		switch taskToDo.operator {
		case '+':
			val = workerMode(&taskToDo, workerID, ouputChannels.addingMachineChannels)
		case '*':
			val = workerMode(&taskToDo, workerID, ouputChannels.multiplyingMachineChannels)
		}

		// Make new product
		newProduct := product{value: val}

		// Send new product to channel
		products <- newProduct

		// Increment of done tasks
		tasksDone++

		// Sleep
		time.Sleep(params.WorkerDelay)
	}
}

// impatientMode simulates impatient worker which changes machine after period of time
// taskToDo is task from worker
// workerID is id of worker
// machines is array of machine's input channels
func impatientMode(taskToDo *task, workerID int, machines []chan taskForMachine) int {
	// Loop for all available machines
	for _, machine := range machines {

		// Channel for machin response
		machineIDResponse := make(chan int)
		machine <- taskForMachine{taskToDo, machineIDResponse}

		for {
			select {
			case machineID := <-machineIDResponse:
				if params.IsVerboseModeOn {
					fmt.Printf("\u001b[32mWorker\u001b[0m %d which is impatient made product: %d %c %d = %d using machine %d\n", workerID, taskToDo.firstArg,
						taskToDo.operator, taskToDo.secondArg, taskToDo.result, machineID)
				}
				return taskToDo.result
			case <-time.After(params.ImpatientWorkerDelay):
				// After delay time go to the next machine
				break
			}
		}
	}

	return -1
}

// patientMode simulates patient worker which waits for result
// taskToDo is task from worker
// workerID is id of worker
// machines is array of machine's input channels
func patientMode(taskToDo *task, workerID int, machines []chan taskForMachine) int {
	// Get random machine to do task
	r := rand.Intn(len(machines))
	// Channel for machin response
	machineIDResponse := make(chan int)
	machines[r] <- taskForMachine{taskToDo, machineIDResponse}

	for {
		select {
		case machineID := <-machineIDResponse:
			if params.IsVerboseModeOn {
				fmt.Printf("\u001b[32mWorker\u001b[0m %d which is patient made product: %d %c %d = %d using machine %d\n", workerID, taskToDo.firstArg,
					taskToDo.operator, taskToDo.secondArg, taskToDo.result, machineID)
			}
			return taskToDo.result
		}
	}
}
