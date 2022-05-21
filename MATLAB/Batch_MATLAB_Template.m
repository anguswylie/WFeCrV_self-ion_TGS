%%%%%%%%%%%%%%%%%%%
%Either run from directory containing all raw TGS data files for this exposure, or change directory here
pname = 'C:\Users\apcwy\Dropbox (The University of Manchester)\Physics PhD\MIT_2022\TGS_Data\Tungsten_Calibration\2022-01-10';
dir=cd(pname);
%%%%%%%%%%%%%%%%%%%
close all;

grat=6.4703; % pulled from metadata in first file, in microns
overlay1=1;	% pulled from metadata in first file
overlay2=1;	% pulled from metadata in first file

posstr='Tungsten_Calibration-2022-01-10-06.40um-spot1-POS-1.txt';
negstr='Tungsten_Calibration-2022-01-10-06.40um-spot1-NEG-1.txt';

EndTime=5000;	% automatically extracted from first file to analyze

TimeIndex=20;  % Loop through these in a script to determine the best one

%TGSPhaseAnalysis(posstr,negstr,grat,2,0,EndTime,overlay1,overlay2,TimeIndex);

%[freq_final,freq_error,speed,diffusivity,diffusivity_err,tau] 
[freq_final,freq_error,speed,diffusivity,diffusivity_err,tau, tauErr, paramrA, AErr, ParamBeta, BetaErr, paramB, BErr, paramTheta, thetaErr, paramC, CErr] = TGSPhaseAnalysis(posstr,negstr,grat,2,0,overlay1,overlay2);
disp('Frequency = ');
disp(freq_final);
disp('Frequency error = ');
disp(freq_error);
disp('=> grating spacing on tungsten sample(m): ');
disp(2665.9/freq_final);
disp('with and error of (m): ');
disp(2665.9*freq_error/(freq_final*freq_final));
disp('Thermal diffusivity = ');
disp(diffusivity);
disp('Thermal diffusivity error = ');
disp(diffusivity_err);


% path to files
%sampleName = string('EFRWMap') + num2str(filenumber);
%fileString = string('\') + sampleName + '.cpr';
%disp("--------------------------------------------------------------------------------");
%disp("Current file is: " + sampleName);
%printFile3 = pname + string('\CompiledStageXY.txt');
%fid3 = fopen( printFile3, 'a' );
%fnStr = num2str(filenumber);
%printStr = fnStr + string(' ') + XPos + string(' ') + YPos + string('\n');
%fprintf(fid3, printStr);
%fclose(fid3);