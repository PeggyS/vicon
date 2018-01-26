function draw_marker_line(h_ax, marker_struc, marker, varargin)

% Inputs:
%		h_ax = handle to the axes where the data is displayed
%		marker_struc = struct with fields
%				samp_freq
%				tbl - table with the global position (vicon trajectory) of each marker
%		marker = string containing the name of the marker to display

% Author: Peggy Skelly
% 2017-08-03: create 

% create a time vector
t = marker_struc.tbl.Frame / marker_struc.samp_freq;
try
	line(h_ax, t, marker_struc.tbl.(marker), varargin{:});
catch ME
	warning('Error adding line for %s', marker)
end