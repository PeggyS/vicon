function side = find_subject_involved_side(subj)
% look up in the database the involved side of the tdvg subject
side = '';

% open connection to database
dbparams = get_db_login_params('tdcs_vgait');

conn = dbConnect(dbparams.dbname, dbparams.user, dbparams.password, dbparams.serveraddr);

% subjects in the db have full s27xxtdvg name, matlab processing uses shorthand s27xx
full_subj = subj;
if length(subj) < 9
	full_subj = strcat(subj, 'tdvg');
end

% select affected_side from tdcs_vgait.demographics where subj = 's2701tdvg';

result = conn.dbSearch('demographics', 'affected_side',...
                           'subj', full_subj);
if length(result)~=1
	warning('error finding affected side for %s', full_subj);
else
	side = result{:};
end


% close the database
conn.dbClose()
