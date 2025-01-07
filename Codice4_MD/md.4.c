#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#define kB 0.08617718  /*  kB= 1./11.604=0.086 meV/K  */
/* UNITS: meV, ps, Ang -- mass is in units of ~1.602e-26 kg ~= 9.648 amu  */

int N;             //number of atoms
int calc_vic;	   //numero di iterazioni per calcolo primi vicini
int n_vic;	   //numero di primi vicini
char *atomtype;    //atomic species (1 char)
double dt;         //timestep
double mass;       //mass
double dskin;      //dimensione della skin
double kspring;    //spring constant
double n_list;    //if 0, no neighbor list, else neighbor list
double d0;         //equilibrium spring distance
double c_rep;      //repulsive interaction of scatterers
double kbox;       //spring constant of box wall
double side,halfside;//side of the box
double cutoff;  //cutoff for interaction among scatterers
long int nsteps;   //number of simulation steps
long int nstep;    //actual step, changing during simulation
long int print;    //print every these steps
double *x,*y,*z,*Vx,*Vy,*Vz,*Fx,*Fy,*Fz;
double *xprev,*yprev,*zprev,*xtmp,*ytmp,*ztmp; // to store the old coordinates for Verlet
double epot,ekin,etot,Tm,Tw;
char inputxyz[30],trajfile[30];
FILE *ftraj;

typedef struct {
    int primo;
    int secondo;
} Vicini;
Vicini *neighbor_list;

double square(double val){ return val*val; }
double cube(double val){ return val*val*val; }

void read_parameters(char *filename){
	char dummy[100];
	FILE *fin;
	void error() { fprintf(stderr,"ERROR in input parameters file %s\n",filename); exit(1); }

	if((fin=fopen(filename,"r"))==NULL) error();
	if( fscanf(fin,"%s %ld ", dummy, &nsteps  ) != 2 ) error();
	if( fscanf(fin,"%s %ld ", dummy, &print   ) != 2 ) error();
	if( fscanf(fin,"%s %lf ", dummy, &mass    ) != 2 ) error();
	if( fscanf(fin,"%s %lf ", dummy, &dt      ) != 2 ) error();
	if( fscanf(fin,"%s %lf ", dummy, &kspring ) != 2 ) error();
	if( fscanf(fin,"%s %lf ", dummy, &d0      ) != 2 ) error();
	if( fscanf(fin,"%s %s  ", dummy, inputxyz ) != 2 ) error();
	if( fscanf(fin,"%s %s  ", dummy, trajfile ) != 2 ) error();
	if( fscanf(fin,"%s %lf ", dummy, &c_rep   ) != 2 ) error();
	if( fscanf(fin,"%s %lf ", dummy, &side    ) != 2 ) error();
	if( fscanf(fin,"%s %lf ", dummy, &kbox    ) != 2 ) error();
	if( fscanf(fin,"%s %lf ", dummy, &cutoff  ) != 2 ) error();
	if( fscanf(fin,"%s %lf ", dummy, &n_list  ) != 2 ) error();
	if( fscanf(fin,"%s %d ", dummy, &calc_vic  ) != 2 ) error();

	//printout parameters to check
	fprintf(stderr,"nsteps %ld\n" ,nsteps);
	fprintf(stderr,"print %ld\n"  ,print);
	fprintf(stderr,"mass %g\n"    ,mass);
	fprintf(stderr,"timestep %g\n",dt);
	fprintf(stderr,"kspring %g\n" ,kspring);
	fprintf(stderr,"d0 %g\n"      ,d0);
	fprintf(stderr,"inputxyz %s\n",inputxyz);
	fprintf(stderr,"trajfile %s\n",trajfile);
	fprintf(stderr,"c_rep %g\n"   ,c_rep);
	fprintf(stderr,"side %g\n"    ,side);
	fprintf(stderr,"kbox %g\n"    ,kbox);
	fprintf(stderr,"cutoff %g\n"  ,cutoff);
	fprintf(stderr,"calc_vic %d\n"  ,calc_vic);

	if(n_list != 0){
		fprintf(stderr,"neighbor list: yes\n");
	}
	else{
		fprintf(stderr,"neighbor list: no\n");
	}

	fclose(fin);
	halfside=side/2.;
}

void readxyz(){
	int i,n=0,readCharCount;
	char dummy[300];
	FILE *fin;
	void error() { fprintf(stderr,"ERROR in input structure file %s, %c %g %g %g\n",inputxyz,atomtype[i],x[i],y[i],z[i]); exit(1); }

	if((fin=fopen(inputxyz,"r"))==NULL) error();

	//the first line should contain the number of atoms
	fgets(dummy,sizeof(dummy),fin);
	if( sscanf(dummy,"%d",&N) != 1 ) error();

	if( (x=(double *)  calloc(N, sizeof(double))) == NULL ) n++;
	if( (y=(double *)  calloc(N, sizeof(double))) == NULL ) n++;
	if( (z=(double *)  calloc(N, sizeof(double))) == NULL ) n++;
	if( (xprev=(double *) calloc(N, sizeof(double))) == NULL ) n++;
	if( (yprev=(double *) calloc(N, sizeof(double))) == NULL ) n++;
	if( (zprev=(double *) calloc(N, sizeof(double))) == NULL ) n++;
	if( (xtmp=(double *) calloc(N, sizeof(double))) == NULL ) n++;
	if( (ytmp=(double *) calloc(N, sizeof(double))) == NULL ) n++;
	if( (ztmp=(double *) calloc(N, sizeof(double))) == NULL ) n++;
	if( (Vx=(double *) calloc(N, sizeof(double))) == NULL ) n++;
	if( (Vy=(double *) calloc(N, sizeof(double))) == NULL ) n++;
	if( (Vz=(double *) calloc(N, sizeof(double))) == NULL ) n++;
	if( (Fx=(double *) calloc(N, sizeof(double))) == NULL ) n++;
	if( (Fy=(double *) calloc(N, sizeof(double))) == NULL ) n++;
	if( (Fz=(double *)  calloc(N, sizeof(double))) == NULL ) n++;
	if( (atomtype=(char *) calloc(N,sizeof(char))) == NULL ) n++;
	if(n>0){fprintf(stderr,"Allocation error %d\n",n); exit(1);}

	// the second line is a comment, we skip it
	fgets(dummy,sizeof(dummy),fin);

	for(i=0;i<N;i++){
		//read positions
		fgets(dummy,sizeof(dummy),fin);
		if( sscanf(dummy,"%s %lf %lf %lf%n", &atomtype[i],&x[i],&y[i],&z[i],&readCharCount) !=4 ) error();
		//read velocities if present, otherwise set them to zero
		if( sscanf(dummy+readCharCount,"%lf %lf %lf", &Vx[i],&Vy[i],&Vz[i]) !=3 ) Vx[i]=Vy[i]=Vz[i]=0.;
	}
	fclose(fin);
	fprintf(stderr,"Simulation with %d atoms\n",N);

}

double distx(int i, int j){
	double dX= x[i]-x[j];
	if(kbox>0.) return dX;              //no PBC
	else return dX-round(dX/side)*side; //yes PBC
}

double disty(int i, int j){
	double dY= y[i]-y[j];
	if(kbox>0.) return dY;              //no PBC
	else return dY-round(dY/side)*side; //yes PBC
}

double distz(int i, int j){
	double dZ= z[i]-z[j];
	if(kbox>0.) return dZ;              //no PBC
	else return dZ-round(dZ/side)*side; //yes PBC
}

double dist(int i, int j){
	return sqrt( square(distx(i,j)) + square(disty(i,j)) + square(distz(i,j)) );
}

// Funzione per determinare quale debba essere la dimensione della skin oltre il cutoff
// Per far questo si deve individuare la velocità maggiore e valutare quale possa essere la 
// distanza percorsa dalla particella in 100 step d'evoluzione (tempo fra il primo aggiornamento 
// ed il successivo della lista dei primi vicini)
void dim_skin(){

	// Valuto quale sia la velocità massima
	double appo = 0; double vmax = 0;

	for (int i=0;i<N;i++){
		if(atomtype[i]=='S'){
			appo = sqrt(Vx[i]*Vx[i] + Vy[i]*Vy[i] + Vz[i]*Vz[i]);

			if(appo > vmax){
				vmax = appo;
			}
		}
	}

	dskin = calc_vic * dt * vmax;
}


// Operazione di creazione della lista di coppie di primi vicini. Tale azione è da fare 
// ogni volta che si intende aggiornare la lista di primi vicini. In primo luogo conto quanti 
// sono i primi vicini, poi creo il contenitore ed infine lo riempio con le singole coppie

void create_list(){
	int limit = 0;
	
	// Calcolo nuovamente la dimensione della skin
	dim_skin();

	for (int i = 0; i < N; i++) {

		// Considero interazione spring fra elementi della catena
		if(atomtype[i] == 'B' && atomtype[i+1] == 'B'){
			limit += 1;
		}

        for (int j = i+1; j < N; j++) {

			// Interazioni spring-like in catena sono considerate prima di entrare in questo ciclo
			if(atomtype[i] == 'B' && atomtype[j] == 'B') continue;
            
			// Considero tutte le particelle che si trovano in cut-off + skin
			// Solo in secondo momento applico il vero cutoff, quando si devono calcolare forze
			if(dist(i, j) < d0 + dskin){
				limit += 1;
			}
        }
    }




	// Creo ora la lista di coppie di primi vicini, considerando solo quelli che hanno passato il
	// test precedente
	neighbor_list = malloc(limit * sizeof(Vicini));


	int conta = 0;
	for (int i = 0; i < N; i++) {

		// Considero interazione spring fra elementi della catena
		if(atomtype[i] == 'B' && atomtype[i+1] == 'B'){
			neighbor_list[conta].primo = i;
			neighbor_list[conta].secondo = i+1;
			conta += 1;
		}

        for (int j = i+1; j < N; j++) {

			// Interazioni spring-like in catena sono considerate prima di entrare in questo ciclo
			if(atomtype[i] == 'B' && atomtype[j] == 'B') continue;
            
			// Considero tutte le particelle che si trovano in cut-off + skin
			// Solo in secondo momento applico il vero cutoff, quando si devono calcolare forze
			if(dist(i, j) < d0 + dskin){
				neighbor_list[conta].primo = i;
				neighbor_list[conta].secondo = j;
				conta += 1;
			}
        }
    }

	n_vic = limit;

}


// Operazione di pulizia della lista, in cui la memoria viene totalmente liberata
void clean_list(){
	free(neighbor_list);
}



void calc_forces(){
	int i,j; double effe,d,d4,d12;
	//reset the forces
	for (i=0;i<N;i++) { Fx[i]=Fy[i]=Fz[i]=0; }


	// Caso senza calcolo della lista dei primi vicini
	if(n_list == 0){
		//chain
		for(i=0;i<N-1;i++){
		    if(atomtype[i]=='B' && atomtype[i+1]=='B') {
			    effe = -kspring*(dist(i,i+1) - d0)/dist(i,i+1);
			    Fx[i] += effe*distx(i,i+1); Fx[i+1] += -effe*distx(i,i+1);
			    Fy[i] += effe*disty(i,i+1); Fy[i+1] += -effe*disty(i,i+1);
			    Fz[i] += effe*distz(i,i+1); Fz[i+1] += -effe*distz(i,i+1);
		    }
		}

		//scatterers
		for(i=0;i<N;i++){
		    for(j=0;j<i;j++){
				if(atomtype[i]=='B' && atomtype[j]=='B') continue;

				d   = dist(i,j);
				if(d>cutoff) continue;
				d4  = d*d*d*d;
				d12 = d4*d4*d4;
				effe = 10.*c_rep/d12;

				Fx[i] +=  effe*distx(i,j);  Fx[j] += -effe*distx(i,j);
				Fy[i] +=  effe*disty(i,j);  Fy[j] += -effe*disty(i,j);
				Fz[i] +=  effe*distz(i,j);  Fz[j] += -effe*distz(i,j);
		    }
		}
	
	}


	// Caso con la lista dei primi vicini
	else{
		//chain
		for(i=0; i<n_vic; i++){
		    if(atomtype[neighbor_list[i].primo]=='B' && atomtype[neighbor_list[i].secondo]=='B') {
			    effe = -kspring*(dist(neighbor_list[i].primo,neighbor_list[i].secondo) - d0)/dist(neighbor_list[i].primo,neighbor_list[i].secondo);
			    Fx[neighbor_list[i].primo] += effe*distx(neighbor_list[i].primo,neighbor_list[i].secondo); 
				Fx[neighbor_list[i].secondo] += -effe*distx(neighbor_list[i].primo,neighbor_list[i].secondo);
			    
				Fy[neighbor_list[i].primo] += effe*disty(neighbor_list[i].primo,neighbor_list[i].secondo); 
				Fy[neighbor_list[i].secondo] += -effe*disty(neighbor_list[i].primo,neighbor_list[i].secondo);
			    
				Fz[neighbor_list[i].primo] += effe*distz(neighbor_list[i].primo,neighbor_list[i].secondo); 
				Fz[neighbor_list[i].secondo] += -effe*distz(neighbor_list[i].primo,neighbor_list[i].secondo);
		    }



			d   = dist(neighbor_list[i].primo,neighbor_list[i].secondo);
			if(d>cutoff) {
				continue;
			}

			else{
				d4  = d*d*d*d;
				d12 = d4*d4*d4;
				effe = 10.*c_rep/d12;

				Fx[neighbor_list[i].primo] +=  effe*distx(neighbor_list[i].primo,neighbor_list[i].secondo);  
				Fx[neighbor_list[i].secondo] += -effe*distx(neighbor_list[i].primo,neighbor_list[i].secondo);

				Fy[neighbor_list[i].primo] +=  effe*disty(neighbor_list[i].primo,neighbor_list[i].secondo);  
				Fy[neighbor_list[i].secondo] += -effe*disty(neighbor_list[i].primo,neighbor_list[i].secondo);

				Fz[neighbor_list[i].primo] +=  effe*distz(neighbor_list[i].primo,neighbor_list[i].secondo);  
				Fz[neighbor_list[i].secondo] += -effe*distz(neighbor_list[i].primo,neighbor_list[i].secondo);
			}
		}
	}	


	//box (if no PBC)
	if(kbox>0.) for (i=0;i<N;i++){
	  if ( x[i] < -halfside ) Fx[i] -= kbox*(x[i] + halfside);
	  if ( x[i] >  halfside ) Fx[i] -= kbox*(x[i] - halfside);
	  if ( y[i] < -halfside ) Fy[i] -= kbox*(y[i] + halfside);
	  if ( y[i] >  halfside ) Fy[i] -= kbox*(y[i] - halfside);
	  if ( z[i] < -halfside ) Fz[i] -= kbox*(z[i] + halfside);
	  if ( z[i] >  halfside ) Fz[i] -= kbox*(z[i] - halfside);
    }

}

void calc_energies(){
	int i,j,Nm=0,Nw=0; double d,d5,d10;
	static int once=1; static double offset=0.;

	if(once){
	    offset=c_rep/pow(cutoff,10);
		once=0;
	}

	ekin=Tm=Tw=0;
	for(i=0;i<N;i++)
	    if(atomtype[i]=='B'){ Tm+=( Vx[i]*Vx[i] + Vy[i]*Vy[i] + Vz[i]*Vz[i] ); Nm++; }
	    else                { Tw+=( Vx[i]*Vx[i] + Vy[i]*Vy[i] + Vz[i]*Vz[i] ); Nw++; }

	ekin = 0.5 * mass * ( Tm + Tw );
	Tm= mass*Tm/(3.*Nm*kB);
	Tw= mass*Tw/(3.*Nw*kB);

	epot=0;

	if(n_list == 0){

		//chain
		for (i=0;i<N-1;i++){
		    if(atomtype[i]=='B' && atomtype[i+1]=='B')
			epot += 0.5*kspring*square( dist(i,i+1) - d0 );
		}

        //scatterers
		for (i=0;i<N;i++){
	    	for(j=0;j<i;j++){
			if(atomtype[i]=='B' && atomtype[j]=='B') continue;

			d   = dist(i,j);
			if(d>cutoff) continue;
			d5  = d*d*d*d*d;
			d10 = d5*d5;
			epot += c_rep/d10 - offset;
	    	}
		}
	}



	else{
		//chain
		for (i=0;i<n_vic;i++){
		    if(atomtype[neighbor_list[i].primo]=='B' && atomtype[neighbor_list[i].secondo]=='B'){
				epot += 0.5*kspring*square( dist(neighbor_list[i].primo,neighbor_list[i].secondo) - d0 );
			}

			else{
				d   = dist(neighbor_list[i].primo,neighbor_list[i].secondo);
				if(d>cutoff) continue;
				d5  = d*d*d*d*d;
				d10 = d5*d5;
				epot += c_rep/d10 - offset;
			}
		}

	}

	//box (if no PBC)
	if(kbox>0.) for (i=0;i<N;i++){
	  if ( x[i] < -halfside ) epot += 0.5*kbox*square(x[i] + halfside);
	  if ( x[i] >  halfside ) epot += 0.5*kbox*square(x[i] - halfside);
	  if ( y[i] < -halfside ) epot += 0.5*kbox*square(y[i] + halfside);
	  if ( y[i] >  halfside ) epot += 0.5*kbox*square(y[i] - halfside);
	  if ( z[i] < -halfside ) epot += 0.5*kbox*square(z[i] + halfside);
	  if ( z[i] >  halfside ) epot += 0.5*kbox*square(z[i] - halfside);
       }

	etot=ekin+epot;
}



void velocity_Verlet_integrator(){
	int i; static int once=1;
	if(once){ once=0; calc_forces(); }

	// update velocities(1)
	for (i=0;i<N;i++){
		Vx[i] += dt*Fx[i]/(2*mass);
		Vy[i] += dt*Fy[i]/(2*mass);
		Vz[i] += dt*Fz[i]/(2*mass);
	}

	//update positions
	for (i=0;i<N;i++){
		x[i] += Vx[i]*dt;
		y[i] += Vy[i]*dt;
		z[i] += Vz[i]*dt;
	}

	calc_forces(); // update the forces

	// update velocities(2)
	for (i=0;i<N;i++){
		Vx[i] += dt*Fx[i]/(2*mass);
		Vy[i] += dt*Fy[i]/(2*mass);
		Vz[i] += dt*Fz[i]/(2*mass);
	}
}

void write_traj(){
	static int once=1;
	int i;
	if(once){
		once=0;
		if((ftraj=fopen(trajfile,"w"))==NULL) { fprintf(stderr,"ERROR while saving trajectory file\n"); exit(1); }
	}

	fprintf(ftraj,"%d\nLattice=\"%g 0.0 0.0  0.0 %g 0.0  0.0 0.0 %g\"\tTIME: %g\n",N,side,side,side,dt*nstep);
	for(i=0;i<N;i++){
		fprintf(ftraj,"%c\t%.6f\t%.6f\t%.6f\t%.6e\t%.6e\t%.6e\t%.6e\t%.6e\t%6e\n" ,atomtype[i],x[i],y[i],z[i],Vx[i],Vy[i],Vz[i],Fx[i],Fy[i],Fz[i]);
	}
	fflush(ftraj);
}

void printout(){
	static int once=1;
	if(once){
		once=0;
		printf("#time\tekin\t\tepot\t\tetot\t\tchain_length\tTmolecule\tTwater\n");
	}
	calc_energies();
	printf("%g\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\n",dt*nstep,ekin,epot,etot,dist(0,N-1),Tm,Tw );
	write_traj();
	fflush(stdout);
}


int main(int argc, char *argv[])
{
   // read parameter file
   if (argc != 2) {fprintf(stderr,"Provide parameter file\n"); exit(1);}
   read_parameters(argv[1]);

   // read initial conditions
   readxyz();

   // crea la lista dei vicini quando necessario
   if(n_list != 0){ create_list(); }


   // write trajectory and print some information
   printout();

   // dynamics loop
   for (nstep=1;nstep<=nsteps;nstep++)
   {

      velocity_Verlet_integrator(); // one time of dynamics

      // write trajectory and print some information
      if ( nstep % print == 0 ) printout();

	  // libera e ricrea la lista dei vicini se necessario
      if ( n_list != 0 && nstep % calc_vic == 0){
		clean_list();
		create_list();
	  }

   }
   
   fclose(ftraj);

   return 0;
}


