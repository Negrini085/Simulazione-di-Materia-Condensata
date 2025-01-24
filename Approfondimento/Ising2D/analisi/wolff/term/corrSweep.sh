#!/bin/bash

tempIsing=(2.4)	                        	     # Temperature a cui simulo il modello
sizeIsing=(100 200 300)                          # Dimensioni del modello di Ising

#---------------------------------------------------------------------#
#       Ciclo sulla dimensione ed eseguo il programma a varie t       #
#---------------------------------------------------------------------#

# Ciclo per aggiornare la dimensione
for ((i=0; i<${#sizeIsing[@]}; i++)); do
    for t in "${tempIsing[@]}"; do
        for ((j=1; j<=4; j++)); do

            # Determino dimensione media del cluster
            nspin=${sizeIsing[i]}
            dimcl=$(LC_NUMERIC=C awk -v nspin="$nspin" 'NR>2{a = a + $4; n++;} END {print (a/n) / (nspin * nspin)}' term_t${t}_size${sizeIsing[i]}_seed${j}.out)

            # Divido il numero di mosse per l'opportuno fattore
            LC_NUMERIC=C awk -v dim="$dimcl" 'NR<=2{print}NR>2{print $1*dim, $2, $3, $4}' term_t${t}_size${sizeIsing[i]}_seed${j}.out >  appo_t${t}_size${sizeIsing[i]}_seed${j}.out
        
            # Sostituisco il file degli osservabili con quello modificato
            rm term_t${t}_size${sizeIsing[i]}_seed${j}.out
            mv appo_t${t}_size${sizeIsing[i]}_seed${j}.out term_t${t}_size${sizeIsing[i]}_seed${j}.out
        done
    done

    dim=${sizeIsing[i]}
    echo "Eseguito studio termalizzazione per dimensione fissata $dim."    
done

echo "Studio della termalizzazione terminato."
