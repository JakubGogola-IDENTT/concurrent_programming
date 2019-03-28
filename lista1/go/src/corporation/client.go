package corporation

import (
	"fmt"
	"params"
	"time"
)

// client is functions which handles client's requests for buying new products.
// clientID is id of current client.
// purchase is channel where offers of buying products are sent.
func client(clientID int, purchase chan<- buyRequest) {
	// Infinite loop of client
	for {
		// Prepare new request of buying product
		request := buyRequest{response: product{}}
		purchase <- request

		response := request.response

		if response == (product{}) {
			continue
		}

		if params.IsVerboseModeOn {
			fmt.Printf("\u001b[34mClient\u001b[0m %d bought product with value %d\n", clientID, response.value)
		}

		time.Sleep(params.ClientDelay)
	}
}
