## Ising1D: a Monte Carlo simulation.
const Ising1DVersion* = "Ising1D 0.1.0"

import std/[streams]
import src/[pcg, paramIn, metropolis]

from std/math import pow
from std/strformat import fmt
from std/strutils import intToStr

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
    temp, acc, hmagn: float32
    nspin, lsim, nblk, term: int
    state, incr: uint64


proc leggiParametri*(par: seq[float32]) = 
    # Funzione per salvare i parametri della simulazione

    if par.len != 9:
        let msg = "Numero di parametri errato. Termino l'esecuzione del programma."
        raise newException(CatchableError, msg)

    else:
        temp = par[0]; acc = par[2]; hmagn = par[3] 
        nspin = int(par[1]); lsim = int(par[4]); nblk = int(par[5]); term = int(par[8]) 
        state = uint64(par[6]); incr = uint64(par[7]) 
        

proc stampaParametri*(par: seq[float32]) = 
    # Funzione per stampare i parametri della simulazione

    if par.len != 9:
        let msg = "Numero di parametri errato. Termino l'esecuzione del programma."
        raise newException(CatchableError, msg)

    else:
        echo "Parametri simulativi: "
        echo fmt"Temperatura:   {temp} "
        echo fmt"Numero spin:   {nspin} "
        echo fmt"J:   {acc} "
        echo fmt"Campo magnetico esterno:   {hmagn} "
        echo fmt"Lunghezza simulazione:   {lsim} "
        echo fmt"Numero di blocchi:   {nblk} "
        echo fmt"Stato pcg:   {state} "
        echo fmt"Incremento pcg:   {incr} "
        echo fmt"Fase di termalizzazione:   {term} "


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

        if lsim < nblk: 
            let msg = "Numero di blocchi maggiore del numero di mosse costituenti la simulazione. Termino l'esecuzione del programma"
            raise newException(CatchableError, msg)

        var 
            rg = newPCG((state, incr))
            appo: float32
            cpblk: float32
            chiblk: float32
            eneblk: float32 = 0
            ene2blk: float32 = 0
            magnblk: float32 = 0
            magn2blk: float32 = 0
            accettate: int = 0
            isingMod: seq[int]
            lenBlk = int(lsim/nblk)

            obsOut = newFileStream(fileOut, fmWrite)
            # confOut = newFileStream("confTerm.dat", fmWrite)



        #----------------------------------------------------------------#
        #       Inizializzazione modello di Ising, termalizzazione       #
        #               e calcolo delle osservabili iniziali             #
        #----------------------------------------------------------------#
        echo "\n\nInizio la termalizzazione del modello di Ising"
        isingMod = inizializzaIsing(rg, nspin)

        for i in 0..<term:
            # confOut.stampaConf(isingMod)
            isingMod.metropolisMove(rg, temp, acc, hmagn, accettate)
    


        #-------------------------------------------------------#
        #         Evoluzione del sistema con Metropolis         #
        #-------------------------------------------------------#
        echo "\n\nInizio la simulazione del modello di Ising"
        accettate = 0      # Solo da qui mi interessa tener conto dell'acceptance rate
        for i in 0..<nblk:

            #---------------------------------------------------#
            #       Studio osservabili nel singolo blocco       #
            #---------------------------------------------------#
            for j in 0..<lenBlk:
                isingMod.metropolisMove(rg, temp, acc, hmagn, accettate)

                # Energia 
                appo = isingMod.calcolaEnergia(acc, hmagn)
                eneblk += appo/float32(lenBlk)
                ene2blk += appo*appo/float32(lenBlk)

                # Magnetizzazione
                appo = isingMod.calcolaMagn()
                magnblk += appo/float32(lenBlk)
                magn2blk += appo*appo/float32(lenBlk)
            
            eneblk = eneblk/float32(isingMod.len())
            magnblk = magnblk/float32(isingMod.len())

            cpblk = 1/(temp * temp) * (ene2blk - pow(eneblk * float32(nspin), 2))/float32(nspin)
            chiblk = 1/(temp * temp) * (magn2blk - pow(magnblk * float32(nspin), 2))/float32(nspin)

            if i != 0:
                obsOut.stampaObs(i+1, eneblk, magnblk, cpblk, chiblk)
            else:    
                obsOut.inizioStampaObs(eneblk, magnblk, cpblk, chiblk)
            
            echo "-----------------------------------------------"
            echo ""
            echo fmt"          Numero blocco: {i+1}" 
            echo fmt"       Acceptance rate: {int(float32(accettate)/float32(lenBlk*nspin)*10000)/100} %" 
            echo ""
            echo "-----------------------------------------------"

            eneblk = 0
            ene2blk = 0
            magnblk = 0
            magn2blk = 0
            accettate = 0
        

        obsOut.close()
        # confOut.close()
