function varargout = vicon_foot_gui(varargin)
% VICON_FOOT_GUI MATLAB code for vicon_foot_gui.fig
%      VICON_FOOT_GUI, by itself, creates a new VICON_FOOT_GUI or raises the existing
%      singleton*.
%
%      H = VICON_FOOT_GUI returns the handle to a new VICON_FOOT_GUI or the handle to
%      the existing singleton*.
%
%      VICON_FOOT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VICON_FOOT_GUI.M with the given input arguments.
%
%      VICON_FOOT_GUI('Property','Value',...) creates a new VICON_FOOT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vicon_foot_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vicon_foot_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vicon_foot_gui

% Last Modified by GUIDE v2.5 18-Sep-2017 17:15:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vicon_foot_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @vicon_foot_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before vicon_foot_gui is made visible.
function vicon_foot_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vicon_foot_gui (see VARARGIN)

% Choose default command line output for vicon_foot_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vicon_foot_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = vicon_foot_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu_marker.
function popupmenu_marker_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_marker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String')); % returns popupmenu_marker contents as cell array
marker_choice = contents{hObject.Value} ; %returns selected item from popupmenu_marker
% make this marker's panel visible and all the others invisible
all_panels = findobj(handles.figure1, '-regexp', 'Tag', 'uipanel_.*');
chosen_panel = findobj(all_panels, 'Tag', ['uipanel_' lower(marker_choice)]);
set(all_panels, 'Visible', 'off')
chosen_panel.Visible = 'on';


% --- Executes during object creation, after setting all properties.
function popupmenu_marker_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_marker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_pos_x_ltoe.
function checkbox_show_line_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles, 'vicon_data')
	parsed_tag = regexp(hObject.Tag, '_', 'split');
	marker = upper(parsed_tag{4});
	xyz = upper(parsed_tag{3});
	pos_vel_acc = parsed_tag{2};
	visible = hObject.Value;
	update_foot_marker_figure(handles, marker, xyz, pos_vel_acc, visible)
end

function edit_filename_Callback(hObject, eventdata, handles)
% hObject    handle to edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.h_waitbar = waitbar(0, 'analyzing path & file name');
handles = clear_axes(handles);
guidata(handles.figure1, handles);
clear_fp_checkboxes(handles)
% get new copy of handles struct since it was changed in clear_fp_checkboxes
handles = guidata(handles.figure1);
handles = parse_path_filename(handles);
waitbar(0.2, handles.h_waitbar, 'loading data')
handles = load_data(handles);
waitbar(0.5, handles.h_waitbar, 'creating figures')
handles = create_insole_figure(handles, 'Left');
handles = create_insole_figure(handles, 'Right');
waitbar(0.7, handles.h_waitbar, 'checking database')
check_database(handles);
guidata(handles.figure1, handles);
handles = guidata(handles.figure1);
waitbar(0.9, handles.h_waitbar, 'computing events')
pbComputeFF_Callback([], [], handles)
handles = guidata(handles.figure1);
pbComputeEvents_Callback([], [], handles)

close(handles.h_waitbar)

function clear_fp_checkboxes(handles)
% handles struct is updated with guidata in ..._Callback(). Make sure to update
% the latest version of the handles struct but getting a fresh copy before each
% call to ..._Callback().
h = guidata(handles.figure1);
h.chbx_left_fp1.Value = 0;
chbx_left_fp1_Callback(h.chbx_left_fp1, [], h) 

h = guidata(handles.figure1);
h.chbx_left_fp2.Value = 0;
chbx_left_fp2_Callback(h.chbx_left_fp2, [], h)

h = guidata(handles.figure1);
h.chbx_right_fp1.Value = 0;
chbx_right_fp1_Callback(h.chbx_right_fp1, [], h)

h = guidata(handles.figure1);
h.chbx_right_fp2.Value = 0;
chbx_right_fp2_Callback(h.chbx_right_fp2, [], h)


function edSubject_Callback(hObject, eventdata, handles)
% hObject    handle to edSubject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file_subj_str = regexpi(handles.edit_filename.String, '/s\d{4}.{0,4}/', 'match');
subj_str = strrep(file_subj_str{:},'/','');
handles.edit_filename.String = strrep(handles.edit_filename.String, subj_str, hObject.String);
edit_filename_Callback([], [], handles)

% --- Executes on selection change in popmenuTrialNum.
function popmenuTrialNum_Callback(hObject, eventdata, handles)
% hObject    handle to popmenuTrialNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
old_trial_str = regexpi(handles.edit_filename.String, '(?<tr_num>\d+)\.csv', 'names');
new_trial_str = hObject.String{hObject.Value};
handles.edit_filename.String = strrep(handles.edit_filename.String, [old_trial_str.tr_num '.csv'], ...
	[num2str(new_trial_str) '.csv']);
edit_filename_Callback([], [], handles)


% --- Executes on selection change in popmenuSession.
function popmenuSession_Callback(hObject, eventdata, handles)
% hObject    handle to popmenuSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
old_sess_str = regexpi(handles.edit_filename.String, '/((pre)|(mid)|(post)|(followup)|(followup2)|(fu)|(fu2))/', 'match');
new_sess_str = hObject.String{hObject.Value};
handles.edit_filename.String = strrep(handles.edit_filename.String, old_sess_str{1}, ['/' new_sess_str '/']);
edit_filename_Callback([], [], handles)


% --- Executes on button press in pb_load_data.
function pb_load_data_Callback(hObject, eventdata, handles)
% hObject    handle to pb_load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% request the data file
[fname, pathname] = uigetfile('*.csv', 'Pick vicon csv file');
if isequal(fname,0) || isequal(pathname,0)
	disp('User canceled. Exitting')
	return
end
filePathName = fullfile(pathname,fname);
handles.edit_filename.String = filePathName;
guidata(handles.figure1, handles);
edit_filename_Callback([], [], handles)


% --- Executes on button press in pbComputeFF.
function pbComputeFF_Callback(hObject, eventdata, handles)
% hObject    handle to pbComputeFF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = find_foot_flat_times(handles);
handles = foot_figure_show_ff_events(handles);
guidata(handles.figure1, handles);

% --- Executes on button press in pbComputeEvents.
function pbComputeEvents_Callback(hObject, eventdata, handles)
% hObject    handle to pbComputeEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = find_hs_to_events( handles );
handles = foot_figure_show_events(handles);
guidata(handles.figure1, handles);

% --- Executes on button press in chbx_left_fp1.
function chbx_left_fp1_Callback(hObject, eventdata, handles)
% hObject    handle to chbx_left_fp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles, 'figure_fp1')
	if hObject.Value==1
		handles = create_fp_figure(handles, 1, 'left');
	end
elseif ~isvalid(handles.figure_fp1)
	if hObject.Value==1
		handles = create_fp_figure(handles, 1, 'left');
	end
else
	delete(handles.figure_fp1)
	handles = rmfield(handles, 'figure_fp1');
end

guidata(handles.figure1, handles);


% --- Executes on button press in chbx_left_fp2.
function chbx_left_fp2_Callback(hObject, eventdata, handles)
% hObject    handle to chbx_left_fp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles, 'figure_fp2')
	if hObject.Value==1
		handles = create_fp_figure(handles, 2, 'left');
	end
elseif ~isvalid(handles.figure_fp2)
	if hObject.Value==1
		handles = create_fp_figure(handles, 2, 'left');
	end
else
	delete(handles.figure_fp2)
	handles = rmfield(handles, 'figure_fp2');
end

guidata(handles.figure1, handles);

% --- Executes on button press in chbx_right_fp1.
function chbx_right_fp1_Callback(hObject, eventdata, handles)
% hObject    handle to chbx_right_fp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles, 'figure_fp1')
	if hObject.Value==1
		handles = create_fp_figure(handles, 1, 'right');
	end
elseif ~isvalid(handles.figure_fp1)
	if hObject.Value==1
		handles = create_fp_figure(handles, 1, 'right');
	end
else
	delete(handles.figure_fp1)
	handles = rmfield(handles, 'figure_fp1');
end

guidata(handles.figure1, handles);


% --- Executes on button press in chbx_right_fp2.
function chbx_right_fp2_Callback(hObject, eventdata, handles)
% hObject    handle to chbx_right_fp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles, 'figure_fp2')
	if hObject.Value==1
		handles = create_fp_figure(handles, 2, 'right');
	end
elseif ~isvalid(handles.figure_fp2)
	if hObject.Value==1
		handles = create_fp_figure(handles, 2, 'right');
	end
else
	delete(handles.figure_fp2)
	handles = rmfield(handles, 'figure_fp2');
end

guidata(handles.figure1, handles);


% --- Executes on button press in pbJointAngles.
function pbJointAngles_Callback(hObject, eventdata, handles)
% hObject    handle to pbJointAngles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
side = handles.popmenu_inv_side.String{1};
handles = create_joint_angle_fig(handles, side);
if strcmp(side,'Right')
	side = 'Left';
else
	side = 'Right';
end
handles = create_joint_angle_fig(handles, side);
guidata(handles.figure1, handles)


% --- Executes on button press in pbExport.
function pbExport_Callback(hObject, eventdata, handles)
% hObject    handle to pbExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
export_data(handles)

% --- Executes during object creation, after setting all properties.
function edit_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ed_y_vel_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to ed_y_vel_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_y_vel_thresh as text
%        str2double(get(hObject,'String')) returns contents of ed_y_vel_thresh as a double


% --- Executes during object creation, after setting all properties.
function ed_y_vel_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_y_vel_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_y_vel_dur_Callback(hObject, eventdata, handles)
% hObject    handle to ed_y_vel_dur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_y_vel_dur as text
%        str2double(get(hObject,'String')) returns contents of ed_y_vel_dur as a double


% --- Executes during object creation, after setting all properties.
function ed_y_vel_dur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_y_vel_dur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_norm_yz_vel_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to ed_norm_yz_vel_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_norm_yz_vel_thresh as text
%        str2double(get(hObject,'String')) returns contents of ed_norm_yz_vel_thresh as a double


% --- Executes during object creation, after setting all properties.
function ed_norm_yz_vel_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_norm_yz_vel_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_heel_z_vel_hs_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to ed_heel_z_vel_hs_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_heel_z_vel_hs_thresh as text
%        str2double(get(hObject,'String')) returns contents of ed_heel_z_vel_hs_thresh as a double


% --- Executes during object creation, after setting all properties.
function ed_heel_z_vel_hs_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_heel_z_vel_hs_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_norm_yz_acc_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to ed_norm_yz_acc_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_norm_yz_acc_thresh as text
%        str2double(get(hObject,'String')) returns contents of ed_norm_yz_acc_thresh as a double


% --- Executes during object creation, after setting all properties.
function ed_norm_yz_acc_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_norm_yz_acc_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_toe_z_vel_hs_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to ed_toe_z_vel_hs_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_toe_z_vel_hs_thresh as text
%        str2double(get(hObject,'String')) returns contents of ed_toe_z_vel_hs_thresh as a double


% --- Executes during object creation, after setting all properties.
function ed_toe_z_vel_hs_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_toe_z_vel_hs_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popmenu_inv_side.
function popmenu_inv_side_Callback(hObject, eventdata, handles)
% hObject    handle to popmenu_inv_side (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popmenu_inv_side contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popmenu_inv_side


% --- Executes during object creation, after setting all properties.
function popmenu_inv_side_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popmenu_inv_side (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edSubject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edSubject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function popmenuSession_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popmenuSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function popmenuTrialNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popmenuTrialNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popmenuAssistDevice.
function popmenuAssistDevice_Callback(hObject, eventdata, handles)
% hObject    handle to popmenuAssistDevice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popmenuAssistDevice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popmenuAssistDevice


% --- Executes during object creation, after setting all properties.
function popmenuAssistDevice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popmenuAssistDevice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
