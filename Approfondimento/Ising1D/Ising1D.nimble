# Package

version       = "0.1.0"
author        = "Negrini085"
description   = "Simulazione Monte-Carlo del modello di Ising 1D in Nim"
license       = "GPL-3.0-or-later"
bin           = @["Ising1D"]


# Dependencies
requires "nim >= 2.0.2"
requires "docopt >= 0.6"


# Tasks
task build, "Compila l'eseguibile\n":
  exec "nim c -d:release Ising1D.nim"

task test, "Esegue i test delle funzioni di Ising1D":
  withDir "tests":
    exec "nim c -d:release --hints:off -r pcg.nim"
    exec "nim c -d:release --hints:off -r paramIn.nim"
    exec "nim c -d:release --hints:off -r metropolis.nim"
    exec "rm pcg paramIn metropolis"


