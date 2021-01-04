-----------------------DOUBTS----------------------------
-- 1- How to use floats in Freest;
-- 2- How to import code in Freest
--in order to have the code organized in files;
-- 3- How to write Strings in Freest;
-- 4- How to catch all the results inside a match in Freest;
---------------------------------------------------------

-----------------------DATATYPES-------------------------
-- It would be useful to have a separated module
--for defining datatypes that are going to be
--used in a lot of files (e.g. Strings)
data String = Nil | StringCons Char String

-- Address should be defined in a "customer" class
data Address = AddressCons String String String

data JourneyPreference = JPrefCons String

data JourneyDate = JDCons String String String --day month year (maybe we should also create a Date datatype)

data JourneyPrice = JPrice Int Int -- euros cents (don't know how to write floats) (problem: cents has to be 0<=cents<=99)

data CustomerAddress = CACons Address

data Decision = Reject | Accept

data CustomerDecision = CDCons Decision

data Message = JourneyPreference
                | JourneyDate
                | JourneyPrice
                | CustomerAddress
                | CustomerDecision

-- Not sure about the skips
type MessageC : SL = +{JourneyPreference: Skip,
                        JourneyDate: Skip,
                        JourneyPrice: Skip,
                        CustomerAddress: Skip,
                        CustomerDecision: Skip}
---------------------------------------------------------

-- main is not supposed to return Int, this is just temporary
main : Int
main =
    -- some mock values
    let maxPrice = 1000 in
    -- There must be another way to write strings in Freest
    --For now this worked
    let country =  StringCons 'P' $ StringCons 'o' $ StringCons 'r'
        $ StringCons 't' $ StringCons 'u' $ StringCons 'g'
        $ StringCons 'a' $ StringCons 'l' Nil in
    let city =
        StringCons 'L' $ StringCons 'i' $ StringCons 's'
        $ StringCons 'b'$ StringCons 'o' $ StringCons 'n' Nil in
    let street =
        StringCons 'R' $ StringCons 'u' $ StringCons 'a'
        $ StringCons ' ' $ StringCons 'A' $ StringCons 'u'
        $ StringCons 'g' $ StringCons 'u' $ StringCons 's'
        $ StringCons 't' $ StringCons 'a' Nil in
    let addr = AddressCons country city street in
    let journeyPref =
        StringCons 'R' $ StringCons 'o' $ StringCons 'm'
        $ StringCons 'e' Nil in

    --channel that will be used in the communication
    let (w,r) = new MessageC in
    let _ = fork (customerOrder maxPrice journeyPref addr w r) in

    maxPrice

customerOrder : Int -> String -> Address -> MessageC -> dualof MessageC -> ()
customerOrder maxPrice journeyPref addr w r =
    -- don't know if it is necessary to pass both ends of the channel
    let _ = fork (agencySell w r) in

    customerOrderCycle journeyPref

customerOrderCycle : String -> ()
customerOrderCycle journeyPref =

    let jp = JPrefCons journeyPref in

    let _ = send jp w in

    let received = receive r in

    let (price, r) = receive r in

    match price with {
        JourneyPrice price -> price --,
        -- don't know how to catch other results   _ v -> printChar 'e' -- print error
    }

    if evalOffer journeyPref price then  else customerOrderCycle journeyPref

agencySell : MessageC -> dualof MessageC -> ()
agencySell w r =
    match r with {

    }

evalOffer : String -> journe
evalOffer journeyPref price