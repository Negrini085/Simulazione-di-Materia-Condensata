#!/bin/bash

input_file="param.in"                            # Nome del file di input
tempIsing=(2.23)	                         # Temperature a cui simulo il modello
sizeIsing=(100)                                  # Dimensioni del modello di Ising
tlim=2.5
term1=50
term2=10000
lsim=1000000

#---------------------------------------------------------------------#
#       Ciclo sulla dimensione ed eseguo il programma a varie t       #
#---------------------------------------------------------------------#

# Ciclo per aggiornare la dimensione
for ((i=0; i<${#sizeIsing[@]}; i++)); do
    sed -i "s/^nspin\s\+.*/nspin\t\t"${sizeIsing[i]}"/" "$input_file"

    for t in "${tempIsing[@]}"; do
        sed -i "s/^temp\s\+.*/temp\t\t"$t"/" "$input_file"

        if (( $(echo "$t < $tlim" | bc -l) )); then
            sed -i "s/^term\s\+.*/term\t\t"$term1"/" "$input_file"
            ./Ising2D wolff param.in analisi/pcrit/zCrit/obs_size${sizeIsing[i]}_t${t}.out
        else
            sed -i "s/^term\s\+.*/term\t\t"$term2"/" "$input_file"
            sed -i "s/^lsim\s\+.*/lsim\t\t"$lsim"/" "$input_file"
            ./Ising2D metro param.in analisi/pcrit/zCrit/obs_size${sizeIsing[i]}_t${t}.out
        fi      
    done

    dim=${sizeIsing[i]}
    echo "Eseguito studio termalizzazione per dimensione fissata $dim."    
done

echo "Studio della termalizzazione terminato."
