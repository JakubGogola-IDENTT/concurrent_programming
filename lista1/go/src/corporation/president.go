package corporation

import (
	"fmt"
	"math/rand"
	"params"
	"time"
)

// president is functions which generates new task for workers.
// tasks is channel where tasks are sended.
func president(tasks chan<- task) {
	// Setting random seed using system clock
	rand.Seed(time.Now().UnixNano())

	// Map of functions which define operations.
	operationFuncs := [4]func(int, int) int{add, sub, mult, div}

	// Map of operators matching functions which define operations.
	operators := [4]byte{'+', '-', '*', '/'}

	// Infinite loop of president
	for {
		// Generating parameters
		firstArg := rand.Intn(params.Bound)
		secondArg := rand.Intn(params.Bound)
		operation := rand.Intn(len(operationFuncs))

		// Structure of new task
		newTask := task{firstArg: firstArg, secondArg: secondArg,
			operation: operationFuncs[operation], operator: operators[operation]}

		// Sending new task to channel
		tasks <- newTask

		// Show info about new task is verbose mode is
		if params.IsVerboseModeOn {
			fmt.Printf("\u001b[31mPresident\u001b[0m added new task %d %c %d\n", firstArg, operators[operation],
				secondArg)
		}

		// Random delay of president
		time.Sleep(params.GetPresidentDelay())
	}
}
