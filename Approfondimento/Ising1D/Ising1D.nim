## Ising1D: a Monte Carlo simulation.
const Ising1DVersion* = "Ising1D 0.1.0"


import src/[pcg, paramIn, metropolis]


from std/streams import newFileStream, close, FileStream
from std/strformat import fmt

const Ising1DDoc* = """
Ising1D CLI:

Usage: 
    ./Ising1D help
    ./Ising1D sim <fileParam> [<fileOut>]

Options:
    -h | --help         Display the Ising1D CLI helper screen.
    --version           Display which Ising1D version is being used.

    <fileParam>         File dove sono definiti i parametri caratteristici della simulazione
    <fileOut>           Nome del file di output, dove verranno stampati i valori d'aspettazione
"""

var
    temp, acc, magn: float32
    nspin, lsim, nblk: int
    state, incr: uint64


proc leggiParametri*(par: seq[float32]) = 
    # Funzione per salvare i parametri della simulazione

    if par.len != 8:
        let msg = "Numero di parametri errato. Termino l'esecuzione del programma."
        raise newException(CatchableError, msg)

    else:
        temp = par[0]; acc = par[2]; magn = par[3] 
        nspin = int(par[1]); lsim = int(par[4]); nblk = int(par[5]) 
        state = uint64(par[6]); incr = uint64(par[7]) 
        

proc stampaParametri*(par: seq[float32]) = 
    # Funzione per stampare i parametri della simulazione

    if par.len != 8:
        let msg = "Numero di parametri errato. Termino l'esecuzione del programma."
        raise newException(CatchableError, msg)

    else:
        echo "Parametri simulativi: "
        echo fmt"Temperatura:   {temp} "
        echo fmt"Numero spin:   {nspin} "
        echo fmt"J:   {acc} "
        echo fmt"Campo magnetico esterno:   {magn} "
        echo fmt"Lunghezza simulazione:   {lsim} "
        echo fmt"Numero di blocchi:   {nblk} "
        echo fmt"Stato pcg:   {state} "
        echo fmt"Incremento pcg:   {incr} "



when isMainModule: 
    import docopt
    from std/cmdline import commandLineParams
    from std/os import splitFile

    let args = docopt(Ising1DDoc, argv=commandLineParams(), version=Ising1DVersion)

    #-----------------------------------------#
    #     Opzione per aiuto con i comandi     #
    #-----------------------------------------#
    if args["help"]:
        echo Ising1DDoc
    

    #-----------------------------------------#
    #   Vera e propria simulazione Ising 1D   #
    #-----------------------------------------#
    elif args["sim"]:
        let fileIn = $args["<fileParam>"]

        var
            dMod: DefMod
            fileOut: string
            fStr: FileStream
            inStr: InputStream

        if args["<fileOut>"]: 
            fileOut = $args["<fileOut>"]
        else: 
            fileOut = "obs.out"
                
        fStr = newFileStream(fileIn, fmRead)
        if fStr == nil:
            let msg = "Errore in apertura del file dei parametri. Controllare nome e cammino forniti in input."
            raise newException(CatchableError, msg)


        #---------------------------------------#
        #       Leggo e salvo i parametri       #
        #---------------------------------------# 
        inStr = newInputStream(fStr, fileIn, 4)
        dMod = inStr.parseDefModel()

        leggiParametri(dMod.params)
        stampaParametri(dMod.params)


        var 
            rg = newPCG((state, incr))
            ene: float32
            magn: float32
            isingMod: seq[int]

        isingMod = inizializzaIsing(rg, nspin)     
        