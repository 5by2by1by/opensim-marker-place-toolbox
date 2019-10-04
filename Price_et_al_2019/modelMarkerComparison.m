%-------------------------------------------------------------------------% 
% modelMarkerComparison.m
% 
% This file pulls the model marker locations from both a manual and 
% autoplaced OpenSim model and calculates the change for each marker.
% Files and directories are dependent on the location of the files on this
% pc, if the directories change you will have to relocate the files. 
% 
% Before running, ensure the following folders are in the parent working
% directory:
%     IKErrors        Where marker errors are written for each trial
%     IKResults       Where kinematic results are  written for each trial
%     IKSetup         Contains generic setup file and trial specific setup 
%                     files are written
%     MarkerData      Contains marker trajectory files for each trial
%     ModelsScaled    Contains the models used in IK
%
% Before running, modify script options cell appropriately.
% 
% Written by Mark Price 07/2019
% Last modified 07/10/2019
%
%-------------------------------------------------------------------------%

close all
clear all
clc

%% script options

% Create strings for the subject name and type of prosthesis.
subjNames = {'S01','S02','S04','S05','S06','S08','S09','S10'};
numSubj = length(subjNames);

% Also define paths to individual subject and model folders in options structure
for i = 1:numSubj
    
    subjDir{i} = [pwd '\' subjNames{i} '\'];
    
    % specify model folder
    manModelDir{i} = [subjDir{i} 'Models\Scaled\'];
    autoModelDir{i} = [subjDir{i} 'Models\AutoPlaced\'];
end

%% Pull OpenSim modeling classes, specify folders and define ikTool

% Pull in the modeling classes straight from the OpenSim distribution
import org.opensim.modeling.*

autoModelTag = '_no-amp_ALLBODY_auto_marker_place_10tilt_lockedasis.osim';
manModelTag = '_RRA_Model_newmass.osim';

lowerLimbIndices = {14:49,14:49,14:49,14:48,14:49,14:49,14:49,14:49};

for i = 1:numSubj
    autoModels{i} = [subjNames{i} autoModelTag];
    manModels{i}  = [subjNames{i} manModelTag];
    
    autoModelFile = [autoModelDir{i} autoModels{i}];
    manModelFile = [manModelDir{i} manModels{i}];
    autoModel = Model(autoModelFile);
    autoModel.initSystem();
    manModel = Model(manModelFile);
    manModel.initSystem();
    
    autoMarkerSet = autoModel.getMarkerSet();
    for j = 1:autoMarkerSet.getSize()
        autoMarkers{i,j}(1) = autoMarkerSet.get(j-1).getOffset().get(0);
        autoMarkers{i,j}(2) = autoMarkerSet.get(j-1).getOffset().get(1);
        autoMarkers{i,j}(3) = autoMarkerSet.get(j-1).getOffset().get(2);
    end
    
    manMarkerSet = manModel.getMarkerSet();
    for j = 1:manMarkerSet.getSize()
        manMarkers{i,j}(1) = manMarkerSet.get(j-1).getOffset().get(0);
        manMarkers{i,j}(2) = manMarkerSet.get(j-1).getOffset().get(1);
        manMarkers{i,j}(3) = manMarkerSet.get(j-1).getOffset().get(2);
        
        markerDiff{i,j} = autoMarkers{i,j} - manMarkers{i,j};
        markerDiffMag(i,j) = norm(markerDiff{i,j});
    end
    
    maxDiff(i) = max(markerDiffMag(i,:),[],2);
    maxDiffLowerLimb(i) = max(markerDiffMag(i,lowerLimbIndices{i}),[],2);
    meanDiffLowerLimb(i) = mean(markerDiffMag(i,lowerLimbIndices{i}),2);
    medianDiffLowerLimb(i) = median(markerDiffMag(i,lowerLimbIndices{i}),2);
end

meanDiffLowerLimbOverall = mean(meanDiffLowerLimb);
medianDiffLowerLimbOverall = median(medianDiffLowerLimb);
    