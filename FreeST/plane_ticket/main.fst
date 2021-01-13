{- |
Module      :  Plane Ticket
Description :  Algorithm that simulates the communication between a plane ticket buyer and an agency
Copyright   :  Jorge Martins & Diogo Lopes

This example is from Vasconcelos, V.T. (and several others):
"Behavioral Types in Programming Languages" (figures 2.4, 2.5 and 2.6)

-}

data Address = Address String String String --address of a customer

type ServiceC : SL = !String;!String;!String;?String
type ChoiceC : SL = +{Accept: ServiceC, Reject: Skip}
type LoopC : SL =  !String;?Int;+{Break: ChoiceC, Continue: LoopC}

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
    let (customerEnd, agencyEnd) = new LoopC in
    --START THE AGENCY
    let _ = fork (agencySell agencyEnd) in
    let (customerEnd,price) = customerMainLoop customerEnd journeyPref in
    (if price <= maxPrice 
        then 
            let customerEnd = select Accept customerEnd in
            let customerEnd = case addr of {
                Address country city street -> 
                        let customerEnd = send country customerEnd in
                        let customerEnd = send city customerEnd in
                        send street customerEnd
                } in 
            let (date,_) = receive customerEnd in 
            printString "Journey date: "; 
            printStringLn date 
        else 
            sink (select Reject customerEnd));
    sink (send True lockw); --Inform main that the customer finished
    printStringLn "Closing the customer!"

customerMainLoop : LoopC -> String -> (ChoiceC,Int)
customerMainLoop customerEnd journeyPref = 
    let customerEnd = send journeyPref customerEnd in 
    let (price,customerEnd) = receive customerEnd in
    let _ = printString "Received price: " in 
    let _ = printIntLn price in
   -- let b = (nextRandom a) in
    if evalOffer journeyPref price 
        then let customerEnd = select Break customerEnd in (customerEnd,price) 
        else let customerEnd = select Continue customerEnd in customerMainLoop customerEnd journeyPref

--Agency Side Algorithm 
agencySell : dualof LoopC -> ()
agencySell agencyEnd = 
    let _ = printStringLn "Starting the Agency!" in
    let romePrice = 289 in 
    let _ = agencyMainLoop agencyEnd romePrice in 
    printStringLn "Closing the Agency!" 

-- Loop in
agencyMainLoop : dualof LoopC -> Int -> ()
agencyMainLoop agencyEnd romePrice =
    let (jp, agencyEnd) = receive agencyEnd in 
    let _ = printString "Received preference: " in 
    let  _ = printStringLn jp in
    let agencyEnd = send romePrice agencyEnd in
    match agencyEnd with {
        Break agencyEnd -> match agencyEnd with {
            Accept agencyEnd -> fork (serviceOrderDelivery agencyEnd),
            Reject agencyEnd -> ()
        },
        Continue agencyEnd -> agencyMainLoop agencyEnd romePrice
    }

serviceOrderDelivery : dualof ServiceC -> ()
serviceOrderDelivery agencyEnd = 
        let _ = printStringLn "Starting the service!" in
        let date = "23/03/2021" in
        ---Receive the Address
        let (country,agencyEnd) = receive agencyEnd in
        let (city,agencyEnd) = receive agencyEnd in
        let (street,agencyEnd) = receive agencyEnd in
        let _  = printString "Customer Address: " in
        let _ = printString country in let _ = printString ", " in
        let _ = printString city in let _ = printString ", " in
        let _ = printStringLn street in
        --send the date
        let _ = send date agencyEnd in 
        printStringLn "Closing the service!"

nextRandom : Int -> Int
nextRandom n = n + 1 * (mod 111 100)

--evaluating the offer(For now it is always true)
evalOffer : String -> Int -> Bool
evalOffer jpref jprice = True

-- Auxiliary function because of fork : () -> ()
sink : Skip -> ()
sink _ = ()
