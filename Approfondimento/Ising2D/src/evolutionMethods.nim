from std/sequtils import newSeqWith
from std/math import floor, exp

import pcg, obs


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


proc wolffMove*(modIsing: var seq[seq[int]], rg: var PCG, temp: float32, acc: float32, nspin: int): float32 = 
    # Algoritmo di Wolff per evolvere il modello di Ising 2D

    var 
        appo: int
        conta: int
        test: IsingCoord
        clusterSize:int = 0
        stack: seq[IsingCoord] = @[]
        padd = 1 - exp(-2*acc/temp)

        # Variabili per coordinate spin
        randSpin, upNeigh, downNeigh, leftNeigh, rightNeigh: IsingCoord

    while clusterSize < nspin * nspin:
        # Valuto casualmente spin
        randSpin = rg.newRandomCoord(nspin)
        stack.add(randSpin)

        # Salvo valore iniziale spin (per successivi confronti) e poi inverto spin
        appo = modIsing[randSpin.xcoor][randSpin.ycoor]
        modIsing[randSpin.xcoor][randSpin.ycoor] = -appo

        # Continuo fino a quando non ho controllato tutte le possibilità
        while stack.len() > 0:
            test = stack.pop
            clusterSize += 1

            # Valuto quali siano i primi vicini
            upNeigh = newCoord(test.xcoor, (test.ycoor + 1) mod nspin)
            downNeigh = newCoord(test.xcoor, (test.ycoor + nspin - 1) mod nspin)
            leftNeigh = newCoord((test.xcoor + 1) mod nspin, test.ycoor)
            rightNeigh = newCoord((test.xcoor + nspin - 1) mod nspin, test.ycoor)

            # Aggiungo al cluster solo se hanno lo stesso orientamento dello spin di partenza
            if modIsing[upNeigh.xcoor][upNeigh.ycoor] == appo and rg.rand() < padd:
                modIsing[upNeigh.xcoor][upNeigh.ycoor] = -appo
                stack.add(upNeigh);

            if modIsing[downNeigh.xcoor][downNeigh.ycoor] == appo and rg.rand() < padd:
                modIsing[downNeigh.xcoor][downNeigh.ycoor] = -appo
                stack.add(downNeigh);

            if modIsing[rightNeigh.xcoor][rightNeigh.ycoor] == appo and rg.rand() < padd:
                modIsing[rightNeigh.xcoor][rightNeigh.ycoor] = -appo
                stack.add(rightNeigh);

            if modIsing[leftNeigh.xcoor][leftNeigh.ycoor] == appo and rg.rand() < padd:
                modIsing[leftNeigh.xcoor][leftNeigh.ycoor] = -appo
                stack.add(leftNeigh);
            
        conta += 1
    
    return clusterSize/conta
