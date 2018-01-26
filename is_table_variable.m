function yes_no = is_table_variable(tbl, varname)
% return true/1 if the variable is in the table

yes_no = false;
if sum(strcmp(tbl.Properties.VariableNames, varname))
	yes_no = true;
end

