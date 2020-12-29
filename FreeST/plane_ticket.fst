sink : Skip -> ()
sink _ = ()

main : Int
main = 
  let (w, r) = new !Int in
  let _      = fork (sink $ send 5 w) in
  let (v, _) = receive r in 
  v