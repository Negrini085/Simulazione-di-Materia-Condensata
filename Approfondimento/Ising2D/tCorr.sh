#!/bin/bash

input_file="param.in"                       # Nome del file di input
tempIsing=(2.1 2.15 2.2 2.25 2.3 2.35)      # Temperature a cui simulo il modello
sizeIsing=(100 200 300 400 500)             # Dimensioni del modello di Ising
rgState=(0 10 20 30)                        # Seed random generator
rgIncr=(5 15 25 35)                         # Incr random generator



#--------------------------------------------------------------------------------#
#       Ciclo sulla dimensione ed eseguo il programma a vari stati del pcg       #
#--------------------------------------------------------------------------------#

# Ciclo per aggiornare la dimensione (e di conseguenza il numero di mosse da fare)
for ((i=0; i<${#sizeIsing[@]}; i++)); do
    sed -i "s/^nspin\s\+.*/nspin\t\t"${sizeIsing[i]}"/" "$input_file"

    for t in "${tempIsing[@]}"; do
        sed -i "s/^temp\s\+.*/temp\t\t"$t"/" "$input_file"

        for ((j=1; j<=${#rgState[@]}; j++)); do
            sed -i "s/^state\s\+.*/state\t\t"${rgState[j-1]}"/" "$input_file"
            sed -i "s/^incr\s\+.*/incr\t\t"${rgIncr[j-1]}"/" "$input_file"

            # Eseguo programma e faccio analisi su tempo di correlazione
            ./Ising2D wolff param.in analisi/wolff/tcorr/tcorr_t${t}_size${sizeIsing[i]}_seed$j.out
       	    echo ""
    	done
    
    done

    dim=${sizeIsing[i]}
    echo ""
    echo "Eseguito studio tempo di correlazione per dimensione fissata $dim."    
done

echo "Studio del tempo di correlazione terminato."
