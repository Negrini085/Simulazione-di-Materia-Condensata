#include "modelXY.h"

int main(){

    // Lettura parametri ed inizializzazione modello
    ModelloXY sistema = ModelloXY("input.dat");
    sistema.stampa_par();

    // Termalizzazione del modello
    // for(int i=0; i<3000; i++) {  }

    // Fase di simulazione, con data-blocking

  return 0;
}


