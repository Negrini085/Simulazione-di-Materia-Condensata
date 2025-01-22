import std/sequtils

proc calcolaEnergia*(modIsing: seq[seq[int]], nspin: int, acc: float32): float32 = 
    # Funzione per calcolare l'energia del modello di Ising

    var ene: float32 = 0

    for i in 0..<nspin:
        for j in 0..<nspin:
            # Interazione orizzontale
            ene -= acc * float32(modIsing[i][j] * modIsing[i][(j+1) mod nspin])
            # Interazione verticale
            ene -= acc * float32(modIsing[j][i] * modIsing[(j+1) mod nspin][i])

    return ene


proc calcolaMagn*(modIsing: seq[seq[int]], nspin: int): float32 = 
    # Funzione per calcolare la magnetizzazione del modello di Ising

    var magn: int = 0

    for i in 0..<nspin:
        for j in 0..<nspin:
            magn += modIsing[i][j]

    return float32(magn)


proc individuaClust*(modIsing: seq[seq[int]], nspin: int): seq[int] = 
    # Funzione per calcolare la dimensione dei cluster (e distinguere i cluster)

    var
        appo: IsingCoord
        startSpin: IsingCoord
        stack: seq[IsingCoord]

        upNeigh, downNeigh: IsingCoord
        leftNeigh, rightNeigh: IsingCoord
        
        current_lab: int = 1
        labels: seq[seq[int]] = newSeqWith(nspin, newSeqWith(nspin, 0))

    # Leggo la matrice delle labels per poter individuare tutti i possibili cluster
    for i in 0..<nspin:
        for j in 0..<nspin:
            
            # Controllo se lo spin in analisi ha già ricevuto una label o meno
            if labels[i][j] == 0:

                # In questo caso devo iniziare a controllare quali spin appartengano allo stesso cluster di quello che stiamo 
                # prendendo in considerazione. Per iniziare il ciclo aggiungo alla stack la coordinata che abbiamo individuato
                # avere label nulla
                stack.add(newCoord(i, j))


                # Procediamo ora con la ricerca degli altri membri del cluster
                while stack.len() > 0:
                
                    # Considero un elemento che fa parte della stack
                    appo = stack.pop()

                    # Aggiungo al cluster in base all'orientamento e in base alla label
                    if modIsing[appo.xcoor][appo.ycoor] == modIsing[i][j] and labels[appo.xcoor][appo.ycoor] == 0:
                    
                        # Aggiorno la label del modello
                        labels[appo.xcoor][appo.ycoor] = current_lab

                        # Valuto i suoi primi vicini, da aggiungere alla stack
                        upNeigh = newCoord(appo.xcoor, (appo.ycoor + 1) mod nspin)
                        downNeigh = newCoord(appo.xcoor, (appo.ycoor + nspin - 1) mod nspin)
                        leftNeigh = newCoord((appo.xcoor + 1) mod nspin, appo.ycoor)
                        rightNeigh = newCoord((appo.xcoor + nspin - 1) mod nspin, appo.ycoor)

                        # Aggiungo i primi vicini alla stack
                        stack.add(upNeigh); stack.add(downNeigh); stack.add(leftNeigh); stack.add(rightNeigh)


                # Una volta terminato il ciclo, e quindi l'individuazione del cluster, aggiorniamo il valore della label
                current_lab += 1
            
