{- |
Module      :  Plane Ticket
Description :  Algorithm that simulates the communication between a plane ticket buyer and an agency
Copyright   :  Jorge Martins & Diogo Lopes

This example is from Vasconcelos, V.T. (and several others):
"Behavioral Types in Programming Languages" (figures 2.4, 2.5 and 2.6)

-}

data Address = Address String String String --address of a customer

type ServiceC : SL = !String;!String;!String;?String
type LoopC : SL = +{Break: Skip, Loop: MessageC;LoopC}
type MessageC : SL = !String;?Int;!String;!String;!String;!String;?String

--type Messages : SL = + {Skip, MessageJourneyPreference;Messages}
---------------------------------------------------------

-- main is not supposed to return Int, this is just temporary
main : String
main =  
    -- some mock values
    let maxPrice = 1000 in
    let country = "Portugal" in
    let city = "Lisbon" in
    let street = "Rua Augusta" in
    let addr = Address country city street in
    let journeyPref = "Rome" in

    --Channel to only let main end after the customer is done
    let (lockw, lockr) = new !Bool in
    --START THE CUSTOMER
    let _ = fork (customerOrder maxPrice journeyPref addr lockw) in 
    let (_,_) = receive lockr in --Once we receive this the customer as finished
    "Finished!!!"

--Customer Side Algorithm
customerOrder : Int -> String -> Address -> !Bool -> ()
customerOrder maxPrice journeyPref addr lockw =
    let _ = printStringLn "Starting the customer!" in

    --Creating a channel for each direction of Customer <-> Agency
    let (customerEnd, agencyEnd) = new MessageC in
    --START THE AGENCY
    let _ = fork (agencySell agencyEnd) in
    let customerEnd = send journeyPref customerEnd in 
    let (price,customerEnd) = receive customerEnd in
    let _ = printString "Received price: " in 
    let _ = printIntLn price in 
    let decision = if evalOffer journeyPref price then "ACCEPT" else "REJECT" in
    let customerEnd = send decision customerEnd in
    let customerEnd = case addr of {
        Address country city street -> 
                let customerEnd = send country customerEnd in
                let customerEnd = send city customerEnd in
                send street customerEnd
    } in 
    let (date,_) = receive customerEnd in 
    let _ = printString "Journey date: " in 
    let _ = printStringLn date in
    let _ = send True lockw in --Inform main that the customer finished
    printStringLn "Closing the customer!"


--Agency Side Algorithm 
agencySell : dualof MessageC -> ()
agencySell agencyEnd = 
    let _ = printStringLn "Starting the Agency!" in
    let romePrice = 289 in 
    let (pref,agencyEnd) = receive agencyEnd in 
    let _ = printString "Received preference: " in 
    let _ = printStringLn pref in 
    let agencyEnd = send romePrice agencyEnd in 
    let (clientDecision,agencyEnd) = receive agencyEnd in 
    let _ = printString "Received decision: " in 
    let _ = printStringLn clientDecision in 
    let _ = fork (serviceOrderDelivery agencyEnd) in
    printStringLn "Closing the Agency!" 


serviceOrderDelivery : dualof ServiceC -> ()
serviceOrderDelivery agencyEnd = 
        let _ = printStringLn "Starting the service!" in
        let date = "23/03/2021" in
        let (country,agencyEnd) = receive agencyEnd in
        let (city,agencyEnd) = receive agencyEnd in
        let (street,agencyEnd) = receive agencyEnd in
        let _  = printString "Customer Address: " in
        let _ = printString country in let _ = printString ", " in
        let _ = printString city in let _ = printString ", " in
        let _ = printStringLn street in
        let _ = send date agencyEnd in 
        printStringLn "Closing the service!"

--evaluating the offer(For now it is always true)
evalOffer : String -> Int -> Bool
evalOffer jpref jprice = True
