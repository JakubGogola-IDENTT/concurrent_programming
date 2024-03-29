package corporation

import (
	"fmt"
	"params"
)

// magazineServer handles storing products in magazine. Clients can buy products from magazine.
// manufacturedProducts is channel where new products are sent.
// purchases is channel where request for buying products are sent.
// info is channel where user can send request for info of list of stored products in magazine.
func magazineServer(manufacturedProducts <-chan product, purchases <-chan buyRequest, info <-chan struct{}) {
	// List of stored products.
	storedProducts := make([]product, 0)

	// Infinite loop for magazine server.
	for {
		select {
		case newProduct := <-manufacturedProducts:
			if len(storedProducts) >= params.SizeOfMagazine {
				if params.IsVerboseModeOn {
					fmt.Println("Magazine is full!")
				}
			} else {
				storedProducts = append(storedProducts, newProduct)
			}

		case purchase := <-purchases:
			if len(storedProducts) == 0 {
				purchase.response <- product{}
			} else {
				purchase.response <- storedProducts[0]
				storedProducts = storedProducts[1:]
			}
		case <-info:
			if len(storedProducts) == 0 {
				fmt.Println("List of products is empty!")
			} else {
				fmt.Println("Stored products: ")
				for i := range storedProducts {
					fmt.Printf("\u001b[35mProduct\u001b[0m %d with value %d\n", i, storedProducts[i].value)
				}
			}
		}
	}
}
