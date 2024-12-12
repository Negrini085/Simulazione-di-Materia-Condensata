#!/usr/bin/awk -f

BEGIN{ ncols=0 }
!/^([:space:]*!|[:space:]*#)/{
	if(NF>ncols) for(i=ncols+1;i<=NF;i++){ ncols=NF; min[i]=max[i]=$i; N[i]=0; sum[i]=0 }
	if(NF>0)for(i=1;i<=NF;i++){
		if($i<min[i]) min[i]=$i; if($i>max[i]) max[i]=$i ; N[i]=N[i]+1; sum[i]=sum[i]+$i
		val[i,N[i]]=$i #storing for standard deviation
	}
}

END{
	for(i=1;i<=ncols;i++){
		std=0;avg=sum[i]/N[i]
		for(j=1;j<=N[i];j++){ std=std+(val[i,j]-avg)^2 }
		print i" min= "min[i]" ;max= "max[i]" ;avg= "avg," ; delta= "max[i]-min[i]," ; std=",sqrt(std/(N[i]-1))," ;N=",N[i]
	}
}
