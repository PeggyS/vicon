function createLineCMenu(hLine, hText)
hcmenu = uicontextmenu;
% ud.hMenuDrag = uimenu(hcmenu, 'Label', 'Update Event Time', 'Tag', 'menuUpdateEvent', 'Callback', {@menuUpdateEvent_Callback, hLine});
ud.hMenuDrag = uimenu(hcmenu, 'Label', 'Draggable', 'Tag', 'menuDraggable', 'Callback', {@menuDraggable_Callback, hLine});
ud.hMenuShow = uimenu(hcmenu, 'Label', 'Show Data Value', 'Tag', 'menuShowData', 'Callback', {@menuShowData_Callback, hLine, hText});
ud.hMenuShow = uimenu(hcmenu, 'Label', 'Delete Event', 'Tag', 'menuDeleteEvent', 'Callback', {@menuDeleteEvent_Callback, hLine});
ud.hText = hText;		% also save the time text handle for quick access
set(hLine, 'UIContextMenu', hcmenu, 'UserData', ud);
