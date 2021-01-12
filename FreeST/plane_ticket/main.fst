{- |
Module      :  Plane Ticket
Description :  Algorithm that simulates the communication between a plane ticket buyer and an agency
Copyright   :  Jorge Martins & Diogo Lopes

This example is from Vasconcelos, V.T. (and several others):
"Behavioral Types in Programming Languages" (figures 2.4, 2.5 and 2.6)

-}

data Address = Address String String String --address of a customer

data Message = JourneyPreference String
                | JourneyDate String -- dd/mm/yyyy
                | JourneyPrice Int -- To simplify we will use ints to describe a price (while freest does not support floats)
                | CustomerAddress Address
                | CustomerDecision String

--Channels to exchange messages
type MessageC : SL = +{JourneyPreference: !String,
                        JourneyDate: !String,
                        JourneyPrice: !Int,
                        CustomerAddress: !String;!String;!String,
                        CustomerDecision: !String}
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
    let (customerSend, agencyReceive) = new MessageC in
    let (agencySend,customerReceive) = new MessageC in
    --START THE AGENCY
    let _ = fork (agencySell agencySend agencyReceive) in
    let customerSend = sendMessage customerSend (JourneyPreference journeyPref) in 
    -- Since FreeST does not have the functionality to collaapse all of the unwanted matches into a _ we have this big match block
    let price = match customerReceive with {
        JourneyPreference customerReceive -> 
                let (_,customerReceive) = receive customerReceive in 
                let _ = printStringLn "Error: received a preference when should have received a journey price!" in 
                -1,
        JourneyPrice customerReceive -> 
                let (price,customerReceive) = receive customerReceive in 
                let evaluation = evalOffer journeyPref price in
                let _ = printString "Received price: " in 
                let _ = printIntLn price in
                price,
        JourneyDate customerReceive -> 
                let (_,customerReceive) = receive customerReceive in 
                let _ = printStringLn "Error: received a date when should have received a journey price!" in 
                -1,
        CustomerAddress customerReceive -> 
                let (_, customerReceive) = receive customerReceive in 
                let (_, customerReceive) = receive customerReceive in
                let (_, customerReceive) = receive customerReceive in
                let _ = printStringLn "Error: received a address when should have received a journey price!" in 
                -1,
        CustomerDecision customerReceive -> 
                let (_,customerReceive) = receive customerReceive in 
                let _ = printStringLn "Error: received a decision when should have received a journey price!" in 
                -1 
    } in
    let _ = send True lockw in --Inform main that the customer finished
    printStringLn "Closing the customer!"


--Agency Side Algorithm 
agencySell : MessageC -> dualof MessageC -> ()
agencySell agencySend agencyReceive = 
    let _ = printStringLn "Starting the Agency!" in
    let romePrice = 289 in 
    let _ = match agencyReceive with {
        JourneyPreference agencyReceive -> 
              let (v,agencyReceive) = receive agencyReceive in 
              let _ = printString "Received preference: " in 
              let _ = printStringLn v in 
              v,
        JourneyPrice agencyReceive -> 
                let (_, agencyReceive) = receive agencyReceive in 
                let _ = printStringLn "Error: received a price when should have received a journey preference!" in 
                "ERR",
        JourneyDate agencyReceive -> 
                let (_, agencyReceive) = receive agencyReceive in 
                let _ = printStringLn "Error: received a date when should have received a journey preference!" in 
                "ERR",
        CustomerAddress agencyReceive -> 
                let (_, agencyReceive) = receive agencyReceive in 
                let (_, agencyReceive) = receive agencyReceive in
                let (_, agencyReceive) = receive agencyReceive in
                let _ = printStringLn "Error: received a price when should have received a journey preference!" in 
                "ERR",
        CustomerDecision agencyReceive -> 
                let (_, agencyReceive) = receive agencyReceive in 
                let _ = printStringLn "Error: received a price when should have received a journey preference!" in 
                "ERR"
    } in 
    let _ = sendMessage agencySend (JourneyPrice romePrice) in 
    printStringLn "Closing the Agency!" 


--serviceOrderDelivery : MessageC -> dualof MessageC -> ()
--serviceOrderDelivery agencySend agencyReceive = ()

--evaluating the offer(For now it is always true)
evalOffer : String -> Int -> Bool
evalOffer jpref jprice = True

--sends a Message in a given MessageC channel
sendMessage : MessageC -> Message -> ()
sendMessage c m = 
  case m of {
    JourneyPreference jpref -> 
      let c  = select JourneyPreference c in
      let c  = send jpref c in
      (),
    JourneyPrice jprice -> 
      let c  = select JourneyPrice c in
      let c  = send jprice c in
      (),
    JourneyDate jd -> 
      let c  = select JourneyDate c in
      let c  = send jd c in
      (),
    CustomerAddress addr -> 
      let c  = select CustomerAddress c in
      case addr of {
        Address country city street -> 
          let c  = send country c in
          let c  = send city c in
          let c  = send street c in
          ()
      },
    CustomerDecision cd ->
      let c  = select CustomerDecision c in
      let c  = send cd c in
      ()
  }
