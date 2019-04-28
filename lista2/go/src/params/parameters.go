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

// ImpatientWorkerDelay is delay of impatient worker
const ImpatientWorkerDelay = 2 * time.Second

// ClientDelay is delay of client
const ClientDelay = 15 * time.Second

// NumOfAddingMachines is number of adding machines
const NumOfAddingMachines = 3

// AddingMachineDelay is delay of adding machine
const AddingMachineDelay = 4 * time.Second

// NumOfMultiplyingMachines is number of adding machines
const NumOfMultiplyingMachines = 3

// MultiplyingMachineDelay is delay of multiplying machine
const MultiplyingMachineDelay = 5 * time.Second

// NumOfWorkers is number of currently active workers
const NumOfWorkers = 6

// NumOfClients is number of currently active clients
const NumOfClients = 8

// SizeOfList is size of list with tasks
const SizeOfList = 10

// SizeOfMagazine is size of magazine with products
const SizeOfMagazine = 15

// GetBossDelay returns random delay for president
func GetBossDelay() time.Duration {
	delaySeed := 4
	return time.Duration(rand.Intn(delaySeed)) * time.Second
}

// WorkerType is enum type for worker
type WorkerType string

// Enums for worker
const (
	PATIENT   WorkerType = "patient"
	IMPATIENT WorkerType = "impatient"
)
