function prelim_plots()
%

% open connection to database
dbparams = get_db_login_params();
conn = dbConnect(dbparams.dbname, dbparams.user, dbparams.password, dbparams.serveraddr);

% get table from the database
whole_tbl = cell2table(conn.dbSearch('vicon_steps', {'subj','data_collect', 'trial', 'assist_device', ...
	'gc_time', 'swing_time', 'single_stance_time', 'double_stance_loading_time', 'double_stance_unloading_time', ...
	'involved_stride_length', 'uninvolved_stride_length', 'involved_step_length', 'uninvolved_step_length', ...
	'involved_fp_vert_peak', 'involved_fp_vert_auc', 'involved_fp_vert_mean', ...
	'uninvolved_fp_vert_peak', 'uninvolved_fp_vert_auc', 'uninvolved_fp_vert_mean'}), ...
	'VariableNames', {'subj','data_collect', 'trial', 'assist_device', ...
	'gc_time', 'swing_time', 'single_stance_time', 'double_stance_loading_time', 'double_stance_unloading_time', ...
	'involved_stride_length', 'uninvolved_stride_length', 'involved_step_length', 'uninvolved_step_length', ...
	'involved_fp_vert_peak', 'involved_fp_vert_auc', 'involved_fp_vert_mean', ...
	'uninvolved_fp_vert_peak', 'uninvolved_fp_vert_auc', 'uninvolved_fp_vert_mean'});

conn.dbClose()



% measure_list = {'swing_time', 'single_stance_time', 'double_stance_loading_time', 'double_stance_unloading_time', ...
% 	'involved_stride_length', 'uninvolved_stride_length', 'involved_step_length', 'uninvolved_step_length', ...
% 	'involved_fp_vert_peak', 'involved_fp_vert_auc', 'involved_fp_vert_mean', ...
% 	'uninvolved_fp_vert_peak', 'uninvolved_fp_vert_auc', 'uninvolved_fp_vert_mean'};

measure_list = {'inv_pct_single_stance_time','uninv_pct_single_stance_time', 'ss_asymmetry', 'gait_speed', ...
 	'single_double_ratio', 'step_asymmetry'};
%measure_list = {'stance_asymmetry'};

subj_list = unique(whole_tbl.subj);

whole_tbl.subj = nominal(whole_tbl.subj);
whole_tbl.data_collect = nominal(whole_tbl.data_collect);
whole_tbl.assist_device = nominal(whole_tbl.assist_device);

for m_cnt = 1:length(measure_list)
	measure = measure_list{m_cnt};
	figure	
	legend_txt = {}; l_cnt = 0;
	for s_cnt = 1:length(subj_list)
		subj = subj_list{s_cnt};
		
		s_tbl = whole_tbl(whole_tbl.subj==subj, :);
		if strcmp(subj, 's2702tdvg')
			% use only data with cane
			s_tbl = s_tbl(s_tbl.assist_device=='cane',:);
		end
		
		switch measure
			case 'inv_pct_single_stance_time'
				s_tbl.data = s_tbl.single_stance_time ./ s_tbl.gc_time .* 100;
			case 'uninv_pct_single_stance_time'
				s_tbl.data = s_tbl.swing_time ./ s_tbl.gc_time .* 100;
			case 'ss_asymmetry'
				inv_stance_pct = s_tbl.single_stance_time ./ s_tbl.gc_time  .* 100;
				uninv_stance_pct = s_tbl.swing_time ./ s_tbl.gc_time  .* 100;
				s_tbl.data = 1 - (inv_stance_pct ) ./ (uninv_stance_pct);
			case 'gait_speed'
				s_tbl.data = s_tbl.involved_stride_length ./ s_tbl.gc_time ./ 1000; % in m/s
			case 'single_double_ratio'
				s_tbl.data = s_tbl.single_stance_time ./ (s_tbl.gc_time-s_tbl.single_stance_time); 
			case 'step_asymmetry'
				s_tbl.data = 1 - s_tbl.involved_step_length ./ s_tbl.uninvolved_step_length;
			case 'stance_asymmetry'
				
		end
		

		[means, sems, counts, gnames] = plot_errorbar_lines(s_tbl.data, s_tbl.data_collect);
		l_cnt = l_cnt+1;
		legend_txt{l_cnt} = [char(subj) ];
		disp([measure ' ' subj ' pre=' num2str(means(1)), ' post=' num2str(means(3)) ...
			' post-pre=' num2str(means(3)-means(1)) ' f/u-pre=' num2str(means(4)-means(1)) ...
			' post%chng=' num2str((means(3)-means(1))/means(1)*100) ' f/u-pre=' num2str((means(4)-means(1))/means(1)*100)])
	end % subj
	
	switch measure
		case 'inv_pct_single_stance_time'
			tlt_str = ['Involved leg - % of gc in single limb support'];
			title(tlt_str)
			ylabel('% of gait cycle')
		case 'uninv_pct_single_stance_time'
			tlt_str = ['Uninvolved leg - % of gc in single limb support'];
			title(tlt_str)
			ylabel('% of gait cycle')
		case 'ss_asymmetry'
			title('Single stance asymmetery')
			ylabel('1 - (inv % ss) / (uninv %ss)')
		case 'gait_speed'
			title ('Self Selected Gait Speed')
			ylabel('Gait Speed (m/s)')
		case 'single_double_ratio'
			title('Affected Leg single stance - double stance ratio')
			ylabel('(single stance time) / (double stance time)')
		case 'step_asymmetry'
			title('Step asymmetry')
			ylabel('1 - (inv step length) / (uninv step length)')
	end

	legend(char(legend_txt))
	
end %measure

return

% ------------------
function [means, sems, counts, gnames] = plot_errorbar_lines(data, grp)

	[means, sems, counts, gnames] = grpstats(data, grp, {'mean', 'sem', 'numel', 'gname'});
	[means, sems, counts, gnames] = order_pre_mid_post_fu(means, sems, counts, gnames);
	
	n_gps = length(gnames);
	h_eb = errorbar(1:n_gps, means, sems);
	% display n for each point
	for n_cnt = 1:length(counts)
		text(n_cnt+0.1, means(n_cnt), ['N = ' num2str(counts(n_cnt))]);
	end
	
	% comparision of pre vs other times
	pre_data = data(grp=='pre');
	for g_cnt = 2:n_gps
		grp_data = data(grp==gnames(g_cnt));
		if ~all(isnan(grp_data))
			[p, h] = ranksum(pre_data, grp_data);
			if p < 0.05
				text(g_cnt+0.1, means(g_cnt)+2*sems(g_cnt), ['p = ' num2str(p)])
			end
		end
	end
	hold on

set(gca, 'Xlim', [0.5 n_gps+0.5], 'XTick', [1:n_gps], 'XTickLabels', gnames)

return

% ---------------------------
function [means, sems, counts, gnames] = order_pre_mid_post_fu(means, sems, counts, gnames)
pre_ind = find(strcmp(gnames,'pre'));
mid_ind = find(strcmp(gnames,'mid'));
post_ind = find(strcmp(gnames,'post'));
followup_ind = find(strcmp(gnames,'followup'));
means = means([pre_ind, mid_ind, post_ind, followup_ind]);
sems = sems([pre_ind, mid_ind, post_ind, followup_ind]);
counts = counts([pre_ind, mid_ind, post_ind, followup_ind]);
gnames = gnames([pre_ind, mid_ind, post_ind, followup_ind]);
return		
		
% ---------------------------
function hb = close_bar(x, bar_vals, gw)
hb(1) = bar(x-gw/4,bar_vals(:,1),gw/2,'b') ;
hold on ;
hb(2) = bar(x+gw/4,bar_vals(:,2),gw/2,'r') ;
hold off ;
return
