function check_database(handles)
% check the database for this data_collection and trial 

% open connection to database
dbparams = get_db_login_params('tdcs_vgait');

try
	conn = dbConnect(dbparams.dbname, dbparams.user, dbparams.password, dbparams.serveraddr);
catch
	warning('could not connect to database')
	return
end
% subjects in the db have full s27xxtdvg name
full_subj = handles.edSubject.String;
if length(full_subj) < 9
	full_subj = strcat(subj, 'tdvg');
end

% select last_update from tdcs_vgait.vicon_steps where subj = 's2702tdvg' and data_collect = 'pre' and trial = 18;

result = conn.dbSearch('vicon_steps', 'last_update',...
                           'subj', full_subj, ...
					   'data_collect', handles.popmenuSession.String{handles.popmenuSession.Value}, ...
					   'trial', handles.popmenuTrialNum.String{handles.popmenuTrialNum.Value} );
% close the database
conn.dbClose()

if ~isempty(result)
	handles.txt_db_date.String = ['database updated: ' result{1}];
else
	handles.txt_db_date.String = 'not in database';
end


