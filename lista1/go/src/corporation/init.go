package corporation

import (
	"fmt"
	"params"
)

// Init starts simulation
func Init() {
	fmt.Println("########################################")
	fmt.Println("### Welcome in corporation simulator ###")
	fmt.Println("########################################")

	//Channel for new tasks from president.
	presidentNewTasksChannel := make(chan task)

	// Channels for worker
	workerTaskRequestsChannel := make(chan taskRequest)
	workerNewProductsChannel := make(chan product)

	// Channel for client
	clientPurchaseChannel := make(chan buyRequest)

	// Info channels
	tasksServerInfoChannel := make(chan struct{})
	magazineServerInfoChannel := make(chan struct{})

	// Start servers for tasks list and stored products list.
	go tasksServer(workerTaskRequestsChannel, presidentNewTasksChannel, tasksServerInfoChannel)
	go magazineServer(workerNewProductsChannel, clientPurchaseChannel, magazineServerInfoChannel)

	// Start president.
	go president(presidentNewTasksChannel)

	// Start workers
	for i := 0; i < params.NumOfWorkers; i++ {
		go worker(i, workerTaskRequestsChannel, workerNewProductsChannel)
	}

	// Start clients
	for i := 0; i < params.NumOfClients; i++ {
		go client(i, clientPurchaseChannel)
	}

	if params.IsVerboseModeOn {
		// Wait for user action (for key pressed)
		fmt.Scanln()
		fmt.Println("########################################")
		fmt.Println("##### Simulations has been stopped #####")
		fmt.Println("########################################")
	}
}
