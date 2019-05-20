package corporation

// task is structure which represents task to do for worker.
// firstArg and secondArg are arguments of operation.
// operation is function which represents binary operand.
type task struct {
	firstArg  int
	secondArg int
	operation func(int, int) int
	operator  byte
	result    int
}

// taskForMachine is wrapper for worker's task with channel for machine response
// taskFromWorker is pointer for task from worker
// machineResponse is chanel for machine response - if machine is avaiable it is struct{}, otherwise - nil
type taskForMachine struct {
	taskFromWorker *task
	machineID      chan int
}

// product is struct which represents product.
// value is value which was computed by worker.
type product struct {
	value int
}

// taskRequest is helper structure for getting task from tasks list
type taskRequest struct {
	response chan task
}

// clientRequest is helper structure for buiyng product from magazine
type buyRequest struct {
	response chan product
}

// acceptReqest is helper structure for checking if machine is busy
type acceptRequest struct {
	response chan struct{}
	isAlive  chan struct{}
}

// breakdownReport is struct for worker to send info about machine breakdown
type breakdownReport struct {
	machineID   int
	machineType byte
}

// repairConfirmation is confirmation of repair
type repairConfirmation struct {
	machineID   int
	machineType byte
}

type repairTask struct {
	machineID   int
	machineType byte
}

// repairRequest is repairer's request for repair
type repairRequest struct {
	response chan repairTask
}

// machineChannels is struct with arrays containing I/O channels for multiplying and adding machines
// addMachineChannels is array with channels for adding machines
// multiplyMchineChannels is array with channels for multilpying machines
type machineChannels struct {
	addMachineChannels      []chan taskForMachine
	addAcceptChannels       []chan acceptRequest
	addRepairChannels       []chan struct{}
	multiplyMachineChannels []chan taskForMachine
	multiplyAcceptChannels  []chan acceptRequest
	multiplyRepairChannels  []chan struct{}
}
