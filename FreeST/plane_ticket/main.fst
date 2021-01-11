-----------------------DATATYPES-------------------------
-- It would be useful to have a separated module
--for defining datatypes that are going to be
--used in a lot of files

type Country = String
type City = String 
type Street = String 

data Address = Address Int Int Int --address of a customer

data Message = JourneyPreference Int
                | JourneyDate Int -- dd/mm/yyyy
                | JourneyPrice Int -- To simplify we will use ints to describe a price (while freest does not support floats)
                | CustomerAddress Address
                | CustomerDecision Int

-- Not sure about the skips
type MessageC : SL = +{JourneyPreference: !Int,
                        JourneyDate: !Int,
                        JourneyPrice: !Int,
                        CustomerAddress: !Int;!Int;!Int,
                        CustomerDecision: !Int}
---------------------------------------------------------

-- main is not supposed to return Int, this is just temporary
main : String
main =  
    --TROCAR OS INTS PARA STRINGS AGAIN
    -- some mock values
    let maxPrice = 1000 in
    let country =  1 in
    let city = 2 in
    let street = 3 in
    let addr = Address country city street in
    let journeyPref = 4 in

    --channel that will be used in the communication
    let (customerSend, agencyReceive) = new MessageC in
    let _ = customerOrder maxPrice journeyPref addr customerSend agencyReceive in 
    "Finished!!!"

    --If we fork customerOrder main ends before the rest is concluded
    --probably we need to block with a channel

--Customer Side Algorithm (trade Ints for strings later)
--customerOrder : Int -> String -> Address -> MessageC -> dualof MessageC -> ()
customerOrder : Int -> Int -> Address -> MessageC -> dualof MessageC -> ()
customerOrder maxPrice journeyPref addr customerSend agencyReceive =
    let _ = printStringLn "Starting the customer!" in
    --Create a new channel for the direction Agency->Customer
    let (agencySend,customerReceive) = new MessageC in
    let _ = fork (agencySell agencySend agencyReceive) in
    let msg = JourneyPreference journeyPref in
    let customerSend = sendMessage[Skip] customerSend msg in 
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
    printStringLn "Closing the customer!"


--Agency Side Algorithm 
agencySell : MessageC -> dualof MessageC -> ()
agencySell agencySend agencyReceive = 
    let _ = printStringLn "Starting the Agency!" in
    let romePrice = 289 in
    let v = match agencyReceive with {
        JourneyPreference agencyReceive -> 
              let (v,agencyReceive) = receive agencyReceive in 
              let _ = printString "Received preference: " in 
              let _ = printIntLn v in 
              v,
        JourneyPrice agencyReceive -> 
                let (_, agencyReceive) = receive agencyReceive in 
                let _ = printStringLn "Error: received a price when should have received a journey preference!" in 
                -1,
        JourneyDate agencyReceive -> 
                let (_, agencyReceive) = receive agencyReceive in 
                let _ = printStringLn "Error: received a date when should have received a journey preference!" in 
                -1,
        CustomerAddress agencyReceive -> 
                let (_, agencyReceive) = receive agencyReceive in 
                let (_, agencyReceive) = receive agencyReceive in
                let (_, agencyReceive) = receive agencyReceive in
                let _ = printStringLn "Error: received a price when should have received a journey preference!" in 
                -1,
        CustomerDecision agencyReceive -> 
                let (_, agencyReceive) = receive agencyReceive in 
                let _ = printStringLn "Error: received a price when should have received a journey preference!" in 
                -1
    } in 
    let answer = JourneyPrice romePrice in 
    let _ = sendMessage[Skip] agencySend answer in 
    printStringLn "Closing the Agency!"

--Change to MessageC -> dualof MessageC -> ()
serviceOrderDelivery : Int -> Int -> ()
serviceOrderDelivery agencySend agencyReceive = ()

--evaluating the offer(For now it is always true)
evalOffer : Int -> Int -> Bool
evalOffer jpref jprice = True

  --sends a Message in a given MessageC channel
sendMessage : forall a : SL => MessageC;a -> Message -> a
sendMessage c m = 
  case m of {
    JourneyPreference jpref -> 
      let c  = select JourneyPreference c in
      let c  = send jpref c in
      c,
    JourneyPrice jprice -> 
      let c  = select JourneyPrice c in
      let c  = send jprice c in
      c,
    JourneyDate jd -> 
      let c  = select JourneyDate c in
      let c  = send jd c in
      c,
    CustomerAddress addr -> 
      let c  = select CustomerAddress c in
      case addr of {
        Address country city street -> 
          let c  = send country c in
          let c  = send city c in
          let c  = send street c in
          c
      },
    CustomerDecision cd ->
      let c  = select CustomerDecision c in
      let c  = send cd c in
      c
  }

