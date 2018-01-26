function add_event_lines(h_ax_list, time_list, line_color, short_tag)

link_var = ['link_event_lines_' short_tag];
% remove any existing link properties
for ax_cnt = 1:length(h_ax_list)
	h_ax = h_ax_list(ax_cnt);
	if isfield(h_ax.UserData, link_var)
		h_ax.UserData.link_event_lines = {}; 
	end
end

for t_cnt = 1:length(time_list)
	h_l = gobjects(size(h_ax_list));
	long_tag = ['line_' short_tag '_' num2str(t_cnt)];

	for ax_cnt = 1:length(h_ax_list)
		h_ax = h_ax_list(ax_cnt);
		% vertical line for to & hs

		h_l(ax_cnt) = line(h_ax, [time_list(t_cnt) time_list(t_cnt)], h_ax.YLim, ...
			'Color', line_color, 'LineWidth', 2, 'Tag', long_tag);
		
		% text to display the value of the visible data line at the vertical line
		val_str = get_line_display_data(h_l(ax_cnt));
		h_txt = text(h_ax, time_list(t_cnt), mean(h_ax.YLim), val_str, 'Visible', 'off');
		% add context menu to the line
		createLineCMenu(h_l(ax_cnt), h_txt)

	end
	
	h_ax.UserData.(link_var){t_cnt} = linkprop(h_l, 'XData');
	
end

% ----------------------------
function createLineCMenu(hLine, hText)
hcmenu = uicontextmenu;
ud.hMenuDrag = uimenu(hcmenu, 'Label', 'Update Event Time', 'Tag', 'menuUpdateEvent', 'Callback', {@menuUpdateEvent_Callback, hLine});
ud.hMenuDrag = uimenu(hcmenu, 'Label', 'Draggable', 'Tag', 'menuDraggable', 'Callback', {@menuDraggable_Callback, hLine});
ud.hMenuShow = uimenu(hcmenu, 'Label', 'Show Data Value', 'Tag', 'menuShowData', 'Callback', {@menuShowData_Callback, hLine, hText});
ud.hMenuShow = uimenu(hcmenu, 'Label', 'Delete Event', 'Tag', 'menuDeleteEvent', 'Callback', {@menuDeleteEvent_Callback, hLine});
ud.hText = hText;		% also save the time text handle for quick access
set(hLine, 'UIContextMenu', hcmenu, 'UserData', ud);
