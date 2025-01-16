import std/unittest
from std/fenv import epsilon

import ../src/obs


proc areClose*(x, y: float32; eps: float32 = epsilon(float32)): bool {.inline.} = abs(x - y) < eps
## `areClose` proc is used to check equivalence in floating point numbers, it's fundamental for testing



suite "Metropolis":

    setup:
        var 
            modIsing: seq[seq[int]]

    teardown:
        discard modIsing


    test "calcolaEnergia proc":
        # Controllo sul calcolo dell'energia
        var appo: seq[int]

        for i in 0..<100:
            for j in 0..<100:
                appo.add(1)

            modIsing.add(appo)
            appo.setLen(0)
        
        check areClose(calcolaEnergia(modIsing, 100, 1), -20000)


    test "calcolaMagn proc":
        # Controllo sul calcolo della magnetizzazione 
        var appo: seq[int]

        for i in 0..<100:
            for j in 0..<100:
                appo.add(1)

            modIsing.add(appo)
            appo.setLen(0)

        check areClose(calcolaMagn(modIsing, 100), 10000)

        modIsing.setLen(0)
        for i in 0..<100:
            for j in 0..<100:
                if j mod 2 == 0:
                    appo.add(1)
                
                else: 
                    appo.add(-1)

            modIsing.add(appo)
            appo.setLen(0)

        check areClose(calcolaMagn(modIsing, 100), 0)
