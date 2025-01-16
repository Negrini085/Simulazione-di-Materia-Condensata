import std/unittest
from std/fenv import epsilon

import ../src/[metropolis, pcg]


proc areClose*(x, y: float32; eps: float32 = epsilon(float32)): bool {.inline.} = abs(x - y) < eps
## `areClose` proc is used to check equivalence in floating point numbers, it's fundamental for testing


suite "Metropolis":

    setup:
        var 
            modIsing: seq[int]
            rg = newPCG((uint64(12), uint64(45)))

    teardown:
        discard modIsing
        discard rg


    test "inizializzaIsing proc":
        # Controllo sulla fase d'inizializzazione del modello di Ising

        modIsing = rg.inizializzaIsing(10000000)

        for i in 0..<len(modIsing):
            check modIsing[i] == 1 or modIsing[i] == -1
    

    test "calcolaEnergia proc":
        # Controllo sul calcolo dell'energia

        for i in 0..<1000:
            modIsing.add(1)
        
        check areClose(calcolaEnergia(modIsing, 1, 0), -1000)
        check areClose(calcolaEnergia(modIsing, 1, 0.5), -1500)

        for i in 0..<4000:
            modIsing.add(1)
        
        check areClose(calcolaEnergia(modIsing, 1, 0.2), -6000, 0.4)


    test "calcolaMagn proc":
        # Controllo sul calcolo della magnetizzazione 

        for i in 0..<1000:
            modIsing.add(1)
        
        check areClose(calcolaMagn(modIsing), 1000)

        for i in 0..<1000:
            modIsing.add(-1)

        check areClose(calcolaMagn(modIsing), 0)
