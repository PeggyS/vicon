function h_l = add_one_event_to_all_axes(h_ax_list, evt_time, line_color, long_tag)
h_l = gobjects(size(h_ax_list));
for ax_cnt = 1:length(h_ax_list)
	h_ax = h_ax_list(ax_cnt);
	
	% vertical line for to & hs
	h_l(ax_cnt) = line(h_ax, [evt_time evt_time], h_ax.YLim, ...
		'Color', line_color, 'LineWidth', 2, 'Tag', long_tag);
	
	% text to display the value of the visible data line at the vertical line
	val_str = get_line_display_data(h_l(ax_cnt));
	h_txt = text(h_ax, evt_time, mean(h_ax.YLim), val_str, 'Visible', 'off');
	% add context menu to the line
	axes(h_ax) %#ok<LAXES>
	createLineCMenu(h_l(ax_cnt), h_txt);
	% by default, turn on draggable
	menuDraggable_Callback(h_l(ax_cnt).UserData.hMenuDrag, [], h_l(ax_cnt))
	
end
return
