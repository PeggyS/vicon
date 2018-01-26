function ignoreSegmentMotionFcn(h_line)

% keep the point/line on the force plate data line
h_fp_line = findobj(h_line.Parent, '-regexp',  'Tag', 'line_FP\d_Force_Fz_N');

x_ind = find(h_fp_line.XData >= h_line.XData, 1);
h_line.YData = h_fp_line.YData(x_ind);

