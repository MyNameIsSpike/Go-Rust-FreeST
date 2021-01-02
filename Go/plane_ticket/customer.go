/**
* Authors: Jorge Martins && Diogo Lopes
*/
package main

import(
	"fmt"
	"sync"
	"math/rand"
	"time"
)

type address struct {
	country string
	city string
	street string
}

func CustomerOrder(maxPrice float64, journeyPref string, addr address, c chan Message, wg *sync.WaitGroup){
	fmt.Println("Starting the customer!")
	defer wg.Done()//Notify wait group when func is over

	go AgencySell(c)//start agency

	var price float64 //agency offer

	for {
		c <- JourneyPreference{journeyPreference: journeyPref}
		received := (<- c)
		switch received.(type) {
			case JourneyPrice:
				price = received.(JourneyPrice).journeyPrice
			default:
				fmt.Println("Error in message type")			
		}
		fmt.Printf("PriceOffer: %.2f\n", price)
		if evalOffer(journeyPref, price) {
			break;
		}
	}

	if price <= maxPrice {
		c <- CustomerDecision{decision: ACCEPT}
		c <- CustomerAddress{customerAddress: addr}
		received := (<- c)
		switch received.(type) {
			case JourneyDate:
				bookedDate := received.(JourneyDate).journeyDate
				fmt.Printf("Flight date: %s, %d/%s/%d\n", bookedDate.Weekday().String(), bookedDate.Day(), bookedDate.Month().String(), bookedDate.Year())
			default:
				fmt.Println("Error in message type")			
		}
	} else { 
		c <- CustomerDecision{decision: REJECT}
	}
	fmt.Println("Closing the customer!")
}

////Utility functions
func evalOffer(journeyPref string, price float64) bool{
	//here we need to be carefull because the random source is not safe in concurrent goroutines
	//It will panic in runtime if 2 goroutines try and access it simultaneously
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	return r.Float32() < 0.5
}