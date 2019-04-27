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
const WorkerDelay = 5 * time.Second

// ClientDelay is delay of client
const ClientDelay = 15 * time.Second

// NumOfWorkers is number of currently active workers
const NumOfWorkers = 3

// NumOfClients is number of currently active clients
const NumOfClients = 5

// SizeOfList is size of list with tasks
const SizeOfList = 8

// SizeOfMagazine is size of magazine with products
const SizeOfMagazine = 10

// GetBossDelay returns random delay for president
func GetBossDelay() time.Duration {
	delaySeed := 4
	return time.Duration(rand.Intn(delaySeed)) * time.Second
}
