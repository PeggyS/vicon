function handles = parse_path_filename(handles)

if exist(handles.edit_filename.String, 'file')
	is_file = true;
elseif exist(handles.edit_filename.String, 'dir')
	is_dir = true;
else
	return
end

% file-path should look like this: /Users/peggy/Documents/BrainLab/tDCS Gait/Data/vicon/s2702tdvg/Pre/Trial15.csv

% subject
tmp_str = regexpi(handles.edit_filename.String, '/s\d{4}.{0,4}/', 'match');
if ~isempty(tmp_str)
	handles.edSubject.String = strrep(tmp_str{:},'/','');
else
	handles.edSubject.String = '';
end

% session
tmp_str = regexpi(handles.edit_filename.String, '/(pre)|(mid)|(post)|(followup)|(fu)/', 'match');
if ~isempty(tmp_str)
	sess = lower(strrep(tmp_str{:},'/',''));
else
	sess = 'pre';
end
switch sess
	case 'pre'
		handles.popmenuSession.Value = 1;
	case 'mid'
		handles.popmenuSession.Value = 2;
	case 'post'
		handles.popmenuSession.Value = 3;
	case {'followup', 'fu'}
		handles.popmenuSession.Value = 4;
end

% all trial numbers in the folder
[path_str, ~, ~] = fileparts(handles.edit_filename.String);
all_files = regexpdir(path_str,'^.*rial.*\.csv'); 
all_trials_cell_struct = regexpi(all_files, '(?<tr_num>\d+)\.csv', 'names');
all_trials = cellfun(@(x)x.tr_num, all_trials_cell_struct, 'UniformOutput', false);
handles.popmenuTrialNum.String = all_trials;


% trial number
tmp_str = regexpi(handles.edit_filename.String, '(?<tr_num>\d+)\.csv', 'names');
if ~isempty(tmp_str)
	handles.popmenuTrialNum.Value = find(contains(all_trials,tmp_str.tr_num)); % this only works since ML 2016b
	% earlier versions will have to use something like
	% 	IndexC = strfind(C, 'bla');
	% Index = find(not(cellfun('isempty', IndexC)));
end

% look up involved side
waitbar(0.1, handles.h_waitbar, 'looking up involved side')
try
	side = find_subject_involved_side(handles.edSubject.String);
catch
	warning('Error connecting to database.')
	side = 'right';
end
switch side
	case 'right'
		handles.popmenu_inv_side.Value = 1;
	case 'left'
		handles.popmenu_inv_side.Value = 2;
end
	

