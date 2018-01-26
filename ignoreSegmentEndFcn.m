function ignoreSegmentEndFcn(h_line)
% h_line is either the left or right endpoint of the segment


h_fp_line = findobj(h_line.Parent, '-regexp',  'Tag', 'line_FP\d_Force_Fz_N');

% delete old fill line
prev_ignor_seg = findobj(h_line.Parent, 'Tag', 'line_ignoreSegment');
if ~isempty(prev_ignor_seg)
	delete(prev_ignor_seg)
end

h_left_pt = findobj(h_line.Parent,  'Tag', 'ignore_seg_left');
left_ind = find(h_fp_line.XData >= h_left_pt.XData, 1);

h_right_pt = findobj(h_line.Parent,  'Tag', 'ignore_seg_right');
right_ind = find(h_fp_line.XData >= h_right_pt.XData, 1);

% fill in the endpoints with a segment
npts = 10;
x = [left_ind-npts:left_ind right_ind:right_ind+npts];
y = h_fp_line.YData(x);


xx = left_ind:right_ind;

yy = spline(x, y, xx);

h_fill_line = line(h_fp_line.XData(xx), yy, 'linewidth', 2, 'Tag', 'line_ignoreSegment');