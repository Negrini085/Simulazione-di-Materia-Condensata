#!/bin/bash

input_file="parameters.5"       # Nome del file di input
mass_values=(5 7.5 10 12.5 15) # Valori di massa da impostare
gamma_values=(0.5 0.75 1 1.25 1.5) # Valori di gamma da impostare


#---------------------------------------#
#       Ciclo sui valori di gamma       #
#---------------------------------------#

# Ciclo per aggiornare il seed
for i in "${gamma_values[@]}"; do

    # Aggiorno valore di gamma 
    sed -i "s/^gamma\s\+.*/gamma        $i/" "$input_file"

    # Ciclo per aggiornare massa costituenti
    for j in "${mass_values[@]}"; do
        # Aggiorno valore di massa 
        sed -i "s/^mass\s\+.*/mass        $j/" "$input_file"
        ./md.x parameters.5 > "fit_g$i-m$j.out"  
    
    done
    
done
