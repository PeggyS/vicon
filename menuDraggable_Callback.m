function menuDraggable_Callback(hObject, eventdata, hLine)
% hObject    handle to menuDraggable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hLine    handle to the line owning this menu

checked = get(hObject, 'Checked');
if strcmp(checked, 'on')
	% it's on, turn it off
	set(hObject, 'Checked', 'off')
	% turn off draggable
	draggable( hLine, 'off');
else
	% it's off, turn it on
	set(hObject, 'Checked', 'on')
	% make it draggable
	draggable( hLine, 'horizontal', @vertLineMotionFcn);   %, 'endfcn', @endVertLineMotionFcn);

end