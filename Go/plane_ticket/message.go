/**
* Authors: Jorge Martins && Diogo Lopes
*/
package main

import(
	"time"
) 

//MESSAGE TO BE TRADED IN THE CHANNELS
//empty interface is implemented by everything and therefere we only need to type swicth in the receiver end
type Message interface{} 

//Message where the customer indicates his journey preference
type JourneyPreference struct {
	journeyPreference string
}

//Message where the service informs the customer the date of his flight
type JourneyDate struct {
	journeyDate time.Time
}

//Message where the agency informs the customer of the price of his journey
type JourneyPrice struct {
	journeyPrice float64
}

//Message where the customer informs the service of his address
type CustomerAddress struct {
	customerAddress address
}

//To emulate a enum describing the customer decision
type Decision string

const ACCEPT Decision = "ACCEPT"
const REJECT Decision = "REJECT"

//Whether or not the customer accepts the price given by the agency
type CustomerDecision struct {
	decision Decision
}

