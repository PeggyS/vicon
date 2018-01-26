
s = RandStream('mcg16807','Seed',0);
% RandStream.setDefaultStream(s);  %set seed so example is reproducible
monthdata = rand(1,30);   %random data
threshold = 0.4;  %for example
tic
aboveThreshold = (monthdata > threshold);  %where above threshold
%aboveThreshold is a logical array, where 1 when above threshold, 0, below.
%we thus want to calculate the difference between rising and falling edges
aboveThreshold = [false, aboveThreshold, false];  %pad with 0's at ends
edges = diff(aboveThreshold);
rising = find(edges==1);     %rising/falling edges
falling = find(edges==-1);  
spanWidth = falling - rising;  %width of span of 1's (above threshold)
wideEnough = spanWidth >= 5;   
startPos = rising(wideEnough);    %start of each span
endPos = falling(wideEnough)-1;   %end of each span
%all points which are in the 5-month span (i.e. between startPos and endPos).
allInSpan = cell2mat(arrayfun(@(x,y) x:1:y, startPos, endPos, 'uni', false));  
toc

disp('===')

tic
aboveThreshold = (monthdata > threshold);
spanLocs = bwlabel(aboveThreshold);   %identify contiguous ones
spanLength = regionprops(spanLocs, 'area');  %length of each span
spanLength = [ spanLength.Area];
goodSpans = find(spanLength>=5);   %get only spans of 5+ points
allInSpans = find(ismember(spanLocs, goodSpans));  %indices of these spans
toc