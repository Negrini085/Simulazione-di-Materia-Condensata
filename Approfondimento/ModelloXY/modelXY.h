#ifndef __ISING__
#define __ISING__

//Random numbers
#include "random.h"

void Input(void)
{
  ifstream ReadInput;

  cout << "Classic 1D Ising model             " << endl;
  cout << "Monte Carlo simulation             " << endl << endl;
  cout << "Nearest neighbour interaction      " << endl << endl;
  cout << "Boltzmann weight exp(- beta * H ), beta = 1/T " << endl << endl;
  cout << "The program uses k_B=1 and mu_B=1 units " << endl;

//Read seed for random numbers
   int p1, p2;
   ifstream Primes("../RANDOM_GEN/Primes");
  if (Primes.is_open()){
    Primes >> p1 >> p2 ;
  } else cerr << "PROBLEM: Unable to open Primes" << endl;
  Primes.close();

   ifstream input("../RANDOM_GEN/seed.in");
   input >> seed[0] >> seed[1] >> seed[2] >> seed[3];
   rnd.SetRandom(seed,p1,p2);
   input.close();
  
//Read input informations
  ReadInput.open("input.dat");

  ReadInput >> temp;
  bet_a = 1.0/temp;
  cout << "Temperature = " << temp << endl;

  ReadInput >> nspin;
  cout << "Number of spins = " << nspin << endl;

  ReadInput >> J;
  cout << "Exchange interaction = " << J << endl;

  ReadInput >> h;
  cout << "External field = " << h << endl << endl;
    
  ReadInput >> metro; // if=1 Metropolis else Gibbs

  ReadInput >> nblk;

  ReadInput >> nstep;

  if(metro==1) cout << "The program perform Metropolis moves" << endl;
  else cout << "The program perform Gibbs moves" << endl;

  cout << "Number of blocks = " << nblk << endl;
  cout << "Number of steps in one block = " << nstep << endl << endl;
  ReadInput.close();


//Prepare arrays for measurements
  iu = 0; //Energy
  ic = 1; //Heat capacity
  im = 2; //Magnetization
  ix = 3; //Magnetic susceptibility
 
  n_props = 4; //Number of observables

//initial configuration
  for (int i=0; i<nspin; ++i)
  {
    //s[i] = 1;
    if(rnd.Rannyu() >= 0.5) s[i] = 1;
    else s[i] = -1;
  }

//Stampo la configurazione iniziale a file
  ofstream fileout;
  fileout.open("config_in.dat", ios::app);
  for(int i=0; i<nspin; i++) { fileout << s[i] << "  "; }
  fileout << endl;
  fileout.close();
  
//Evaluate energy etc. of the initial configuration
  Measure();

  //Print initial values for measured properties
  cout << double(nspin) << endl;
  cout << "Initial energy per particle      = " << walker[iu]/(double)nspin << endl;
  cout << "Initial magnetization            = " << walker[im] << endl << endl;

  cout << "----------------------------" << endl << endl;

}
#endif
