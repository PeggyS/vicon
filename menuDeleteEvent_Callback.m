function menuIgnoreSegment_Callback(hObject, eventdata, h_line)
% hObject    handle to menuDeleteEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hLine    handle to the line owning this menu

% update the handles.event_struct and any other lines with this tag in figures other 

% remove the event from the event_struct with the x data of this line

% get the guidata of the vicon_foot_gui figure
h_fig = h_line.Parent.Parent;
if strncmp(h_fig.Tag, 'figure_fp', 9)
	h_main_fig = h_fig.UserData.parent_gui;
else
	h_main_fig = h_fig;
end
handles = guidata(h_main_fig);

event = regexp(h_line.Tag, '_', 'split'); % splits the line tag into 'line', 'rhs', '2' 

% remove the event from the struct
% handles.event_struct.(event{2})(str2double(event(3))) = []; <- wrong
% If an event is removed, then removing the 2nd event may remove the
% wrong one. Remove 1st event, then try to remove the last event, since it is
% indexed into event_struct by ?he tag, the tag number and index may not match
% find the event by matching time
evt_ind = find(handles.event_struct.(event{2}) == h_line.XData(1));
assert(length(evt_ind)==1, 'error finding time = %f, in event_struct.%s', h_line.XData(1), event{2})
handles.event_struct.(event{2})(evt_ind) = [];

% remove any lines with this tag in figures
h_all_lines = findobj(h_main_fig, 'Tag', h_line.Tag);

if isfield(handles, 'figure_fp1')
	h_fp1_line = findobj(handles.figure_fp1, 'Tag', h_line.Tag);
	if ~isempty(h_fp1_line)
		delete(h_fp1_line);
	end
end
if isfield(handles, 'figure_fp2')
	h_fp2_line = findobj(handles.figure_fp2, 'Tag', h_line.Tag);
	if ~isempty(h_fp2_line)
		delete(h_fp2_line);
	end
end

delete(h_all_lines)

guidata(h_main_fig, handles)