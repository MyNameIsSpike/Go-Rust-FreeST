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
main : ()
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
    customerOrder maxPrice journeyPref addr customerSend agencyReceive

    --If we fork customerOrder main ends before the rest is concluded
    --probably we need to block with a channel

--Customer Side Algorithm (trade Ints for strings later)
--customerOrder : Int -> String -> Address -> MessageC -> dualof MessageC -> ()
customerOrder : Int -> Int -> Address -> MessageC -> dualof MessageC -> ()
customerOrder maxPrice journeyPref addr customerSend agencyReceive =
    -- don't know if it is necessary to pass both ends of the channel
    let (agencySend,customerReceive) = new MessageC in
    let _ = fork (agencySell agencySend agencyReceive) in
    let msg = JourneyPreference journeyPref in
    let _ = sendMessage customerSend msg in 
    match customerReceive with {
        JourneyPreference customerReceive -> let (v,customerReceive) = receive customerReceive in printIntLn v,
        JourneyPrice customerReceive -> let (v,customerReceive) = receive customerReceive in printIntLn v,
        JourneyDate customerReceive -> let (v,customerReceive) = receive customerReceive in printIntLn v,
        CustomerAddress customerReceive -> 
          let (country,customerReceive) = receive customerReceive in 
          let (city,customerReceive) = receive customerReceive in
          let (street,customerReceive) = receive customerReceive in
          printIntLn (country+city+street),
        CustomerDecision customerReceive -> let (v,customerReceive) = receive customerReceive in printIntLn v
    }

--Agency Side Algorithm 
agencySell : MessageC -> dualof MessageC -> ()
agencySell agencySend agencyReceive = 
    let _ = match agencyReceive with {
        JourneyPreference agencyReceive -> let (v,agencyReceive) = receive agencyReceive in printIntLn v,
        JourneyPrice agencyReceive -> let (v,agencyReceive) = receive agencyReceive in printIntLn v,
        JourneyDate agencyReceive -> let (v,agencyReceive) = receive agencyReceive in printIntLn v,
        CustomerAddress agencyReceive -> 
          let (country,agencyReceive) = receive agencyReceive in 
          let (city,agencyReceive) = receive agencyReceive in
          let (street,agencyReceive) = receive agencyReceive in
          printIntLn (country+city+street),
        CustomerDecision agencyReceive -> let (v,agencyReceive) = receive agencyReceive in printIntLn v
    } in 
    let answer = JourneyPreference 5 in 
    sendMessage agencySend answer

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


  --customerOrderCycle : String -> ()
--customerOrderCycle journeyPref =

   -- let jp = JPrefCons journeyPref in

   -- let _ = send jp w in

    --let received = receive r in

    --let (price, r) = receive r in

  --  match price with {
    --    JourneyPrice price -> price --,
        -- don't know how to catch other results   _ v -> printChar 'e' -- print error
  --  }

   -- if evalOffer journeyPref price then  else customerOrderCycle journeyPref