function [ ds, new_events ] = edit_events( varargin )
%EDIT_EVENTS Display and edit heel strike & toe off events from vicon foot marker data
%   Detailed explanation goes here
%
%	Input parameter value pairs (optional):
%		'data_file' - file name (string) to the input. It is a tab delimited text 
%			file with the first row containing the variable names. This
%			should be the file containing the 'zeroed' force plate data.
%
%		'event_file' - file name (string) of the corresponding event
%			data, a matlab *.mat file.
%
%
%
%	Output
%		tbl - table of the vicon data
%		new_events - event structure with fields rhs, rto, lhs, lto

% Author: Peggy Skelly
% 2017-08-08: create 


% define input parser
p = inputParser;
p.addParameter('data_file', '', @isstr);
p.addParameter('event_file', '', @isstr);

p.addParameter('figures', struct([]), @isstruct);
p.addParameter('events', struct([]), @isstruct);


% parse the input
p.parse(varargin{:});
inputs = p.Results;


if isempty(inputs.data_file)		% no file specified
	% request the data file
	[fname, pathname] = uigetfile('*.csv', 'Pick vicon csv file');
	if isequal(fname,0) || isequal(pathname,0)
		disp('User canceled. Exitting')
		return
	else
		filePathName = fullfile(pathname,fname);
	end
else
	filePathName = inputs.data_file;
end
% input file with vicon data
vicon_data = read_vicon_csv(filePathName);

% time 
t = vicon_data.markers.tbl.Frame / vicon_data.markers.samp_freq;

% use toe and heel x, y, z, pos, vel & acc
left.toe = get_data(vicon_data.markers.tbl, 'LTOE');
left.heel = get_data(vicon_data.markers.tbl, 'LHEE');

right.toe = get_data(vicon_data.markers.tbl, 'RTOE');
right.heel = get_data(vicon_data.markers.tbl, 'RHEE');


% display data
[ hfig_struct.left, hfig_struct.right ] = display_foot_data_figure( left, right, strrep(filePathName,'_', ' ') );


% show events
display_events(hfig_struct.right, event_struct.rhs, event_struct.rto)
display_events(hfig_struct.left, event_struct.lhs, event_struct.lto)

% edit/verify heel strike & toe off events
new_events = edit_event_struct(hfig_struct);


% have events changed? - if so save
if ~isequal(new_events, event_struct) 
	% save events
	save_events(new_events);
end

end

% -------------------------------------------------------------------
function display_events(h_fig, hs_times, to_times)
% display lines for right heel strike (red) & toe off (black)
figure(h_fig);
ax_ylim = get(gca,'ylim');
data_line = findobj(h_fig, 'Tag', 'data');
assert(~isempty(data_line), 'did not find data line')

y_data = get(data_line, 'YData');
ylim(2) = max([ax_ylim(2), max(y_data)]);
ylim(1) = min([ax_ylim(1), min(y_data)]);

% axis menu to add event 
hcmenu = uicontextmenu;
ud.hMenuHs = uimenu(hcmenu, 'Label', 'Add Heel Strike', 'Tag', 'menuHs', 'Callback', {@menuHs_Callback, gca});
ud.hMenuTo = uimenu(hcmenu, 'Label', 'Add Toe Off', 'Tag', 'menuTo', 'Callback', {@menuTo_Callback, gca});
ud.ylim = ylim;
set(gca, 'UIContextMenu', hcmenu, 'UserData', ud);

% heel strike
% t = get(data_line, 'XData');
x = [hs_times, hs_times]';
y = repmat(ylim', [1 length(hs_times)]);
hs_lines = add_hs_lines(x, y);

% toe off
x = [to_times, to_times]';
y = repmat(ylim', [1 length(to_times)]);
to_lines = add_to_lines(x, y);

% key press function to use arrow keys to page through the data
set(gcf,'KeyPressFcn', @figure_KeyPressFcn)

end

% -------------------------------------------------------------------
function h_lines = add_hs_lines(x, y)
h_lines = line(x, y, 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2, 'Tag', 'hs');
arrayfun(@createLineCMenu, h_lines)
end

% -------------------------------------------------------------------
function h_lines = add_to_lines(x, y)
h_lines = line(x, y, 'Color', 'k', 'LineStyle', '--', 'LineWidth', 2, 'Tag', 'to');
arrayfun(@createLineCMenu, h_lines)
end

% -------------------------------------------------------------------
function new_struct = edit_event_struct(h_fig_struct)
% display a window with a check box asking if event changes should be saved
% the window halts program progress while events are disabled or moved as
% desired. 

f = figure('Position',[700 1000 400 200]);
uicontrol('Position', [20 100 200 40], 'String', {'Edit HS & TO events'; ...
	'Right-click on a line to disable/enable'}, ...
    'Style', 'text');
h = uicontrol('Position', [20 20 200 40], 'String', 'Continue', ...
                      'Callback', 'uiresume(gcbf)');
% disp('This will print immediately');
uiwait(gcf);
% disp('This will print after you click Continue'); 

% if check box, then get the events to return
hAxRight = findobj(h_fig_struct.right, 'Type', 'axes');
hAxLeft = findobj(h_fig_struct.left, 'Type', 'axes');

% new_struct.rhs = get_event_inds(hAxRight, 'hs');
% new_struct.rto = get_event_inds(hAxRight, 'to');
% new_struct.lhs = get_event_inds(hAxLeft, 'hs');
% new_struct.lto = get_event_inds(hAxLeft, 'to');
new_struct.rhs = get_event_times(hAxRight, 'hs');
new_struct.rto = get_event_times(hAxRight, 'to');
new_struct.lhs = get_event_times(hAxLeft, 'hs');
new_struct.lto = get_event_times(hAxLeft, 'to');

close(f);
end % edit_events

% -------------------------------------------------------------------
function times = get_event_times(hAx, tag)
% get the times of the events identified by tag in the axis

% get the time vector 
hData = findobj(hAx, 'Tag', 'data');
assert(~isempty(hData), 'no line with data tag')

hEvtLines = findobj(hAx, 'Tag', tag);
assert(~isempty(hEvtLines), 'no %s event tag found', tag)

x_cell = get(hEvtLines, 'XData');
x_mat = cell2mat(x_cell);
times = x_mat(:,1);

times = sort(times);
end

% ----------------------------
function createLineCMenu(hLine)
hcmenu = uicontextmenu;
ud.hMenuShow = uimenu(hcmenu, 'Label', 'Disable', 'Tag', 'menuDisable', 'Callback', {@menuDisable_Callback, hLine});
ud.hMenuDrag = uimenu(hcmenu, 'Label', 'Draggable', 'Tag', 'menuDraggable', 'Callback', {@menuDraggable_Callback, hLine});
set(hLine, 'UIContextMenu', hcmenu, 'UserData', ud);
end

% --------------------------------------------------------------------
function menuDisable_Callback(hObject, eventdata, hLine)
% hObject    handle to menuDisable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hLine    handle to the line owning this menu
checked = get(hObject, 'Checked');
ud = get(hLine, 'UserData');
if strcmp(checked, 'on')
	% it's on, turn it off
	set(hObject, 'Checked', 'off')
	% change style & tag
    tag_str = get(hLine, 'Tag');
    tag_str = strrep(tag_str, 'disabled_', '');
	set(hLine, 'LineWidth', 2, 'Tag', tag_str)
	% check for userdata & change lines if they exist
	if isfield(ud, 'hLine_rto')
		set(ud.hLine_rto, 'LineStyle', '--')
	end
	if isfield(ud, 'hLine_lto')
		set(ud.hLine_lto, 'LineStyle', '--')
	end
	if isfield(ud, 'hLine_lhs')
		set(ud.hLine_lhs, 'LineStyle', '-')
	end
else
	% it's off, turn it on
	set(hObject, 'Checked', 'on')
	% change style & tag 
    tag_str = get(hLine, 'Tag');
    tag_str = ['disabled_' tag_str];
	set(hLine, 'LineWidth', 0.5, 'Tag', tag_str)
    % check for userdata & change lines if they exist
	if isfield(ud, 'hLine_rto')
		set(ud.hLine_rto, 'LineStyle', ':')
	end
	if isfield(ud, 'hLine_lto')
		set(ud.hLine_lto, 'LineStyle', ':')
	end
	if isfield(ud, 'hLine_lhs')
		set(ud.hLine_lhs, 'LineStyle', ':')
	end
end
end % menuDisable_Callback

% --------------------------------------------------------------------
function menuDraggable_Callback(hObject, eventdata, hLine)
% hObject    handle to menuDraggable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hLine    handle to the line owning this menu

checked = get(hObject, 'Checked');
if strcmp(checked, 'on')
	% it's on, turn it off
	set(hObject, 'Checked', 'off')
	% turn off draggable
	draggable( hLine, 'off');
else
	% it's off, turn it on
	set(hObject, 'Checked', 'on')
	% make it draggable
%	if strcmp(get(hLine, 'Tag'), 'endMEPline')
		% endMEPline has an endfcn
%		draggable( hLine, 'horizontal', @vertLineMotionFcn, 'endfcn', @endMepEndFcn);
%	else
		draggable( hLine, 'horizontal');    % , @vertLineMotionFcn);
%	end	
end
end % menuDraggable_Callback

% --------------------------------------------------------------------
function menuHs_Callback(hObject, eventdata, hAx)
% hObject    handle to menuHs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hAx    handle to the axis owning this menu
% checked = get(hObject, 'Checked');
ud = get(hAx, 'UserData');
cur_pt = get(hAx, 'CurrentPoint');
x_pos = cur_pt(1,1);
add_hs_lines([x_pos, x_pos], ud.ylim);
end

% --------------------------------------------------------------------
function menuTo_Callback(hObject, eventdata, hAx)
% hObject    handle to menuHs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hAx    handle to the axis owning this menu
% checked = get(hObject, 'Checked');
ud = get(hAx, 'UserData');
cur_pt = get(hAx, 'CurrentPoint');
x_pos = cur_pt(1,1);
add_to_lines([x_pos, x_pos], ud.ylim);
end