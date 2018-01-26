function handles = find_foot_flat_times( handles )
%FIND_FOOT_FLAT_TIMES Determine the foot on ground times from vicon data
%   Detailed explanation goes here
%
%


% Author: Peggy Skelly
% 2017-08-16: create 


if ~isfield(handles, 'vicon_data')
	disp('No vicon data to compute events.')
	return
end

% time 
t = handles.vicon_data.markers.tbl.Frame / handles.vicon_data.markers.samp_freq;

% use toe and heel x, y, z, pos, vel & acc
left.toe = get_data(handles.vicon_data.markers.tbl, 'LTOE');
left.heel = get_data(handles.vicon_data.markers.tbl, 'LHEE');

right.toe = get_data(handles.vicon_data.markers.tbl, 'RTOE');
right.heel = get_data(handles.vicon_data.markers.tbl, 'RHEE');

% compute heel strike & toe off events
l_foot_on_floor = find_ff_times(handles, t, left);
r_foot_on_floor = find_ff_times(handles, t, right);

% save info in a struct
handles.event_struct.rff = r_foot_on_floor;
handles.event_struct.lff = l_foot_on_floor;

return  % find_foot_flat_times


% ---------------------------------------------------------------------------
function data = get_data(tbl, marker)
data.x.pos = tbl(:, [marker '_X_mm']);
data.y.pos = tbl(:, [marker '_Y_mm']);
data.z.pos = tbl(:, [marker '_Z_mm']);
data.x.vel = tbl(:, [marker '_X_vel_mm_per_s']);
data.y.vel = tbl(:, [marker '_Y_vel_mm_per_s']);
data.z.vel = tbl(:, [marker '_Z_vel_mm_per_s']);
data.x.acc = tbl(:, [marker '_X_acc_mm_per_s_2']);
data.y.acc = tbl(:, [marker '_Y_acc_mm_per_s_2']);
data.z.acc = tbl(:, [marker '_Z_acc_mm_per_s_2']);
return


% ---------------------------------------------------------------------------
function t_foot_on_floor = find_ff_times(handles, t, toe_heel_data)
% Because there seems to be drift in the z pos data, can't just find when the z
% pos is below a threshold and assume the foot is on the ground.

threshold = str2double(handles.ed_y_vel_thresh.String);	% below thresh, foot is on the ground ( mm_s)
duration = str2double(handles.ed_y_vel_dur.String);  % seconds - data should be below threshold for this long
npts = duration / (t(2)-t(1));
% foot_on_floor_ind_list = find_span_start(abs(table2array(toe_heel_data.toe.y.vel)) < threshold, npts); % ind of the beginning of probable foot on floor
[ff_ind_beg_list, ff_ind_end_list] = find_continuous(abs(table2array(toe_heel_data.toe.y.vel)) < threshold, npts); % ind of beg & end of probable foot on floor
ff_ind_mid_list = floor(mean([ff_ind_end_list;ff_ind_beg_list],1));
% convert inds to times
t_foot_on_floor = t(ff_ind_mid_list);
return


% % ---------------------------------------------------------------------------
% function [startPos] = find_span_start(logical_data, npts)
% %logical_data is a logical array
% 
% if size(logical_data,1) > 1, logical_data = logical_data'; end % make it a row vector
% 
% %we thus want to calculate the difference between rising and falling edges
% logical_data = [false, logical_data, false];  %pad with 0's at ends
% edges = diff(logical_data);
% rising = find(edges==1);     %rising/falling edges
% falling = find(edges==-1);  
% spanWidth = falling - rising;  %width of span of 1's (above threshold)
% wideEnough = spanWidth >= npts;   
% startPos = rising(wideEnough);    %start of each span
% %endPos = falling(wideEnough)-1;   %end of each span
% %all points which are in the npts span (i.e. between startPos and endPos).
% %allInSpan = cell2mat(arrayfun(@(x,y) x:1:y, startPos, endPos, 'uni', false));  
% 
% return % find_span_start



