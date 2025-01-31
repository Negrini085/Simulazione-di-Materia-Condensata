#ifndef __ISING__
#define __ISING__

#include <iostream>
#include <fstream>
#include <ostream>
#include <iomanip>
#include <vector>
#include <cmath>

using namespace std;

//Random numbers
#include "random/random.h"

// Variabile globale per acc. rate
int accettate = 0;

// Funzione per condizioni al contorno periodiche
int Pbc(int nspin, int i)
{
    if(i >= nspin) i = i - nspin;
    else if(i < 0) i = i + nspin;
    return i;
}


// Classe per studio del modello di Ising
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
        
        ifstream input("random/seed.in"); int seed[4];
        input >> seed[0] >> seed[1] >> seed[2] >> seed[3];
        m_rnd.SetRandom(seed,p1,p2);
        input.close();
        Primes.close();

        //Leggiamo parametri simulativi
        ifstream fileIn;
        fileIn.open(nomeF);

        fileIn >> m_temp;
        m_beta = 1.0/m_temp;
        fileIn >> m_nspin;
        fileIn >> m_J;    
        fileIn >> m_nblk;
        fileIn >> m_nstep;
        fileIn >> m_delta;
        fileIn >> m_term;

        fileIn.close();

        //Inizializzazione della matrice (parto con tutti gli spin verso l'alto)
        m_lattice.resize(m_nspin, vector<double>(m_nspin));

        for(int i=0; i<m_nspin; i++){
            for(int j=0; j<m_nspin; j++){
                m_lattice[i][j] = M_PI/2;
            }
        }

    }
    // Costruttore che legge input da file & configurazione iniziale da file
    ModelloXY(string nomeInp, string nomeConf){
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
        
        ifstream input("random/seed.in"); int seed[4];
        input >> seed[0] >> seed[1] >> seed[2] >> seed[3];
        m_rnd.SetRandom(seed,p1,p2);
        input.close();
        Primes.close();

        //Leggiamo parametri simulativi
        ifstream fileIn;
        fileIn.open(nomeInp);

        fileIn >> m_temp;
        m_beta = 1.0/m_temp;
        fileIn >> m_nspin;
        fileIn >> m_J;    
        fileIn >> m_nblk;
        fileIn >> m_nstep;
        fileIn >> m_delta;
        fileIn >> m_term;

        fileIn.close();

        fileIn.open(nomeConf);
        //Inizializzazione della matrice (parto con tutti gli spin verso l'alto)
        m_lattice.resize(m_nspin, vector<double>(m_nspin));

        for(int i=0; i<m_nspin; i++){
            for(int j=0; j<m_nspin; j++){
                fileIn >> m_lattice[i][j];
            }
        }
        fileIn.close();
    }
    //Distruttore
    ~ModelloXY() {;}


    // Metodi get per ottenere i parametri simulativi
    int getNblk(){ return m_nblk; }
    int getNspin(){ return m_nspin; }
    int getNstep(){ return m_nstep; }
    double getTemp(){ return m_temp; }
    double getBeta(){ return m_beta; }
    double getDelta(){ return m_delta; }
    double getTerm(){ return m_term; }

    // Metodi set per poter fare raffreddamento della configurazione
    void setTemp(double t){
        m_beta = 1/t; 
        m_temp = t;
    }


    // Stampo i parametri della simulazione
    void stampa_par(){
            cout << endl;
            cout << "Parametri simulativi:" << endl << endl;
            cout << "Lato reticolo:           " << m_nspin << endl;
            cout << "Temperatura:             " << setprecision(3) << m_temp << endl;
            cout << "Beta:                    " << setprecision(3) << m_beta << endl;
            cout << "J:                       " << setprecision(3) << m_J << endl;
            cout << "Delta:                   " << setprecision(3) << m_delta << endl;
            cout << "Numero blocchi           " << m_nblk << endl;
            cout << "Lunghezza simulazione:   " << m_nstep << endl;
            cout << "Fase di termalizzazione: " << m_term << endl;
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

    // Stampo la matrice a file
    void stampa_mat(string fName){
        ofstream fileOut;
        fileOut.open(fName);

        for(int i=0; i<m_nspin; i++){
            for(int j=0; j<m_nspin; j++){
                fileOut << m_lattice[i][j] << "    ";
            }
            fileOut << endl;
        }

        fileOut.close();
    }

    // Calcolo magnetizzazione lungo x del sistema
    double getMagnX(){
        double appo = 0;

        for(int i=0; i<m_nspin; i++){
            for(int j=0; j<m_nspin; j++){
                appo += cos(m_lattice[i][j]);
            }
        }

        return appo;
    }
    
    
    // Calcolo magnetizzazione lungo y del sistema
    double getMagnY(){
        double appo = 0;

        for(int i=0; i<m_nspin; i++){
            for(int j=0; j<m_nspin; j++){
                appo += sin(m_lattice[i][j]);
            }
        }

        return appo;
    }


    // Calcolo energia del sistema
    double getEne(){
        double appo = 0;

        for(int i=0; i<m_nspin; i++){
            for(int j=0; j<m_nspin; j++){
                appo -= m_J * cos(m_lattice[i][j] - m_lattice[i][Pbc(m_nspin, j+1)]);
                appo -= m_J * cos(m_lattice[j][i] - m_lattice[Pbc(m_nspin, j+1)][i]);
            }
        }

        return appo;
    }

    // Energia interazione con primi vicini (serve per mossa metropolis)
    double Boltzmann(double spin, int xcoor, int ycoor){
      double ene = 0;
      
      // Considero separatamente i quattro primi vicini
      ene = -m_J * cos(m_lattice[xcoor][Pbc(m_nspin, ycoor + 1)] - spin);
      ene -= m_J * cos(m_lattice[xcoor][Pbc(m_nspin, ycoor - 1)] - spin);
      ene -= m_J * cos(m_lattice[Pbc(m_nspin, xcoor + 1)][ycoor] - spin);
      ene -= m_J * cos(m_lattice[Pbc(m_nspin, xcoor - 1)][ycoor] - spin);

      return ene;
    }


    // Singola mossa metropolis
    void Move(){
        
        // Seleziono lo spin da ruotare
        int xcoor, ycoor;

	do{
	    xcoor = static_cast<int>(m_rnd.Rannyu(0, m_nspin));
	}while(xcoor < 0);

	do{
	   ycoor = static_cast<int>(m_rnd.Rannyu(0, m_nspin));
	}while(ycoor < 0);

        // Valuto di quanto ruotare (parametro delta fissato per acceptance rate 50%)
        double change = m_rnd.Rannyu(-m_delta, m_delta);

        // Energie prima e dopo inversione
        double appo = m_lattice[xcoor][ycoor] + change;
        double enei = Boltzmann(m_lattice[xcoor][ycoor], xcoor, ycoor);
        double enef = Boltzmann(appo, xcoor, ycoor);

        // Valuto la differenza di energia
        if(enef - enei < 0){
            m_lattice[xcoor][ycoor] = appo;
            accettate += 1;
        }
        else if(m_rnd.RannyuUnit() < exp(-m_beta * (enef - enei))){
            m_lattice[xcoor][ycoor] = appo;
            accettate += 1;
        }

    }


    // Sweep del reticolo con metropolis
    void Sweep(){

        // Per fare uno seep, servono nspin * nspin tentativi
        for(int i=0; i<m_nspin*m_nspin; i++){ Move(); }

    }




    private:
    // Data membri classe --> sono parametri simulativi
    Random m_rnd;
    vector<vector<double>> m_lattice;
    double m_temp, m_J, m_beta, m_delta;
    int m_nblk, m_nstep, m_nspin, m_term;
    
};




#endif
