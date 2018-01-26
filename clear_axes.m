function handles = clear_axes(handles)
% remove all axes children

marker_list = handles.popupmenu_marker.String; % 

num_plots = length(marker_list);
for plt_cnt = 1:num_plots
% clear axes
	ax_str = ['axes' num2str(plt_cnt)];
	h_ax = handles.(ax_str);
	cla(h_ax, 'reset')
end