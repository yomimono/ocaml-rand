open Cmdliner

let savefile afile thingtobesaved =
  let channel = open_out afile in
  output_string channel thingtobesaved;
  close_out channel 

let readfile bfile =
  let channel = open_in bfile in
  Std.input_all channel

let base64 code infile outfile =
  let coding = match code with
  | "E" -> Nocrypto.Base64.encode
  | "D" -> Nocrypto.Base64.decode
  | _ -> failwith "Please use either 'E' or 'D' for encoding or decoding" in
  savefile outfile (Cstruct.to_string (coding (Cstruct.of_string (readfile infile))))

  (*commandline interface*)

let code = 
  let doc = "Enter E for encoding and D for decoding" in
  Arg.(value & pos 0 string "E" & info [] ~doc)

let infile = 
  let doc = "File to be encoded with base64 or decoded from base64." in
  Arg.(value & opt string "infile.txt" & info ["i"; "in"] ~doc)

let outfile =
  let doc = "File for encoded/decoded string to be saved." in
  Arg.(value & opt string "outfile.txt" & info ["o"; "out"] ~doc)
  
let cmd =
  let doc = "encodes/decodes to/from base64; enter 'E' or 'D' before other args for encoding or decoding (default=E)" in
  let man = [
    `S "BUGS";
    `P "Submit at https://github.com/qlai/ocaml-rand"]
  in
  Term.(pure base64 $ code $ infile $ outfile ),
  Term.info "base64" ~version:"0.0.1" ~doc ~man

let () = match Term.eval cmd with `Error _ -> exit 1 | _ -> exit 0

