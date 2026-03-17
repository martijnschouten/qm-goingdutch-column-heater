procedure CreateConcentricArcsMM;
var
    Board            : IPCB_Board;
    ArcTop              : IPCB_Arc;
    ArcBottom              : IPCB_Arc;
    LeftSpoke             : IPCB_Track;
    RightSpoke            : IPCB_Track;
    CurrentR         : Double;
    StepR             : Double;
    StartR           : Double;
    EndR             : Double;
    OriginX          : Double;
    OriginY          : Double;
    AngleStep        : Double;
    StartAngleStartTop  : Double;
    StopAngleStartTop   : Double;
    StartAngleStartBottom  : Double;
    StopAngleStartBottom   : Double;
    CurrentStartAngleTop: Double;
    CurrentStopAngleTop : Double;
    CurrentStartAngleBottom: Double;
    CurrentStopAngleBottom : Double;
    TrackWidth : Double;
    RadAngle : Double;
begin
    Board := PCBServer.GetCurrentPCBBoard;
    if Board = nil then
    begin
        ShowError('Please open a PCB document first.');
        Exit;
    end;

    // Parameters in Millimeters
    StartR := MmsToCoord(36.3);
    EndR   := MmsToCoord(49.5);
    StepR   := MmsToCoord(0.32);

    // Parameters in degrees
    AngleStep := 0.5;
    StartAngleStartTop := 0;
    StopAngleStartTop := 179.5;
    StartAngleStartBottom := 180;
    StopAngleStartBottom := 359.5;

    // Get the Relative Origin coordinates from the board
    OriginX := Board.XOrigin;
    OriginY := Board.YOrigin;

    CurrentR := StartR;
    CurrentStartAngleTop := StartAngleStartTop;
    CurrentStopAngleTop := StopAngleStartTop;
    CurrentStartAngleBottom := StartAngleStartBottom;
    CurrentStopAngleBottom := StopAngleStartBottom;

    TrackWidth := StepR/2;

    PCBServer.PreProcess; // Start undo stack

    while CurrentR <= (EndR + 0.001) do // Added small epsilon for float precision
    begin
        ArcTop := PCBServer.PCBObjectFactory(eArcObject, eNoDimension, eCreate_Default);

        // Coordinates and Geometry
        ArcTop.XCenter    := OriginX + MmsToCoord(0);
        ArcTop.YCenter    := OriginY + MmsToCoord(0);
        ArcTop.Radius     := CurrentR;
        ArcTop.LineWidth  := TrackWidth; // Typical track width
        ArcTop.StartAngle := CurrentStartAngleTop;
        ArcTop.EndAngle   := CurrentStopAngleTop;
        ArcTop.Layer      := eTopLayer;

        Board.AddPCBObject(ArcTop);



        ArcBottom := PCBServer.PCBObjectFactory(eArcObject, eNoDimension, eCreate_Default);

        // Coordinates and Geometry
        ArcBottom.XCenter    := OriginX + MmsToCoord(0);
        ArcBottom.YCenter    := OriginY + MmsToCoord(0);
        ArcBottom.Radius     := CurrentR;
        ArcBottom.LineWidth  := TrackWidth; // Typical track width
        ArcBottom.StartAngle := CurrentStartAnglebottom;
        ArcBottom.EndAngle   := CurrentStopAnglebottom;
        ArcBottom.Layer      := eTopLayer;

        Board.AddPCBObject(ArcBottom);



        LeftSpoke := PCBServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);

        // Convert start angle to Radians for Trig
        RadAngle := CurrentStopAngleTop * (Pi / 180.0);

        // Start Point (at CurrentR)
        LeftSpoke.X1 := OriginX + (CurrentR * Cos(RadAngle));
        LeftSpoke.Y1 := OriginY + (CurrentR * Sin(RadAngle));

        // End Point (at CurrentR + Step)
        LeftSpoke.X2 := OriginX + ((CurrentR + StepR) * Cos(RadAngle));
        LeftSpoke.Y2 := OriginY + ((CurrentR + StepR) * Sin(RadAngle));

        LeftSpoke.Width := TrackWidth;
        LeftSpoke.Layer := eTopLayer;
        Board.AddPCBObject(LeftSpoke);

        RightSpoke := PCBServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);

        // Convert start angle to Radians for Trig
        RadAngle := CurrentStopAngleBottom * (Pi / 180.0);

        // Start Point (at CurrentR)
        RightSpoke.X1 := OriginX + (CurrentR * Cos(RadAngle));
        RightSpoke.Y1 := OriginY + (CurrentR * Sin(RadAngle));

        // End Point (at CurrentR + Step)
        RightSpoke.X2 := OriginX + ((CurrentR + StepR) * Cos(RadAngle));
        RightSpoke.Y2 := OriginY + ((CurrentR + StepR) * Sin(RadAngle));

        RightSpoke.Width := TrackWidth;
        RightSpoke.Layer := eTopLayer;
        Board.AddPCBObject(RightSpoke);


        CurrentStopAngleTop := CurrentStopAngleTop - AngleStep;
        CurrentStartAngleTop : = CurrentStartAngleTop - AngleStep;
        CurrentStopAngleBottom := CurrentStopAngleBottom - AngleStep;
        CurrentStartAngleBottom : = CurrentStartAngleBottom - AngleStep;
        CurrentR := CurrentR + StepR;
    end;

    ArcTop := PCBServer.PCBObjectFactory(eArcObject, eNoDimension, eCreate_Default);

    // Coordinates and Geometry
    ArcTop.XCenter    := OriginX + MmsToCoord(0);
    ArcTop.YCenter    := OriginY + MmsToCoord(0);
    ArcTop.Radius     := CurrentR;
    ArcTop.LineWidth  := TrackWidth; // Typical track width
    ArcTop.StartAngle := CurrentStopAngleBottom + AngleStep;
    ArcTop.EndAngle   := CurrentStopAngleTop + AngleStep;
    ArcTop.Layer      := eTopLayer;

    Board.AddPCBObject(ArcTop);

    PCBServer.PostProcess; // End undo stack

    // Refresh the workspace
    ResetParameters;
    Board.ViewManager_FullUpdate;
end;
