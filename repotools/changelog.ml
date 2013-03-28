(*
 * Copyright (c) 2012-2013 Anil Madhavapeddy <anil@recoil.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Core.Std

(* Parse our homebrew Github CHANGES format for repositories, which is:
0.9.0 (trunk)
* improve (but break) the command-line interface by using cmdliner

0.8.2 [Dec 2012]
* Fix an issue with 'opam reinstall <packages>' where packages were reinstalled in reverse order
* etc...
*)
let parse buf =
  let lines = String.split ~on:'\n' buf in
  let rec aux_header res =
    function
    |[] | ""::_ -> List.rev res (* EOF *)
    |hd::tl -> begin
      prerr_endline hd;
      let (version,_) = String.lsplit2_exn ~on:' ' hd in
      aux_changes version res [] tl
    end
  (* Consume until new line or EOF *)
  and aux_changes version res acc =
   let combine l = (version, (String.concat ~sep:"\n" (List.rev l))) :: res in
   function
   |[] -> List.rev (combine acc)
   |""::tl -> aux_header (combine acc) tl
   |hd::tl -> aux_changes version res (hd::acc) tl
  in
  aux_header [] lines
