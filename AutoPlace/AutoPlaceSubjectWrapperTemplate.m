
close all
clear all
clc

global myModel fileID markerScale divisor iteration

% Create strings for the subject name and type of prosthesis. For file naming and labeling only.
subject = 'A07';
prosType = 'passive';


import org.opensim.modeling.*

iteration = 1;
markerScale = 1;
divisor = 1;

% downSample the passive .trc file for speed, do not downsample for most accurate results
file_input = 'Passive_Pref0002.trc'; 	% Your marker tracking .trc file
file_output = 'Chopped.trc';			% Leave this, used in other functions
downSampleTRC(divisor,file_input,file_output)

% create new file for log of marker search
fileID = fopen(['coarseMarkerSearch_log_' subject '_' prosType '_' char(datetime('now','TimeZone','local','Format','d-MMM-y_HH.mm.ss_Z')) '.txt'], 'w'); 


myModel = [subject '_' prosType '_pre_auto_marker_place.osim'];	% define .osim model used as the starting point
newName = [subject '_' prosType '_ROB_auto_marker_place.osim'];	% set name for new .osim model created after placing ROB markers

% Set model and algorithm options:
options.modelFolder = [pwd '\Models\'];
options.IKsetup = 'markerOptIKSetup.xml';	% Specify the IK setup file used to configure IK
% options.limbScaleFactor = limbScaleFactor;  % segment scale factor
options.model = myModel;                    % generic model name
options.subjectMass = 73.1637;
options.newName = newName;

% Choose which set of bodies/markers is being placed. 'ROB' = Rest of
% body, 'pros' = Markers on the prosthesis, 'prosThigh' = Thigh markers on
% the prosthesis side and the socket joint center of rotation:
options.bodySet = 'ROB';

% List marker coordinates to be locked - algorithm cannot move them from
% hand-picked location:
options.fixedMarkerCoords = {'L_HEEL_SUP y','L_TOE x','L_TOE y','L_TOE z', 'L_THIGH_PROX_ANT x'};

% Specify frame from .trc file at which socket flexion should be minimized (zero-crossing of horizontal GRF in this case):
options.flexionZero = 98; 

% Specify marker search convergence threshold. All markers must move less 
% than convThresh mm from start position at each markerset iteration to 
% converge. If 1, a full pass with no marker changes must take place:
options.convThresh = 1; 

tic

X_ROB = coarseMarkerSearch(options);
model = Model('autoScaleWorker.osim');
model.initSystem();
model.print(newName);

myModel = newName;
newName = [subject '_' prosType '_PROS_auto_marker_place.osim'];
options.bodySet = 'pros';
X_pros = coarseMarkerSearch(options);
model = Model('autoScaleWorker.osim');
model.initSystem();
model.print(newName);

myModel = newName;
newName = [subject '_' prosType '_FULL_auto_marker_place.osim'];
options.bodySet = 'prosThigh';
X_prosThigh = coarseMarkerSearch(options);
model = Model('autoScaleWorker.osim');
model.initSystem();
model.print(newName);

fclose(fileID);