function data = read_vicon_csv(filename)
%READ_VICON_CSV - read data in from a vicon csv file
%
% input
%	filename - name of file to read
%
% output
%	data structure with the fields (depending on file contents. If not, then the field is missing.):
%		events = struc with fields
%				samp_freq
%				tbl = table with variables:  Subject Context  Name  Time_s Description
%		devices = struct with fields
%				samp_freq
%				tbl - table with variables for the force plates (FP1_ForceFx_N,
%				etc). There may also be emg data.
%					Frame = frame number (starting with 1) at the 100Hz 
%					Sub_Frame = count of datapoints (starting with 0) that are
%					recorded over that 100 Hz video frame. (FP data is recorded
%					at 1000Hz, so there are 10 samples (0-9) for each video frame.)
%		model_outputs = struct with fields
%				samp_freq
%				tbl - table with 569 variables of the plug-in dynamic gait model
%		markers = struct with fields
%				samp_freq
%				tbl - table with the global position (vicon trajectory) of each marker

% Author: Peggy Skelly
% 2017-08-03: create 
% 2020-01-07: with the upgrade in Vicon from 1.8 to 2, the csv files are
% saved as UTF-8 in version 2. In version 1.8 they were saved as 'Western
% (Windows 1252)' and the default encoding 'ISO-8859-1' to read in worked fine. 
% If the file date of the csv file is older than 2019-12-01, then use the
% old encoding. If it is later, then use UTF-8 encoding to read it in.


if ~exist(filename, 'file')
	error('%s does not exist', filename);
end

% check the file's date to decide what encoding to use when reading in
f_info = dir(filename);
cutoff_datenum = datenum(2019,12,01); % date defining the use of different encoding
if f_info.datenum >= cutoff_datenum
	encoding = 'UTF-8';
else
	encoding = 'ISO-8859-1';
end

% open the file
fid = fopen(filename, 'r', 'n', encoding);
data.filename = filename;

% read in 1st line
txt = fgetl(fid);
% remove wierd first character that seems to be present in vicon nexus
% 2.8.2 when exporting accelerations
if double(txt(1)) == 65279
	txt = txt(2:end);
end
	
while ischar(txt) % txt will change to -1 when end of file is reached
	
	% look for keywords: Events, Devices, Model Outputs
	switch txt
		case 'Events'
			data.events = read_events(fid);
		case 'Devices'
			data.devices = read_devices(fid);
		case 'Model Outputs'
			data.model_outputs = read_model_outputs(fid);
		case 'Trajectories'
			data.markers = read_model_outputs(fid);
	end
	% read in next line
	txt = fgetl(fid);
	
end
	
% close the file
fclose(fid);
return

function events = read_events(fid)
% read the next line, it should be the vicon sampling freq
txt = fgetl(fid);
events.samp_freq = str2double(txt);
% next line is the column labels of the following table
txt = fgetl(fid);
tmp = textscan(txt,'%s','Delimiter',',');
col_names = tmp{1}';
% turn col_names into valid table variable names
col_names = cellfun(@(x)strrep(x, ' ', '_'),col_names,'Uniformoutput',false); % replace blanks with underscores
col_names = cellfun(@(x)strrep(x, ')', ''),col_names,'Uniformoutput',false); % remove parentheses
col_names = cellfun(@(x)strrep(x, '(', ''),col_names,'Uniformoutput',false); % remove parentheses
% read in the data
events.tbl = read_text_table(fid, col_names);
return

function tbl = read_text_table(fid, col_names)
tbl = table();
% read lines until there is a blank line
txt = fgetl(fid);
line_cnt = 0;
while ~isempty(txt)
	
	tmp = textscan(txt, '%s','Delimiter',',');
	row_data = tmp{1}';
	
	line_cnt = line_cnt+1;
	data_cell(line_cnt,:) = row_data;

	txt = fgetl(fid);
end
% put the data into a table
tbl = cell2table(data_cell, 'VariableNames', col_names);
return

function tbl = read_data_table(fid, col_names)
tbl = table();

% read lines until there is a blank line
txt = fgetl(fid);
line_cnt = 0;
while ~isempty(txt)
	% put the data into a table
	tmp = textscan(txt, '%f','Delimiter',',');
	row_data = tmp{1}';
	
	line_cnt = line_cnt+1;
	if exist('data_mat', 'var') && size(data_mat,2) ~= length(row_data) % if the initial rows do not have data in the
		% last column, then that column is ignored by textscan. Add columns of
		% nans to the data_mat or row_data so data_mat and row_data have the same number of
		% cols.
		if size(data_mat,2) < length(row_data)
			n_cols_to_add = length(row_data) -  size(data_mat,2);
			nan_data = nan(size(data_mat,1), n_cols_to_add);
			data_mat = [data_mat nan_data];
		else
			n_cols_to_add = size(data_mat,2) - length(row_data);
			nan_data = nan(1, n_cols_to_add);
			row_data = [row_data nan_data];
		end
	end
	data_mat(line_cnt,:) = row_data;

	txt = fgetl(fid);
end
tbl = array2table(data_mat, 'VariableNames', col_names);
return

function new_name = combine_names(name1, name2)
if isempty(name1)
	new_name = name2;
elseif isempty(name2)
	new_name = name1;
else
	new_name = [name1 '_' name2];
end
return

function devices = read_devices(fid)
% read the next line, it should be the vicon sampling freq
txt = fgetl(fid);
devices.samp_freq = str2double(txt);
% next 3 lines form the column labels of the following table
txt = fgetl(fid);
tmp = textscan(txt,'%s','Delimiter',',');
col_names = tmp{1}';
% turn col_names into valid table variable names
% 1st row:  FP1 (3979) - Force
col_names = cellfun(@(x)strrep(x, ' - ', '_'),col_names,'Uniformoutput',false); % replace blank & dash with underscores
col_names = cellfun(@(x)regexprep(x, ' \(\d{4}\)', ''),col_names,'Uniformoutput',false); % remove parentheses & info in between
col_names = cellfun(@(x)strrep(x, ' ', '_'),col_names,'Uniformoutput',false); % replace any other blanks with underscores
% check each col name & if blank, repeat the previous col name
for c_cnt = 2:length(col_names)
	if ~isempty(col_names{c_cnt-1}) && isempty(col_names{c_cnt})
		col_names{c_cnt} = col_names{c_cnt-1};
	end
end

% 2nd row: Frame	Sub Frame	Fx	Fy ...
txt = fgetl(fid);
tmp = textscan(txt,'%s','Delimiter',',');
col2_names = tmp{1}';
col2_names = cellfun(@(x)strrep(x, ' ', '_'),col2_names,'Uniformoutput',false); % replace blank with underscores

% 3rd row: units like: N mm.N
txt = fgetl(fid);
tmp = textscan(txt,'%s','Delimiter',',');
col3_names = tmp{1}';
col3_names = cellfun(@(x)strrep(x, '.', ''),col3_names,'Uniformoutput',false); % remove dot 

% info from the 3 rows into a single column name
col_names = cellfun(@(x,y)combine_names(x,y), col_names, col2_names, 'UniformOutput', false);
col_names = cellfun(@(x,y)combine_names(x,y), col_names, col3_names, 'UniformOutput', false);

% read in the data
devices.tbl = read_data_table(fid, col_names);

return

function devices = read_model_outputs(fid)
% read the next line, it should be the vicon sampling freq
txt = fgetl(fid);
devices.samp_freq = str2double(txt);
% next 3 lines form the column labels of the following table
txt = fgetl(fid);
tmp = textscan(txt,'%s','Delimiter',',');
col_names = tmp{1}';
% turn col_names into valid table variable names
% 1st row:  		s2702tdvg:LAbsAnkleAngle			s2702tdvg:LAnkleAngles	
col_names = cellfun(@(x)regexprep(x, '^.*:', ''),col_names,'Uniformoutput',false); % remove subj number & :
col_names = cellfun(@(x)strrep(x, ' ', '_'),col_names,'Uniformoutput',false); % replace blank with underscores
% check each col name & if blank, repeat the previous col name
for c_cnt = 2:length(col_names)
	if ~isempty(col_names{c_cnt-1}) && isempty(col_names{c_cnt})
		col_names{c_cnt} = col_names{c_cnt-1};
	end
end

% 2nd row: Frame	Sub Frame	X Y Z ...X' Y' Z'
txt = fgetl(fid);
tmp = textscan(txt,'%s','Delimiter',',');
col2_names = tmp{1}';
col2_names = cellfun(@(x)strrep(x, ' ', '_'),col2_names,'Uniformoutput',false); % replace blank with underscores
col2_names = cellfun(@(x)strrep(x, '''''', '_acc'),col2_names,'Uniformoutput',false); % replace '' with acc
col2_names = cellfun(@(x)strrep(x, '''', '_vel'),col2_names,'Uniformoutput',false); % replace ' with vel

% 3rd row: units like: N mm.N
txt = fgetl(fid);
tmp = textscan(txt,'%s','Delimiter',',');
col3_names = tmp{1}';
col3_names = cellfun(@(x)strrep(x, ' ', '_'),col3_names,'Uniformoutput',false); % 
col3_names = cellfun(@(x)strrep(x, '.', ''),col3_names,'Uniformoutput',false); % remove dot 
col3_names = cellfun(@(x)strrep(x, '/', '_per_'),col3_names,'Uniformoutput',false); % replace /
col3_names = cellfun(@(x)strrep(x, '²', '_2'),col3_names,'Uniformoutput',false); % replace 
col3_names = cellfun(@(x)strrep(x, '³', '_3'),col3_names,'Uniformoutput',false); % replace 
col3_names = cellfun(@(x)strrep(x, '^4', '_4'),col3_names,'Uniformoutput',false); % replace 
col3_names = cellfun(@(x)strrep(x, '^5', '_5'),col3_names,'Uniformoutput',false); % replace 
% in 'Trajectories' section, the last column doesn't have a 3rd row value, add
% an empty string
if length(col3_names) < length(col_names)
	col3_names(end+1) = {''};
end


% info from the 3 rows into a single column name
col_names = cellfun(@(x,y)combine_names(x,y), col_names, col2_names, 'UniformOutput', false);
col_names = cellfun(@(x,y)combine_names(x,y), col_names, col3_names, 'UniformOutput', false);

% read in the data
devices.tbl = read_data_table(fid, col_names);

return

