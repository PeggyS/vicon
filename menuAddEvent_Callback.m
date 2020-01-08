function menuAddEvent_Callback(hObject, eventdata, h_ax)
% hObject    handle to menuDraggable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hLine    handle to the axes owning this menu

% get left or right from axes tag
	if contains(h_ax.Tag, 'axes_l')
		side = 'l';
	else
		side = 'r';
	end

% get the guidata of the vicon_foot_gui figure
h_fig = h_ax.Parent;
if strncmp(h_fig.Tag, 'figure_fp', 9) || strncmp(h_fig.Tag, 'figure_insole', 13)
	h_main_fig = h_fig.UserData.parent_gui;
	h_ax_insole_list = findobj(h_fig, 'Type', 'axes'); % insole or fsr axes
else
	h_main_fig = h_fig;

	insole_fig = findobj(0, '-regexp', 'Tag', ['figure_insole_' side '.*']);
	h_ax_insole_list = findobj(insole_fig, 'Type', 'axes');
end
fp_figs = findobj(0, '-regexp', 'Tag', 'figure_fp.*');
fp_axes_possible = findobj(fp_figs, 'Type', 'axes');
fp_axes = [];
for f_cnt = 1:length(fp_axes_possible)
	% verify the axes title is for the correct side
	if strncmp(fp_axes_possible(f_cnt).Title.String, side, 1)
		fp_axes = [fp_axes; fp_axes_possible(f_cnt)]; %#ok<AGROW>
	end
end

% marker axes
h_ax_list_main = findobj(h_main_fig, '-regexp', 'Tag', ['axes_' side '.*']); % hee & toe marker axes for this side

% all axes to add an event
h_ax_list = [h_ax_list_main; h_ax_insole_list; fp_axes];

handles = guidata(h_main_fig);

% x position to add the event is at cursor position
cursor_pos = get(h_ax, 'CurrentPoint');
evt_time = cursor_pos(1);

switch hObject.Tag
	case 'menuAddHS'
		event = [side 'hs'];
		line_color = 'k';
	case 'menuAddTO'
		event = [side 'to'];
		line_color = [0 0.8 0.1];
end

new_event_num = length(handles.event_struct.(event).times) + 1;
handles.event_struct.(event).times(new_event_num) = evt_time;

long_tag = ['line_' event '_' num2str(new_event_num)];

% add the line to each axes
h_l = add_one_event_to_all_axes(h_ax_list, evt_time, line_color, long_tag);

% link the xdata
handles.event_struct.(event).links(new_event_num) = linkprop(h_l, 'XData');

guidata(h_main_fig, handles);