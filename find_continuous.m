function [varargout] = find_continuous(logical_data, npts)

%logical_data is a logical array
if size(logical_data,1) > 1, logical_data = logical_data'; end % make it a row vector

%we thus want to calculate the difference between rising and falling edges
logical_data = [false, logical_data, false];  %pad with 0's at ends
edges = diff(logical_data);
rising = find(edges==1);     %rising/falling edges
falling = find(edges==-1);  
spanWidth = falling - rising;  %width of span of 1's (above threshold)
wideEnough = spanWidth >= npts;   
startPos = rising(wideEnough);    %start of each span
endPos = falling(wideEnough)-1;   %end of each span
%all points which are in the npts span (i.e. between startPos and endPos).
%allInSpan = cell2mat(arrayfun(@(x,y) x:1:y, startPos, endPos, 'uni', false));  

if nargout > 0
	varargout{1} = startPos;
end
if nargout > 1
	varargout{2} = endPos;
end

end % find_continuous
