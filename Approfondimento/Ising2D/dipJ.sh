#!/bin/bash

input_file="param4.in"      	       					# Nome del file di input
tempIsing=(1.0 1.5 1.55 1.6 1.65 1.7 2.0 2.5 3.0 3.5 4.0)               # Temperature a cui simulo il modello
parJ=(0.77)                            					# Valori del parametro J


#--------------------------------------------------------------------------------#
#       Ciclo sulla dimensione ed eseguo il programma a vari stati del pcg       #
#--------------------------------------------------------------------------------#

# Ciclo per aggiornare la dimensione (e di conseguenza il numero di mosse da fare)
for j in "${parJ[@]}"; do

    # Cambio parametro J
    sed -i "s/^acc\s\+.*/acc\t\t"$j"/" "$input_file"
    for t in "${tempIsing[@]}"; do
        # Cambio temperatura d'esecuzione
        sed -i "s/^temp\s\+.*/temp\t\t"$t"/" "$input_file"
        
        # Eseguo programma e faccio analisi su termalizzazione
        ./dipJ1 wolff param4.in analisi/pcrit/dipJ/dipJ_t${t}_J$j.out
    done
done

echo "Studio della termalizzazione terminato."
