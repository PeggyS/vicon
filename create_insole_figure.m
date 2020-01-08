function handles = create_insole_figure(handles, side)

if ~isfield(handles, 'vicon_data') 
	return
end

if ~isfield(handles.vicon_data, 'devices')
	disp('No FP data to display')
	return
end

fig_str = ['figure_insole_' lower(side)];
fig_pos = [1116         260         671        1085];

% insole figure is saved in the main gui handles
handles.(fig_str) = figure('Pos', fig_pos, 'Tag', fig_str, 'Name', [side ' FSR Insole']);
% save the main gui figure in the userdata of the insole figure
handles.(fig_str).UserData.parent_gui = handles.figure1;

% time 
% Frame = sec/100; Sub_Frame = milliseconds after the frame
t = handles.vicon_data.devices.tbl.Frame / 100 + handles.vicon_data.devices.tbl.Sub_Frame/1000;

% plot the 8 sensors
fsr_list = {'Lat_Heel', 'Med_Heel', 'Lat_Instep', 'Lat_MT', 'Center_MT', 'Med_MT', 'Lat_Toe', 'Med_Toe'};
for cnt = 1:8
	fsr_var = ['Imported_Analog_EMG_#1_Voltage_' upper(side(1)) '_' fsr_list{cnt} '_V'];
	h_ax(cnt) = subplot(8,1,cnt);
	h_ax(cnt).Tag = ['axes_' lower(side(1)) '_' lower(fsr_list{cnt})];
	create_axes_CMenu(h_ax(cnt))
	h_line = line(t, handles.vicon_data.devices.tbl.(fsr_var), ...
		'Tag', ['line_fsr_' lower(side(1)) '_' lower(fsr_list{cnt})]);
	ylabel(strrep(fsr_list{cnt}, '_', ' '))

	if cnt == 1
		title(side)
	end
	if cnt == 8
		xlabel('Time (s)')
	end
end

handles.(fig_str).UserData.linkprop_list = linkprop(h_ax, 'XLim');


return

% ----------------------------
function create_axes_CMenu(h_ax)
hcmenu = uicontextmenu;
ud.hMenuDrag = uimenu(hcmenu, 'Label', 'Add HS', 'Tag', 'menuAddHS', 'Callback', {@menuAddEvent_Callback, h_ax});
ud.hMenuShow = uimenu(hcmenu, 'Label', 'Add TO', 'Tag', 'menuAddTO', 'Callback', {@menuAddEvent_Callback, h_ax});

set(h_ax, 'UIContextMenu', hcmenu, 'UserData', ud);
