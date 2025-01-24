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


proc wolffMove*(modIsing: var seq[seq[int]], rg: var PCG, temp: float32, acc: float32, nspin: int): int = 
    # Algoritmo di Wolff per evolvere il modello di Ising 2D

    var 
        test: IsingCoord
        clusterSize:int = 1
        stack: seq[IsingCoord] = @[]
        padd = 1 - exp(-2*acc/temp)

        # Genero casualmente una coordinata appartendente al reticolo (sarà lo spin casuale)
        randSpin = rg.newRandomCoord(nspin)

        # Valuto le coordinate dei primi vicini
        upNeigh = newCoord(randSpin.xcoor, (randSpin.ycoor + 1) mod nspin)
        downNeigh = newCoord(randSpin.xcoor, (randSpin.ycoor + nspin - 1) mod nspin)
        leftNeigh = newCoord((randSpin.xcoor + 1) mod nspin, randSpin.ycoor)
        rightNeigh = newCoord((randSpin.xcoor + nspin - 1) mod nspin, randSpin.ycoor)

    #Aggiungo i primi vicini alla stack
    stack.add(upNeigh); stack.add(downNeigh); stack.add(leftNeigh); stack.add(rightNeigh)

    # Cambio l'orientazione dello spin (per evitare se ho già incluso o meno uno spin nel cluster)
    modIsing[randSpin.xcoor][randSpin.ycoor] = - modIsing[randSpin.xcoor][randSpin.ycoor]

    # Continuo fino a quando non ho controllato tutte le possibilità
    while stack.len() > 0:
        test = stack.pop

        # Controllo se per caso ha lo stesso orientamento dello spin di partenza (quindi opposto una 
        # volta effettuato il flip)
        if modIsing[test.xcoor][test.ycoor] != modIsing[randSpin.xcoor][randSpin.ycoor]:

            # Valuto se ha senso aggiungere o meno lo spin (ho una certa probabilità d'accettazione)
            if rg.rand() < padd:
                
                # Aggiungo lo spin nel cluster e inverto lo spin
                clusterSize += 1
                modIsing[test.xcoor][test.ycoor] = - modIsing[test.xcoor][test.ycoor] 

                # Valuto quali siano i primi vicini e aggiungo nella stack
                upNeigh = newCoord(test.xcoor, (test.ycoor + 1) mod nspin); stack.add(upNeigh)
                downNeigh = newCoord(test.xcoor, (test.ycoor + nspin - 1) mod nspin); stack.add(downNeigh)
                leftNeigh = newCoord((test.xcoor + 1) mod nspin, test.ycoor); stack.add(leftNeigh)
                rightNeigh = newCoord((test.xcoor + nspin - 1) mod nspin, test.ycoor); stack.add(rightNeigh)
    
    return clusterSize
