# Package
version       = "0.1.0"
author        = "Negrini085"
description   = "Simulazione Monte-Carlo del modello di Ising 2D in Nim"
license       = "GPL-3.0-or-later"
bin           = @["Ising2D"]


# Dependencies
requires "nim >= 2.0.2"
requires "docopt >= 0.6"


# Tasks
task build, "Compila l'eseguibile\n":
  exec "nim c -d:release Ising2D.nim"

task test, "Esegue i test delle funzioni di Ising2D":
  withDir "tests":
    exec "nim c -d:release --hints:off -r pcg.nim"
    exec "nim c -d:release --hints:off -r paramIn.nim"
    exec "rm pcg paramIn"
