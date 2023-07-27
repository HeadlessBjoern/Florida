%% Master script for the Florida / IAPS project

% - X trials of XXXXX

%% General settings, screens and paths

% Set up MATLAB workspace
clear all;
close all;
clc;
rootFilepath = pwd; % Retrieve the present working directory

% define paths
PPDEV_PATH = '/home/methlab/Documents/MATLAB/ppdev-mex-master'; % for sending EEG triggers
TITTA_PATH = '/home/methlab/Documents/MATLAB/Titta'; % for Tobii ET
DATA_PATH = '/home/methlab/Desktop/Florida/data'; % folder to save data
FUNS_PATH = '/home/methlab/Desktop/Florida' ; % folder with all functions

% make data dir, if doesn't exist yet
mkdir(DATA_PATH)

% add path to folder with functions
addpath(FUNS_PATH)

% manage screens
screenSettings

%% Collect subject infos 
dialogID;

%% Protect Matlab code from participant keyboard input
ListenChar(2);

%% Set up stimuli list
stimID;

for stims = 1:numel(stimIDs)
    % Randomize stimulus list
    randStim(stims) = randi([1, numel(stimIDs)]);
end

%% Run IAPS
IAPS;

%% Allow keyboard input into Matlab code
ListenChar(0);