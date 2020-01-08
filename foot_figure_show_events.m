function handles = foot_figure_show_events(handles)

% event struct contains the time (s):
% handles.event_struct.rhs.times = rhs_times;
% handles.event_struct.rhs.links = linkprops;
% handles.event_struct.rto.times = rto_times;
% handles.event_struct.lhs.times = lhs_times;
% handles.event_struct.lto.times = lto_times;
% handles.event_struct.lff
% handles.event_struct.lff

% remove any existing event lines, associated text, & link properies. Link properties are removed
% in the add_event_lines function
h_lines = findobj(handles.figure1, '-regexp', 'Tag', 'line_([rl])((hs)|(to))_\d+');
for l_cnt = 1:length(h_lines)
	delete(h_lines(l_cnt).UserData.hText);
end
if ~isempty(h_lines), delete(h_lines), end

% right & left axes in main window with ankle markers
r_axes = findobj(handles.figure1, '-regexp', 'Tag', 'axes_r.*');
l_axes = findobj(handles.figure1, '-regexp', 'Tag', 'axes_l.*');

% axes in insole figures
if isfield(handles, 'figure_insole_left')
	l_fsr_axes = findobj(handles.figure_insole_left, '-regexp', ...
		'Tag', 'axes_.*');
	l_axes = [l_axes; l_fsr_axes];
end
if isfield(handles, 'figure_insole_right')
	r_fsr_axes = findobj(handles.figure_insole_right, '-regexp', ...
		'Tag', 'axes_.*');
	r_axes = [r_axes; r_fsr_axes];
end

% right heel strikes - black lines
handles.event_struct.rhs = add_event_lines(r_axes, handles.event_struct.rhs, 'k', 'rhs');
% right toe off - green lines
handles.event_struct.rto = add_event_lines(r_axes, handles.event_struct.rto, [0 0.8 0.1], 'rto');

% left heel strikes - black lines
handles.event_struct.lhs = add_event_lines(l_axes, handles.event_struct.lhs, 'k', 'lhs');
% left toe offs - green lines
handles.event_struct.lto = add_event_lines(l_axes, handles.event_struct.lto, [0 0.8 0.1], 'lto');

