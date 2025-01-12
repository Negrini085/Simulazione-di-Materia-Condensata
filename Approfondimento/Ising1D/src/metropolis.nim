from std/math import exp
from std/sequtils import newSeqWith

import pcg

proc inizializzaIsing*(rg: var PCG, nspin: int): seq[int] = 
    # Funzione per inizializzare il modello di Ising. Gli spin saranno orientati
    # in modo casuale
    
    return newSeqWith(nspin, if rg.rand < 0.5: -1 else: 1)


proc calcolaEnergia*(modIsing: seq[int], acc: float32, hmagn: float32): float32 = 
    # Funzione per calcolare l'energia del modello di Ising

    var ene: float32 = 0

    for i in 0..<len(modIsing):
        ene -= acc * float32(modIsing[i] * modIsing[(i+1) mod len(modIsing)]) + hmagn * float32(modIsing[i])

    return ene


proc calcolaMagn*(modIsing: seq[int]): float32 = 
    # Funzione per calcolare la magnetizzazione del modello di Ising

    var magn: int = 0

    for i in 0..<len(modIsing):
        magn += modIsing[i]

    return float32(magn)/float32(modIsing.len())


proc metropolisMove*(modIsing: var seq[int], rg: var PCG, temp: float32, acc: float32, hmagn: float32, accettate: var int) = 
    # Algoritmo di Metropolis per evolvere il modello di Ising

    # Indice per selezionare lo spin
    var 
        diffE: float32
        ind, prev, next, appo: int


    for i in 0..<len(modIsing):
        ind = int(rg.rand(float32(0), float32(len(modIsing))))
        prev = if (ind - 1) mod len(modIsing) == -1: len(modIsing)-1 else: (ind - 1) mod len(modIsing)
        next = (ind + 1) mod len(modIsing)

        appo = modIsing[ind mod len(modIsing)]
        diffE = 2 * acc * float32(appo) * float32(modIsing[prev] + modIsing[next]) + 2 * hmagn * float32(appo)

        if diffE < 0:
            modIsing[ind] = -appo
            accettate += 1

        elif rg.rand() < exp(-diffE/temp):
            modIsing[ind] = -appo
            accettate += 1
