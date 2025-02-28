reset
load "~/.gnuplot"
set fit nolog results

#I assume we have a file last.xyz with only the low-coordinated oxygens in the last frame of traj.dump

# check min/max/average values of the droplet
!./columninfo.awk screen3.xyz

#set the following initial values for the fit
x0=25.8567
y0=27.4256
z0=1.0
zmin=5.84711 #zmin corresponds to the bottom atoms of the droplet
r=26.5

h(x,y) = sqrt(r**2 - (x-x0)**2 - (y-y0)**2) + z0

# fit above zmin to exclude the atoms at the interface
fit [x0-r:x0+r][y0-r:y0+r][zmin+3:] h(x,y) "screen3.xyz" u 2:3:4 via x0,y0,z0,r

# check the fit
sp h(x,y), "screen3.xyz" u 2:3:4 w p t 'Surface oxigen'

# calculate the wetting angle from r,z0,zmin
angle=asin((zmin - z0)/r)*180/pi + 90

print "wetting angle theta = ",angle

