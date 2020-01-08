function vertLineMotionFcn(hLine)
% as the vertical line moves, update the value text
% text handle is stored in the hLine's userdata

ud = get(hLine, 'UserData');
if isempty(ud) || ~isfield(ud, 'hText')
	uiwait(warndlg({'vertLineMotionFcn'; ...
    	'Line user data or hText field is missing. This should not happen.'; ...
		'Please tell Peggy.'}, ...
        'Vicon_foot_gui', 'modal'));
	return
end
oldPos = get(ud.hText, 'Position');
xValue = get(hLine, 'XData');
val_str = get_line_display_data(hLine);
set(ud.hText, 'Position', [xValue(1) oldPos(2)], 'String', val_str);

