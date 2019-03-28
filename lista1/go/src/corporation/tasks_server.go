package corporation

import (
	"fmt"
	"params"
)

// tasksServer handles list of task to do.
// taskRequest is channel where requests from workers for new tasks are sended.
// tasks is channel where boss sends new tasks.
// info is channel where user sends request for information about list of tasks to do.
func tasksServer(taskRequests <-chan taskRequest, tasks <-chan task, info <-chan struct{}) {
	// List of tasks to do.
	tasksToDo := make([]task, 0)

	// Infinite loop of worker.
	for {
		select {
		case request := <-taskRequests:
			// If list of tasks to do is empty send nil.
			if len(tasksToDo) == 0 {
				request.response <- task{}
			} else {
				// Otherwise send first task from list.
				request.response <- tasksToDo[0]
				tasksToDo = tasksToDo[1:]
			}
		case newTask := <-tasks:
			// If boss send new task add it to list of tasks to do.
			if len(tasksToDo) >= params.SizeOfList {
				if params.IsVerboseModeOn {
					fmt.Println("List of tasks is full!")
				}
			} else {
				tasksToDo = append(tasksToDo, newTask)
			}
		case <-info:
			// If user sends request show list of tasks
			if len(tasksToDo) == 0 {
				fmt.Println("List of tasks is empty!")
			} else {
				fmt.Println("Tasks waiting for workers:")
				for i := range tasksToDo {
					fmt.Printf("\u001b[36mTask\u001b[0m %d: %d %c %d\n", i, tasksToDo[i].firstArg, tasksToDo[i].operator,
						tasksToDo[i].secondArg)
				}
			}
		}
	}
}
