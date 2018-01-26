function handles = load_data(handles)

% load the vicon csv file data 
if ~exist(handles.edit_filename.String, 'file')
	warning('file %s does not exist', handles.edit_filename.String)
	return
end

handles.vicon_data = read_vicon_csv(handles.edit_filename.String);


marker_list = handles.popupmenu_marker.String;
% marker_list = {'LTOE'}; 

xyz_list = {'x', 'y', 'z'};
pos_vel_acc_list = {'pos', 'vel', 'acc'};


num_plots = length(marker_list);
for plt_cnt = 1:num_plots
	marker = marker_list{plt_cnt};
	
	% set up axes
	ax_str = ['axes' num2str(plt_cnt)];
	h_ax(plt_cnt) = handles.(ax_str);
	axes(h_ax(plt_cnt))
	box on
	set(h_ax(plt_cnt), 'Tag', lower(['axes_' marker]))
	title(marker)
	
	% check what lines to display
	for xyz_cnt = 1:length(xyz_list)
		xyz = xyz_list{xyz_cnt};
		
		for pva_cnt = 1:length(pos_vel_acc_list)
			pva_str = pos_vel_acc_list{pva_cnt};
			
			chkbx_str = ['checkbox_' pva_str '_' xyz '_' lower(marker)]; % name of the check box
			value = handles.(chkbx_str).Value; % value of the checkbox
% 			if value
				% this line is to be displayed
				update_foot_marker_figure(handles, marker, xyz, pva_str, value) % last parameter is visibility
% 			end
		end
	end
	
end

h_ax(1).UserData.linkprop_list = linkprop(h_ax, 'XLim');
