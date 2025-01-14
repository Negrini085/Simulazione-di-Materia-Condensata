import std/unittest
from std/fenv import epsilon
from std/streams import FileStream, newFileStream
import ../src/paramIn


proc areClose*(x, y: float32; eps: float32 = epsilon(float32)): bool {.inline.} = abs(x - y) < eps
## `areClose` proc is used to check equivalence in floating point numbers, it's fundamental for testing


suite "paramIn":

    setup:
        var 
            dMod: DefMod 
            fStr: FileStream
            inStr: InputStream
            fname = "files/param.in"
        
    teardown:
        discard dMod
        discard fStr
        discard inStr
        discard fname


    test "parseDefModel proc":
        # Controllo di lettura corretta del file dei parametri

        fStr = newFileStream(fname, fmRead)
        inStr = newInputStream(fStr, fname, 4)
        dMod = inStr.parseDefModel()
        
        check areClose(dMod.params[0], 0.5)
        check int(dMod.params[1]) == 200
        check areClose(dMod.params[2], 1.0)
        check int(dMod.params[3]) == 1000000
        check int(dMod.params[4]) == 100
        check int(dMod.params[5]) == 0
        check int(dMod.params[6]) == 12
        check int(dMod.params[7]) == 3000
