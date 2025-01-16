from std/sequtils import newSeqWith
from std/math import floor, exp
from std/strformat import fmt

import pcg

proc inizializzaIsing*(rg: var PCG, nspin: int): seq[seq[int]] = 
    # Funzione per inizializzare il modello di Ising. Gli spin saranno orientati
    # in modo casuale

    var model: seq[seq[int]]

    # Inizializzo il modello
    for i in 0..<nspin:
        model.add(newSeqWith(nspin, if rg.rand < 0.5: -1 else: 1))

    return model


proc inizializzaIsing*(nspin: int): seq[seq[int]] = 
    # Funzione per inizializzare il modello di Ising. Gli spin saranno orientati
    # ordinati, tutti up

    var model: seq[seq[int]]

    # Inizializzo il modello
    for i in 0..<nspin:
        model.add(newSeqWith(nspin, 1))

    return model


proc metropolisMove*(modIsing: var seq[seq[int]], rg: var PCG, temp: float32, acc: float32, nspin: int, accettate: var int) = 
    # Algoritmo di Metropolis per evolvere il modello di Ising 2D

    # Indice per selezionare lo spin
    var 
        nmove = int(nspin * nspin)
        diffE: float32
        xcoor, ycoor, appo: int
        up, down, left, right: int


    for i in 0..<nmove:

        # Seleziono casualmente uno spin facente parte del modello
        xcoor = int(floor(rg.rand(float32(0), float32(nspin)))) mod nspin
        ycoor = int(floor(rg.rand(float32(0), float32(nspin)))) mod nspin

        # Determino quali sono i primi vicini in questo caso (facendo attenzione a bc)
        down = (ycoor + 1) mod nspin
        right = (xcoor + 1) mod nspin
        up = (ycoor - 1 + nspin) mod nspin
        left = (xcoor - 1 + nspin) mod nspin

        # Calcolo i contributi energetici
        appo = modIsing[xcoor][ycoor]
        diffE = 2 * acc * float32(appo) * float32((modIsing[right][ycoor] + modIsing[left][ycoor] + modIsing[xcoor][up] + modIsing[xcoor][down]))

        if diffE < 0:
            modIsing[xcoor][ycoor] = -appo
            accettate += 1

        elif rg.rand() < exp(-diffE/temp):
            modIsing[xcoor][ycoor] = -appo
            accettate += 1
        
    echo fmt"AR: {int(accettate/(nspin * nspin)*10000)/100}"
    accettate = 0