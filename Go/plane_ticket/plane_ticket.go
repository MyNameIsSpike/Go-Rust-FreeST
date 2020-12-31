package main

import(
	"fmt"
	"sync"
	"math/rand"
	"time"
)

//Message to be traded by the channels
//I believe it is more efficient than a channel for each type
//Also its more readable than creating a message interface
type message struct {
	journeyPreference string
	journeyDate time.Time
	journeyPrice float64
	customerAddress address
	decision string
}

type address struct {
	country string
	city string
	street string
}


var agencyPriceCatalog = map[string]float64 {
	"Rome": 289.65,
	"Paris": 167.75,
	"Lisbon": 196.46,
	"London":  155.97,
	"New York": 456.67,
	"Kyoto": 516.00,
}

func main() {
	
	///some mock values
	var maxPrice float64 = 1000.00
	var addr address = address{country: "Portugal", city: "Lisbon", street: "Confidencial"}
	var journeyPref = "Rome"

	//channel that will be used by the goroutines
	c := make(chan message)

	var wg sync.WaitGroup //we need a group because otherwise the main func will end without ensuring everything is done

	wg.Add(1)
	go customer(maxPrice, journeyPref, addr, c, &wg) //start goroutine

	wg.Wait()

}


////Utility functions
func evalOffer(journeyPref string, price float64) bool{
	return rand.Float32() < 0.5
}


////GOROUTINES
func customer(maxPrice float64, journeyPref string, addr address, c chan message, wg *sync.WaitGroup){
	
	defer wg.Done()//Notify wait group when func is over
	
	go agency(c)//start agency

	loop := true // to end the loop
	var price float64 //agency offer

	for loop {
		c <- message{journeyPreference: journeyPref}
		price = (<- c).journeyPrice
		fmt.Printf("PriceOffer: %.2f\n", price)
		loop = evalOffer(journeyPref, price)
	}

	if price <= maxPrice {
		c <- message{decision: "ACCEPT"}
		c <- message{customerAddress: addr}
		bookedDate := (<- c).journeyDate
		fmt.Println(bookedDate)
	} else { 
		c <- message{} //customer address fields will be ""
	}
	fmt.Println("Closing the customer!")
}

func agency(c chan message){

	var received message
	for true {
		//Receiving the wanted journey and informing the price
		received := <-c
		if received.journeyPreference == ""{
			//Once we dont receive a string its because the customer ended the transaction
			break;
		}
		fmt.Printf("JourneyPref: %s\n", received.journeyPreference)
		price := agencyPriceCatalog[received.journeyPreference]
		c <- message{journeyPrice: price}
	}

	fmt.Println(received.decision)
	if received.decision == "ACCEPT" {
		go service(c)
	}

	fmt.Println("Closing the agency!")
}

func service(c chan message) {
	addr := (<-c).customerAddress //receive address (to store I guess)
	fmt.Printf("Customer Address:\n Country: %s, City: %s, Street: %s\n", addr.country, addr.city, addr.street)
	now := time.Now()
	offset := rand.Int()
	date := now.AddDate(0,0,offset)
	c <- message{journeyDate: date}
	fmt.Println("Closing the service!")
}