function is_var = table_variable_exists(tbl, varname)

is_var = sum(strcmpi(tbl.Properties.VariableNames, varname));

return