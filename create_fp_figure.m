function handles = create_fp_figure(handles, fp_num, side)

if ~isfield(handles, 'vicon_data') 
	return
end

if ~isfield(handles.vicon_data, 'devices')
	disp('No FP data to display')
	return
end

fig_str = ['figure_fp' num2str(fp_num)];
fig_pos = [1673         935-(fp_num-1)*379         652         265];

% fp figure is saved in the main gui handles
handles.(fig_str) = figure('Pos', fig_pos);
% save the main gui figure in the userdata of the fp figure
handles.(fig_str).UserData.parent_gui = handles.figure1;
handles.(fig_str).Tag = fig_str;

% time 
% Frame = sec/100; Sub_Frame = milliseconds after the frame
t = handles.vicon_data.devices.tbl.Frame / 100 + handles.vicon_data.devices.tbl.Sub_Frame/1000;

fp_var = ['FP' num2str(fp_num) '_Force_Fz_N'];
h_line = plot(t, handles.vicon_data.devices.tbl.(fp_var), 'Tag', ['line_' fp_var]);
h_ax = h_line.Parent;

% save the data in the axes userdata
h_ax.UserData.vert_fp.t = t;
h_ax.UserData.vert_fp.data = handles.vicon_data.devices.tbl.(fp_var);

% the normalized ground reaction force from the vicon data's model outputs
% saved in axes user data so it can be accessed when exporting data to database
% and maybe to display it (need to add button or something to the figure to draw
% the line)
if ~isfield(handles.vicon_data, 'model_outputs')
	disp('model_outputs missing. Cannot get NormalizedGRF')
else
	% these variables may not exist, though -- FIXME
	if table_variable_exists(handles.vicon_data.model_outputs.tbl, [upper(side(1)) 'NormalisedGRF_X_N'])
		h_ax.UserData.norm_grf.t = handles.vicon_data.model_outputs.tbl.Frame / 100;
		h_ax.UserData.norm_grf.x = handles.vicon_data.model_outputs.tbl.([upper(side(1)) 'NormalisedGRF_X_N']);
		h_ax.UserData.norm_grf.y = handles.vicon_data.model_outputs.tbl.([upper(side(1)) 'NormalisedGRF_Y_N']);
		h_ax.UserData.norm_grf.z = handles.vicon_data.model_outputs.tbl.([upper(side(1)) 'NormalisedGRF_Z_N']);
	end
end


title(side)
ylabel(strrep(fp_var, '_', ' '))
xlabel('Time (s)')

if ~isfield(handles, 'event_struct')
	return
end

hs_str = [side(1) 'hs'];
to_str = [side(1) 'to'];
% heel strikes - black lines
add_event_lines(h_ax, handles.event_struct.(hs_str), 'k', hs_str)
% toe off - green lines
add_event_lines(h_ax, handles.event_struct.(to_str), [0 0.8 0.1], to_str)

% add menu to identify time segement of force data when the other toe has hit
% the force plate
hcmenu = uicontextmenu;
ud.hMenuIgnore = uimenu(hcmenu, 'Label', 'Ignore segment', 'Tag', 'menuIgnoreSegment', 'Callback', {@menuIgnoreSegment_Callback, h_line});
set(h_line, 'UIContextMenu', hcmenu, 'UserData', ud);
return