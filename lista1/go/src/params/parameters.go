package params

import (
	"math/rand"
	"time"
)

// IsVerboseModeOn is flag which indicates whether the verbose mode is on.
var IsVerboseModeOn = true

// Bound for random arguments
const Bound = 2137

// WorkerDelay is delay of single worker
const WorkerDelay = 2 * time.Second

// ClientDelay is delay of client
const ClientDelay = 8 * time.Second

// NumOfWorkers is number of currently active workers
const NumOfWorkers = 4

// NumOfClients is number of currently active clients
const NumOfClients = 2

// SizeOfList is size of list with tasks
const SizeOfList = 10

// SizeOfMagazine is size of magazine with products
const SizeOfMagazine = 5

// GetBossDelay returns random delay for president
func GetBossDelay() time.Duration {
	delaySeed := 5
	return time.Duration(rand.Intn(delaySeed)) * time.Second
}
