#!/bin/bash

input_file="param1.in"                                                          # Nome del file di input
tempIsing=(0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0)     # Temperature a cui simulo il modello
sizeIsing=(1000 3000 6000 10000)                                                # Dimensioni del modello di Ising

t_s=1.0 
l1=5000000
l2=500000 
#---------------------------------------------------------------------#
#       Ciclo sulla dimensione ed eseguo il programma a varie t       #
#---------------------------------------------------------------------#

# Ciclo per aggiornare la dimensione
for ((i=0; i<${#sizeIsing[@]}; i++)); do
    sed -i "s/^nspin\s\+.*/nspin\t\t"${sizeIsing[i]}"/" "$input_file"

    for t in "${tempIsing[@]}"; do
        sed -i "s/^temp\s\+.*/temp\t\t"$t"/" "$input_file"
        
        if (( $(echo "$t < $t_s" | bc -l) )); then
            sed -i "s/^lsim\s\+.*/lsim\t\t"$l1"/" "$input_file"
        else
            sed -i "s/^lsim\s\+.*/lsim\t\t"$l2"/" "$input_file"
        fi


	    # Eseguo programma per determinazione osservabili
        ./Ising1D sim param1.in analisi/magn0.0/obs/obs_size${sizeIsing[i]}_t${t}.out
    
    done

    dim=${sizeIsing[i]}
    echo "Eseguito studio osservabili per dimensione fissata $dim."    
done

echo "Studio osservabili terminato."
