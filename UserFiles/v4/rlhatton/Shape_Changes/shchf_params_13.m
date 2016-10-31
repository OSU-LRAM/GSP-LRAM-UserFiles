function output = shchf_params_13(input_mode)

	% Default argument
	if ~exist('input_mode','var')
		
		input_mode = 'initialize';
		
	end
		
	% Name the .mat file with the fourier coefficients
	paramfile = 'params_13';
	
	
	switch input_mode
		
		case 'name'
			
			output = 'params_13';
			
		case 'dependency'
			
			output.dependency = {fullfile(pwd,[paramfile '.mat'])};
			
		case 'initialize'

			%%%%
			%%
			%Path definitions

			% Load the points that the user clicked and the time vector
			load(paramfile)
            
            % Check if start and end are the same point, and set boundary
            % conditions accordingly
            if alpha1(1)==alpha1(end) && alpha2(1)==alpha2(end)
                splinemode = 'periodic';
            else
                splinemode = 'complete';
            end
            
            % Generate spline structures for the selected points
            switch splinemode
                
                case 'periodic'
                    
                    % Fit a periodic spline to the selected points; the endslopes are found
                    % by averaging the positions of the points before and after the join
                    endslope1 = (alpha1(2)-alpha1(end-1))/(t(end)-t(end-2));
                    endslope2 = (alpha2(2)-alpha2(end-1))/(t(end)-t(end-2));
                    spline_alpha1 = spline(t,[endslope1;alpha1(:);endslope1]);
                    spline_alpha2 = spline(t,[endslope2;alpha2(:);endslope2]);
                    
                case 'complete'
                    
                    % Fit a non-periodic spline to the selected points
                    spline_alpha1 = spline(t,alpha1(:));
                    spline_alpha2 = spline(t,alpha2(:));

            end
            
            % The gait path is now defined by evaluating the two splines at
            % specified times
			p.phi_def = @(t) [ppval(spline_alpha1,t(:)),ppval(spline_alpha2,t(:))];
            
            
            % Speed up execution by defining the gait velocity as well (so
            % the evaluator doesn't need to numerically take the derivative
            % at every time
            spline_dalpha1 = ppdiff(spline_alpha1);
            spline_dalpha2 = ppdiff(spline_alpha2);	
            
            % The gait path is now defined by evaluating the two splin
            % derivatives at specified times
			p.dphi_def = @(t) [ppval(spline_dalpha1,t(:)),ppval(spline_dalpha2,t(:))];
 
			
			%marker locations
			p.phi_marker = [];
			
			%arrows to plot
			p.phi_arrows = 2;

			%time to run path
			p.time_def = t([1 end]); %#ok<COLND>


			%path resolution
			p.phi_res = 50;
			



			%%%%
			%Save the shch properties
			output = p;
	end
	
end