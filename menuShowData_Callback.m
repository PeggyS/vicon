function menuShowData_Callback(hObject, eventdata, hLine, hText)
% hObject    handle to menuShowTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hLine    handle to the line owning this menu
% hText		handle to the time text
checked = get(hObject, 'Checked');
if strcmp(checked, 'on')
	% it's on, turn it off
	set(hObject, 'Checked', 'off')
	% hide the time text 
	set(hText, 'Visible', 'off')
else
	% it's off, turn it on
	set(hObject, 'Checked', 'on')
	% show time text 
	set(hText, 'Visible', 'on')
end
