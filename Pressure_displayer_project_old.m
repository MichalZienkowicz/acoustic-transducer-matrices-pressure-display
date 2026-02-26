classdef Pressure_displayer_project < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        LeftPanel                       matlab.ui.container.Panel
        ExportpressureDataButton        matlab.ui.control.Button
        setparametersofmodeltodesiredvaluesLabel  matlab.ui.control.Label
        generatinganddisplayingaccousticpressureandphasesLabel  matlab.ui.control.Label
        enabledisplayofcomponentsyouwishtoseeontheschemeLabel  matlab.ui.control.Label
        displayspeakerdistributionCheckBox  matlab.ui.control.CheckBox
        displayfocuspointCheckBox       matlab.ui.control.CheckBox
        GenerateDataButton              matlab.ui.control.Button
        DisplayDataButton               matlab.ui.control.Button
        TextArea                        matlab.ui.control.TextArea
        DatastatusLabel                 matlab.ui.control.Label
        YLabel                          matlab.ui.control.Label
        XLabel                          matlab.ui.control.Label
        speakersspreadYEditField        matlab.ui.control.NumericEditField
        numberofspeakersYEditField      matlab.ui.control.NumericEditField
        RestoredefaultsettingsButton    matlab.ui.control.Button
        additionalvisibilitybordermEditField  matlab.ui.control.NumericEditField
        additionalvisibilityborderLabel  matlab.ui.control.Label
        ResolutionnumberofpointsgeneratedLabel  matlab.ui.control.Label
        ZaxisSlider                     matlab.ui.control.Slider
        ZaxisSliderLabel                matlab.ui.control.Label
        YaxisSlider                     matlab.ui.control.Slider
        YaxisSliderLabel                matlab.ui.control.Label
        XaxisSlider                     matlab.ui.control.Slider
        XaxisSliderLabel                matlab.ui.control.Label
        ZEditField                      matlab.ui.control.NumericEditField
        ZEditFieldLabel                 matlab.ui.control.Label
        YEditField                      matlab.ui.control.NumericEditField
        YEditFieldLabel                 matlab.ui.control.Label
        XEditField                      matlab.ui.control.NumericEditField
        XEditFieldLabel                 matlab.ui.control.Label
        FocuspointcoordinatesDropDown   matlab.ui.control.DropDown
        FocuspointcoordinatesDropDownLabel  matlab.ui.control.Label
        Label                           matlab.ui.control.Label
        topbottomdistmEditField         matlab.ui.control.NumericEditField
        topbottomdistancemLabel         matlab.ui.control.Label
        signalamplitudeEditField        matlab.ui.control.NumericEditField
        signalamplitudeEditFieldLabel   matlab.ui.control.Label
        signalfrequencyHzEditField      matlab.ui.control.NumericEditField
        signalfrequencyHzLabel          matlab.ui.control.Label
        speakersspreadXEditField        matlab.ui.control.NumericEditField
        speakersspreadmLabel            matlab.ui.control.Label
        speakerradiusmEditField         matlab.ui.control.NumericEditField
        speakerradiusmLabel             matlab.ui.control.Label
        numberofspeakersXEditField      matlab.ui.control.NumericEditField
        numberofspeakersEditFieldLabel  matlab.ui.control.Label
        UIAxes_3                        matlab.ui.control.UIAxes
        RightPanel                      matlab.ui.container.Panel
        GridLayout2                     matlab.ui.container.GridLayout
        dimentionalaccousticpressuredisplaypresentingLabel  matlab.ui.control.Label
        Label_2                         matlab.ui.control.Label
        AccousticpressureLabel          matlab.ui.control.Label
        UIAxes_9                        matlab.ui.control.UIAxes
        UIAxes                          matlab.ui.control.UIAxes
        UIAxes_10                       matlab.ui.control.UIAxes
        UIAxes_5                        matlab.ui.control.UIAxes
        UIAxes_2                        matlab.ui.control.UIAxes
        UIAxes_7                        matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = private)
        speakerCoordinatesX 
        speakerCoordinatesY % vectors with location of speakers centers
        focusPointX
        focusPointY
        focusPointZ % coordinates of point of focus of speakers waves
        PressureValueVectorX
        PressureVauelVectorY
        PressureValueVectorZ % vectors creating grid, sizes appropriate for val array
        phaseArrayBottom % phases of top speakers
        phaseArrayTop % phases of bottom speakers
        ValArray % array of pressure data ready to be plotted
        substituteFocPointX 
        substituteFocPointY % used for displaying plots, to visualise data 
                            % despite unfound calculating error, which 
                            % repleces X and Y at some point
        dataReady % boolean used to properly handle displaying data

    end

    
    
    methods (Access = private)
        
        function CirclesPlot3D(app)
            r = app.speakerradiusmEditField.Value;
            fi = 0:2*pi/10:2*pi;
            nX = app.numberofspeakersXEditField.Value;
            yUnit = r*sin(fi)+app.speakerCoordinatesY(:);
            zUnitBottom(1:length(fi)) = 0;
            zUnitTop(1:length(fi)) = app.topbottomdistmEditField.Value;
            
            for ix = 1:nX
                xUnit = r*cos(fi)+app.speakerCoordinatesX(ix);
                plot3(app.UIAxes_3, xUnit,yUnit,zUnitBottom,"Color",'r',LineWidth=0.7);
                plot3(app.UIAxes_3, xUnit,yUnit,zUnitTop,"Color",'r',LineWidth=0.7);
            end

        end
        
        function CountSpeakerCoordinates(app)
            r = app.speakerradiusmEditField.Value;
            spreadX = app.speakersspreadXEditField.Value;
            spreadY = app.speakersspreadYEditField.Value;
            nX = app.numberofspeakersXEditField.Value;
            nY = app.numberofspeakersYEditField.Value;

            app.speakerCoordinatesX = (0:(2*r+spreadX):(nX-1)*(2*r+spreadX));
            app.speakerCoordinatesY = (0:(2*r+spreadY):(nY-1)*(2*r+spreadY));
            
        end
        
        function [xVec,yVec,zVec] = MakeMeshgridBase(app)
            r = app.speakerradiusmEditField.Value;
            Xmin = app.speakerCoordinatesX(1);
            Xmax = app.speakerCoordinatesX(end);
            Xstep = app.XaxisSlider.Value;
            Ymin = app.speakerCoordinatesY(1);
            Ymax = app.speakerCoordinatesY(end);
            Ystep = app.YaxisSlider.Value;
            height = app.topbottomdistmEditField.Value;
            Zstep = app.ZaxisSlider.Value;
            border = app.additionalvisibilitybordermEditField.Value;
            
            xVec = linspace(Xmin-border-r,Xmax+border+r,Xstep);
            yVec = linspace(Ymin-border-r,Ymax+border+r,Ystep);
            zVec = linspace(0,height,Zstep);
            
        end
        
        function TryUpdateSpeakerDistrib(app)
            cla(app.UIAxes_3,"reset");
            hold(app.UIAxes_3,"on");
            if(app.displayspeakerdistributionCheckBox.Value == true || app.displayfocuspointCheckBox.Value == true)
                app.CountSpeakerCoordinates;
            end
            if(app.displayspeakerdistributionCheckBox.Value == true)
                app.CirclesPlot3D;
            end
            if(app.displayfocuspointCheckBox.Value == true)
                [app.focusPointX,app.focusPointY,app.focusPointZ] = app.CountFocusPointCoordinates;
                app.FocPointPlot3D;
            end
            hold(app.UIAxes_3,"off");
            axis(app.UIAxes_3,"equal");
            grid(app.UIAxes_3,"on");
            title(app.UIAxes_3,"Model scheme","FontSize",11);
            xlabel(app.UIAxes_3,"X");
            ylabel(app.UIAxes_3,"Y");
            zlabel(app.UIAxes_3,"Z");
            view(app.UIAxes_3,120,30);
              
        end
        
        function [xFoc,yFoc,zFoc] = CountFocusPointCoordinates(app)
            if(app.FocuspointcoordinatesDropDown.Value == "m")
                xFoc = app.XEditField.Value;
                yFoc = app.YEditField.Value;
                zFoc = app.ZEditField.Value;
            elseif(app.FocuspointcoordinatesDropDown.Value == "%")
                xFoc = (app.speakerCoordinatesX(end))*app.XEditField.Value/100;
                yFoc = (app.speakerCoordinatesY(end))*app.YEditField.Value/100;
                zFoc = app.topbottomdistmEditField.Value*app.ZEditField.Value/100;
            end
            
        end
                
        function UpdateFocusPointEditFields(app)
            previousX = app.XEditField.Value;
            previousY = app.YEditField.Value;
            previousZ = app.ZEditField.Value;

            if (app.FocuspointcoordinatesDropDown.Value == "%")
                app.XEditField.Value = previousX/app.speakerCoordinatesX(end)*100;
                app.YEditField.Value = previousY/app.speakerCoordinatesY(end)*100;
                app.ZEditField.Value = previousZ/app.topbottomdistmEditField.Value*100;
            elseif(app.FocuspointcoordinatesDropDown.Value == "m")
                app.XEditField.Value = app.speakerCoordinatesX(end)*previousX/100;
                app.YEditField.Value = app.speakerCoordinatesY(end)*previousY/100;
                app.ZEditField.Value = app.topbottomdistmEditField.Value*previousZ/100;
            end
            
        end
        
        function FocPointPlot3D(app)
            plot3(app.UIAxes_3,app.focusPointX,app.focusPointY,app.focusPointZ,"o","MarkerSize",5,"Color",'b');
            r = app.speakerradiusmEditField.Value;
            xUnit1(1:2) = app.focusPointX;
            yUnit1(1:2) = app.focusPointY;
            zUnit1(1:2) = app.focusPointZ;
            xUnit2 = linspace(-r,app.focusPointX,2);
            yUnit2 = linspace(-r,app.focusPointY,2);
            zUnit2 = linspace(0,app.focusPointZ,2);
            plot3(app.UIAxes_3,xUnit2,yUnit1,zUnit1,xUnit1,yUnit2,zUnit1,xUnit1,yUnit1,zUnit2,"Color",'b',"LineWidth",0.5)
        end
        
        
        function phiArray = CountPhaseArray(app,height)
            f = app.signalfrequencyHzEditField.Value;
            omega = 2*pi*f;
            c = 343;
            phi = zeros(length(app.speakerCoordinatesX), length(app.speakerCoordinatesY));
            for ix = 1:length(app.speakerCoordinatesX)
                for iy = 1:length(app.speakerCoordinatesY)
                    focusR = sqrt((app.speakerCoordinatesX(ix)-app.focusPointX)^2+ ...
                                  (app.speakerCoordinatesY(iy)-app.focusPointY)^2+ ...
                                  (height - app.focusPointZ)^2);
                    phi(ix,iy) = omega*rem(focusR,(f/c))/c;
                end
            end
            phiArray = phi;
        end
        
        function CountPressureLevelData(app,phi0bottom,phi0top)
            f = app.signalfrequencyHzEditField.Value;
            A = app.signalamplitudeEditField.Value;
            omega = 2*pi*f;
            c = 343;
            X = app.speakerCoordinatesX;
            Y = app.speakerCoordinatesY;
            Zbottom = 0;
            Ztop = app.topbottomdistmEditField.Value;
            
            for ixV = 1:length(app.PressureValueVectorX)
                for iyV = 1:length(app.PressureVauelVectorY)
                    for izV = 1:length(app.PressureValueVectorZ)
                        p=0;
                        for ix=1:length(X)
                            for iy=1:length(Y)            
                                rBottom = sqrt((app.PressureValueVectorX(ixV)-X(ix))^2 + (app.PressureVauelVectorY(iyV)-Y(iy))^2 + (app.PressureValueVectorZ(izV)-Zbottom)^2);
                                rTop = sqrt((app.PressureValueVectorX(ixV)-X(ix))^2 + (app.PressureVauelVectorY(iyV)-Y(iy))^2 + (app.PressureValueVectorZ(izV)-Ztop)^2);
                                p = p+A/rBottom*cos(omega*rBottom/c - app.phaseArrayBottom(ix,iy) + phi0bottom) + A/rTop*cos(omega*rTop/c - app.phaseArrayTop(ix,iy) + phi0top);
                            end
                        end
                        app.ValArray(ixV,iyV,izV) = p;
                    end
                end
            end
            
        end
        
        
        function PhiArrayPlot2D(app,phiArrayBottom, phiArrayTop)
            zUnit = rem(rad2deg(phiArrayBottom(:,:)),360);
            cla(app.UIAxes,"reset");
            hold(app.UIAxes,"on")
            cd = colormap(app.UIAxes,'parula'); 

            for ix = 1:size(zUnit,1)
                for iy = 1:size(zUnit,2)
                    rectangle(app.UIAxes,"Position",[ix-1 iy-1 1 1],"FaceColor",cd(ceil(zUnit(ix,iy)/360*size(cd,1)),:));
                end
            end
            hold(app.UIAxes,"off")
            colorbar(app.UIAxes,'eastoutside');
            xlabel(app.UIAxes,"X");
            ylabel(app.UIAxes,"Y");
            title(app.UIAxes,"Phases of top array","FontSize",11,'fontweight','bold')
            clim(app.UIAxes,[0,360]);
                        
            zUnit = rem(rad2deg(phiArrayTop(:,:)),360);
            cla(app.UIAxes_9,"reset");
            hold(app.UIAxes_9,"on")
            cd = colormap(app.UIAxes_9,'parula'); 

            for ix = 1:size(zUnit,1)
                for iy = 1:size(zUnit,2)
                    rectangle(app.UIAxes_9,"Position",[ix-1 iy-1 1 1],"FaceColor",cd(ceil(zUnit(ix,iy)/360*size(cd,1)),:));
                end
            end
            hold(app.UIAxes_9,"off")
            colorbar(app.UIAxes_9,'eastoutside');
            xlabel(app.UIAxes_9,"X");
            ylabel(app.UIAxes_9,"Y");
            title(app.UIAxes_9,"Phases of bottom array","FontSize",11,'fontweight','bold')
            clim(app.UIAxes_9,[0,360]);
            
        end       

        % functions below may require adjusting X and Y values, to display
        % data properly, and not mirrored and/or displaying X data as Y
        % data, and Y data as X data.

        % functionality of changing resolution, also requires adjusting.
        % Error may occur, of which reason is probably either 
        % MakeMeshgridBase method, or CountPressureLevelData method, 
        % missinteracting with Plot functions below.
        function PlotPressureSlices3D(app)
            cla(app.UIAxes_6,"reset");
            graph = slice(app.UIAxes_6,app.PressureValueVectorX,app.PressureVauelVectorY,app.PressureValueVectorZ, ...
                          app.ValArray,app.substituteFocPointX, app.substituteFocPointY, app.focusPointZ);
            set(graph,'EdgeColor','none',...
                       'FaceColor','interp',...
                       'FaceAlpha','interp')
            alpha(app.UIAxes_6,"color");
            title(app.UIAxes_6,"accoustic pressure slices","FontSize",11,'fontweight','bold');
            xlabel(app.UIAxes_6,"X");
            ylabel(app.UIAxes_6,"Y");
            zlabel(app.UIAxes_6,"Z");
            view(app.UIAxes_6,120,30);          
                        
        end
        
        function PlotSlice2d(app)
            cla(app.UIAxes_2,"reset");
            graphX = slice(app.UIAxes_2,app.PressureValueVectorX,app.PressureVauelVectorY,app.PressureValueVectorZ, ...
                          app.ValArray,app.substituteFocPointX,app.substituteFocPointY,app.focusPointZ);

            set(graphX,'EdgeColor','none',...
                       'FaceColor','interp',...
                       'FaceAlpha','interp')
            grid(app.UIAxes_2,"off")
            alpha(app.UIAxes_2,"color");
            title(app.UIAxes_2,"Acoustic pressure - X values","FontSize",11,'fontweight','bold');
            ylabel(app.UIAxes_2,"Y");
            zlabel(app.UIAxes_2,"Z");
            view(app.UIAxes_2,90,0);
                        
            cla(app.UIAxes_7,"reset");
            graphX = slice(app.UIAxes_7,app.PressureValueVectorX,app.PressureVauelVectorY,app.PressureValueVectorZ, ...
                          app.ValArray,app.substituteFocPointX,app.substituteFocPointY,app.focusPointZ);

            set(graphX,'EdgeColor','none',...
                       'FaceColor','interp',...
                       'FaceAlpha','interp')
            grid(app.UIAxes_7,"off")
            alpha(app.UIAxes_7,"color");
            title(app.UIAxes_7,"Acoustic pressure - Z values","FontSize",11,'fontweight','bold');
            xlabel(app.UIAxes_7,"X");
            ylabel(app.UIAxes_7,"Y");
            view(app.UIAxes_7,0,90);
            colorbar(app.UIAxes_7,'eastoutside')

            cla(app.UIAxes_10,"reset");
            graphX = slice(app.UIAxes_10,app.PressureValueVectorX,app.PressureVauelVectorY,app.PressureValueVectorZ, ...
                          app.ValArray,app.substituteFocPointX,app.substituteFocPointY,app.focusPointZ);

            set(graphX,'EdgeColor','none',...
                       'FaceColor','interp',...
                       'FaceAlpha','interp')
            grid(app.UIAxes_10,"off")
            alpha(app.UIAxes_10,"color");
            title(app.UIAxes_10,"Acoustic pressure - Y values","FontSize",11,'fontweight','bold');
            xlabel(app.UIAxes_10,"X");
            zlabel(app.UIAxes_10,"Z");
            view(app.UIAxes_10,0,0);
        end
        
        function PlotPressure3D(app)
            cla(app.UIAxes_5,"reset");
            data = smooth3(app.ValArray);
            patch(app.UIAxes_5,isocaps(data,.5),...
                'FaceColor','interp','EdgeColor','none');
            p1 = patch(app.UIAxes_5,isosurface(data,.5),...
                'FaceColor','blue','EdgeColor','none');
            isonormals(data,p1);
            view(app.UIAxes_5,3); 
            axis(app.UIAxes_5,'vis3d', 'tight') ;
            camlight(app.UIAxes_5,'left') ;
            lighting(app.UIAxes_5, 'gouraud');
            alpha(app.UIAxes_5,'color');
            alpha(app.UIAxes_5,'scaled');
            title(app.UIAxes_5,"Acoustic pressure 3D","FontSize",11,'fontweight','bold');
            xlabel(app.UIAxes_5,"X");
            ylabel(app.UIAxes_5,"Y");
            zlabel(app.UIAxes_5,"Z");
     
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: numberofspeakersXEditField
        function numberofspeakersXEditFieldValueChanged(app, event)
            app.TryUpdateSpeakerDistrib;
        end

        % Value changed function: numberofspeakersYEditField
        function numberofspeakersYEditFieldValueChanged(app, event)
            app.TryUpdateSpeakerDistrib;
        end

        % Value changed function: speakerradiusmEditField
        function speakerradiusmEditFieldValueChanged(app, event)
            app.TryUpdateSpeakerDistrib;
        end

        % Value changed function: topbottomdistmEditField
        function topbottomdistmEditFieldValueChanged(app, event)
            app.TryUpdateSpeakerDistrib;  
        end

        % Value changed function: speakersspreadXEditField
        function speakersspreadXEditFieldValueChanged(app, event)
            app.TryUpdateSpeakerDistrib;       
        end

        % Value changed function: speakersspreadYEditField
        function speakersspreadYEditFieldValueChanged(app, event)
            app.TryUpdateSpeakerDistrib;       
        end

        % Value changed function: displayspeakerdistributionCheckBox
        function displayspeakerdistributionCheckBoxValueChanged(app, event)
            app.TryUpdateSpeakerDistrib;        
        end

        % Value changed function: XEditField
        function XEditFieldValueChanged(app, event)
            app.TryUpdateSpeakerDistrib;  
        end

        % Value changed function: YEditField
        function YEditFieldValueChanged(app, event)
            app.TryUpdateSpeakerDistrib;
        end

        % Value changed function: ZEditField
        function ZEditFieldValueChanged(app, event)
            app.TryUpdateSpeakerDistrib;     
        end

        % Value changed function: displayfocuspointCheckBox
        function displayfocuspointCheckBoxValueChanged(app, event)
            app.TryUpdateSpeakerDistrib; 
        end

        % Value changed function: FocuspointcoordinatesDropDown
        function FocuspointcoordinatesDropDownValueChanged(app, event)
            app.CountSpeakerCoordinates;
            app.UpdateFocusPointEditFields;
            [app.focusPointX,app.focusPointY,app.focusPointZ] = app.CountFocusPointCoordinates;
        end

        % Button pushed function: GenerateDataButton
        function GenerateDataButtonPushed(app, event)
            app.TextArea.Value = "Generating data...";
            app.CountSpeakerCoordinates;
            [app.focusPointX,app.focusPointY,app.focusPointZ] = app.CountFocusPointCoordinates;
            app.phaseArrayBottom = app.CountPhaseArray(0);
            app.phaseArrayTop = app.CountPhaseArray(app.topbottomdistmEditField.Value);
            [app.PressureValueVectorX,app.PressureVauelVectorY,app.PressureValueVectorZ] = app.MakeMeshgridBase;
            app.CountPressureLevelData(0,0);
            app.substituteFocPointY = app.focusPointX/app.speakerCoordinatesX(end)*app.speakerCoordinatesY(end);
            app.substituteFocPointX = app.focusPointY/app.speakerCoordinatesY(end)*app.speakerCoordinatesX(end);
            app.dataReady = true;
            app.TextArea.Value = "Data generated successfully.";
        end

        % Button pushed function: DisplayDataButton
        function DisplayDataButtonPushed(app, event)
            if(app.dataReady)
                app.TextArea.Value = "Displaying data";
                app.PhiArrayPlot2D(app.phaseArrayBottom,app.phaseArrayTop); 
                %app.PlotPressureSlices3D;
                app.PlotSlice2d;
                app.PlotPressure3D;
                app.TextArea.Value = "Data displayed successfully";
            else
                app.TextArea.Value = "There is nothing to display. Generate data first, in order to display it";
            end
        end

        % Value changed function: XaxisSlider
        function XaxisSliderValueChanged(app, event)
            app.YaxisSlider.Value = app.XaxisSlider.Value;           
        end

        % Value changed function: YaxisSlider
        function YaxisSliderValueChanged(app, event)
            app.XaxisSlider.Value= app.YaxisSlider.Value;            
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {667, 667};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {515, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 1357 667];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {515, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.LeftPanel);
            title(app.UIAxes_3, 'Model scheme')
            xlabel(app.UIAxes_3, 'X')
            ylabel(app.UIAxes_3, 'Y')
            zlabel(app.UIAxes_3, 'Z')
            app.UIAxes_3.FontSize = 9;
            app.UIAxes_3.Position = [295 452 183 185];

            % Create numberofspeakersEditFieldLabel
            app.numberofspeakersEditFieldLabel = uilabel(app.LeftPanel);
            app.numberofspeakersEditFieldLabel.HorizontalAlignment = 'right';
            app.numberofspeakersEditFieldLabel.Position = [27 538 111 22];
            app.numberofspeakersEditFieldLabel.Text = 'number of speakers';

            % Create numberofspeakersXEditField
            app.numberofspeakersXEditField = uieditfield(app.LeftPanel, 'numeric');
            app.numberofspeakersXEditField.Limits = [1 100];
            app.numberofspeakersXEditField.RoundFractionalValues = 'on';
            app.numberofspeakersXEditField.ValueDisplayFormat = '%.0f';
            app.numberofspeakersXEditField.ValueChangedFcn = createCallbackFcn(app, @numberofspeakersXEditFieldValueChanged, true);
            app.numberofspeakersXEditField.Position = [153 538 52 22];
            app.numberofspeakersXEditField.Value = 10;

            % Create speakerradiusmLabel
            app.speakerradiusmLabel = uilabel(app.LeftPanel);
            app.speakerradiusmLabel.HorizontalAlignment = 'right';
            app.speakerradiusmLabel.Position = [40 496 100 22];
            app.speakerradiusmLabel.Text = 'speaker radius, m';

            % Create speakerradiusmEditField
            app.speakerradiusmEditField = uieditfield(app.LeftPanel, 'numeric');
            app.speakerradiusmEditField.ValueChangedFcn = createCallbackFcn(app, @speakerradiusmEditFieldValueChanged, true);
            app.speakerradiusmEditField.Position = [153 496 100 22];
            app.speakerradiusmEditField.Value = 0.005;

            % Create speakersspreadmLabel
            app.speakersspreadmLabel = uilabel(app.LeftPanel);
            app.speakersspreadmLabel.HorizontalAlignment = 'right';
            app.speakersspreadmLabel.Position = [27 517 111 22];
            app.speakersspreadmLabel.Text = 'speakers spread, m';

            % Create speakersspreadXEditField
            app.speakersspreadXEditField = uieditfield(app.LeftPanel, 'numeric');
            app.speakersspreadXEditField.Limits = [0 Inf];
            app.speakersspreadXEditField.ValueChangedFcn = createCallbackFcn(app, @speakersspreadXEditFieldValueChanged, true);
            app.speakersspreadXEditField.Position = [153 517 52 22];
            app.speakersspreadXEditField.Value = 0.002;

            % Create signalfrequencyHzLabel
            app.signalfrequencyHzLabel = uilabel(app.LeftPanel);
            app.signalfrequencyHzLabel.HorizontalAlignment = 'right';
            app.signalfrequencyHzLabel.Position = [25 388 113 22];
            app.signalfrequencyHzLabel.Text = 'signal frequency, Hz';

            % Create signalfrequencyHzEditField
            app.signalfrequencyHzEditField = uieditfield(app.LeftPanel, 'numeric');
            app.signalfrequencyHzEditField.Limits = [1 Inf];
            app.signalfrequencyHzEditField.ValueDisplayFormat = '%.0f';
            app.signalfrequencyHzEditField.Position = [153 388 100 22];
            app.signalfrequencyHzEditField.Value = 40000;

            % Create signalamplitudeEditFieldLabel
            app.signalamplitudeEditFieldLabel = uilabel(app.LeftPanel);
            app.signalamplitudeEditFieldLabel.HorizontalAlignment = 'right';
            app.signalamplitudeEditFieldLabel.Position = [47 367 91 22];
            app.signalamplitudeEditFieldLabel.Text = 'signal amplitude';

            % Create signalamplitudeEditField
            app.signalamplitudeEditField = uieditfield(app.LeftPanel, 'numeric');
            app.signalamplitudeEditField.Limits = [0 Inf];
            app.signalamplitudeEditField.Position = [153 367 100 22];
            app.signalamplitudeEditField.Value = 0.02;

            % Create topbottomdistancemLabel
            app.topbottomdistancemLabel = uilabel(app.LeftPanel);
            app.topbottomdistancemLabel.HorizontalAlignment = 'right';
            app.topbottomdistancemLabel.Position = [34 475 104 22];
            app.topbottomdistancemLabel.Text = 'top-bottom dist., m';

            % Create topbottomdistmEditField
            app.topbottomdistmEditField = uieditfield(app.LeftPanel, 'numeric');
            app.topbottomdistmEditField.Limits = [0.001 Inf];
            app.topbottomdistmEditField.ValueChangedFcn = createCallbackFcn(app, @topbottomdistmEditFieldValueChanged, true);
            app.topbottomdistmEditField.Position = [153 475 100 22];
            app.topbottomdistmEditField.Value = 0.24;

            % Create Label
            app.Label = uilabel(app.LeftPanel);
            app.Label.Position = [59 306 25 22];
            app.Label.Text = '';

            % Create FocuspointcoordinatesDropDownLabel
            app.FocuspointcoordinatesDropDownLabel = uilabel(app.LeftPanel);
            app.FocuspointcoordinatesDropDownLabel.HorizontalAlignment = 'right';
            app.FocuspointcoordinatesDropDownLabel.Position = [39 306 135 22];
            app.FocuspointcoordinatesDropDownLabel.Text = 'Focus point coordinates:';

            % Create FocuspointcoordinatesDropDown
            app.FocuspointcoordinatesDropDown = uidropdown(app.LeftPanel);
            app.FocuspointcoordinatesDropDown.Items = {'%', 'm'};
            app.FocuspointcoordinatesDropDown.ValueChangedFcn = createCallbackFcn(app, @FocuspointcoordinatesDropDownValueChanged, true);
            app.FocuspointcoordinatesDropDown.Position = [189 306 63 22];
            app.FocuspointcoordinatesDropDown.Value = '%';

            % Create XEditFieldLabel
            app.XEditFieldLabel = uilabel(app.LeftPanel);
            app.XEditFieldLabel.HorizontalAlignment = 'center';
            app.XEditFieldLabel.Position = [46 285 50 22];
            app.XEditFieldLabel.Text = 'X';

            % Create XEditField
            app.XEditField = uieditfield(app.LeftPanel, 'numeric');
            app.XEditField.ValueChangedFcn = createCallbackFcn(app, @XEditFieldValueChanged, true);
            app.XEditField.Position = [46 264 52 22];
            app.XEditField.Value = 50;

            % Create YEditFieldLabel
            app.YEditFieldLabel = uilabel(app.LeftPanel);
            app.YEditFieldLabel.HorizontalAlignment = 'center';
            app.YEditFieldLabel.Position = [108 285 50 22];
            app.YEditFieldLabel.Text = 'Y';

            % Create YEditField
            app.YEditField = uieditfield(app.LeftPanel, 'numeric');
            app.YEditField.ValueChangedFcn = createCallbackFcn(app, @YEditFieldValueChanged, true);
            app.YEditField.Position = [108 264 52 22];
            app.YEditField.Value = 50;

            % Create ZEditFieldLabel
            app.ZEditFieldLabel = uilabel(app.LeftPanel);
            app.ZEditFieldLabel.HorizontalAlignment = 'center';
            app.ZEditFieldLabel.Position = [173 285 50 22];
            app.ZEditFieldLabel.Text = 'Z';

            % Create ZEditField
            app.ZEditField = uieditfield(app.LeftPanel, 'numeric');
            app.ZEditField.ValueChangedFcn = createCallbackFcn(app, @ZEditFieldValueChanged, true);
            app.ZEditField.Position = [173 264 52 22];
            app.ZEditField.Value = 50;

            % Create XaxisSliderLabel
            app.XaxisSliderLabel = uilabel(app.LeftPanel);
            app.XaxisSliderLabel.HorizontalAlignment = 'right';
            app.XaxisSliderLabel.Position = [39 191 38 22];
            app.XaxisSliderLabel.Text = 'X axis';

            % Create XaxisSlider
            app.XaxisSlider = uislider(app.LeftPanel);
            app.XaxisSlider.Limits = [20 200];
            app.XaxisSlider.ValueChangedFcn = createCallbackFcn(app, @XaxisSliderValueChanged, true);
            app.XaxisSlider.Position = [98 200 153 3];
            app.XaxisSlider.Value = 50;

            % Create YaxisSliderLabel
            app.YaxisSliderLabel = uilabel(app.LeftPanel);
            app.YaxisSliderLabel.HorizontalAlignment = 'right';
            app.YaxisSliderLabel.Position = [38 148 38 22];
            app.YaxisSliderLabel.Text = 'Y axis';

            % Create YaxisSlider
            app.YaxisSlider = uislider(app.LeftPanel);
            app.YaxisSlider.Limits = [20 200];
            app.YaxisSlider.ValueChangedFcn = createCallbackFcn(app, @YaxisSliderValueChanged, true);
            app.YaxisSlider.Position = [97 157 153 3];
            app.YaxisSlider.Value = 50;

            % Create ZaxisSliderLabel
            app.ZaxisSliderLabel = uilabel(app.LeftPanel);
            app.ZaxisSliderLabel.HorizontalAlignment = 'right';
            app.ZaxisSliderLabel.Position = [40 105 37 22];
            app.ZaxisSliderLabel.Text = 'Z axis';

            % Create ZaxisSlider
            app.ZaxisSlider = uislider(app.LeftPanel);
            app.ZaxisSlider.Limits = [20 200];
            app.ZaxisSlider.Position = [98 114 153 3];
            app.ZaxisSlider.Value = 100;

            % Create ResolutionnumberofpointsgeneratedLabel
            app.ResolutionnumberofpointsgeneratedLabel = uilabel(app.LeftPanel);
            app.ResolutionnumberofpointsgeneratedLabel.HorizontalAlignment = 'center';
            app.ResolutionnumberofpointsgeneratedLabel.Position = [32 218 225 22];
            app.ResolutionnumberofpointsgeneratedLabel.Text = 'Resolution (number of points generated):';

            % Create additionalvisibilityborderLabel
            app.additionalvisibilityborderLabel = uilabel(app.LeftPanel);
            app.additionalvisibilityborderLabel.HorizontalAlignment = 'center';
            app.additionalvisibilityborderLabel.Position = [31 423 107 30];
            app.additionalvisibilityborderLabel.Text = {' additional visibility '; 'border, m'};

            % Create additionalvisibilitybordermEditField
            app.additionalvisibilitybordermEditField = uieditfield(app.LeftPanel, 'numeric');
            app.additionalvisibilitybordermEditField.Limits = [0 Inf];
            app.additionalvisibilitybordermEditField.Position = [153 431 100 22];
            app.additionalvisibilitybordermEditField.Value = 0.01;

            % Create RestoredefaultsettingsButton
            app.RestoredefaultsettingsButton = uibutton(app.LeftPanel, 'push');
            app.RestoredefaultsettingsButton.Position = [71 33 140 23];
            app.RestoredefaultsettingsButton.Text = 'Restore default settings';

            % Create numberofspeakersYEditField
            app.numberofspeakersYEditField = uieditfield(app.LeftPanel, 'numeric');
            app.numberofspeakersYEditField.Limits = [1 100];
            app.numberofspeakersYEditField.ValueChangedFcn = createCallbackFcn(app, @numberofspeakersYEditFieldValueChanged, true);
            app.numberofspeakersYEditField.Position = [204 538 49 22];
            app.numberofspeakersYEditField.Value = 10;

            % Create speakersspreadYEditField
            app.speakersspreadYEditField = uieditfield(app.LeftPanel, 'numeric');
            app.speakersspreadYEditField.Limits = [0 Inf];
            app.speakersspreadYEditField.ValueChangedFcn = createCallbackFcn(app, @speakersspreadYEditFieldValueChanged, true);
            app.speakersspreadYEditField.Position = [204 517 49 22];
            app.speakersspreadYEditField.Value = 0.002;

            % Create XLabel
            app.XLabel = uilabel(app.LeftPanel);
            app.XLabel.HorizontalAlignment = 'center';
            app.XLabel.Position = [163 559 25 22];
            app.XLabel.Text = 'X';

            % Create YLabel
            app.YLabel = uilabel(app.LeftPanel);
            app.YLabel.HorizontalAlignment = 'center';
            app.YLabel.Position = [217 559 25 22];
            app.YLabel.Text = 'Y';

            % Create DatastatusLabel
            app.DatastatusLabel = uilabel(app.LeftPanel);
            app.DatastatusLabel.HorizontalAlignment = 'right';
            app.DatastatusLabel.Position = [351 138 69 22];
            app.DatastatusLabel.Text = 'Data status:';

            % Create TextArea
            app.TextArea = uitextarea(app.LeftPanel);
            app.TextArea.Interruptible = 'off';
            app.TextArea.Editable = 'off';
            app.TextArea.Position = [311 79 150 60];
            app.TextArea.Value = {'No data generated'};

            % Create DisplayDataButton
            app.DisplayDataButton = uibutton(app.LeftPanel, 'push');
            app.DisplayDataButton.ButtonPushedFcn = createCallbackFcn(app, @DisplayDataButtonPushed, true);
            app.DisplayDataButton.Position = [336 168 100 23];
            app.DisplayDataButton.Text = 'Display Data';

            % Create GenerateDataButton
            app.GenerateDataButton = uibutton(app.LeftPanel, 'push');
            app.GenerateDataButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateDataButtonPushed, true);
            app.GenerateDataButton.Position = [336 202 100 23];
            app.GenerateDataButton.Text = 'Generate Data';

            % Create displayfocuspointCheckBox
            app.displayfocuspointCheckBox = uicheckbox(app.LeftPanel);
            app.displayfocuspointCheckBox.ValueChangedFcn = createCallbackFcn(app, @displayfocuspointCheckBoxValueChanged, true);
            app.displayfocuspointCheckBox.Text = 'display focus point';
            app.displayfocuspointCheckBox.Position = [311 344 121 22];

            % Create displayspeakerdistributionCheckBox
            app.displayspeakerdistributionCheckBox = uicheckbox(app.LeftPanel);
            app.displayspeakerdistributionCheckBox.ValueChangedFcn = createCallbackFcn(app, @displayspeakerdistributionCheckBoxValueChanged, true);
            app.displayspeakerdistributionCheckBox.Text = 'display speaker distribution';
            app.displayspeakerdistributionCheckBox.Position = [311 364 167 22];

            % Create enabledisplayofcomponentsyouwishtoseeontheschemeLabel
            app.enabledisplayofcomponentsyouwishtoseeontheschemeLabel = uilabel(app.LeftPanel);
            app.enabledisplayofcomponentsyouwishtoseeontheschemeLabel.WordWrap = 'on';
            app.enabledisplayofcomponentsyouwishtoseeontheschemeLabel.Position = [311 394 168 42];
            app.enabledisplayofcomponentsyouwishtoseeontheschemeLabel.Text = 'enable display of components you wish to see on the scheme';

            % Create generatinganddisplayingaccousticpressureandphasesLabel
            app.generatinganddisplayingaccousticpressureandphasesLabel = uilabel(app.LeftPanel);
            app.generatinganddisplayingaccousticpressureandphasesLabel.HorizontalAlignment = 'center';
            app.generatinganddisplayingaccousticpressureandphasesLabel.WordWrap = 'on';
            app.generatinganddisplayingaccousticpressureandphasesLabel.Position = [301 232 170 74];
            app.generatinganddisplayingaccousticpressureandphasesLabel.Text = 'generating and displaying acoustic pressure and phases in which the speakers need to be to achieve given results';

            % Create setparametersofmodeltodesiredvaluesLabel
            app.setparametersofmodeltodesiredvaluesLabel = uilabel(app.LeftPanel);
            app.setparametersofmodeltodesiredvaluesLabel.HorizontalAlignment = 'center';
            app.setparametersofmodeltodesiredvaluesLabel.WordWrap = 'on';
            app.setparametersofmodeltodesiredvaluesLabel.Position = [79 562 132 74];
            app.setparametersofmodeltodesiredvaluesLabel.Text = 'set parameters of model to desired values';

            % Create ExportpressureDataButton
            app.ExportpressureDataButton = uibutton(app.LeftPanel, 'push');
            app.ExportpressureDataButton.Position = [311 33 150 23];
            app.ExportpressureDataButton.Text = 'Export pressure Data';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.RightPanel);
            app.GridLayout2.ColumnWidth = {250, 250, 250, 45, '1x'};
            app.GridLayout2.RowHeight = {20, '1x', '5.57x', 14, 15, 90, 15, 40, 14, '5.91x'};
            app.GridLayout2.ColumnSpacing = 7.125;
            app.GridLayout2.RowSpacing = 6.94285665239607;
            app.GridLayout2.Padding = [7.125 6.94285665239607 7.125 6.94285665239607];

            % Create UIAxes_7
            app.UIAxes_7 = uiaxes(app.GridLayout2);
            title(app.UIAxes_7, 'Acoustic pressure - Z values')
            zlabel(app.UIAxes_7, 'Z')
            app.UIAxes_7.FontSize = 9;
            app.UIAxes_7.Layout.Row = [2 4];
            app.UIAxes_7.Layout.Column = [3 4];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.GridLayout2);
            title(app.UIAxes_2, 'Acoustic pressure - X values')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.FontSize = 9;
            app.UIAxes_2.Layout.Row = [2 4];
            app.UIAxes_2.Layout.Column = 1;

            % Create UIAxes_5
            app.UIAxes_5 = uiaxes(app.GridLayout2);
            title(app.UIAxes_5, 'Acoustic pressure 3D')
            xlabel(app.UIAxes_5, 'X')
            ylabel(app.UIAxes_5, 'Y')
            zlabel(app.UIAxes_5, 'Z')
            app.UIAxes_5.Layout.Row = [8 10];
            app.UIAxes_5.Layout.Column = [3 4];

            % Create UIAxes_10
            app.UIAxes_10 = uiaxes(app.GridLayout2);
            title(app.UIAxes_10, 'Acoustic pressure - Y values')
            zlabel(app.UIAxes_10, 'Z')
            app.UIAxes_10.FontSize = 9;
            app.UIAxes_10.Layout.Row = [2 4];
            app.UIAxes_10.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout2);
            title(app.UIAxes, 'Phases of bottom array')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.FontSize = 9;
            app.UIAxes.Layout.Row = 10;
            app.UIAxes.Layout.Column = 2;

            % Create UIAxes_9
            app.UIAxes_9 = uiaxes(app.GridLayout2);
            title(app.UIAxes_9, 'Phases of top array')
            xlabel(app.UIAxes_9, 'X')
            ylabel(app.UIAxes_9, 'Y')
            zlabel(app.UIAxes_9, 'Z')
            app.UIAxes_9.FontSize = 9;
            app.UIAxes_9.Layout.Row = 10;
            app.UIAxes_9.Layout.Column = 1;

            % Create AccousticpressureLabel
            app.AccousticpressureLabel = uilabel(app.GridLayout2);
            app.AccousticpressureLabel.VerticalAlignment = 'top';
            app.AccousticpressureLabel.WordWrap = 'on';
            app.AccousticpressureLabel.Layout.Row = 5;
            app.AccousticpressureLabel.Layout.Column = [1 2];
            app.AccousticpressureLabel.Text = 'Acoustic pressure distribution at the coordinates of focus point, presented in 2D graphs.';

            % Create Label_2
            app.Label_2 = uilabel(app.GridLayout2);
            app.Label_2.VerticalAlignment = 'bottom';
            app.Label_2.WordWrap = 'on';
            app.Label_2.Layout.Row = 8;
            app.Label_2.Layout.Column = [1 2];
            app.Label_2.Text = {'Graphs presenting phases, in which speakers in given model have to work in order'; 'to generate sound waves focused in given point'};

            % Create dimentionalaccousticpressuredisplaypresentingLabel
            app.dimentionalaccousticpressuredisplaypresentingLabel = uilabel(app.GridLayout2);
            app.dimentionalaccousticpressuredisplaypresentingLabel.HorizontalAlignment = 'center';
            app.dimentionalaccousticpressuredisplaypresentingLabel.VerticalAlignment = 'bottom';
            app.dimentionalaccousticpressuredisplaypresentingLabel.WordWrap = 'on';
            app.dimentionalaccousticpressuredisplaypresentingLabel.Layout.Row = 6;
            app.dimentionalaccousticpressuredisplaypresentingLabel.Layout.Column = [3 4];
            app.dimentionalaccousticpressuredisplaypresentingLabel.Text = 'Three dimentional acoustic pressure display, presenting pressure data in between bottom and top array of speakers, extended horizontally by value of  ''additional visibility border''.';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Pressure_displayer_project

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end