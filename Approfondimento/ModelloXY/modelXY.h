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

        //Inizializzazione della matrice (parto con tutti gli spin verso l'alto)
        m_lattice = new double*[m_nspin];
        for(int i=0; i<m_nspin; i++){
            m_lattice[i] = new double[m_nspin];
        }

        for(int i=0; i<m_nspin; i++){
            for(int j=0; j<m_nspin; j++){
                m_lattice[i][j] = M_PI/2;
            }
        }

    }
    //Distruttore
    ~ModelloXY() {
        for(int i=0; i<m_nspin; i++){
            delete[] m_lattice[i];
        }
        delete[] m_lattice;
    }


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

    // Stampo la matrice a terminale
    void stampa_mat(){
        for(int i=0; i<m_nspin; i++){
            for(int j=0; j<m_nspin; j++){
                cout << m_lattice[i][j] << "    ";
            }
            cout << endl;
        }
    }


    private:
    double** m_lattice;
    double m_temp, m_J, m_beta;
    int m_nblk, m_nstep, m_nspin;
    
};




#endif
