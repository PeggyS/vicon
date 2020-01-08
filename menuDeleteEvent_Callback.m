function menuDeleteEvent_Callback(hObject, eventdata, h_line)
% hObject    handle to menuDeleteEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hLine    handle to the line owning this menu

% update the handles.event_struct and any other lines with this tag in figures other 

% remove the event from the event_struct with the x data of this line

% get the guidata of the vicon_foot_gui figure
h_fig = h_line.Parent.Parent;
if strncmp(h_fig.Tag, 'figure_fp', 9) || strncmp(h_fig.Tag, 'figure_insole', 13)
	h_main_fig = h_fig.UserData.parent_gui;
else
	h_main_fig = h_fig;
end
handles = guidata(h_main_fig);

event = regexp(h_line.Tag, '_', 'split'); % splits the line tag into 'line', 'rhs', '2' 


% find the event by matching time
evt_ind = find(handles.event_struct.(event{2}).times == h_line.XData(1));
assert(length(evt_ind)==1, 'error finding time = %f, in event_struct.%s', h_line.XData(1), event{2})

% remove the event from the struct
handles.event_struct.(event{2}).times(evt_ind) = [];
handles.event_struct.(event{2}).links(evt_ind) = [];

% remove any lines with this tag in figures
h_all_lines = findobj(0, 'Tag', h_line.Tag);

delete(h_all_lines)

guidata(h_main_fig, handles)