#!/bin/bash

sort -g -k1,1 2Dbinning.dat | awk 'BEGIN{R=0; S=0}NF==0{next}{ if($1!=R){print R,sum;sum=0;R=$1; S=$2} } { if($2==S){sum=sum+$3} } { sum = sum + $3/($2 - S); S=$2; }' > 1Dprob_proj_q.dat
