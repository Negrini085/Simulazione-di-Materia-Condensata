#!/bin/bash

sort -g -k1,1 2Dbinning.dat | awk 'BEGIN{R=0}NF==0{next}{ if($1!=R){print R,sum;sum=0;R=$1;} } { sum=sum+$3; }' > 1Dprob_proj_q.dat
