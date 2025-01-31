#include "modelXY.h"

int main(int argc, char** argv){

    int nspin;
    double ene = 0;
    double magnY = 0;
    double magnX = 0;

    //File dei parametri
    if(argc != 3){
        cout << "Utilizzo codice: ./modelXY <nome file input> <nome file conf>" << endl;
        return -1;
    }

    // Lettura parametri ed inizializzazione modello
    ModelloXY sistema = ModelloXY(argv[1]);
    sistema.stampa_par();
    
    nspin = sistema.getNspin() * sistema.getNspin();
    
    for(int i=0; i<sistema.getTerm(); i++){ sistema.Sweep(); }

    cout << "# Numero mossa" << "   " << "Energia" << "    " << "Magnetizzazione X" << "    " << "Magnetizzazione Y" << "    " << "Acc. rate" << endl;

    // Termalizzazione del modello
    accettate = 0;
    for(int i=0; i<sistema.getNblk(); i++){

        for(int j=0; j<sistema.getNstep(); j++){
            // Eseguo uno sweep del sistema
            sistema.Sweep();

            ene += sistema.getEne();
            magnX += sistema.getMagnX();
            magnY += sistema.getMagnY();

        }

        // Stampo osservabili
        cout << i+1 << "   " << ene/double(sistema.getNstep()*nspin)  << "  " <<  magnX/double(sistema.getNstep()*nspin) << "   " << magnY/double(sistema.getNstep()*nspin) << endl;
        
        accettate = 0;
        ene = 0;
        magnX = 0;
        magnY = 0;
    }

    sistema.stampa_mat(argv[2]);

  return 0;
}


