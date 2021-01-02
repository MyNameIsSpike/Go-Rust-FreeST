/**
* Authors: Jorge Martins && Diogo Lopes
*/
package main

import(
	"sync"
)

func main() {
	
	///some mock values
	var maxPrice float64 = 1000.00
	var addr address = address{country: "Portugal", city: "Lisbon", street: "Rua Augusta"}
	var journeyPref = "Rome"

	//channel that will be used by the goroutines
	c := make(chan Message)

	var wg sync.WaitGroup //we need a group because otherwise the main func will end without ensuring everything is done
	
	wg.Add(1)
	go CustomerOrder(maxPrice, journeyPref, addr, c, &wg) //start goroutine
	wg.Wait()

}
