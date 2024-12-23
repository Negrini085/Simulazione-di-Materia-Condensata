#!/bin/bash

N=100
input_file="parameters.6"       # Nome del file di input

#-----------------------------------------------------------#
#       Ciclo per il numero di simulazioni necessario       #
#-----------------------------------------------------------#


for ((i=34; i<=N; i++)); do

    ./md.x $input_file > "rateCalc/refolding_$i.out"  
        
done
