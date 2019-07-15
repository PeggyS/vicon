function vicon_info2db(handles, gc_data_tbl)
% send the data  table in the mysql database
%
%

% open connection to database
dbparams = get_db_login_params('tdcs_vgait');
dbtable = 'vicon_steps';
% % since this takes a while, display a waitbar
% hwb = waitbar(0, 'Sending Gait Info Data to the Database');

% update the waitbar
% waitbar(i/count, hwb);

add_to_database = true;
% check to see if this is already in the database
update_txt = regexpi(handles.txt_db_date.String,' ', 'split');
if strcmp(update_txt{1}, 'database')  % data is in database
	answer = questdlg({['Info in database: ' update_txt{3} ' ' update_txt{4}]; ...
		'Overwrite database with new info?'},'', 'No');
	if strcmp(answer, 'Yes')
		% delete old data from database
		try
			conn = dbConnect(dbparams.dbname, dbparams.user, dbparams.password, dbparams.serveraddr);
		catch
			disp('error connecting to database')
			return
		end
		
		% remove all the old data
		conn.dbDeleteRow(dbtable, 'subj', handles.edSubject.String, ...
					'data_collect', handles.popmenuSession.String{handles.popmenuSession.Value}, ...
					'trial', handles.popmenuTrialNum.String{handles.popmenuTrialNum.Value});
		conn.dbClose()
	else
		% don't overwrite data
		add_to_database = false;
	end
end

if add_to_database
	% add one row for each row in gc_data_tbl
	constInfo = {handles.edSubject.String handles.popmenuSession.String{handles.popmenuSession.Value} ...
		handles.popmenuTrialNum.String{handles.popmenuTrialNum.Value} ...
		handles.popmenuAssistDevice.String{handles.popmenuAssistDevice.Value}};
	const_colnames = {'subj', 'data_collect', 'trial', 'assist_device'};
	var_list = gc_data_tbl.Properties.VariableNames;
	try
		conn = dbConnect(dbparams.dbname, dbparams.user, dbparams.password, dbparams.serveraddr);
	catch
		disp('error connecting to database')
		return
	end
	for cnt = 1:height(gc_data_tbl)
		values = constInfo;
		colnames = const_colnames;
		% do not include nans
		for vv = 1:length(var_list)
			var = var_list{vv};
			if ~isnan(gc_data_tbl.(var)(cnt))
				colnames = [colnames {var}];
				values = [values {gc_data_tbl.(var)(cnt)}];
			end
		end
		
		conn.dbAddRow(dbtable,colnames, values);
	end
	% close the database
	conn.dbClose()
	
	
end % add_to_database


return

