/**
* Authors: Jorge Martins && Diogo Lopes
* This example is from Vasconcelos, V.T. (and several others):
* "Behavioral Types in Programming Languages" (figures 2.4, 2.5 and 2.6)
*/
package main

import(
	"fmt"
)

func AgencySell(c chan Message){

	//Mock catalog
	var agencyPriceCatalog = map[string]float64 {
		"Rome": 289.65,
		"Paris": 167.75,
		"Lisbon": 196.46,
		"London":  155.97,
		"New York": 456.67,
		"Kyoto": 516.00,
	}

	fmt.Println("Starting the agency!")
	var received Message
	MainLoop:
		for {
			//Receiving the wanted journey and informing the price
			received = <-c
			switch received.(type) {
				case CustomerDecision:
					break MainLoop
				case JourneyPreference:
					pref := received.(JourneyPreference).journeyPreference
					fmt.Printf("JourneyPref: %s\n", pref)
					c <- JourneyPrice{journeyPrice: agencyPriceCatalog[pref]}
				default:
					fmt.Println("Error in message type")			
			}
		}

	cDecision := received.(CustomerDecision).decision
	fmt.Println("Decision: " + cDecision)
	if cDecision == "ACCEPT" {
		go ServiceOrderDelivery(c)
	}
	//If the client rejected the transaction ends so no need for the else clause
	fmt.Println("Closing the agency!")
}