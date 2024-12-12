#!/usr/bin/awk -f
# Evaluates the mean squared displacement, MSD(t),
# of a three-column file (time, x, y)
# The average is performed on every possible interval.
#
# Example: ./msd.awk trajectory.dat
#
# Requires gawk from gnu.org
# Copyright (C) March 2010 Roberto Guerra, robguerra at unimore dot it.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# You can view a copy of the GNU General Public License at:
# http://www.gnu.org/copyleft/gpl.html
#

BEGIN{
i=0;NPOINTS=1000;
}

{
  i++;time[i]=$1;x[i]=$2;y[i]=$3;
}

END{
  NVAL=i;  if(NVAL>10) msdmax=int(NVAL/2); else exit 1;
  print NVAL" samples found."
# msd calculation
  for(t1=1;t1<=msdmax+1;t1+=int(msdmax/NPOINTS)) #starting from 1 to allow logarithmic scales
  {
    msd[t1]=msdhalf1[t1]=msdhalf2[t1]=0.0; nmsd=nhalf1=nhalf2=0; #resetting counters
    printf("\rcalculating msd... %d%%        ",int((t1*100.0)/msdmax));fflush(stdout);
    for(t2=1;t2<=NVAL-t1;t2++){
      val=( x[t1+t2]-x[t2] )^2 + ( y[t1+t2]-y[t2] )^2
      msd[t1]+=val ; nmsd++
      if(t1<=int(msdmax/2) && t2<=int((NVAL-t1)/2)) {msdhalf1[t1]+=val ; nhalf1++}       # using first and second halves of the data to estimate the error
      else if(t1<=int(msdmax/2) && t2>int((NVAL-t1)/2)) {msdhalf2[t1]+=val ; nhalf2++}
    }
#printout
    msd[t1]/=nmsd
    if(t1<=int(msdmax/2)){
      msdhalf1[t1]/=nhalf1; msdhalf2[t1]/=nhalf2;
      print time[t1+1]-time[1],msd[t1],msdhalf1[t1],msdhalf2[t1] > "msd.dat"
    }
    else print time[t1+1]-time[1],msd[t1] > "msd.dat"
  }
  print ""
}


