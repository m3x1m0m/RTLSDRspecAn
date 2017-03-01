function d = haversine (lat1,lat2,lon1,lon2)
	R = 6371e3;                                                     % Earth radius
        rad = pi/180;

	phi1 = lat1*rad;
	phi2 = lat2*rad;
	dphi = (lat2-lat1)*rad;
	dlambda = (lon2-lon1)*rad;

	a = sin(dphi/2)*sin(dphi/2) + cos(phi1)*cos(phi2)*sin(dlambda/2)*sin(dlambda/2);
	c = 2*atan2(sqrt(a), sqrt(1-a));
	d = R*c;  
endfunction;
