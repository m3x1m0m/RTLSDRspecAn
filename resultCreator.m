%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author:       Max
% Date:         23.02.2017
% File:         resultCreator.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Vars
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		fileSyllable = '003samples/samples_';
		fileRes = 'results.csv';
		R = 6371e3; 							% Earth radius
		rad = pi/180;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Collect samples and produce a result
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		[status,list]=system(['ls -d ' fileSyllable '*/']);		% Get a list of all relevant files
		A = strread(list, '%s', 'delimiter', sprintf('\n'));
		for i = 1:(numel(A))
			B = cell2mat(A(i));
			processSamples(B,0);					% Deactivate plotting	
		end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Use haversine function to calculate distances
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		D = dlmread(fileRes);						% matrix to draw
		%x = D(:,3);
		%y = D(:,2);
		%z = 10.^(D(:,4)/10);
		%n = 256;
		%Longmax = max(x)
		%Latmax	= max(y)		
		%Longmin = min(x)
		%Latmin = min(y)
		%[X, Y] = meshgrid(linspace(min(x),max(x),n), linspace(min(y),max(y),n));
		%Z = griddata(x,y,z,X,Y);
		%Z(isnan(Z)) = 0;	
		%imshow(Z);
		%contourf(peaks);
		%colormap('autumn');
		%colorbar;
	
		f474 = [];							% Create new matrizes for only 1 freq.
		f594 = [];
		f626 = [];
	
		for i = 1:length(D)						% Do the sorting
			switch(D(i,1))                                      
                        	case 474e6
                                	f474 = [f474; [D(i,2) D(i,3) D(i,4)]];
                        	case 594e6
                                	f594 = [f594; [D(i,2) D(i,3) D(i,4)]];
                        	case 626e6
                                	f626 = [f626; [D(i,2) D(i,3) D(i,4)]];
                        	otherwise
                                	SomethingWentWrong = 0
                	end
		end
		
		[dc,f474max] = max(f474(:,3));					% Getting the source of the signal
		[dc,f594max] = max(f594(:,3));
		[dc,f626max] = max(f626(:,3));
	
		[r,c] = size(f474);						% Computing the distance using the haversine func
		f474 = [f474 [zeros(r,1)]];
		for i = 1:length(f474)	
			f474(i,:) = [f474(i,1:3) haversine(f474(f474max,1),f474(i,1),f474(f474max,2),f474(i,2))];
		end	
		f474 = sortrows(f474,4);
		
		[r,c] = size(f594);						
		f594 = [f594 [zeros(r,1)]];
		for i = 1:length(f594)	
			f594(i,:) = [f594(i,1:3) haversine(f594(f594max,1),f594(i,1),f594(f594max,2),f594(i,2))];
		end	
		%f594 = sortrows(f594,4);
		
		[r,c] = size(f626);					
		f626 = [f626 [zeros(r,1)]];
		for i = 1:length(f626)	
			f626(i,:) = [f626(i,1:3) haversine(f626(f626max,1),f626(i,1),f626(f626max,2),f626(i,2))];
		end	
		f626 = sortrows(f626,4);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Plot signal_strength(distance)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		d = linspace(1,10e3,1000);
		F474 = -20*log10((4*pi*d*474e6)/3e8);	
		F594 = -20*log10((4*pi*d*594e6)/3e8);
		F626 = -20*log10((4*pi*d*626e6)/3e8);
		fig = plot(f474(:,4),f474(:,3),'r.',f594(:,4),f594(:,3),'g.',f626(:,4),f626(:,3),'b.');
		set(fig,'MarkerSize',20);
		set(fig,'LineWidth',20);
		hold on;
		xlabel('d/m');
		ylabel('A/dB');
		grid on;
		%plot(d,F474,'r',d,F594,'b',d,F626,'g');
