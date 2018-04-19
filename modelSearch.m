function [z,finalErr] = modelSearch(model, targetframes)

	%% INITIALIZE MULTI-THREADING ==============================================
	mv = version('-release');
	switch mv
		case '2013a'
			poolSize = matlabpool('size');
			if poolSize == 0
				warning('cellID: Matlabpool not open, opening for multithreading...');
				matlabpool('open');					% if the number of cores used isn't the right one, run cluster profile manager to set.
			end
			poolSize = matlabpool('size');			% double check
			if poolSize == 0
				warning('cellID: Failed to open Matlabpool for multithreading, loop run in sequential mode');
			else
				fprintf('cellID: multithreading using %d cores\r',poolSize);
			end
		case '2015a'
			delete(gcp);
			parpool;
	end
	%% RUN OPTIMIZATION

    % take initial guess from model information.
    for i=1:model.N
       guess(i) = model.xyz0(i,3); % initial guess always rotation axis in y, which is closer to real cell rotation axis
    end
    
% 	lowerbound = ones(1,model.N)*(model.c(3)-model.R);
% 	upperbound = ones(1,model.N)*(model.c(3)+model.R);
	lowerbound = ones(1,model.N).*([1 1] + model.r*2);
	upperbound = ones(1,model.N).*(model.box - model.r*2);

	options = optimoptions(@fmincon,'Algorithm','interior-point');
	options = optimoptions(options, 'UseParallel', 'never');	% never use parallel is important here to enable parfor in the error function
    problem = createOptimProblem('fmincon','objective',@(z) modelSearchErr(z,model,targetframes),'x0',guess,'lb',lowerbound,'ub',upperbound,'options',options);
	gs = GlobalSearch('Display','iter','TolX',1);
	[z,finalErr] = run(gs,problem);
	
end

function modelErr = modelSearchErr(z,model,targetframes)

	% 1. Setting up model according to new z parameters.
	for i=1:length(z)
		model.xyz0(i,3) = z(i);	% setting the temporary z value for this guess
	end

	% 2. Getting error for each frame, parallel processing!
	N = length(targetframes);	% number of frames to be matched
	parfor i=1:N
		[axisangle{i},frameErr(i)] = rotationSearch(model, targetframes{i},'geneticalgorithm');
	end
	modelErr = sum(frameErr);

	outputSearchMovie(model, axisangle, frameErr, targetframes)
	fprintf('modelSearchErr error:%d\r',modelErr);
end



function outputSearchMovie(model, axisangle, frameErr, targetframes)
	fprintf('%0.2f ',model.xyz0(:,3));
	fprintf('\r');
	
	% display
		N = length(targetframes);	% number of frames to be matched
		RGB = zeros(model.box(1),model.box(2),3,N);
		for i=1:N
			proj2D = projectModel(model,axisangle{i});
			RGB(:,:,1,i) = targetframes{i};
			RGB(:,:,2,i) = proj2D;
		end
		close all;
		
	% create filepath
		fp = [pwd '\modelsearch\'];
		fp_pic = [fp 'pic\'];
		if ~exist(fp,'dir')
			mkdir(fp);
			mkdir(fp_pic);
		end
	
	% write to figure
		h = figure;
		montage(RGB); drawnow;
		I_screen = getframe(h);
		fnstring = sprintf('%0.3f_',model.xyz0(:,3));
		imwrite(I_screen.cdata,[fp_pic 'z_' fnstring 'error_' num2str(sum(frameErr)) '.png'],'png');
	
	% write to files 1
		fid = fopen([fp 'results_z_search.txt'],'a');
		for i=1:model.N
			fprintf(fid,'spot %d (xyz): ',i);
			fprintf(fid,'%0.2f %0.2f %0.2f ',model.xyz0(i,1),model.xyz0(i,2),model.xyz0(i,3));
		end
		fprintf(fid,'\r');
		fclose(fid);
	
	% write to file 2
		fid = fopen([fp 'results_rotation_search.txt'],'a');
		for i=1:N
			fprintf(fid,'frame %d: ',i);
			fprintf(fid,'%0.2f %0.2f %0.2f %0.2f ',axisangle{i}(1),axisangle{i}(2),axisangle{i}(3),axisangle{i}(4));
			fprintf(fid,'%0.2f ',frameErr(i));
		end
		fprintf(fid,'\r');
		fclose(fid);
	
	% write to files 3
		fid = fopen([fp 'results_iteration_error.txt'],'a');
		fprintf(fid,'%f\r',sum(frameErr));
		fclose(fid);
	
end
