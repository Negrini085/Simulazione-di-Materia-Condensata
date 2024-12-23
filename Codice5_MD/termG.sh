#!/bin/bash

input_file="parameters.5"       # Nome del file di input
gamma_values=(0.5 0.75 1 1.25 1.5) # Valori di gamma da impostare


#---------------------------------------#
#       Ciclo sui valori di gamma       #
#---------------------------------------#

# Ciclo per aggiornare gamma
for i in "${gamma_values[@]}"; do

    # Aggiorno valore di gamma 
    sed -i "s/^gamma\s\+.*/gamma        $i/" "$input_file"

    echo "Studio termalizzazione con gamma = $i"
    ./md.x parameters.5 > "term$i.out"  
    
done
