## Ising2D: a Monte Carlo simulation.
const Ising2DVersion* = "Ising2D 0.1.0"

import std/[streams]
import src/[pcg, paramIn, obs, evolutionMethods]

from std/strformat import fmt
from std/strutils import intToStr

const Ising2DDoc* = """
Ising2D CLI:

Usage: 
    ./Ising2D help
    ./Ising2D sim <fileParam> [<fileOut>]

Options:
    -h | --help         Display the Ising2D CLI helper screen.
    --version           Display which Ising2D version is being used.

    <fileParam>         File dove sono definiti i parametri caratteristici della simulazione
    <fileOut>           Nome del file di output, dove verranno stampati i valori d'aspettazione
"""

var
    temp, acc: float32
    nspin, lsim, nblk, term: int
    state, incr: uint64


proc leggiParametri*(par: seq[float32]) = 
    # Funzione per salvare i parametri della simulazione

    if par.len != 8:
        let msg = "Numero di parametri errato. Termino l'esecuzione del programma."
        raise newException(CatchableError, msg)

    else:
        temp = par[0]; acc = par[2]; 
        nspin = int(par[1]); lsim = int(par[3]); nblk = int(par[4]); term = int(par[7]) 
        state = uint64(par[5]); incr = uint64(par[6]) 
        

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
        echo fmt"Lunghezza simulazione:   {lsim} "
        echo fmt"Numero di blocchi:   {nblk} "
        echo fmt"Stato pcg:   {state} "
        echo fmt"Incremento pcg:   {incr} "
        echo fmt"Fase di termalizzazione:   {term} "


proc inizioStampaTerm*(streamOut: FileStream; eneblk, magnblk: float32) = 
    # Funzione per intestazione del file di output

    if not isNil(streamOut):
        streamOut.writeLine("# Simulazione modello di Ising 1D")
        streamOut.writeLine("# Mossa \t Energia \t Magnetizzazione")
        streamOut.writeLine(fmt"1     {eneblk}      {magnblk}")

    else:
        let msg = "Errore in apertura del file di output! Termino esecuzione del programma."
        raise newException(CatchableError, msg)


proc stampaTerm*(streamOut: FileStream, nmove: int, eneblk, magnblk: float32) = 
    # Funzione per intestazione del file di output

    if not isNil(streamOut):
        streamOut.writeLine(fmt"{nmove}     {eneblk}      {magnblk}")

    else:
        let msg = "Errore in apertura del file di output! Termino esecuzione del programma."
        raise newException(CatchableError, msg)


proc inizioStampaObs*(streamOut: FileStream; eneblk, magnblk, cpblk, chiblk: float32) = 
    # Funzione per intestazione del file di output

    if not isNil(streamOut):
        streamOut.writeLine("# Simulazione modello di Ising 1D")
        streamOut.writeLine("# Mossa \t Energia \t Magnetizzazione \t Calore specifico \t Suscettività")
        streamOut.writeLine(fmt"1     {eneblk}      {magnblk}     {cpblk}     {chiblk}")

    else:
        let msg = "Errore in apertura del file di output! Termino esecuzione del programma."
        raise newException(CatchableError, msg)


proc stampaObs*(streamOut: FileStream, nmove: int, eneblk, magnblk, cpblk, chiblk: float32) = 
    # Funzione per intestazione del file di output

    if not isNil(streamOut):
        streamOut.writeLine(fmt"{nmove}     {eneblk}      {magnblk}     {cpblk}     {chiblk}")

    else:
        let msg = "Errore in apertura del file di output! Termino esecuzione del programma."
        raise newException(CatchableError, msg)


proc stampaConf*(streamOut: FileStream, isingMod: seq[int]) = 
    # Funzione per stampare la configurazione iniziale

    if not isNil(streamOut):
        var conf: string = ""
        for i in isingMod:
            conf = conf & intToStr(i) & "    "

        streamOut.writeLine(conf)

    else:
        let msg = "Errore in apertura del file di output! Termino esecuzione del programma."
        raise newException(CatchableError, msg)










when isMainModule: 
    import docopt
    from std/cmdline import commandLineParams
    from std/os import splitFile

    let args = docopt(Ising2DDoc, argv=commandLineParams(), version=Ising2DVersion)

    #-----------------------------------------#
    #     Opzione per aiuto con i comandi     #
    #-----------------------------------------#
    if args["help"]:
        echo Ising2DDoc
    

    #-----------------------------------------#
    #   Vera e propria simulazione Ising 2D   #
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

        if lsim < nblk: 
            let msg = "Numero di blocchi maggiore del numero di mosse costituenti la simulazione. Termino l'esecuzione del programma"
            raise newException(CatchableError, msg)

        var 
            rg = newPCG((state, incr))
            appo: float32
            eneblk: float32 = 0
            magnblk: float32 = 0
            accettate: int = 0
            isingMod: seq[seq[int]]
            lenBlk = int(lsim/nblk)

            obsOut = newFileStream(fileOut, fmWrite)
            # confOut = newFileStream("confTerm.dat", fmWrite)



        #----------------------------------------------------------------#
        #       Inizializzazione modello di Ising, termalizzazione       #
        #               e calcolo delle osservabili iniziali             #
        #----------------------------------------------------------------#
        echo "\n\nInizio la termalizzazione del modello di Ising"
        isingMod = inizializzaIsing(rg, nspin)    


        #-------------------------------------------------------#
        #         Evoluzione del sistema con Metropolis         #
        #-------------------------------------------------------#
        # echo "\n\nInizio la simulazione del modello di Ising"
        accettate = 0      # Solo da qui mi interessa tener conto dell'acceptance rate
        for i in 0..<lsim:
            isingMod.metropolisMove(rg, temp, acc, nspin, accettate)
            echo fmt"Effettuata la mossa: {i+1}"

            # Energia             
            eneblk = isingMod.calcolaEnergia(nspin, acc)/float32(nspin * nspin)
            magnblk = isingMod.calcolaMagn(nspin)/float32(nspin * nspin)

            if i == 0:
                obsOut.iniziostampaTerm(eneblk, magnblk)
            else:
                obsOut.stampaTerm(i+1, eneblk, magnblk)
        

        obsOut.close()
        # confOut.close()