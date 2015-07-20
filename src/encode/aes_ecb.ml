open Cmdliner
open Common
open Nocrypto
open Cipher_block

let aesecb encode yourkey keyfile infile outfile = 
  let checkkey akey =
  match akey with 
  | "NA" -> failwith "no key entered"
  | _ -> akey in
  let getkey = match keyfile with
  | "NA" -> checkkey yourkey (*TODO: here we need to decide whether key is entered or read from file*)
  | _ -> readfile keyfile in

  let key = (padding getkey) |> Cstruct.of_string |> AES.ECB.of_secret in
  let coding = match encode with 
  | "E" -> AES.ECB.encrypt ~key:key (Cstruct.of_string(padding(readfile infile)))
  | "D" -> AES.ECB.decrypt ~key:key (Cstruct.of_string(padding(readfile infile)))
  | _ -> failwith "please enter E or D" in
savefile outfile (Cstruct.to_string coding)

  (*commandline interface start here*)

let encode =
  let doc = "E or D" in
  Arg.(value & pos 0 string "E" & info [] ~doc)
(*
let nobits =
  let doc = "number of bits" in
  Arg.(value & opt int 128 & info ["b"; "bits"] ~doc) 
*)
let yourkey = 
  let doc = "key" in
  Arg.(value & opt string "NA" & info ["k"; "key"] ~doc)

let keyfile =
  let doc = "keyfile" in
  Arg.(value & opt string "NA" & info ["kf" ; "keyfile"] ~doc)

let cmd =
  let doc = "aes block cipher" in
  let man = [
    `S "BUGS" ;
    `P "Submit via github"]
  in
  Term.(pure aesecb $ encode $ yourkey $ keyfile $ infile $ outfile),
  Term.info "aes" ~version:"0.0.1" ~doc ~man

let () = match Term.eval cmd with `Error _ -> exit 1 | _ -> exit 0
