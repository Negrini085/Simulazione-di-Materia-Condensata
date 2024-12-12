#!/bin/bash
input_file="dipT/lammps_"       # Nome del file di input
program="./temporanea/lammps - in"                
num_iterazioni=1000             # Numero di iterazioni
T_values=(25 50 75 100 125 150 175 200 225 250 275 300)  # Valori di temperatura da impostare



#----------------------------------------------------------------#
#       Ciclo sul seed ed eseguo il programma a vari gamma       #
#----------------------------------------------------------------#

# Ciclo per aggiornare il seed
for T in "${T_values[@]}"; do

    echo "Studio del coefficiente di diffusione: temperatura $T Kelvin"

    # Eseguo programma e faccio analisi su distanza quadratica media
    "$program" "$input_file" "$T.in"  
    ./msd2D.awk xy_$T.dat
    mv "msd.dat" "msd_$T.dat"
    
done

echo ""
echo "Processo completato! Eseguito per tutte le temperature."
