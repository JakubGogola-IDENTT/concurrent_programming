package corporation

import (
	"flag"
	"fmt"
	"params"
)

// parseFlags parses command-line flags
func parseFlags() {
	mode := flag.Bool("i", false, "deactivates verbose mode and activates interactive mode")

	flag.Parse()

	if *mode {
		params.IsVerboseModeOn = false
	}
}

// printCommands prints avaiable commands in interactive mode
func printCommands() {
	fmt.Println("Usage (avaiable commands):")
	fmt.Println("m - print list of products stored in magazine")
	fmt.Println("t - print list of tasks to do")
}

// Init starts simulation
func Init() {
	parseFlags()

	fmt.Println("\u001b[33m########################################")
	fmt.Println("### \u001b[1mWelcome in corporation simulator\u001b[0m\u001b[33m ###")
	fmt.Println("########################################\u001b[0m")
	fmt.Print("\n(Press any key to stop simlation)\n\n")

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
		fmt.Println("\u001b[33m########################################")
		fmt.Println("##### Simulations has been stopped #####")
		fmt.Println("########################################\u001b[0m")
	} else {
		var cmd string
		printCommands()

		for {
			fmt.Scanln(&cmd)
			switch cmd {
			case "m":
				magazineServerInfoChannel <- struct{}{}
			case "t":
				tasksServerInfoChannel <- struct{}{}
			case "h":
				printCommands()
			default:
				fmt.Println("Invalid command")
				fmt.Println("Type 'h' to see avaiable commands")
			}
		}

	}
}
