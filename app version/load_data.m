function load_data(app)

% load the vicon csv file data for this app
if ~exist(app.EditField_filename.Value, 'file')
	error('file %s does not exist', app.EditField_filename.Value)
	return
end

app.vicon_data = read_vicon_csv(app.EditField_filename.Value);


if isempty(app.h_foot_data_fig)
	app.h_foot_data_fig = figure;
else
	figure(app.h_foot_data_fig)
end

marker_list = {'LTOE'}; %, 'LHEE', 'RTOE', 'RHEE'};
xyz_list = {'x', 'y', 'z'};
pos_vel_acc_list = {'pos'}; %, 'vel', 'acc'};


num_plots = length(marker_list);
for plt_cnt = 1:num_plots
	marker = marker_list{plt_cnt};
	
	% set up axes
	h_ax = subplot(num_plots,1,plt_cnt);
	set(h_ax, 'Tag', lower(['axes_' marker]))
	title(marker)
	
	% check what lines to display
	for xyz_cnt = 1:length(xyz_list)
		xyz = xyz_list{xyz_cnt};
		
		for pva_cnt = 1:length(pos_vel_acc_list)
			pva_str = pos_vel_acc_list{pva_cnt};
			
			chkbx_str = ['CheckBox_' pva_str '_' xyz '_' lower(marker)]; % name of the check box
			value = app.(chkbx_str).Value; % value of the checkbox
			if value
				% this line is to be displayed
				update_foot_marker_figure(app, marker, xyz, pva_str, 1) % last parameter is visibility
			end
		end
	end
	
end


