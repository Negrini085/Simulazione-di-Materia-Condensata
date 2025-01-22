## Ising2D: a Monte Carlo simulation.
const Ising2DVersion* = "Ising2D 0.1.0"

import std/[streams]
import src/[pcg, paramIn, obs, evolutionMethods]

from std/math import pow
from std/strformat import fmt
from std/strutils import intToStr

const Ising2DDoc* = """
Ising2D CLI:

Usage: 
    ./Ising2D help
    ./Ising2D metro <fileParam> [<fileOut> <confOut>]
    ./Ising2D wolff <fileParam> [<fileOut> <confOut>]

Options:
    -h | --help         Display the Ising2D CLI helper screen.
    --version           Display which Ising2D version is being used.

    <fileParam>         File dove sono definiti i parametri caratteristici della simulazione
    <fileOut>           Nome del file di output, dove verranno stampati i valori d'aspettazione
    <confOut>           Nome del file di output per la stampa della configurazione
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


proc inizioStampaWolffObs*(streamOut: FileStream; eneblk, magnblk, cpblk, chiblk, dimclblk: float32) = 
    # Funzione per intestazione del file di output

    if not isNil(streamOut):
        streamOut.writeLine("# Simulazione modello di Ising 1D")
        streamOut.writeLine("# Mossa \t Energia \t Magnetizzazione \t Calore specifico \t Suscettività \t Dimensione cluster")
        streamOut.writeLine(fmt"1     {eneblk}      {magnblk}     {cpblk}     {chiblk}     {dimclblk}")

    else:
        let msg = "Errore in apertura del file di output! Termino esecuzione del programma."
        raise newException(CatchableError, msg)


proc stampaWolffObs*(streamOut: FileStream, nmove: int, eneblk, magnblk, cpblk, chiblk, dimclblk: float32) = 
    # Funzione per intestazione del file di output

    if not isNil(streamOut):
        streamOut.writeLine(fmt"{nmove}     {eneblk}      {magnblk}     {cpblk}     {chiblk}     {dimclblk}")

    else:
        let msg = "Errore in apertura del file di output! Termino esecuzione del programma."
        raise newException(CatchableError, msg)


proc stampaConf*(streamOut: FileStream, isingMod: seq[seq[int]], nspin: int) = 
    # Funzione per stampare la configurazione iniziale

    if not isNil(streamOut):
        var conf: string
        for i in 0..<nspin:
            conf = ""
            for j in 0..<nspin:
                conf = conf & intToStr(isingMod[i][j]) & "    "

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










    #-----------------------------------------------#
    #   Simulazione Ising 2D algoritmo metropolis   #
    #-----------------------------------------------#
    elif args["metro"]:
        let fileIn = $args["<fileParam>"]

        var
            dMod: DefMod
            fileOut: string
            confFile: string
            fStr: FileStream
            inStr: InputStream

        if args["<fileOut>"]: 
            fileOut = $args["<fileOut>"]
        else: 
            fileOut = "obs.out"

        if args["<confOut>"]: 
            confFile = $args["<confOut>"]
        else: 
            confFile = "conf.out"
                
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
            tc = 2.27
            rg = newPCG((state, incr))
            appo: float32
            cpblk: float32
            chiblk: float32
            eneblk: float32 = 0
            ene2blk: float32 = 0
            magnblk: float32 = 0
            magn2blk: float32 = 0
            accettate: int = 0
            isingMod: seq[seq[int]]
            lenBlk = int(lsim/nblk)

            obsOut = newFileStream(fileOut, fmWrite)
            #confOut = newFileStream(confFile, fmWrite)



        #----------------------------------------------------------------#
        #       Inizializzazione modello di Ising, termalizzazione       #
        #               e calcolo delle osservabili iniziali             #
        #----------------------------------------------------------------#
        echo "\n\nStudio con algoritmo di Metropolis"
        echo "Inizio la termalizzazione del modello di Ising"
        isingMod = inizializzaIsing(nspin)    

        for i in 0..term:
            isingMod.metropolisMove(rg, temp, acc, nspin, accettate)
    
        # Stampa della configurazione termalizzata
        # confOut.stampaConf(isingMod, nspin) 


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
                isingMod.metropolisMove(rg, temp, acc, nspin, accettate)

                # Energia 
                appo = isingMod.calcolaEnergia(nspin, acc)
                eneblk += appo/float32(lenBlk)
                ene2blk += appo*appo/float32(lenBlk)

                # Magnetizzazione
                appo = isingMod.calcolaMagn(nspin)
                magnblk += appo/float32(lenBlk)
                magn2blk += appo*appo/float32(lenBlk)
          
            
            cpblk = 1/(temp * temp) * (ene2blk - pow(eneblk, 2))/float32(nspin * nspin)
            chiblk = 1/(temp) * (magn2blk - pow(magnblk, 2))/float32(nspin * nspin)

            eneblk = eneblk/float32(nspin * nspin)
            magnblk = magnblk/float32(nspin * nspin)

            if i != 0:
                obsOut.stampaObs(i+1, eneblk, magnblk, cpblk, chiblk)
            else:    
                obsOut.inizioStampaObs(eneblk, magnblk, cpblk, chiblk)
            
            echo "-----------------------------------------------"
            echo ""
            echo fmt"          Numero blocco: {i+1}" 
            echo fmt"       Acceptance rate: {int(float32(accettate)/float32(lenBlk*nspin*nspin)*10000)/100} %" 
            echo ""
            echo "-----------------------------------------------"

            eneblk = 0
            ene2blk = 0
            magnblk = 0
            magn2blk = 0
            accettate = 0
        

        obsOut.close()
        #confOut.close()









    #-------------------------------------------------#
    #   Simulazione Ising 2D con algoritmo di Wolff   #
    #-------------------------------------------------#
    elif args["wolff"]:
        let fileIn = $args["<fileParam>"]

        var
            dMod: DefMod
            fileOut: string
            confFile: string
            fStr: FileStream
            inStr: InputStream

        if args["<fileOut>"]: 
            fileOut = $args["<fileOut>"]
        else: 
            fileOut = "obs.out"

        if args["<confOut>"]: 
            confFile = $args["<confOut>"]
        else: 
            confFile = "conf.out"
                
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
            tc = 2.27
            rg = newPCG((state, incr))
            appo: float32
            cpblk: float32
            chiblk: float32
            dimclblk: int = 0
            eneblk: float32 = 0
            ene2blk: float32 = 0
            magnblk: float32 = 0
            magn2blk: float32 = 0
            isingMod: seq[seq[int]]
            lenBlk = int(lsim/nblk)

            obsOut = newFileStream(fileOut, fmWrite)
            confOut = newFileStream(confFile, fmWrite)



        #----------------------------------------------------------------#
        #       Inizializzazione modello di Ising, termalizzazione       #
        #               e calcolo delle osservabili iniziali             #
        #----------------------------------------------------------------#
        echo "\n\nStudio con algoritmo di Wolff"
        echo "Inizio la termalizzazione del modello di Ising"
        isingMod = inizializzaIsing(nspin)    

        for i in 0..term:
            dimclblk = isingMod.wolffMove(rg, temp, acc, nspin)

        # Stampa della configurazione termalizzata
        # confOut.stampaConf(isingMod, nspin) 

        #--------------------------------------------------#
        #         Evoluzione del sistema con Wolff         #
        #--------------------------------------------------#
        echo "\n\nInizio la simulazione del modello di Ising"
        for i in 0..<nblk:
            
            dimclblk = 0
            #---------------------------------------------------#
            #       Studio osservabili nel singolo blocco       #
            #---------------------------------------------------#
            for j in 0..<lenBlk:
                dimclblk += isingMod.wolffMove(rg, temp, acc, nspin)

                # Energia 
                appo = isingMod.calcolaEnergia(nspin, acc)
                eneblk += appo/float32(lenBlk)
                ene2blk += appo*appo/float32(lenBlk)

                # Magnetizzazione
                appo = isingMod.calcolaMagn(nspin)
                magnblk += appo/float32(lenBlk)
                magn2blk += appo*appo/float32(lenBlk)


            cpblk = 1/(temp * temp) * (ene2blk - pow(eneblk, 2))/float32(nspin * nspin)
            chiblk = 1/(temp) * (magn2blk - pow(magnblk, 2))/float32(nspin * nspin)

            eneblk = eneblk/float32(nspin * nspin)
            magnblk = magnblk/float32(nspin * nspin)

            if i != 0:
                obsOut.stampaWolffObs(i+1, eneblk, magnblk, cpblk, chiblk, float32(dimclblk)/float32(lenBlk))
            else:    
                obsOut.inizioStampaWolffObs(eneblk, magnblk, cpblk, chiblk, float32(dimclblk)/float32(lenBlk))
            
            echo "-----------------------------------------------"
            echo ""
            echo fmt"          Numero blocco: {i+1}" 
            echo ""
            echo "-----------------------------------------------"

            eneblk = 0
            ene2blk = 0
            magnblk = 0
            magn2blk = 0
        

        obsOut.close()
        confOut.close()
