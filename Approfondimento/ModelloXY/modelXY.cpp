#include "modelXY.h"

int main(int argc, char** argv){

    //File dei parametri
    if(argc != 2){
        cout << "Utilizzo codice: ./modelXY <nome file input>" << endl;
        return -1;
    }

    // Lettura parametri ed inizializzazione modello
    ModelloXY sistema = ModelloXY(argv[1]);
    sistema.stampa_par();

    cout << "Numero mossa" << "   " << "Energia" << "    " << "Magnetizzazione X" << "    " << "Magnetizzazione Y" << "    " << "Acc. rate" << endl;
    
    for(int i=0; i<sistema.getTerm(); i++){ sistema.Sweep(); }

    // Termalizzazione del modello
    for(int i=0; i<sistema.getNstep(); i++){
        // Eseguo uno sweep del sistema
        sistema.Sweep();

        // Stampo osservabili
        cout << i+1 << "   " << sistema.getEne()  << "  " << sistema.getMagnX() << "   " << sistema.getMagnY() << "   " << accettate*100/(sistema.getNspin() * sistema.getNspin()) << endl;
        accettate = 0;
    }

  return 0;
}


