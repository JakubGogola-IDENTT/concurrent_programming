package corporation

import (
	"fmt"
	"params"
	"time"
)

// worker represents corporation worker which is used like gorutine
// workerId is id of current worker
// tasks is channel with task to do.
// products is channel where final product is sended.
func worker(workerID int, taskRequests chan<- taskRequest, products chan<- product) {
	// Infinite loop of worker
	for {
		//var taskToDo task

		// Prepare and send new request
		request := taskRequest{response: task{}}
		taskRequests <- request

		// Check response
		taskToDo := request.response
		if taskToDo.operation == nil {
			continue
		}

		// Make new product
		val := taskToDo.operation(taskToDo.firstArg, taskToDo.secondArg)
		newProduct := product{value: val}

		if params.IsVerboseModeOn {
			fmt.Printf("\u001b[32mWorker\u001b[0m %d made product: %d %c %d = %d\n", workerID, taskToDo.firstArg,
				taskToDo.operator, taskToDo.secondArg, val)
		}

		// Send new product to channel
		products <- newProduct

		// Sleep
		time.Sleep(params.WorkerDelay)
	}
}
