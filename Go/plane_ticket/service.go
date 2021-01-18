/**
* Authors: Jorge Martins && Diogo Lopes
* This example is from Vasconcelos, V.T. (and several others):
* "Behavioral Types in Programming Languages" (figures 2.4, 2.5 and 2.6)
*/
package main

import(
	"fmt"
	"math/rand"
	"time"
)

func ServiceOrderDelivery(c chan Message){
	fmt.Println("Starting the service!")
	received := <-c //receive address (to store I guess)
	switch received.(type) {
		case CustomerAddress:
			addr := received.(CustomerAddress).customerAddress
			fmt.Printf("Customer Address: Country-> %s, City-> %s, Street-> %s\n", addr.country, addr.city, addr.street)
		default:
			fmt.Println("Error in message type")			
	}

	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	day := r.Intn(30)+1
	month := r.Intn(12)+1
	flightDate := time.Date(2021,time.Month(month),day,0,0,0,0,time.UTC)
	c <- JourneyDate{journeyDate: flightDate}
	fmt.Println("Closing the service!")
}