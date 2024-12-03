#!/usr/bin/awk -f
#
#  takes a column and prints the binned probability distribution
BEGIN{
    col=9; nbins=30; tmin=20000; if(tmax=="") tmax=2e7
}
!/#/&&$1>tmin&&$1<tmax{
    n++
    v[n]=$(col)

}
END{
    max=min=v[1]
    for(i=1;i<=n;i++){
	if(v[i]>max) max=v[i];
	if(v[i]<min) min=v[i];
    }
    range=max-min; delta=range/nbins
    print "min=",min,", max=",max > "/dev/stderr"
    for(i=0;i<=nbins;i++) p[i]="0.0"
    for(i=1;i<=n;i++){
	bin=int((v[i]-min)/delta)
	p[bin]+=1
    }
    for(i=0;i<=nbins;i++){
	print (i+0.5)*delta+min,p[i]/(n*delta)
    }
}
