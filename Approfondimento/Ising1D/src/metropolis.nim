import pcg

proc inizializzaIsing*(rg: var PCG, nspin: int): seq[int] = 
    # Funzione per inizializzare il modello di Ising. Gli spin saranno orientati
    # in modo casuale

    var cont: seq[int]

    for i in 0..(nspin-1):
        # Oriento up oppure down in modo equiprobabile
        if rg.rand < 0.5:
            cont.add(-1)
        else:
            cont.add(1)

    return cont


proc calcolaEnergia*(modIsing: seq[int], acc: float32, magn: float32): float32 = 
    # Funzione per calcolare l'energia del modello di Ising

    var ene: float32 = 0

    for i in 0..<len(modIsing):
        ene -= acc * float32(modIsing[i]) * float32(modIsing[(i+1) mod len(modIsing)]) + magn * float32(modIsing[i])

    return ene