package corporation

// task is structure which represents task to do for worker.
// firstArg and secondArg are arguments of operation.
// operation is function which represents binary operand.
type task struct {
	firstArg  int
	secondArg int
	operation func(int, int) int
	operator  byte
}

// taskForMachine is wrapper for worker's task with channel for machine response
// taskFromWorker is pointer for task from worker
// machineResponse is chanel for machine response - if machine is avaiable it is struct{}, otherwise - nil
type taskForMachine struct {
	taskFromWorker  *task
	machineResponse chan struct{}
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
