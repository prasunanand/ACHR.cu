load('p/Projects/veryfastFVA/data/models/P_Putida/Pputida_model_glc_min.mat');%model putida
putida=model;
%%
%load warmup points
%3,000 (MATLAB)
warmupPts3000=createHRWarmup(putida,3000);
%5,000 (MATLAB)
warmupPts5000=createHRWarmup(putida,5000);
%2,120
warmup2120=csvread('P_Putida.mps2120warmup.csv');
%3,000
warmup3000=csvread('P_Putida.mps3000warmup.csv');
%5,000
warmup5000=csvread('P_Putida.mps5000warmup.csv');
%10,000
warmup10000=csvread('P_Putida.mps10000warmup.csv');
%%
%sampling 100,000 points 1000 steps
%cd 3000_warmup_Matlab
%ACHRSampler(putida, warmupPts3000, 'Putida3000M', 10, 10000, 1000, [], [], 3600*24, 1);
%cd ..
%cd 5000_warmup_Matlab
%ACHRSampler(putida, warmupPts5000, 'Putida5000M', 10, 10000, 1000, [], [], 3600*24, 1);
%cd ..
%
cd 2120_warmup_VF
ACHRSampler(putida, warmup2120, 'Putida2120', 10, 10000, 1000, [], [], 3600*24, 1);
cd ..
%
cd 3000_warmup_VF
ACHRSampler(putida, warmup3000, 'Putida3000', 10, 10000, 1000, [], [], 3600*24, 1);
cd ..
%
cd 5000_warmup_VF
ACHRSampler(putida, warmup5000, 'Putida5000', 10, 10000, 1000, [], [], 3600*24, 1);
cd ..
%
cd 10000_warmup_VF
ACHRSampler(putida, warmup10000, 'Putida10000', 10, 10000, 1000, [], [], 3600*24, 1);
cd ..
%
%%
%Check if they are solutions Sv=0

%%
%The sampling without FVA bounds

%%
figure;
subplot(2,2,1)
hist(warmupPts(1,:))
subplot(2,2,2)
hist(warmup10000(1,:))
subplot(2,2,3)
hist(warmup50000(1,:))
%%
for i=1:length(putida.rxns)
    if any(warmup50000(:,i) < putida.lb) || any(warmup50000(:,i)>putida.ub)
        i
    end
end
%%
%for i=1:length(putida.rxns)
    if any(centerPoint < putida.lb) || any(centerPoint > putida.ub)
        i
    end
%end

%%

for randPointID=1:5000
    randPointID;
            % Pick a random warmup point
            %randPointID = ceil(nWrmup*rand);
            randPoint = warmupPoints(:,randPointID);

            % Get a direction from the center point to the warmup point
            u = (randPoint-centerPoint);
            u = u/norm(u);

            % Figure out the distances to upper and lower bounds
            distUb = (maxFlux - prevPoint);
            distLb = (prevPoint - minFlux);

            % Figure out if we are too close to a boundary
            validDir = ((distUb > dTol) & (distLb > dTol));
            %model.rxns(~validDir)

            % Zero out the directions that would bring us too close to the
            % boundary. This may cause problems.
            %u(~validDir) = 0;

            % Figure out positive and negative directions
            posDirn = find(u(validDir) > uTol);
            negDirn = find(u(validDir) < -uTol);

            % Figure out all the possible maximum and minimum step sizes
            maxStepTemp = distUb(validDir)./u(validDir);
            minStepTemp = -distLb(validDir)./u(validDir);
            maxStepVec = [maxStepTemp(posDirn);minStepTemp(negDirn)];
            minStepVec = [minStepTemp(posDirn);maxStepTemp(negDirn)];

            % Figure out the true max & min step sizes
            maxStep = min(maxStepVec);
            minStep = max(minStepVec);
            %fprintf('%f\t%f\n',minStep,maxStep);

            % Find new direction if we're getting too close to a constraint
            if (abs(minStep) < maxMinTol & abs(maxStep) < maxMinTol) | (minStep > maxStep)
%                 fprintf('Warning %f %f\n',minStep,maxStep);
%                 save('warningData')
%                 continue;
            else
               randPointID 
            end
            
end

