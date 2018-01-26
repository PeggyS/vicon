function handles = foot_figure_show_ff_events(handles)

% event struct contains the time (s):
% handles.event_struct.rhs = rhs_times;
% handles.event_struct.rto = rto_times;
% handles.event_struct.lhs = lhs_times;
% handles.event_struct.lto = lto_times;
% handles.event_struct.lff
% handles.event_struct.lff

% remove any existing event lines & link properies
h_lines = findobj(handles.figure1, '-regexp', 'Tag', 'line_([rl])(ff)_\d+');
if ~isempty(h_lines), delete(h_lines), end

% right & left axes
r_axes = findobj(handles.figure1, '-regexp', 'Tag', 'axes_r.*');
l_axes = findobj(handles.figure1, '-regexp', 'Tag', 'axes_l.*');


% right foot flats - mageneta asterix
add_ff_lines(r_axes, handles.event_struct.rff, 'm', 'rff')

% leftt foot flats - mageneta asterix
add_ff_lines(l_axes, handles.event_struct.lff, 'm', 'lff')

% --------------------------------------------------------------------------------
function add_ff_lines(h_ax_list, time_list, line_color, short_tag)
% remove any existing link properties
for ax_cnt = 1:length(h_ax_list)
	h_ax = h_ax_list(ax_cnt);
	if isfield(h_ax.UserData, 'link_ff_lines')
		h_ax.UserData.link_ff_lines = {}; 
	end
end

for t_cnt = 1:length(time_list)
	h_l = gobjects(size(h_ax_list));
	long_tag = ['line_' short_tag '_' num2str(t_cnt)];
	
	for ax_cnt = 1:length(h_ax_list)
		h_ax = h_ax_list(ax_cnt);
		% 
		ylims = get(h_ax, 'YLim');
		h_l(ax_cnt) = line(h_ax, time_list(t_cnt), ylims(1), ...
			'Color', line_color, 'Marker', '*', 'Tag', long_tag);

		draggable(h_l(ax_cnt), 'h')
	end
	
	h_ax.UserData.link_ff_lines{t_cnt} = linkprop(h_l, 'XData');
	
end
