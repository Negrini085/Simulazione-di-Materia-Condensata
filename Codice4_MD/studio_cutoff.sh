#!/bin/bash

input_file="parameters.4"                       # Nome del file di input
program="./md.x"                                # Programma da eseguire
program_prof="gprof ./md.x"                     # Programma per profiling
cutoff=(0.5 0.75 1 1.25 1.5 1.75 2)       # Valori di cutoff da impostare


#---------------------------------------------------#
#       Check prima dell'esecuzione del ciclo       #
#---------------------------------------------------#  

# Controlla se il file di input esiste
if [ ! -f "$input_file" ]; then
    echo "Errore: il file di input '$input_file' non esiste!"
    exit 1
fi

# Controlla se il programma eseguibile esiste
if [ ! -x "$program" ]; then
    echo "Errore: il programma '$program' non è eseguibile!"
    exit 1
fi



#-----------------------------------------------#
#               Ciclo sul cutoff                #
#-----------------------------------------------#
for cut in "${cutoff[@]}"; do

    # Aggiorna il valore del cutoff nel file di input
    sed -i "s/^cutoff\s\+.*/cutoff        $cut/" "$input_file"
    echo "Aggiornato cutoff = $cut"

    # Esegui il programma e salva l'output
    "$program" "$input_file" > "cutoff/r_cut/output.$cut.dat" 
    gprof ./md.x | head -18 > "cutoff/r_cut/prof.$cut.dat"

    echo ""
    echo ""
done

echo "Processo completato!"
