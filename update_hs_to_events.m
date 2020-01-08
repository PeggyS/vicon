function update_hs_to_events(h_line)
% update the event_struct with the x data of this line

% get the guidata of the vicon_foot_gui figure
h_fig = h_line.Parent.Parent;
if strncmp(h_fig.Tag, 'figure_fp', 9) || strncmp(h_fig.Tag, 'figure_insole', 13)
	h_main_fig = h_fig.UserData.parent_gui;
else
	h_main_fig = h_fig;
end
handles = guidata(h_main_fig);

event = regexp(h_line.Tag, '_', 'split'); % splits the line tag into 'line', 'rhs', '2' 

handles.event_struct.(event{2}).times(str2double(event(3))) = h_line.XData(1);

% % update any other lines with this tag in other figures
% if h_fig==h_main_fig  % line is in main figure, check fp figures
% 	if isfield(handles, 'figure_fp1')
% 		h_fp1_line = findobj(handles.figure_fp1, 'Tag', h_line.Tag);
% 		if ~isempty(h_fp1_line)
% 			h_fp1_line.XData = h_line.XData;
% 		end
% 	end
% 	if isfield(handles, 'figure_fp2')
% 		h_fp2_line = findobj(handles.figure_fp2, 'Tag', h_line.Tag);
% 		if ~isempty(h_fp2_line)
% 			h_fp2_line.XData = h_line.XData;
% 		end
% 	end
% else  % line is in a fp figure
% 	% set lines in main figure
% 	h_other_lines = findobj(h_main_fig, 'Tag', h_line.Tag);
% 	set(h_other_lines, 'XData', h_line.XData);
% 	% set line that may be in other fp figure
% 	fp_num = str2double(regexp(h_fig.Tag, '\d+', 'match'));
% 	if fp_num==1, fp_change_num=2; end
% 	if fp_num==2, fp_change_num=1; end
% 	
% 	fp_fig_str = ['figure_fp' num2str(fp_change_num)];
% 	if isfield(handles, fp_fig_str)
% 		h_fp_line = findobj(handles.(fp_fig_str), 'Tag', h_line.Tag);
% 		if ~isempty(h_fp_line)
% 			h_fp_line.XData = h_line.XData;
% 		end
% 	end
% 	
% 	
% end
guidata(h_main_fig, handles)