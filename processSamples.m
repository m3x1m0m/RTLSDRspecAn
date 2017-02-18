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
		fs = conf(1);
		fstart = conf(2);
		N = conf(3);
		B = conf(4);
		fc = fs/2;					% Cutoff frequency
		df = fs/N;					% Frequency resolution
		fstop = B * fc + fstart;			% Stop freq
		
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Clue samples together
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
		for i = 0:(B - 1)		
			Raw = dlmread([dir '/samp_' num2str(i) '.csv']);	% Read raw data 
			H = fft(Raw, N);			% Perform FFT clue
			H = H(1:N/2);	
			Ha( (i*(N/2)+1) : ((i+1)*(N/2)) ) = H;   	
		end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Process samples
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		amplitude = abs(Ha);				% Normalize and take abs()
		Hmax = max(amplitude);
		amplitude = amplitude / Hmax;

		f = linspace(fstart, fstop, B*(N/2));		% Generate acc. freq. vector

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Show plots
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		subplot(411);				
		plot(f,amplitude);

		title([ 'Spectrum Analysis from ' num2str(fstart/1e6) ' MHz to ' num2str(fstop/1e6) ' MHz']);
		xlabel('f/Hz');
		ylabel('|H|');

		Hmax = max(amplitude);
		axis([fstart fstop 0 1.1*Hmax]);
		grid on;
	
		subplot(412);				% Smooth out signal
		wndwSize = 16;
		h = (ones(1,wndwSize)/wndwSize).*hamming(wndwSize);
		amplitude = filter(h, 1, amplitude); 
		plot(f,amplitude);
		title([ 'Spectrum Analysis from ' num2str(fstart/1e6) ' MHz to ' num2str(fstop/1e6) ' MHz' '(Hamming)']);
		axis([fstart fstop 0 1.1*Hmax]);
		grid on;
			
		
	
		amplitude = 20*log(amplitude);			% Same in dB this is power!
		subplot(413);
		plot(f,amplitude);

		xlabel('f/Hz');
		ylabel('|H|');

		Hmax = max(amplitude);
		Hmin = min(amplitude);
		axis([fstart fstop -60 20])
		set(gca,'xtick',fstart:1e6:fstop);% grid
		set(gca,'ytick',round(Hmin/10)*10:10:round((0.9*Hmax)/10)*10);
		grid on;

endfunction;
