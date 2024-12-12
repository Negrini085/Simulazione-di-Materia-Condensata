#!/bin/bash         
T_values=(25 50 75 100 125 150 175 200 225 250 275 300)  # Valori di temperatura da impostare



#------------------------------------------------#
#       Studio coefficiente di diffusione        #
#------------------------------------------------#

# Ciclo per aggiornare il seed
for T in "${T_values[@]}"; do

    awk '{print $1, $2}' msd_$T.dat > msd_py_$T.dat
    
done

echo ""
echo "Processo completato! Eseguito per tutte le temperature."
