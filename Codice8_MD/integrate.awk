#!/usr/bin/awk -f
#evaluates the integral of a curve y(x) from a two-column file
#col. 1 = x, col. 2 = y

!/#/{ n++; data[n,1]=$1; data[n,2]=$2; }

END{
  if(start == "") start=data[1,1]
  if(end   == "") end = data[n,1]
  for(i=1;i<n;i++){
    if(data[i,1] < start ) continue
    if(data[i,1] >= end ) break
    delta=data[i+1,1]-data[i,1]
    res+=delta*(data[i+1,2]+data[i,2])/2.
  }
   print "#integral from",start,"to",end,"(interval",(end-start)")" >"/dev/stderr"
   print res
}


