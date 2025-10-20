function utilities = getUtilities(fig, bangDAQ)

%This function will generate a panel for the user to end the program.

%Set a panel into the original gui.
utilities = uipanel(fig);

%Set up the location of the panel into the original gui.
left = 40;  %The left edge of the panel.
bottom = 3; %The bottom edge of the panel.
width = 1200;  %The width of the panel.
height = 60;   %The height of the panel.
utilities.Position = [left, bottom, width, height];

%Do the panel layout and set the height and width of the rows and columns.
handles.utilitiesGridLayout = uigridlayout(utilities, [1 3]);
handles.utilitiesGridLayout.RowHeight = {40};
handles.utilitiesGridLayout.ColumnWidth = {width - 30};

%Place the close window button into the gui.
label = 'Close Window';
row = 1;
column = [1 2];
handles.quitButton = getQuitButton(handles, label, row, column);

end  %End of the function getUtilities.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function quitButton = getQuitButton(handles, Text, row, column)
%This function will get the handle for the quit button.

quitButton = uibutton(handles.utilitiesGridLayout);
quitButton.Text = Text;
quitButton.FontWeight = 'bold';
quitButton.FontSize = 24;
quitButton.FontColor = [0 0 0];
quitButton.Layout.Row = row;
quitButton.Layout.Column = column;
quitButton.BackgroundColor = [1 1 1];
quitButton.ButtonPushedFcn = {@quitButtonFlag};
end
%End of the function quitButton.m

function quitButtonFlag(arc, event)
%This function closes the program.

%If the user clicks the close window button then close the window.
closereq();
end
%End of the function quitButtonFlag.m


