function menuUpdateEvent_Callback(hObject, eventdata, hLine)
% hObject    handle to menuDraggable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hLine    handle to the line owning this menu

% update the handles.event_struct and any other lines with this tag in figures other 
update_hs_to_events(hLine)

