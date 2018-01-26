function dbparams = get_db_login_params()
% change these values as needed for where the database is running

[~, name] = system('hostname');
if strncmp(name, 'mini-meg', 8)
    dbparams.serveraddr = 'localhost';
else
    dbparams.serveraddr = '10.83.111.19';
end
dbparams.dbname = 'tdcs_vgait';
dbparams.user = 'tdcs_vgait';
dbparams.password = 'tdcs_vgait';



