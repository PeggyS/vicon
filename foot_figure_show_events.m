function handles = foot_figure_show_events(handles)

% event struct contains the time (s):
% handles.event_struct.rhs = rhs_times;
% handles.event_struct.rto = rto_times;
% handles.event_struct.lhs = lhs_times;
% handles.event_struct.lto = lto_times;
% handles.event_struct.lff
% handles.event_struct.lff

% remove any existing event lines, associated text, & link properies. Link properties are removed
% in the add_event_lines function
h_lines = findobj(handles.figure1, '-regexp', 'Tag', 'line_([rl])((hs)|(to))_\d+');
for l_cnt = 1:length(h_lines)
	delete(h_lines(l_cnt).UserData.hText);
end
if ~isempty(h_lines), delete(h_lines), end

% right & left axes
r_axes = findobj(handles.figure1, '-regexp', 'Tag', 'axes_r.*');
l_axes = findobj(handles.figure1, '-regexp', 'Tag', 'axes_l.*');


% right heel strikes - black lines
add_event_lines(r_axes, handles.event_struct.rhs, 'k', 'rhs')
% right toe off - green lines
add_event_lines(r_axes, handles.event_struct.rto, [0 0.8 0.1], 'rto')

% left heel strikes - black lines
add_event_lines(l_axes, handles.event_struct.lhs, 'k', 'lhs')
% left toe offs - green lines
add_event_lines(l_axes, handles.event_struct.lto, [0 0.8 0.1], 'lto')

