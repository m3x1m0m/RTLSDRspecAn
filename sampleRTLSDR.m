%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author:	S3xm3x
% Date: 	17.02.2017
% File: 	sampleRTLSDR.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function samplefile = sampleRTLSDR(fs,fstart,N,B,lat,long,fm)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Vars
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		fc = fs/2;				% Cutoff frequency
		df = fs/N;				% Frequency resolution
		fstop = B * fc + fstart;		% Stop freq
		filename = '/tmp/capture.bin';		% Filename for temporary storage
		system('echo ''----------------------------------------------------------------------------------------------------------''');
		system(['echo ''fc = ' num2str(fc/1e6) ' MHz N = ' num2str(N) ' B = ' num2str(B) ' df = ' num2str(df/1e3) ' KHz fstart = ' num2str(fstart/1e6) ' MHz fstop = ' num2str(fstop/1e6) ' MHz''']);
		 system('echo ''----------------------------------------------------------------------------------------------------------''');

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Get samples
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
		% Create directory
		sampFile = strftime ('%Y_%m_%d_%H_%M_%S', localtime (time ()));
		if exist(['samples_' sampFile]', 'dir') ~= 7;
		       	system(['mkdir ' 'samples_' sampFile] );
			% Return value
			samplefile = ['samples_' sampFile];
		end

		for i = 0:(B - 1)	
			% Move further by ft
			ft = i*fc + fstart;
			% Command for sampling	
			rtlsdr_cmd = ['rtl_sdr ' filename ' -s ' num2str(fs) ' -f ' num2str(ft) ' -g 40 -n ' num2str(N)];
			system(rtlsdr_cmd);

			% Convert sampled data
			fid = fopen(filename,'rb'); 
			Raw = fread(fid,'uint8=>double'); 
			Raw = Raw-127.5; 
			Raw = Raw(1:2:end) + j*Raw(2:2:end);
			fclose(filename);
		
			% Wite data into a file
			% Just in case you want to do something else with it later 
			dlmwrite(['samples_' sampFile '/samp_' num2str(i) '.csv'], Raw); 	
		end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Save configuration
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		dlmwrite(['samples_' sampFile '/conf.csv'], [fs,fstart,N,B,lat,long,fm]);
		system('echo ''----------------------------------------------------------------------------------------------------------''');
		system(['echo ''fc = ' num2str(fc/1e6) ' MHz N = ' num2str(N) ' B = ' num2str(B) ' df = ' num2str(df/1e3) ' KHz fstart = ' num2str(fstart/1e6) ' MHz fstop = ' num2str(fstop/1e6) ' MHz''']);
		 system('echo ''----------------------------------------------------------------------------------------------------------''');
	
endfunction;
