#!/bin/bash

input_file="parameters.5"       # Nome del file di input
output_file="results.dat"       # Nome del file di output dove salvare i risultati
program="./md.x"                
num_iterazioni=100            # Numero di iterazioni



#---------------------------------------------------#
#       Check prima dell'esecuzione del ciclo       #
#---------------------------------------------------#  

if [ ! -f "$input_file" ]; then
    echo "Errore: il file di input '$input_file' non esiste!"
    exit 1
fi

if [ ! -x "$program" ]; then
    echo "Errore: il programma '$program' non è eseguibile!"
    exit 1
fi




> "$output_file"

#----------------------------------------------------------------#
#       Ciclo sul seed ed eseguo il programma a vari gamma       #
#----------------------------------------------------------------#
# Ciclo per aggiornare il seed
for i in $(seq 1 $num_iterazioni); do
    seed=$((10*i + 20)) 

    # Aggiorno valore del seed
    sed -i "s/^seed\s\+.*/seed        $seed/" "$input_file"

    echo "Iterazione $i: aggiornato seed = $seed"

    "$program" "$input_file" > "output_$i.dat"  
    result=$(awk 'NR>250{a = a + $5 + 0.0; n++} END {print a/n}' output_$i.dat)

    if [ $((i%10)) != 0 ]; then
        rm output_$i.dat
    fi

    # Stampo valori a file e a terminale
    echo "$result" >> "$output_file"
    
done
mean=$(awk '{a = a + $1 + 0.0; n++} END {print a/n}' results.dat)

echo ""
echo "Processo completato! Eseguito per $num_iterazioni iterazioni."
echo "I risultati sono stati salvati in: $output_file"
echo "La lunghezza media della catena è pari a: $mean"
