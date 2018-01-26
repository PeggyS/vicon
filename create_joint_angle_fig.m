function handles = create_joint_angle_fig(handles, side)

if ~isfield(handles, 'vicon_data') 
	return
end
if ~isfield(handles.vicon_data, 'model_outputs')
	warning('No model outputs in the vicon data')
	return
end

% time
t = handles.vicon_data.model_outputs.tbl.Frame / handles.vicon_data.model_outputs.samp_freq;
% joint angles
ankle_var = [upper(side(1)) 'AbsAnkleAngle_X_deg'];
knee_var = [upper(side(1)) 'KneeAngles_X_deg'];
hip_var =  [upper(side(1)) 'HipAngles_X_deg'];

if is_table_variable(handles.vicon_data.model_outputs.tbl, hip_var)
	hip_angle = handles.vicon_data.model_outputs.tbl.(hip_var);
else
	hip_angle = nan(size(t));
end
if is_table_variable(handles.vicon_data.model_outputs.tbl, knee_var)
	knee_angle = handles.vicon_data.model_outputs.tbl.(knee_var);
else
	knee_angle = nan(size(t));
end
if is_table_variable(handles.vicon_data.model_outputs.tbl, ankle_var)
	ankle_angle = handles.vicon_data.model_outputs.tbl.(ankle_var);
else
	ankle_angle = nan(size(t));
end

% the figure
handles.joint_angle_fig = figure('position', [1000         438         640         900], ...
	'Tag', 'joint_angle_fig');
% save the main gui figure in the userdata of the joint angle figure
handles.joint_angle_fig.UserData.parent_gui = handles.figure1;



h_ax_hip = subplot(3,1,1);
plot(t, hip_angle)
title({side;'Hip'})
ylabel('Angle (°)')


h_ax_knee = subplot(3,1,2);
plot(t, knee_angle)
title('Knee')
ylabel('Angle (°)')

h_ax_ankle = subplot(3,1,3);
plot(t, ankle_angle)
title('Ankle')
ylabel('Angle (°)')
xlabel('Time (s)')

handles.joint_angle_fig.UserData.linkprop = linkprop([h_ax_hip, h_ax_knee, h_ax_ankle],'XLim');

if ~isfield(handles, 'event_struct')
	return
end

hs_str = [lower(side(1)) 'hs'];
to_str = [lower(side(1)) 'to'];
% heel strikes - black lines
add_event_lines(h_ax_hip, handles.event_struct.(hs_str), 'k', hs_str)
add_event_lines(h_ax_knee, handles.event_struct.(hs_str), 'k', hs_str)
add_event_lines(h_ax_ankle, handles.event_struct.(hs_str), 'k', hs_str)
% toe off - green lines
add_event_lines(h_ax_hip, handles.event_struct.(to_str), [0 0.8 0.1], to_str)
add_event_lines(h_ax_knee, handles.event_struct.(to_str), [0 0.8 0.1], to_str)
add_event_lines(h_ax_ankle, handles.event_struct.(to_str), [0 0.8 0.1], to_str)
