package corporation

import (
	"math/rand"
	"params"
	"time"
)

// president is functions which generates new task for workers.
// tasks is channel where tasks are sended.
func president(tasks chan<- task) {
	rand.Seed(time.Now().UnixNano())

	// Map of functions which define operations.
	operationFuncs := [4]func(int, int) int{add, sub, mult, div}

	// Map of operators matching functions which define operations.
	operators := [4]byte{'+', '-', '*', '/'}

	for {
		// Generating parameters
		firstArg := rand.Intn(2137)
		secondArg := rand.Intn(2137)
		operation := rand.Intn(len(operationFuncs))

		newTask := task{firstArg: firstArg, secondArg: secondArg,
			operation: operationFuncs[operation], operator: operators[operation]}

		// Sending new task to channel
		tasks <- newTask

		// Random delay of president
		time.Sleep(params.GetPresidentDelay())
	}
}
