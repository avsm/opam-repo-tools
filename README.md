A collection of tools to inspect a Github repository and extract metadata.

* `opam-changelog`: looks at the `CHANGES` file in this format:
```
0.9.0 (trunk)
* improve (but break) the command-line interface by using cmdliner

0.8.2 [Dec 2012]
* Fix an issue with 'opam reinstall <packages>' where packages were reinstalled in reverse order
* etc...
```
