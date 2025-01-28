#include "modelXY.h"

int main(){

    // Lettura parametri ed inizializzazione modello
    ModelloXY sistema = ModelloXY("input.dat");
    sistema.stampa_par();
    sistema.stampa_mat();
    cout << sistema.getMagnX() << endl;
    cout << sistema.getMagnY() << endl;

    // Termalizzazione del modello
    // for(int i=0; i<3000; i++) {  }

    // Fase di simulazione, con data-blocking

  return 0;
}


