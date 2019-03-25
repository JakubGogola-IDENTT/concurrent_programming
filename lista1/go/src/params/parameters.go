package params

import (
	"math/rand"
	"time"
)

// IsVerboseModeOn is flag which indicates whether the verbose mode is on.
var IsVerboseModeOn = true

// Bound for random arguments
var Bound = 2137

// WorkerDelay is delay of single worker
var WorkerDelay = 3 * time.Second

// GetPresidentDelay returns random delay for president
func GetPresidentDelay() time.Duration {
	delaySeed := 5
	return time.Duration(rand.Intn(delaySeed)) * time.Second
}
