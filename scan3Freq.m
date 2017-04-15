%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author:       Max
% Date:         06.04.2017
% File:         scan3Freq.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function scan3Freq(lat,lon)
	%cd /home/maximilian/RTLSDRspecAn
	sampleRTLSDR(1.8e6,463e6,2048,25,lat,lon,474e6);
	sampleRTLSDR(1.8e6,583e6,2048,25,lat,lon,594e6);
	sampleRTLSDR(1.8e6,615e6,2048,25,lat,lon,626e6);
endfunction;
