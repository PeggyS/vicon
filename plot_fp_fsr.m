

function data = plot_fp_fsr(varargin)

% input parameter-value pairs:
%	file - .csv file to read in
%	data - data struct already read in with read_vicon_csv()


% define input parser
p = inputParser;
p.addParameter('file', '', @ischar);
p.addParameter('data', struct(), @isstruct);

% parse the input
p.parse(varargin{:});
inputs = p.Results;

if ~isempty(inputs.file)
	data = read_vicon_csv(inputs.file);
else 
	data = inputs.data;
end

% data = read_vicon_csv(fname);
t = data.devices.tbl.Frame / 100 + data.devices.tbl.Sub_Frame/1000;

figure
subplot(2,1,1)
plot(t,-data.devices.tbl.FP1_Force_Fz_N)
ylabel('FP1 Vertical Force (N)')
subplot(2,1,2)
ylabel('Left FSR (V)')
xlabel('Time (s)')
hold on
plot(t,data.devices.tbl.Analog_EMG_Voltage_L_Lat_Heel_V)
plot(t,data.devices.tbl.Analog_EMG_Voltage_L_Med_Heel_V)
plot(t,data.devices.tbl.Analog_EMG_Voltage_L_Med_MT_V)
plot(t,data.devices.tbl.Analog_EMG_Voltage_L_Med_Toe_V)
plot(t,data.devices.tbl.Analog_EMG_Voltage_L_Center_MT_V)
plot(t,data.devices.tbl.Analog_EMG_Voltage_L_Lat_Toe_V)
plot(t,data.devices.tbl.Analog_EMG_Voltage_L_Lat_MT_V)
plot(t,data.devices.tbl.Analog_EMG_Voltage_L_Lat_Instep_V)
legend('Lat Heel', 'Med Heel', 'Med MT','Med Toe','Center MT','Lat Toe','Lat MT','Lat Instep')


figure
subplot(2,1,1)
plot(t,-data.devices.tbl.FP2_Force_Fz_N)
ylabel('FP2 Vertical Force (N)')
subplot(2,1,2)
ylabel('Right FSR (V)')
xlabel('Time (s)')
hold on
plot(t,data.devices.tbl.Analog_EMG_Voltage_R_Lat_Heel_V)
plot(t,data.devices.tbl.Analog_EMG_Voltage_R_Med_Heel_V)
plot(t,data.devices.tbl.Analog_EMG_Voltage_R_Med_MT_V)
plot(t,data.devices.tbl.Analog_EMG_Voltage_R_Med_Toe_V)
plot(t,data.devices.tbl.Analog_EMG_Voltage_R_Center_MT_V)
plot(t,data.devices.tbl.Analog_EMG_Voltage_R_Lat_Toe_V)
plot(t,data.devices.tbl.Analog_EMG_Voltage_R_Lat_MT_V)
plot(t,data.devices.tbl.Analog_EMG_Voltage_R_Lat_Instep_V)
legend('Lat Heel', 'Med Heel', 'Med MT','Med Toe','Center MT','Lat Toe','Lat MT','Lat Instep')