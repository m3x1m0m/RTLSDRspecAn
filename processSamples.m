%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author:	Max
% Date: 	23.02.2017
% File: 	processSamples.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function processSamples (dir, ploton)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Vars
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		conf = dlmread([dir '/conf.csv']);		% Readout conf.
		fs = conf(1)
		fstart = conf(2)
		N = conf(3)
		B = conf(4)
		lat = conf(5)
		lon = conf(6)
		fm = conf(7)
		fc = fs/2					% Cutoff frequency
		df = fs/N					% Frequency resolution
		fstop = B * fc + fstart				% Stop freq
		D = 2^10;					% Decimation factor
				
		switch(fm)					% Normalize on the highest value measured for the
								% corresponding TV signal
			case 474e6
				%Hnormal = 1.9071e+04
				Hnormal = 3621.373
			case 594e6
				%Hnormal = 1.8748e+04
				Hnormal = 3459.997
			case 626e6	
				%Hnormal = 1.6057e+04
				Hnormal = 3405.801
			otherwise 
				Hnormal = 0
		end	

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Clue samples together
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
		for i = 0:(B - 1)		
			Raw = dlmread([dir '/samp_' num2str(i) '.csv']);	% Read raw data 
			H = fft(real(Raw), N);			% Perform FFT clue
			H = H(1:N/2);	
			Ha( (i*(N/2)+1) : ((i+1)*(N/2)) ) = H;   	
		end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Process samples
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		amplitude = abs(Ha);				% Take abs()

		f = linspace(fstart, fstop, B*(N/2));		% Generate acc. freq. vector

		wndwSize = 2048;
		h = (ones(1,wndwSize)/wndwSize);
		amplitudeS = filter(h, 1, amplitude); 

		PTV = zeros(1,length(amplitudeS));		% Determine the signal power	
		b = round((fm-5e6-fstart)/df);
		t = round((fm+5e6-fstart)/df);
		PTV(1,:) = mean(amplitudeS(b:t));
		PTV(1)		

		amplitudenorm = amplitudeS / Hnormal;		% Normalizing
		amplitudedB = 20*log10(amplitudenorm);
		PTVdB = 20*log10(PTV/Hnormal);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Save processing results
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		 
                resFile = 'results.csv'; 
                dlmwrite(resFile, [fm,lat,lon,PTVdB(1),Hnormal], "-append");

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Show plots
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		if (ploton!=1)					% If and only if plots are activated
			return;
		end	
		
		figure(411);					
		plot(f,amplitude);
		set(gca, "fontsize", 20);	

		%title([ 'Spectrum Analysis from ' num2str(fstart/1e6) ' MHz to ' num2str(fstop/1e6) ' MHz @' num2str(lat,'%3.6f') ',' num2str(lon,'%3.6f')]);
		xlabel('f/Hz');
		ylabel('|H|');

		Hmax = max(amplitude);
		axis([fstart fstop 0 1.1*Hmax]);
		grid on;
		set(gca,'xtick',fstart:10e6:fstop);% grid
			
		figure(412);						% This is the smooth signal	
		plot(f,amplitudeS);
		set(gca, "fontsize", 18);	
		%title([ 'Spectrum Analysis from ' num2str(fstart/1e6) ' MHz to ' num2str(fstop/1e6) ' MHz (LP Filter Smooting)  @' num2str(lat,'%3.6f') ',' num2str(lon,'%3.6f')]);
		Hmax = max(amplitudeS);
		axis([fstart fstop 0 1.1*Hmax]);
		grid on;
			
		figure(413);						% Introduce average power
		Hmax = max(amplitudedB);
		Hmin = -35;
		
		plot(f,amplitudedB,f,PTVdB,'r','LineWidth',2);
		set(gca, "fontsize", 20);		
		%text(fstart+B,PTVdB(1)-3, ['20*log(|Htv,avg|) = ' num2str(PTVdB(1)) ' |Htv,avg| = ' num2str(PTV(1))]);
		axis([fstart fstop Hmin 1.1*Hmax])
		
		xlabel('f/Hz');
		ylabel('|Htv,avg| in dB');
		%title([ 'Spectrum Analysis from ' num2str(fstart/1e6) ' MHz to ' num2str(fstop/1e6) ' MHz (LP Filter Smooting)  @' num2str(lat,'%3.6f') ',' num2str(lon,'%3.6f')]);

		set(gca,'xtick',fstart:10e6:fstop);% grid
		set(gca,'ytick',round(Hmin/10)*10:10:round((0.9*Hmax)/10)*10);
		grid on;			

endfunction;
