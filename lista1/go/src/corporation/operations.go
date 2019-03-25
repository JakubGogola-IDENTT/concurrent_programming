package corporation

// add adds two integer numbers.
// It returns result ot addition.
func add(a int, b int) int {
	return a + b
}

// sub subtracts two integer numbers.
// It returns result of subtraction.
func sub(a int, b int) int {
	return a - b
}

// mult multiplies two integer numbers.
// It return result of multiplication.
func mult(a int, b int) int {
	return a * b
}

// div divides two integer numbers.
// If divider is not 0 it returns result of division, otherwise it returns 0.
func div(a int, b int) int {
	if b != 0 {
		return a / b
	}

	return 0
}
