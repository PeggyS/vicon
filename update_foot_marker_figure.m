function update_foot_marker_figure(handles, marker, xyz, pos_vel_acc, visible)
	
h_ax = findobj(handles.figure1, 'Tag', ['axes_' lower(marker)]);

xyz_str = ['_' upper(xyz) '_'];

switch lower(pos_vel_acc)
	case 'pos'
		pva_str = 'mm';
	case 'vel'
		pva_str = 'vel_mm_per_s';
	case 'acc'
		pva_str = 'acc_mm_per_s_2';
end

marker_full_name = [marker xyz_str pva_str];	% variable name in vicon data marker table
marker_line_tag  = ['line_' marker_full_name];	% tag given to the line

h_line = findobj(h_ax, 'Tag', marker_line_tag);

if visible
	vis_str = 'on';
else
	vis_str = 'off';
end

if isempty(h_line)   % it doesn't exist
	% get the color and linestyle
	color_str = get_color(xyz);
	style_str = get_style(pos_vel_acc);
	
	% draw the line
	draw_marker_line(h_ax, handles.vicon_data.markers, marker_full_name, ...
		 'Tag', marker_line_tag, ...
 		'color',color_str,'linestyle',style_str, 'Visible', vis_str)
else
	% make it visible or not 
	h_line.Visible = vis_str;
end
return % update_foot_marker_figure

% ------------------------------------------------
function color_str = get_color(xyz_str)
color_str = 'k'; % default to black

switch lower(xyz_str)
	case 'x'
		color_str = 'r';
	case 'y'
		color_str = 'g';
	case 'z'
		color_str = 'b';
end
return

% ------------------------------------------------
function style_str = get_style(pva_str)
style_str = '-'; % default to plain line
switch lower(pva_str)
	case 'pos'
		style_str = '-';
	case 'vel'
		style_str = '--';
	case 'acc'
		style_str = '-.';
end
return