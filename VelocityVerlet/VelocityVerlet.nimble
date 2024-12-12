# Package
version       = "0.1.0"
author        = "Negrini085"
description   = "Algoritmo velocity verlet per la simulazione di una catena di masse e molle"
license       = "MIT"
bin           = @["VelocityVerlet"]


# Dependencies

requires "nim >= 2.0.2"

task build, "Build the `VelocityVerlet` executable\n":
  exec "nim c -d:release velVerlet.nim"


task test, "Run the `VelocityVerlet` tests":
  withDir "tests":   
    exec "nim c -d:release --hints:off -r streamingIO.nim"
    exec "rm streamingIO"

