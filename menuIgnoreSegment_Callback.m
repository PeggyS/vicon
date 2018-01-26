function menuIgnoreSegment_Callback(hObject, eventdata, h_line)
% hObject    handle to menuDeleteEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hLine    handle to the line owning this menu


% add a short line segment with symbols at the 2 ends for adjustment
% the line segment will replace the data when the toe hit the force plate

% position of the cursor click
axes(h_line.Parent)
cursor_loc = get(h_line.Parent, 'CurrentPoint');
cursor_x = cursor_loc(1);


% default line segment length = 0.1 s
left_ind = find(h_line.XData >= cursor_x-0.05, 1);
right_ind = find(h_line.XData >= cursor_x+0.05, 1);

h_left_marker = line( h_line.XData(left_ind), h_line.YData(left_ind), ...
	'Tag', 'ignore_seg_left', ...
	'marker', '.', 'markersize', 50, 'color', [0 0.8 0]);
draggable(h_left_marker, @ignoreSegmentMotionFcn, 'endfcn', @ignoreSegmentEndFcn)

h_right_marker = line( h_line.XData(right_ind), h_line.YData(right_ind), ...
	'Tag', 'ignore_seg_right', ...
	'marker', '.', 'markersize', 50, 'color', [0.8 0 0]);
draggable(h_right_marker, @ignoreSegmentMotionFcn, 'endfcn', @ignoreSegmentEndFcn)

