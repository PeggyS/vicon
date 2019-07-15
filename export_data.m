function export_data(handles)

% data is labeled relative to the involved side
inv_side = handles.popmenu_inv_side.String{handles.popmenu_inv_side.Value};
inv_side = lower(inv_side(1));
if strcmp(inv_side, 'r')
	uninv_side = 'l';
else
	uninv_side = 'r';
end
h_inv_axes = findobj(handles.figure1, 'Tag', ['axes_' inv_side 'hee']);
h_uninv_axes = findobj(handles.figure1, 'Tag', ['axes_' uninv_side 'hee']);


h_inv_hs_lines = findobj(h_inv_axes, '-regexp', 'Tag', ['line_' inv_side 'hs_\d+']);
inv_hs_times = sort(arrayfun(@(x)(x.XData(1)), h_inv_hs_lines));
h_inv_to_lines = findobj(h_inv_axes, '-regexp', 'Tag', ['line_' inv_side 'to_\d+']);
inv_to_times = sort(arrayfun(@(x)(x.XData(1)), h_inv_to_lines));

h_uninv_hs_lines = findobj(h_uninv_axes, '-regexp', 'Tag', ['line_' uninv_side 'hs_\d+']);
uninv_hs_times = sort(arrayfun(@(x)(x.XData(1)), h_uninv_hs_lines));
h_uninv_to_lines = findobj(h_uninv_axes, '-regexp', 'Tag', ['line_' uninv_side 'to_\d+']);
uninv_to_times = sort(arrayfun(@(x)(x.XData(1)), h_uninv_to_lines));

% verify the uninv toe off is included in the 1st gait cycle. If not, use the
% next gait cycle as the first one
% uninv toe off
ind = find(uninv_to_times>inv_hs_times(1) & uninv_to_times<inv_hs_times(2));
if length(ind)<1      % no uninv toe off found in the 1st inv gait cycle
	% remove the 1st inv heel strike, so the gait cycles start at the 2nd
	% inv hs
	inv_hs_times = inv_hs_times(2:end);
end

% gait cycle times & event info
num_gcs = length(inv_hs_times)-1;
gc_beg_time = nan(num_gcs,1);
gc_end_time = nan(num_gcs,1);
involved_to_time = nan(num_gcs,1);
uninvolved_hs_time = nan(num_gcs,1);
uninvolved_to_time = nan(num_gcs,1);
involved_stride_length = nan(num_gcs,1);
uninvolved_stride_length = nan(num_gcs,1);
involved_step_length = nan(num_gcs,1);
uninvolved_step_length = nan(num_gcs,1);

% step length info
h_inv_y = findobj(h_inv_axes, '-regexp', 'Tag', 'line_.*HEE_Y_mm'); % computer - door axis
h_inv_x = findobj(h_inv_axes, '-regexp', 'Tag', 'line_.*HEE_X_mm'); % offices - wall axis
h_uninv_y = findobj(h_uninv_axes, '-regexp', 'Tag', 'line_.*HEE_Y_mm'); % computer - door axis
h_uninv_x = findobj(h_uninv_axes, '-regexp', 'Tag', 'line_.*HEE_X_mm'); % offices - wall axis
% heel marker x & y data
heel.involved.x = h_inv_x.YData;
heel.involved.y = h_inv_y.YData;
heel.t = h_inv_x.XData;
heel.uninvolved.x = h_uninv_x.YData;
heel.uninvolved.y = h_uninv_y.YData;

for gc_cnt = 1:num_gcs
	gc_beg_time(gc_cnt) = inv_hs_times(gc_cnt);
	gc_end_time(gc_cnt) = inv_hs_times(gc_cnt+1);
	% inv to off
	ind = find(inv_to_times>inv_hs_times(gc_cnt) & inv_to_times<inv_hs_times(gc_cnt+1));
	assert(length(ind)==1, 'involved %s side: found %d toe offs between %f and %f', ...
		inv_side, length(ind), inv_hs_times(gc_cnt), inv_hs_times(gc_cnt+1))
	involved_to_time(gc_cnt) = inv_to_times(ind);
	
	% uninv heel strike
	uninv_hs_ind = find(uninv_hs_times>inv_hs_times(gc_cnt) & uninv_hs_times<inv_hs_times(gc_cnt+1));
	assert(length(uninv_hs_ind)==1, 'uninvolved %s side: found %d heel strikes between %f and %f', ...
		uninv_side, length(uninv_hs_ind), inv_hs_times(gc_cnt), inv_hs_times(gc_cnt+1))
	uninvolved_hs_time(gc_cnt) = uninv_hs_times(uninv_hs_ind);
	
	% uninv toe off
	ind = find(uninv_to_times>inv_hs_times(gc_cnt) & uninv_to_times<inv_hs_times(gc_cnt+1));
	assert(length(ind)==1, 'uninvolved %s side: found %d toe offs between %f and %f', ...
		uninv_side, length(ind), inv_hs_times(gc_cnt), inv_hs_times(gc_cnt+1))
	uninvolved_to_time(gc_cnt) = uninv_to_times(ind);
	
	% involved stride length = distance between heel markers beginning & end of gc
	ind_gc_beg = find(heel.t >= gc_beg_time(gc_cnt), 1, 'first');
	ind_gc_end = find(heel.t >= gc_end_time(gc_cnt), 1, 'first');
	% distance = norm([y2-y1, x2-x1])
	involved_stride_length(gc_cnt) = norm([heel.involved.y(ind_gc_end)-heel.involved.y(ind_gc_beg) , ...
		heel.involved.x(ind_gc_end)-heel.involved.x(ind_gc_beg)]);
	
	% uninvolved stride length = distance between uninvolved heel markers on 2
	% consecutive heel strikes - the uninvolved stride may be the one before or
	% after the involved gait cycle
	if length(uninv_hs_times) > gc_cnt % if there will be an ending hs index
		ind_1st_hs = find(heel.t >= uninv_hs_times(gc_cnt), 1, 'first');
		ind_2nd_hs = find(heel.t >= uninv_hs_times(gc_cnt+1), 1, 'first');
		% distance = norm([y2-y1, x2-x1])
		uninvolved_stride_length(gc_cnt) = norm([heel.uninvolved.y(ind_2nd_hs)-heel.uninvolved.y(ind_1st_hs) , ...
			heel.uninvolved.x(ind_2nd_hs)-heel.uninvolved.x(ind_1st_hs)]);
	end

	% step length = distance between heels at heel strike 
	involved_step_length(gc_cnt) = norm([heel.involved.y(ind_gc_end)-heel.uninvolved.y(ind_gc_end) , ...
			heel.involved.x(ind_gc_end)-heel.uninvolved.x(ind_gc_end)]);
	t_ind_uninv_hs = find(heel.t >= uninv_hs_times(uninv_hs_ind), 1, 'first');
	uninvolved_step_length(gc_cnt) = norm([heel.uninvolved.y(t_ind_uninv_hs)-heel.involved.y(t_ind_uninv_hs) , ...
			heel.uninvolved.x(t_ind_uninv_hs)-heel.involved.x(t_ind_uninv_hs)]);
	
end

gc_data_tbl = table(gc_beg_time, gc_end_time, involved_to_time, uninvolved_hs_time, uninvolved_to_time, ...
				involved_stride_length, uninvolved_stride_length, involved_step_length, uninvolved_step_length, ...
			'VariableNames',{'gc_beg', 'gc_end', 'involved_to', 'uninvolved_hs', 'uninvolved_to', ...
					'involved_stride_length', 'uninvolved_stride_length', 'involved_step_length', 'uninvolved_step_length'});

% some computed values
gc_data_tbl.gc_time = gc_data_tbl.gc_end - gc_data_tbl.gc_beg;
gc_data_tbl.swing_time = gc_data_tbl.gc_end - gc_data_tbl.involved_to;
gc_data_tbl.single_stance_time = gc_data_tbl.uninvolved_hs - gc_data_tbl.uninvolved_to;
gc_data_tbl.double_stance_loading_time = gc_data_tbl.uninvolved_to - gc_data_tbl.gc_beg;
gc_data_tbl.double_stance_unloading_time = gc_data_tbl.involved_to - gc_data_tbl.uninvolved_hs;

				
% add forceplate data columns (with all nans for now)
fp_mat = nan(height(gc_data_tbl), 12);
fp_tbl = array2table(fp_mat, 'VariableNames', {'involved_fp_vert_peak', 'involved_fp_vert_auc', 'involved_fp_vert_mean', ...
		'uninvolved_fp_vert_peak', 'uninvolved_fp_vert_auc', 'uninvolved_fp_vert_mean', ...
		'ss_involved_fp_vert_peak', 'ss_involved_fp_vert_auc', 'ss_involved_fp_vert_mean', ...
		'ss_uninvolved_fp_vert_peak', 'ss_uninvolved_fp_vert_auc', 'ss_uninvolved_fp_vert_mean'});
gc_data_tbl = horzcat(gc_data_tbl, fp_tbl);

% if force plate data figures, extract fp data
fpfig_list = {'figure_fp1', 'figure_fp2'};
for fp_cnt = 1:length(fpfig_list)
	fp_fig = fpfig_list{fp_cnt};
	if isfield(handles, fp_fig) && isgraphics(handles.(fp_fig))
		
		% force plate vertical data (from the line in the figure)
		h_data_line = findobj(handles.(fp_fig),'-regexp', 'Tag','line_.*Fz_N');
		data = h_data_line.YData;
		side = h_data_line.Parent.Title.String;

		% if there is a segment to ignore, replace that segment of data with the
		% 'line_ignoreSegment' data
		h_ignore_seg = findobj(handles.(fp_fig), 'Tag', 'line_ignoreSegment');
		if ~isempty(h_ignore_seg)
			h_left_pt = findobj(handles.(fp_fig),  'Tag', 'ignore_seg_left');
			left_ind = find(h_data_line.XData >= h_left_pt.XData, 1);

			h_right_pt = findobj(handles.(fp_fig),  'Tag', 'ignore_seg_right');
			right_ind = find(h_data_line.XData >= h_right_pt.XData, 1);

			data(left_ind:right_ind) = h_ignore_seg.YData;
		end
		data = abs(data);
		[start_ind, end_ind] = find_continuous(data > 10, 500); % find at least 0.5s * 1000 samp/s = 500 samples of data above threshold
		% if there looks like more than 1 foot strike (segments of continuous data
		if length(start_ind) > 1
			list_string = cell(length(start_ind),1);
			% ask which segment to use as fp data
			for ind_cnt = 1:length(start_ind)
				list_string{ind_cnt} = [num2str(h_data_line.XData(start_ind(ind_cnt))) ' - ' ...
					num2str(h_data_line.XData(end_ind(ind_cnt)))];
			end
			[sel, ok] = listdlg('ListString', list_string);
			if ok
				start_ind = start_ind(sel);
				end_ind = end_ind(sel);
			else
				return
			end
% 			keyboard
		end
		
		mid_ind = floor(mean([start_ind, end_ind]));
		
		% corresponding hs & to
		if strcmp(inv_side, side(1))
			% involved
			ipsi_to_time = inv_to_times(find(inv_to_times>=h_data_line.XData(mid_ind), 1));
			ipsi_hs_time = inv_hs_times(find(inv_hs_times<=h_data_line.XData(mid_ind), 1, 'last'));
		else
			ipsi_to_time = uninv_to_times(find(uninv_to_times>h_data_line.XData(mid_ind), 1));
			ipsi_hs_time = uninv_hs_times(find(uninv_hs_times<=h_data_line.XData(mid_ind), 1, 'last'));
		end
		assert(~isempty(ipsi_hs_time), 'no heel strike before fp data')
		assert(ipsi_to_time>ipsi_hs_time, 'hs after to?')
		
		t_fp = find(h_data_line.XData>=ipsi_hs_time & h_data_line.XData<=ipsi_to_time);
		fp_max = max(data(t_fp));
		fp_mean = mean(data(t_fp));
		fp_auc = trapz(h_data_line.XData(t_fp), data(t_fp));
				
		
		% the gait cycle to save the data to
		
		gc_ind = find(gc_beg_time < h_data_line.XData(mid_ind) & gc_end_time > h_data_line.XData(mid_ind));
		if isempty(gc_ind) && ~strcmp(inv_side, side(1)) % no gc found & uninvolved side
			% the uninv foot hit force plate before a inv hs - so there is no
			% gait cycle to associate with the fp data
			% add a row without gc info to store the fp info
			gc_data_tbl(height(gc_data_tbl)+1,:) = array2table(nan(1,width(gc_data_tbl)));
			gc_ind = height(gc_data_tbl);
		end
		
		%assert(length(gc_ind)==1, 'found %d gait cycles with forceplate data', length(gc_ind))
		if length(gc_ind)==1
			% find the other leg to off & hs times to compute single stance values
			
			% involved or uninvolved?
			if strcmp(inv_side, side(1))
				% involved
				contra_to_time = uninv_to_times(find(uninv_to_times>h_data_line.XData(start_ind), 1));
				contra_hs_time = uninv_hs_times(find(uninv_hs_times>h_data_line.XData(start_ind), 1));
				var_names = {'involved_fp_vert_peak', 'involved_fp_vert_auc', 'involved_fp_vert_mean' ...
					'ss_involved_fp_vert_peak', 'ss_involved_fp_vert_auc', 'ss_involved_fp_vert_mean'};
			else
				% uninvolved
				contra_to_time = inv_to_times(find(inv_to_times>h_data_line.XData(start_ind), 1));
				contra_hs_time = inv_hs_times(find(inv_hs_times>h_data_line.XData(start_ind), 1));
				var_names = {'uninvolved_fp_vert_peak', 'uninvolved_fp_vert_auc', 'uninvolved_fp_vert_mean' ...
					'ss_uninvolved_fp_vert_peak', 'ss_uninvolved_fp_vert_auc', 'ss_uninvolved_fp_vert_mean'};
			end
			% verify hs & to times occur within the fp data time
			assert(contra_hs_time>h_data_line.XData(start_ind) && contra_to_time>h_data_line.XData(start_ind) ...
				&& contra_hs_time<h_data_line.XData(end_ind) && contra_to_time<h_data_line.XData(end_ind), 'hs & to not within fp times')
			ss_start_ind = find(h_data_line.XData >= contra_to_time,1);
			ss_end_ind = find(h_data_line.XData >= contra_hs_time,1);
			
			% single stance force plate data
			ss_fp_max = max(data(ss_start_ind:ss_end_ind));
			ss_fp_mean = mean(data(ss_start_ind:ss_end_ind));
			ss_fp_auc = trapz(h_data_line.XData(ss_start_ind:ss_end_ind), data(ss_start_ind:ss_end_ind));
				
			
			gc_data_tbl(gc_ind,var_names) = {fp_max, fp_auc, fp_mean, ss_fp_max, ss_fp_auc, ss_fp_mean};


			% normalisedGRF (from axes userdata)
			h_ax = handles.(fp_fig).CurrentAxes;
			if isfield(h_ax.UserData, 'norm_grf')
				if width(gc_data_tbl) < 32    % if norm_grf variables need to be added to the table
					tmp_mat = nan(height(gc_data_tbl), 24);
					tmp_tbl = array2table(tmp_mat, 'VariableNames', {'involved_norm_grf_z_peak', 'involved_norm_grf_z_auc', 'involved_norm_grf_z_mean',...
							'involved_norm_grf_norm_peak', 'involved_norm_grf_norm_auc', 'involved_norm_grf_norm_mean', ...
							'uninvolved_norm_grf_z_peak', 'uninvolved_norm_grf_z_auc', 'uninvolved_norm_grf_z_mean', ...
							'uninvolved_norm_grf_norm_peak', 'uninvolved_norm_grf_norm_auc', 'uninvolved_norm_grf_norm_mean', ...
							'ss_involved_norm_grf_z_peak', 'ss_involved_norm_grf_z_auc', 'ss_involved_norm_grf_z_mean',...
							'ss_involved_norm_grf_norm_peak', 'ss_involved_norm_grf_norm_auc', 'ss_involved_norm_grf_norm_mean', ...
							'ss_uninvolved_norm_grf_z_peak', 'ss_uninvolved_norm_grf_z_auc', 'ss_uninvolved_norm_grf_z_mean', ...
							'ss_uninvolved_norm_grf_norm_peak', 'ss_uninvolved_norm_grf_norm_auc', 'ss_uninvolved_norm_grf_norm_mean'});
					gc_data_tbl = horzcat(gc_data_tbl, tmp_tbl);
				end

				if strcmp(inv_side, side(1))
					% involved
					var_names = {'involved_norm_grf_z_peak', 'involved_norm_grf_z_auc', 'involved_norm_grf_z_mean',...
						'involved_norm_grf_norm_peak', 'involved_norm_grf_norm_auc', 'involved_norm_grf_norm_mean', ...
						'ss_involved_norm_grf_z_peak', 'ss_involved_norm_grf_z_auc', 'ss_involved_norm_grf_z_mean',...
							'ss_involved_norm_grf_norm_peak', 'ss_involved_norm_grf_norm_auc', 'ss_involved_norm_grf_norm_mean'};
				else
					% uninvolved
					var_names = {'uninvolved_norm_grf_z_peak', 'uninvolved_norm_grf_z_auc', 'uninvolved_norm_grf_z_mean', ...
						'uninvolved_norm_grf_norm_peak', 'uninvolved_norm_grf_norm_auc', 'uninvolved_norm_grf_norm_mean',...
						'ss_uninvolved_norm_grf_z_peak', 'ss_uninvolved_norm_grf_z_auc', 'ss_uninvolved_norm_grf_z_mean', ...
							'ss_uninvolved_norm_grf_norm_peak', 'ss_uninvolved_norm_grf_norm_auc', 'ss_uninvolved_norm_grf_norm_mean'};
				end
				msk = h_ax.UserData.norm_grf.t >= ipsi_hs_time & h_ax.UserData.norm_grf.t <= ipsi_to_time & ~isnan(h_ax.UserData.norm_grf.z);
				norm_grf_t = h_ax.UserData.norm_grf.t(msk);
				norm_grf_x = h_ax.UserData.norm_grf.x(msk);
				norm_grf_y = h_ax.UserData.norm_grf.y(msk);
				norm_grf_z = h_ax.UserData.norm_grf.z(msk);

				if isempty(norm_grf_z)
					norm_grf_z_peak = nan;
					norm_grf_z_mean = nan;
					norm_grf_z_auc = nan;
					norm_grf_norm_peak = nan;
					norm_grf_norm_mean = nan;
					norm_grf_norm_auc = nan;
					norm_ss_t = nan;
					ss_norm_grf_norm_peak = nan;
					ss_norm_grf_norm_mean = nan;
					ss_norm_grf_norm_auc = nan;
					norm_grf_z_peak = nan;
					norm_grf_z_mean = nan;
					norm_grf_z_auc = nan;
					ss_norm_grf_z_peak = nan;
					ss_norm_grf_z_mean = nan;
					ss_norm_grf_z_auc = nan;
					
				else
					norm_grf_z_peak = max(norm_grf_z);
					norm_grf_z_mean = mean(norm_grf_z);
					norm_grf_z_auc = trapz(norm_grf_t, norm_grf_z);
					
					
					ss_t = h_ax.UserData.norm_grf.t >= contra_to_time & h_ax.UserData.norm_grf.t <= contra_hs_time;
					ss_norm_grf_z_peak = max(h_ax.UserData.norm_grf.z(ss_t));
					if isempty(ss_norm_grf_z_peak), ss_norm_grf_z_peak = nan; end
					ss_norm_grf_z_mean = mean(h_ax.UserData.norm_grf.z(ss_t));
					ss_norm_grf_z_auc = trapz(h_ax.UserData.norm_grf.t(ss_t), h_ax.UserData.norm_grf.z(ss_t));
					
					% norm of the whole normalised grf
					norm_grf_norm = nan(size(norm_grf_z));
					for vec_cnt = 1:length(norm_grf_z)
						norm_grf_norm(vec_cnt) = norm([norm_grf_x(vec_cnt), norm_grf_y(vec_cnt), norm_grf_z(vec_cnt)]);
					end
					norm_grf_norm_peak = max(norm_grf_norm);
					norm_grf_norm_mean = nanmean(norm_grf_norm);
					norm_grf_norm_auc = trapz(norm_grf_t, norm_grf_norm);
					
					norm_ss_t = norm_grf_t >= contra_to_time & norm_grf_t <= contra_hs_time;
					
					
					ss_norm_grf_norm_peak = max(norm_grf_norm(norm_ss_t));
					ss_norm_grf_norm_mean = nanmean(norm_grf_norm(norm_ss_t));
					ss_norm_grf_norm_auc = trapz(norm_grf_t(norm_ss_t), norm_grf_norm(norm_ss_t));
				end
				gc_data_tbl(gc_ind,var_names) = {norm_grf_z_peak, norm_grf_z_mean, norm_grf_z_auc, ...
					norm_grf_norm_peak, norm_grf_norm_mean, norm_grf_norm_auc, ...
					ss_norm_grf_z_peak, ss_norm_grf_z_mean, ss_norm_grf_z_auc, ...
					ss_norm_grf_norm_peak, ss_norm_grf_norm_mean, ss_norm_grf_norm_auc};
			end
		end
		
	end
end


% save data to a file
filename = lower(handles.edit_filename.String);
filename = strrep(filename, '/data/', '/analysis/');
filename = strrep(filename, '.csv', '_gait_info.txt');
[pathstr, fname, ext] = fileparts(filename);
cur_dir = pwd;
changed_dir = false;
if ~isempty(pathstr) && ~strcmp(pathstr,cur_dir)
	if ~exist(pathstr, 'dir')
		answer = questdlg(['Create folder: ' pathstr '?']);
		if strcmp(answer, 'Yes')
			mkdir(pathstr)
		end
	end
	cd(pathstr)
	changed_dir = true;
end

[filename, pathname] = uiputfile('*.txt', 'Save gait cycle info as', filename);
if changed_dir, cd(cur_dir), end
if isequal(filename,0) || isequal(pathname,0)
	   disp('User pressed cancel')
	   return
end
	
file_name = fullfile(pathname, filename);
disp(['Saving ', file_name])
writetable(gc_data_tbl, file_name, 'Delimiter', '\t')

% send data to database
vicon_info2db(handles, gc_data_tbl)
check_database(handles)


return



