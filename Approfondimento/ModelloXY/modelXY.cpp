#include "modelXY.h"

int main(int argc, char** argv){

    double ene = 0;
    double magnY = 0;
    double magnX = 0;

    //File dei parametri
    if(argc != 3){
        cout << "Utilizzo codice: ./modelXY <nome file input> <nome file conf>" << endl;
        return -1;
    }

    // Lettura parametri ed inizializzazione modello
    ModelloXY sistema = ModelloXY(argv[1], "conf.dat");
    sistema.stampa_par();
    sistema.stampa_mat();

//    cout << "Numero mossa" << "   " << "Energia" << "    " << "Magnetizzazione X" << "    " << "Magnetizzazione Y" << "    " << "Acc. rate" << endl;
    
    for(int i=0; i<sistema.getTerm(); i++){ sistema.Sweep(); }
    sistema.stampa_mat();

//
//    // Termalizzazione del modello
//    accettate = 0;
//    for(int i=0; i<sistema.getNblk(); i++){
//
//        for(int j=0; j<sistema.getNstep(); j++){
//            // Eseguo uno sweep del sistema
//            sistema.Sweep();
//
//            ene += sistema.getEne();
//            magnX += sistema.getMagnX();
//            magnY += sistema.getMagnY();
//
//        }
//
//        // Stampo osservabili
//        cout << i+1 << "   " << ene/double(sistema.getNstep())  << "  " <<  magnX/double(sistema.getNstep()) << "   " << magnY/double(sistema.getNstep()) << endl;
//        
//        accettate = 0;
//        ene = 0;
//        magnX = 0;
//        magnY = 0;
//    }
//
//    sistema.stampa_mat();

  return 0;
}


