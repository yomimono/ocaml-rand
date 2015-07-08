(*rand -generate pseudo-random byte

args
-out file
-rand file(s)  (Use specified file or files or EGD socket (see RAND_egd) for seeding the random number generator. Multiple files can be specified separated by a OS-dependent character. The separator is ; for MS-Windows, , for OpenVMS, and : for all others.)
-base64
-hex

dependencies
-nocrypto
-ocaml-hex

aim:
rand [-out OUTFILE | --outfile=OUTFILE] [-seed RANDSEED | --randseed=RANDSEED] [ENCODE]

*)
open Hex

(*implementation*)

type encoding = Base64 | Hex | NoEncoding

let encode_str = function Base64 -> "base64" | Hex -> "hex" | NoEncoding -> "noencoding"

let rand outfile randseed encode = 
  let chan = open_in randseed in
    try while true do let inputseed = input_line chan in
    let generatedRand =
    match inputseed with
      |"noseed" -> Nocrypto.Rng.generate (*TO DO: use nocrypto lib generate pseudo rand*)
      | _ -> Niocrypto.Rng.create ~seed:inputseed in (*TO DO: sort out seeded generation*)
  let encodedRand = 
    match encode with
      | "base64" -> Nocrypto.Base64.encode generatedRand(*use nocrypto to encode randbytes with base 64 encoding*)
      | "hex" -> Hex.of_string generatedRand (*hex encoding of randbytes*)
      | "noencoding" -> generatedRand in
  let save file string =
    let channel = open_out file in
      output_string channel string;
      close_out channel in
    match outfile with
      | Some x -> save x encodedRand
      | "NoOutput" -> print_endline encodedRand
(* commandline interface*)

open Cmdliner;;
let outfile =
  let doc = "Write to file instead of standard output." in
  Arg.(required & pos_left ~rev:true 0 (some string) file [] & info ["out"; "outfile"] ~docv:"OUTFILE" ~doc)

let randseed = 
  let doc = "user provide seed" in
  Arg.(required & pos"" & info ["seed"; "randseed"] ~docv:"RANDSEED" ~doc)

let encode = 
  let doc = "perform base64/PEM encoding" in
  let base64 = Base64, Arg.info ["base64"; "pem"] ~doc in
  let doc = "perform hex encoding" in 
  let hex = Hex, Arg.info ["hex"] ~doc in
  let doc = "neither base64 or hex encoding required" in
  let noencoding = NoEncoding, Arg.info ["none";"noencoding"] ~doc in 
  Arg.(last & vflag_all [NoEncoding] [base64; hex; noencoding])

let cmd =
  let doc = "rand" in
  let man = [
  `S "BUGS";
  `P "Email to <giulia.lai@gmail.com>." ] in
Term.(ret (pure rand $ outfile $ randseed $ encode)),
Term.info "rand" ~version:rand_version.currentversion ~doc ~man

let () = match Term.eval cmd with
`Error _ -> exit 1 | _ -> exit 0
