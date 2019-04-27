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
