import std/unittest
import ../src/[evolutionMethods, pcg]

suite "Evoluzione sistema":

    setup:
        var 
            modIsing: seq[seq[int]]
            rg = newPCG((uint64(12), uint64(45)))

    teardown:
        discard modIsing
        discard rg


    test "inizializzaIsing proc":
        # Controllo sulla fase d'inizializzazione del modello di Ising (temperatura infinita)

        modIsing = rg.inizializzaIsing(1000)

        for i in 0..<len(modIsing):
            for j in 0..<len(modIsing):
                check modIsing[i][j] == 1 or modIsing[i][j] == -1


    test "inizializzaIsing proc":
        # Controllo sulla fase d'inizializzazione del modello di Ising (temperatura nulla)

        modIsing = inizializzaIsing(1000)

        for i in 0..<len(modIsing):
            for j in 0..<len(modIsing):
                check modIsing[i][j] == 1
    