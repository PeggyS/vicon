function event_struc = add_event_lines(h_ax_list, event_struc, line_color, short_tag)

% link_var = ['link_event_lines_' short_tag];
% % remove any existing link properties
% for ax_cnt = 1:length(h_ax_list)
% 	h_ax = h_ax_list(ax_cnt);
% 	if isfield(h_ax.UserData, link_var)
% 		h_ax.UserData.link_event_lines = {}; 
% 	end
% end

for t_cnt = 1:length(event_struc.times)
	
	long_tag = ['line_' short_tag '_' num2str(t_cnt)];

	evt_time = event_struc.times(t_cnt);
	h_l = add_one_event_to_all_axes(h_ax_list, evt_time, line_color, long_tag);
	
	if isfield(event_struc, 'links') && length(event_struc.links) >= t_cnt
		addtarget(event_struc.links(t_cnt), h_l);
	else
		event_struc.links(t_cnt) = linkprop(h_l, 'XData');
	end
	
end


