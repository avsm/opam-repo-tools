open Cmdliner

let changelog branch user repo =
  let clog = Github_repo.changelog ~branch ~user ~repo () in
  match clog with
  | None -> prerr_endline "Unable to retrieve a valid CHANGES file"; exit (-1)
  | Some clog ->
      let pchanges = Changelog.parse_markdown clog in
      List.iter (fun (date, changes) ->
      print_endline date;
      print_endline (Omd.to_html changes);
      print_endline "") pchanges;
      `Ok  ()

let branch =
  let doc = "Remote branch to retrieve CHANGES from" in
  Arg.(value & opt string "master" & info ["b"; "branch"] ~docv:"BRANCH" ~doc)

let user =
  let doc = "Github username to query (will form URL of form https://github.com/$(i,USER)" in
  Arg.(required & pos 0 (some string) None & info [] ~doc ~docv:"USER")

let repo =
  let doc = "Github repository to query" in
  Arg.(required & pos 1 (some string) None & info [] ~doc ~docv:"REPO")

let cmd : (unit Term.t * Term.info) =
  let doc = "Query changelog from remote repo and make sure it is well-formed and parseable" in
  let man = [
    `S "BUGS";
    `P "Email them to <anil@recoil.org>.";
    `S "SEE ALSO";
    `P "$(b,opam)(1)" ]
  in
  Term.(ret (pure changelog $ branch $ user $ repo)),
  Term.(info "opam-changelog" ~version:"1.6.1" ~doc ~man)

let () = match Term.eval cmd with `Error _ -> exit 1 | _ -> exit 0
