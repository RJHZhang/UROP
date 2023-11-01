%% %% Phase Matching
%  A script version of the Phase Matching GUI app. It allows users run the
%  automatic version of the code when the dataset is large on a HPC.
%
%  Author: Raymond Zhang
%  Created: 2023-07-24
%  Updated: 2023-11-01

close all; clc; clear;
addpath(genpath('utility'))


%% USERS INPUTS
disp('Initialising inputs');

InputData = input_data;
InputData.folder_path = 'C:\Users\rzha0171\Documents\GitHub\UROP\SampleData\CardiacCycle\';
InputData.filename_1 = '0-499-Nuc.tif';
InputData.filename_2 = '0-499-Ca.tif';   % optional
InputData.filename_3 = '';               % optional
InputData.main_ch = 2; % channel to be used for reference
InputData.phase = 5;  % frame to be used for reference

InputParams = input_params;
InputParams.n_scales = 5;
InputParams.min_peak_height = 0;
InputParams.min_peak_prominence = 0.05;

InputParams.ROI = [236, 183, 338, 337];     % x_start, y_start, x_end, y_end
InputParams.padding = 3;
InputParams.n_neighbours = 2;

Visibility = 'on'; % display figures or not
OutputFolder = 'PhaseMatchingOutput';
Output = '111';

disp('Inputs initialised');


%% Initiation
disp('Processing user inputs');
ImgRef = InputData.get_img;
figure('Visible',Visibility);
imshow(ImgRef);
title('This is our reference image for phase matching')
disp('User inputs processed')


%% Preliminary Phase Matching
disp('Performing preliminary phase matching');
SsimScoresMain = ssim_wrapper(ImgRef, InputData.main_path, 1:InputData.width, 1:InputData.height, 1:InputData.n_frames, InputParams.n_scales);
[Pks, PkLocs, N_pks, MeanDist] = find_peaks(SsimScoresMain, InputParams.min_peak_height, InputParams.min_peak_prominence, InputData.phase);

figure('Visible',Visibility);
plot(1:InputData.n_frames, SsimScoresMain); hold on;
plot(PkLocs, Pks, "*")
title(['ssim scores. ', num2str(N_pks), ' peaks found at an average distance of ', num2str(MeanDist)])
disp('Preliminary phase matching complete')


%% ROI Based Phase Matching
disp('Performing advanced phase matching');
[MatchedFrames, N_pks, MeanDist] = temporal_phase_matching(InputData, InputParams);
disp('Advanced phase matching complete');


%% Create movie
CutLength = InputParams.cut_length(MeanDist);
ImagesToSave = cell(InputData.n_channels, N_pks, 2*CutLength+1);
ImagesToSave = construct_movie(InputData.file_paths, ImagesToSave, MatchedFrames, CutLength);


%% Output
disp('Saving files');
OutputPath = [InputData.folder_path, OutputFolder];
mkdir(OutputPath);
javaaddpath('loci_tools.jar')

if Output(1) == '1'
    save_multitiff(N_pks, InputData.n_channels, CutLength, ImagesToSave, OutputPath)
end
if Output(2) == '1'
    save_single_phase(InputData.tif_info, N_pks, InputData.n_channels, CutLength, ImagesToSave, OutputPath, InputData.phase);
end
if Output(3) == '1'
    save_all_phase(InputData.tif_info, N_pks, InputData.n_channels, CutLength, ImagesToSave, OutputPath);
end
disp('Files saved');