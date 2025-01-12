#/bin/bash

input_file="param.in"       # Nome del file di input
tempIsing=(0.5 1.0 1.5 2.0)                 # Temperature a cui simulo il modello
sizeIsing=(1000 3000 6000 10000)            # Dimensioni del modello di Ising

#--------------------------------------------------------------------------------#
#       Ciclo sulla dimensione ed eseguo il programma a vari stati del pcg       #
#--------------------------------------------------------------------------------#

# Ciclo per aggiornare la dimensione (e di conseguenza il numero di mosse da fare)
for ((i=0; i<${#sizeIsing[@]}; i++)); do
    sed -i "s/^nspin\s\+.*/nspin\t\t"${sizeIsing[i]}"/" "$input_file"

    for t in "${tempIsing[@]}"; do
        sed -i "s/^temp\s\+.*/temp\t\t"$t"/" "$input_file"

        # Eseguo programma e faccio analisi su lunghezza dei blocchi
        ./Ising1D sim param.in analisi/lblk/lblk_t${t}_size${sizeIsing[i]}.out
       	echo ""
    	done
    
    done

    dim=${sizeIsing[i]}
    echo ""
    echo "Eseguito studio lunghezza dei blocchi per dimensione fissata $dim."    
done

echo "Studio della lunghezza dei blocchi terminato."
