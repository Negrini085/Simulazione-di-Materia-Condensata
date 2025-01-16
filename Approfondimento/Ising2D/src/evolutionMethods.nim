from std/sequtils import newSeqWith

import pcg

proc inizializzaIsing*(rg: var PCG, nspin: int): seq[seq[int]] = 
    # Funzione per inizializzare il modello di Ising. Gli spin saranno orientati
    # in modo casuale

    var model: seq[seq[int]]

    # Inizializzo il modello
    for i in 0..<nspin:
        model.add(newSeqWith(nspin, if rg.rand < 0.5: -1 else: 1))

    return model

