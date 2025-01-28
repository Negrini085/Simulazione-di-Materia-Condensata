#ifndef __ISING__
#define __ISING__

#include <iostream>
#include <fstream>
#include <ostream>
#include <cmath>
#include <iomanip>

using namespace std;

//Random numbers
#include "random.h"


class ModelloXY{
    public:
    // Costruttore di default
    ModelloXY(){;}
    // Costruttore che legge input da file
    ModelloXY(string nomeF){
        // Stampo tipologia di codice
        cout << "***************************************" << endl;
        cout << "*           Modello XY                *" << endl;
        cout << "*      Simulazione Monte Carlo        *" << endl;
        cout << "***************************************" << endl;


        // Setup del generatore di numeri casuali
        int p1, p2;
        ifstream Primes("random/Primes");
        if (Primes.is_open()){
            Primes >> p1 >> p2 ;
        } else cerr << "PROBLEM: Unable to open Primes" << endl;
        Primes.close();

        //Leggiamo parametri simulativi
        ifstream fileIn;
        fileIn.open("input.dat");

        fileIn >> m_temp;
        m_beta = 1.0/m_temp;
        fileIn >> m_nspin;
        fileIn >> m_J;    
        fileIn >> m_nblk;
        fileIn >> m_nstep;

        fileIn.close();
    }
    //Distruttore
    ~ModelloXY() {;}


    // Stampo i parametri della simulazione
    void stampa_par(){
            cout << endl;
            cout << "Parametri simulativi:" << endl << endl;
            cout << "Lato reticolo:           " << m_nspin << endl;
            cout << "Temperatura:             " << setprecision(3) << m_temp << endl;
            cout << "Beta:                    " << setprecision(3) << m_beta << endl;
            cout << "J:                       " << setprecision(3) << m_J << endl;
            cout << "Numero blocchi           " << m_nblk << endl;
            cout << "Lunghezza simulazione:   " << m_nstep << endl;
            cout << endl << endl << endl;
    }


    private:
    double m_temp, m_J, m_beta;
    int m_nblk, m_nstep, m_nspin;
    
};




#endif
