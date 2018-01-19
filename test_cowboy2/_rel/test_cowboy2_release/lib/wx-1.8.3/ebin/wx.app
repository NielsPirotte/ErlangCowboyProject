%% This is an -*- erlang -*- file.
%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2010-2016. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%
%% %CopyrightEnd%

{application, wx,
 [{description, "Yet another graphics system"},
  {vsn, "1.8.3"},
  {modules,
   [
    %% Generated modules
  wxGLCanvas, wxAcceleratorEntry, wxStaticBoxSizer, wxUpdateUIEvent, wxIcon, wxColourPickerEvent, wxGraphicsMatrix, wxImage, wxGraphicsContext, wxPreviewFrame, wxFileDialog, wxFlexGridSizer, wxPrintDialogData, wxColourData, wxMouseCaptureChangedEvent, wxDCOverlay, wxClipboardTextEvent, wxChoicebook, wxSystemOptions, wxGridCellFloatRenderer, wxWindowDC, wxStatusBar, wxInitDialogEvent, wxEvent, wxTaskBarIconEvent, wxGraphicsObject, wxPrintout, wxSysColourChangedEvent, wxGridCellRenderer, wxListCtrl, wxLocale, wxPreviewControlBar, wxBitmap, wxGridCellAttr, wxQueryNewPaletteEvent, wxSizerItem, wxPasswordEntryDialog, wxFrame, wxNavigationKeyEvent, wxGraphicsRenderer, wxGridCellBoolRenderer, wxMouseCaptureLostEvent, wxTextEntryDialog, wxIdleEvent, wxStyledTextCtrl, wxChoice, wxListItem, wxSpinCtrl, wxMDIClientWindow, wxMDIChildFrame, wxStdDialogButtonSizer, wxPrintPreview, wxPrintData, wxDirPickerCtrl, wxKeyEvent, wxEraseEvent, wxFontDialog, wxRadioBox, wxCalendarDateAttr, wxGridCellEditor, wxPalette, wxTreebook, wxSizeEvent, wxLogNull, wxPageSetupDialog, wxDirDialog, wxPreviewCanvas, wxTextAttr, wxScrollWinEvent, wxCalendarCtrl, wxJoystickEvent, wxAuiDockArt, wxWindowDestroyEvent, wxSetCursorEvent, wxMirrorDC, wxControl, wxToggleButton, wxTopLevelWindow, wxGraphicsFont, wxStaticText, wxIconizeEvent, wxPrinter, wxStaticBitmap, wxGridBagSizer, wxListbook, wxGridSizer, wxScrollEvent, wx_misc, wxWindowCreateEvent, wxSashLayoutWindow, wxGridCellFloatEditor, wxStyledTextEvent, wxMoveEvent, wxPrintDialog, wxStaticBox, wxBufferedDC, wxRadioButton, wxClientDC, wxMaximizeEvent, wxDateEvent, wxTextCtrl, wxCalendarEvent, wxGauge, wxGridCellTextEditor, wxSizerFlags, wxDataObject, wxShowEvent, wxBitmapDataObject, wxFindReplaceDialog, wxTextDataObject, wxStaticLine, wxMiniFrame, wxListEvent, wxDialog, wxPaintDC, wxTreeCtrl, wxScreenDC, wxBitmapButton, wxPopupWindow, wxChildFocusEvent, wxFilePickerCtrl, wxPostScriptDC, wxGrid, wxAuiSimpleTabArt, wxSashEvent, wxScrolledWindow, wxMask, wxFontData, wxScrollBar, wxMenuEvent, wxCheckBox, wxHtmlWindow, wxIconBundle, wxListItemAttr, wxAuiManager, wxBoxSizer, wxClipboard, wxMouseEvent, wxMenu, wxAuiPaneInfo, wxPaintEvent, wxSplitterWindow, wxProgressDialog, wxGridCellNumberEditor, wxListBox, wxActivateEvent, wxNotebookEvent, wxFileDirPickerEvent, wxMenuItem, wxCursor, wxMessageDialog, wxButton, wxMenuBar, wxDisplayChangedEvent, wxToolBar, wxGraphicsPen, wxGridCellNumberRenderer, wxPaletteChangedEvent, wxArtProvider, wxHtmlEasyPrinting, wxBufferedPaintDC, wxFindReplaceData, wxListView, wxSplitterEvent, wxEvtHandler, wxGridEvent, wxColourPickerCtrl, wxContextMenuEvent, wxCheckListBox, wxGridCellBoolEditor, wxMultiChoiceDialog, wxOverlay, wxDropFilesEvent, wxColourDialog, wxCommandEvent, wxSashWindow, wxDatePickerCtrl, wxFocusEvent, wxXmlResource, wxGridCellChoiceEditor, wxImageList, wxAuiNotebook, wxNotifyEvent, wxToolTip, wxSlider, wxPanel, wxSizer, wxGraphicsPath, wxGBSizerItem, wxPen, wxBrush, wxAuiNotebookEvent, wxPageSetupDialogData, wxLayoutAlgorithm, wxSplashScreen, wxComboBox, wxGridCellStringRenderer, wxTaskBarIcon, wxPopupTransientWindow, wxFileDataObject, wxFontPickerCtrl, wxPickerBase, wxCloseEvent, wxNotebook, wxDC, wxMemoryDC, wxCaret, wxAcceleratorTable, wxGraphicsBrush, wxMDIParentFrame, wxHelpEvent, wxGenericDirCtrl, wxToolbook, wxFont, wxControlWithItems, wxSystemSettings, wxWindow, wxHtmlLinkEvent, wxTreeEvent, wxSpinEvent, wxSingleChoiceDialog, wxFontPickerEvent, wxAuiTabArt, wxRegion, wxSpinButton, wxAuiManagerEvent, glu, gl,
    %% Handcrafted modules
    wx,
    wx_object,
    wxe_master,
    wxe_server,
    wxe_util
   ]},
  {registered, []},
  {applications, [stdlib, kernel]},
  {env, []},
  {runtime_dependencies, ["stdlib-2.0","kernel-3.0","erts-6.0"]}
 ]}.
