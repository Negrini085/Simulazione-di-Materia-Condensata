#!/bin/bash

input_file="parameters.1"       # Nome del file di input
output_file="results.dat"       # Nome del file di output dove salvare i risultati
program="./mc.x"                
num_iterazioni=1000             # Numero di iterazioni
gamma_values=(0.05 0.075 0.1 0.125 0.15 0.175 0.2 0.225 0.25 0.275 0.3)  # Valori di gamma da impostare





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

    result=""
    # Ciclo interno per variare gamma a seme fissato
    for gamma in "${gamma_values[@]}"; do
        sed -i "s/^gamma\s\+.*/gamma\t\t$gamma/" "$input_file"

        # Eseguo programma e faccio analisi su termalizzazione
        "$program" "$input_file" > "output.dat"  
        sum=$(awk 'NR>1&&$6+0.0<100{a = a + $7} $6+0.0>100{exit} END {print a}' output.dat)

        if [[ -n "$sum" ]]; then
            result="$result$sum "
        else
            result="$result0 "
        fi
    done

    # Stampo valori a file e a terminale
    echo "$result" >> "$output_file"

    echo "Risultati per seed $seed: $result"
    echo ""  
    
done

echo ""
echo "Processo completato! Eseguito per $num_iterazioni iterazioni."
echo "I risultati sono stati salvati in: $output_file"
