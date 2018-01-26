function display_marker_data(data, marker)

hf = figure;

h_ax1 = subplot(3,1,1);
title(marker)
ylabel('pos (mm)')
draw_marker_line(h_ax1, data.markers, [marker '_X_mm'], 'color','r','linestyle','-')
draw_marker_line(h_ax1, data.markers, [marker '_Y_mm'], 'color','g','linestyle','-')
draw_marker_line(h_ax1, data.markers, [marker '_Z_mm'], 'color','b','linestyle','-')
line([0 6],[0 0],'color','k','linestyle',':')
x = mean(h_ax1.XLim);
hl1 = line([x, x], h_ax1.YLim, 'LineWidth', 2);
draggable(hl1,'h')

h_ax2 = subplot(3,1,2);
ylabel('vel (mm/s)')
draw_marker_line(h_ax2, data.markers, [marker '_X_vel_mm_per_s'], 'color','r','linestyle','-')
draw_marker_line(h_ax2, data.markers, [marker '_Y_vel_mm_per_s'], 'color','g','linestyle','-')
draw_marker_line(h_ax2, data.markers, [marker '_Z_vel_mm_per_s'], 'color','b','linestyle','-')
line([0 6],[0 0],'color','k','linestyle',':')
hl2 = line([x, x], h_ax2.YLim, 'LineWidth', 2);
draggable(hl2,'h')

h_ax3 = subplot(3,1,3);
draw_marker_line(h_ax3, data.markers, [marker '_X_acc_mm_per_s_2'], 'color','r','linestyle','-')
draw_marker_line(h_ax3, data.markers, [marker '_Y_acc_mm_per_s_2'], 'color','g','linestyle','-')
draw_marker_line(h_ax3, data.markers, [marker '_Z_acc_mm_per_s_2'], 'color','b','linestyle','-')
line([0 6],[0 0],'color','k','linestyle',':')
hl3 = line([x, x], h_ax3.YLim, 'LineWidth', 2);
draggable(hl3,'h')
ylabel('acc (mm/s^2)')
xlabel('time (s)')
legend('X', 'Y', 'Z')

hf.UserData.hax_link = linkprop([h_ax1,h_ax2,h_ax3], {'xlim'});
hf.UserData.hl_link = linkprop([hl1,hl2,hl3], 'XData');

