function prelim_plots()
%

% open connection to database
dbparams = get_db_login_params('tdcs_vgait');
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


measure_list = {'swing_time', 'single_stance_time', 'double_stance_loading_time', 'double_stance_unloading_time', ...
	'involved_stride_length', 'uninvolved_stride_length', 'involved_step_length', 'uninvolved_step_length', ...
	'involved_fp_vert_peak', 'involved_fp_vert_auc', 'involved_fp_vert_mean', ...
	'uninvolved_fp_vert_peak', 'uninvolved_fp_vert_auc', 'uninvolved_fp_vert_mean'};

subj_list = unique(whole_tbl.subj);

whole_tbl.subj = nominal(whole_tbl.subj);
whole_tbl.data_collect = nominal(whole_tbl.data_collect);
whole_tbl.assist_device = nominal(whole_tbl.assist_device);

for s_cnt = 1:length(subj_list)
	subj = subj_list{s_cnt};
	
	s_tbl = whole_tbl(whole_tbl.subj==subj, :);
	if strcmp(subj, 's2702tdvg')
		% use only data with cane
		s_tbl = s_tbl(s_tbl.assist_device=='cane',:);
	end
	
	s_tbl.pct_inv_swing = s_tbl.swing_time ./ s_tbl.gc_time;
	s_tbl.pct_uninv_swing = s_tbl.single_stance_time ./ s_tbl.gc_time;
	
	figure
	plot_errorbar_lines(s_tbl(:,{ 'pct_uninv_swing', 'pct_inv_swing',}), s_tbl.data_collect)	
	tlt_str = [subj ' - % of gc in single limb support'];;
	title(tlt_str)
	ylabel('% of gait cycle')
	legend('involved', 'uninvolved')
	print(gcf,'-dpng',[tlt_str '.png'])

	figure
	plot_errorbar_lines(s_tbl(:,{'involved_stride_length', 'uninvolved_stride_length'}), s_tbl.data_collect)	
	tlt_str = [subj ' - Stride Length'];
	title(tlt_str)
	ylabel('Stride Length (mm)')
	legend('involved', 'uninvolved')
	print(gcf,'-dpng',[tlt_str '.png'])
	
	figure
	plot_errorbar_lines(s_tbl(:,{'involved_step_length', 'uninvolved_step_length'}), s_tbl.data_collect)	
	tlt_str = [subj ' - Step Length'];
	title(tlt_str)
	ylabel('Step Length (mm)')
	legend('involved', 'uninvolved')
	print(gcf,'-dpng',[tlt_str '.png'])
	
	figure
	plot_errorbar_lines(s_tbl(:,{'involved_fp_vert_peak', 'uninvolved_fp_vert_peak'}), s_tbl.data_collect)	
	tlt_str = [subj ' - Peak Vertical GRF'];
	title(tlt_str)
	ylabel('Peak Vertical GRF (N)')
	legend('involved', 'uninvolved')
	print(gcf,'-dpng',[tlt_str '.png'])
	
	figure
	plot_errorbar_lines(s_tbl(:,{'involved_fp_vert_auc', 'uninvolved_fp_vert_auc'}), s_tbl.data_collect)	
	tlt_str = [subj ' - AUC Vertical GRF'];
	title(tlt_str)
	ylabel('AUC Vertical GRF (Ns)')
	legend('involved', 'uninvolved')
	print(gcf,'-dpng',[tlt_str '.png'])
	
	figure
	plot_errorbar_lines(s_tbl(:,{'involved_fp_vert_mean', 'uninvolved_fp_vert_mean'}), s_tbl.data_collect)	
	tlt_str = [subj ' - Mean Vertical GRF'];
	title(tlt_str)
	ylabel('Mean Vertical GRF (N)')
	legend('involved', 'uninvolved')
	print(gcf,'-dpng',[tlt_str '.png'])
end

return

% ------------------
function plot_errorbar_lines(tbl_data, grp)
for cnt = 1:width(tbl_data)
	[means, sems, counts, gnames] = grpstats(tbl_data{:,cnt}, grp, {'mean', 'sem', 'numel', 'gname'});
	[means, sems, counts, gnames] = order_pre_mid_post_fu(means, sems, counts, gnames);
	
	n_gps = length(gnames);
	h_eb = errorbar(1:n_gps, means, sems);
	for n_cnt = 1:length(counts)
		text(n_cnt+0.1, means(n_cnt), ['N = ' num2str(counts(n_cnt))]);
	end
	hold on
end
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
