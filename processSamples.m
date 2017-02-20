%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author:	Max
% Date: 	17.02.2017
% File: 	processSamples.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function processSamples (dir)

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
		Hnormal = 15559.216				% Av. power in front of the tower		
		
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

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Show plots
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		subplot(411);				
		plot(f,amplitude);

		title([ 'Spectrum Analysis from ' num2str(fstart/1e6) ' MHz to ' num2str(fstop/1e6) ' MHz @' num2str(lat,'3.6f') ',' num2str(lon,'3.6f')]);
		xlabel('f/Hz');
		ylabel('|H|');

		Hmax = max(amplitude);
		axis([fstart fstop 0 1.1*Hmax]);
		grid on;
	
		subplot(412);						% Smooth out signal
		wndwSize = 2048;
		h = (ones(1,wndwSize)/wndwSize);
		amplitude = filter(h, 1, amplitude); 
		plot(f,amplitude);
		title([ 'Spectrum Analysis from ' num2str(fstart/1e6) ' MHz to ' num2str(fstop/1e6) ' MHz (LP Filter Smooting)  @' num2str(lat,'%3.6f') ',' num2str(lon,'%3.6f')]);
		Hmax = max(amplitude);
		axis([fstart fstop 0 1.1*Hmax]);
		grid on;
			
		subplot(413);						% Introduce average power
		PTV = zeros(1,length(amplitude));			
		b = round((fm-5e6-fstart)/df);
		t = round((fm+5e6-fstart)/df);
		PTV(1,:) = mean(amplitude(b:t));		

		amplitude = amplitude / Hnormal;			% Normalizing
		amplitude = 20*log10(amplitude);
		PTVdB = 20*log10(PTV/Hnormal);
		Hmax = max(amplitude);
		Hmin = -35;
		
		plot(f,amplitude,f,PTVdB,'r','LineWidth',2);
		text(fstart+B,PTVdB(1)-3, ['20*log(|Htv,avg|) = ' num2str(PTVdB(1)) ' |Htv,avg| = ' num2str(PTV(1))]);
		axis([fstart fstop Hmin 1.1*Hmax])
		
		xlabel('f/Hz');
		ylabel('|Htv,avg| in dB');
		title([ 'Spectrum Analysis from ' num2str(fstart/1e6) ' MHz to ' num2str(fstop/1e6) ' MHz (LP Filter Smooting)  @' num2str(lat,'%3.6f') ',' num2str(lon,'%3.6f')]);

		set(gca,'xtick',fstart:2e6:fstop);% grid
		set(gca,'ytick',round(Hmin/10)*10:10:round((0.9*Hmax)/10)*10);
		grid on;			
endfunction;
