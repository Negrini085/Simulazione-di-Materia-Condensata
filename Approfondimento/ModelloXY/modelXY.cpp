#include "modelXY.h"

int main(){

    // Lettura parametri ed inizializzazione modello
    ModelloXY sistema = ModelloXY("input.dat");
    sistema.stampa_par();

    // Termalizzazione del modello
    for(int i=0; i<100000; i++) {
        sistema.Sweep();
        cout << i+1 << "   " << sistema.getEne() << endl;
    }

  return 0;
}


