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

(* Interface to Github-hosted repositories *)
open Printf

(** Fetch a HTTP [uri] via GET *)
let http_get uri =
  (* TODO yuck! simpler api needed in cohttp *)
  match_lwt Cohttp_lwt_unix.Client.get uri with
    |None -> failwith ("unable to get changes for " ^ (Uri.to_string uri))
    |Some (r, b) ->
       (* TODO check the r code is a 200 *)
       Cohttp_lwt_body.string_of_body b

(** Fetch a CHANGES file from the [branch] of a [user]/[repo] in Github *)
let changelog ?(branch="master") ~user ~repo () =
  (* Assume a CHANGES file is present in master *)
  let uri = Uri.of_string (sprintf "https://raw.github.com/%s/%s/%s/CHANGES" user repo branch) in
  try
    let clog = Lwt_unix.run (http_get uri) in
    Some (Package_changelog.parse clog)
  with exn ->
    eprintf "Unable to parse %s: %s\n%!" (Uri.to_string uri) (Printexc.to_string exn);
    None
