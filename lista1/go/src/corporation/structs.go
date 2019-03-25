package corporation

// task is structure which represents task to do for worker.
// firstArg and secondArg are arguments of operation.
// operation is function which represents binary operand.
type task struct {
	firstArg  int
	secondArg int
	operation func(int, int) int
}

// product is struct which represents product.
// value is value which was computed by worker.
type product struct {
	value int
}
