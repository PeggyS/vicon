function update_foot_marker_figure(app, marker, xyz, pos_vel_acc, visible)

switch upper(marker)
	case 'LTOE'
		h_ax = findobj(app.h_foot_data_fig, 'Tag', 'axes_ltoe');
	case 'LHEE'
	case 'RTOE'
	case 'RHEE'
end

switch lower(xyz)
	case 'x'
		xyz_str = '_X_';
	case 'y'
		xyz_str = '_Y_';
	case 'z'
		xyz_str = '_Z_';
end

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

if isempty(h_line) && visible == 1  % it doesn't exist and it should be visible
	% get the color and linestyle
	color_str = get_color(app, xyz);
	style_str = get_style(app, pos_vel_acc);
	% draw the line
	draw_marker_line(h_ax, app.vicon_data.markers, marker_full_name, ...
		'color',color_str,'linestyle',style_str, 'Tag', marker_line_tag)
	return
end

if ~isempty(h_line) % line exists
	% make it visible or not 
	if visible
		h_line.Visible = 'on';
	else
		h_line.Visible = 'off';
	end
end
return % update_foot_marker_figure

% ------------------------------------------------
function color_str = get_color(app, xyz_str)
color_str = 'k'; % default to black
dd_str = ['DropDown_' lower(xyz_str) '_color']; % dropdown uicontrol string

color_name = app.(dd_str).Value;
switch lower(color_name)
	case 'red'
		color_str = 'r';
	case 'green'
		color_str = 'g';
	case 'blue'
		color_str = 'b';
end
return

% ------------------------------------------------
function style_str = get_style(app, pva_str)
style_str = '-'; % default to plain line
dd_str = ['DropDown_' lower(pva_str) '_linestyle']; % dropdown uicontrol string

style_str = app.(dd_str).Value;
return