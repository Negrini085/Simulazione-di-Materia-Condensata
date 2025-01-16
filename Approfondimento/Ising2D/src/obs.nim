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
