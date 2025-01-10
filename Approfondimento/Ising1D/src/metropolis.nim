from std/math import exp

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


proc calcolaMagn*(modIsing: seq[int]): float32 = 
    # Funzione per calcolare la magnetizzazione del modello di Ising

    var magn: int = 0

    for i in 0..<len(modIsing):
        magn += modIsing[i]

    return float32(magn)/float32(modIsing.len())


proc metropolisMove*(modIsing: var seq[int], rg: var PCG, temp: float32, acc: float32, magn: float32, accettate: var int) = 
    # Algoritmo di Metropolis per evolvere il modello di Ising

    # Indice per selezionare lo spin
    var 
        ind = int(rg.rand(float32(0), float32(len(modIsing))))
        diffE = 2 * acc * float32(modIsing[ind]) * float32(modIsing[(ind - 1) mod len(modIsing)] + modIsing[(ind + 1) mod len(modIsing)]) + magn * float32(modIsing[ind])
    
    if diffE < 0:
        modIsing[ind] *= -1
        accettate += 1

    elif rg.rand() < exp(-diffE/temp):
        modIsing[ind] *= -1
        accettate += 1
