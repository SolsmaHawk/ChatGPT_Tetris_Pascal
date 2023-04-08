program Tetris;

{$mode objfpc}{$H+}

uses
  CRT, DOS, math;

const
  BoardWidth = 10;
  BoardHeight = 20;
  BlockSize = 2;

type
  TetriminoShape = array [0..3, 0..3] of Boolean;
  Tetrimino = record
    Shape: TetriminoShape;
    X, Y: Integer;
    Color: Byte;
  end;

var
  Board: array [0..BoardWidth - 1, 0..BoardHeight - 1] of Byte;
  CurrentTetrimino: Tetrimino;
  NextTetrimino: Tetrimino;
  Score: Integer;

procedure InitBoard;
var
  x, y: Integer;
begin
  for x := 0 to BoardWidth - 1 do
    for y := 0 to BoardHeight - 1 do
      Board[x, y] := 0;
end;

function RandomTetrimino: Tetrimino;
const
  Tetriminos: array [0..6] of TetriminoShape = (
    ((False, False, False, False),
     (False, False, False, False),
     (True, True, True, True),
     (False, False, False, False)),
     
    ((True, False, False, False),
     (True, True, True, False),
     (False, False, False, False),
     (False, False, False, False)),
     
    ((False, False, True, False),
     (False, False, True, False),
     (False, False, True, False),
     (False, False, True, False)),
     
    ((False, True, True, False),
     (False, True, False, False),
     (False, True, False, False),
     (False, False, False, False)),
     
    ((False, True, False, False),
     (False, True, True, False),
     (False, False, True, False),
     (False, False, False, False)),
     
    ((False, False, False, False),
     (False, True, True, False),
     (False, True, True, False),
     (False, False, False, False)),
     
    ((False, True, True, False),
     (False, False, True, True),
     (False, False, False, False),
     (False, False, False, False))
  );
begin
  Result.Shape := Tetriminos[random(7)];
  Result.X := BoardWidth div 2 - 2;
  Result.Y := 0;
  Result.Color := random(15) + 1;
end;

procedure DrawTetrimino(T: Tetrimino);
var
  x, y: Integer;
begin
  for x := 0 to 3 do
    for y := 0 to 3 do
      if T.Shape[x, y] then begin
        GotoXY((T.X + x) * BlockSize, T.Y + y);
        TextBackground(T.Color);
        Write('  ');
      end;
end;

procedure EraseTetrimino(T: Tetrimino);
var
  x, y: Integer;
begin
  for x := 0 to 3 do
    for y := 0 to 3 do
      if T.Shape[x, y] then begin
        GotoXY((T.X + x) * BlockSize, T.Y + y);
        TextBackground(Black);
        Write('  ');
      end;
end;

function CanMove(T: Tetrimino; Dx, Dy: Integer): Boolean;
var
  x, y: Integer;
begin
  for x := 0 to 3 do
    for y := 0 to 3 do
      if T.Shape[x, y] then begin
        if (T.X + x + Dx < 0) or (T.X + x + Dx >= BoardWidth) then begin
          CanMove := False;
          Exit;
        end;
        if (T.Y + y + Dy >= BoardHeight) or (Board[T.X + x + Dx, T.Y + y + Dy] <> 0) then begin
          CanMove := False;
          Exit;
        end;
      end;
  Result := True;
end;

procedure MoveTetrimino(var T: Tetrimino; Dx, Dy: Integer);
begin
  if CanMove(T, Dx, Dy) then begin
    EraseTetrimino(T);
    T.X := T.X + Dx;
    T.Y := T.Y + Dy;
    DrawTetrimino(T);
  end;
end;

procedure RotateTetrimino(var T: Tetrimino);
var
  NewShape: TetriminoShape;
  x, y: Integer;
begin
  for x := 0 to 3 do
    for y := 0 to 3 do
      NewShape[x, y] := T.Shape[3 - y, x];
  if CanMove(T, 0, 0) then begin
    EraseTetrimino(T);
    T.Shape := NewShape;
    DrawTetrimino(T);
  end;
end;

procedure CheckLines;
var
  x, y, Lines, LineCount: Integer;
  IsLineFull: Boolean;
begin
  Lines := 0;
  for y := BoardHeight - 1 downto 0 do begin
    IsLineFull := True;
    for x := 0 to BoardWidth - 1 do
      if Board[x, y] = 0 then begin
        IsLineFull := False;
        Break;
      end;
    if IsLineFull then begin
      Inc(Lines);
      for x := 0 to BoardWidth - 1 do begin
        for LineCount := y downto 1 do
          Board[x, LineCount] := Board[x, LineCount - 1];
        Board[x, 0] := 0;
      end;
      GotoXY(1, 22);
      Write('Score: ', Score);
    end;
  end;
  if Lines > 0 then begin
    Score := Score + Round(Power(2, Lines - 1)) * 100;
    GotoXY(1, 24);
    Write('Lines: ', Lines);
    GotoXY(1, 22);
    Write('Score: ', Score);
  end;
end;

procedure PlaceTetriminoOnBoard(T: Tetrimino);
var
  x, y: Integer;
begin
  for x := 0 to 3 do
    for y := 0 to 3 do
      if T.Shape[x, y] then
        Board[T.X + x, T.Y + y] := T.Color;
  CheckLines;
end;

procedure GameOver;
begin
  Sound(220); Delay(200); NoSound;
  Sound(165); Delay(200); NoSound;
  Sound(110); Delay(200); NoSound;
  Sound(82); Delay(200); NoSound;
  Sound(110); Delay(200); NoSound;
  Sound(165); Delay(200); NoSound;
  Sound(220); Delay(200); NoSound;
  Delay(500);
  ClrScr;
  GotoXY(1, 1);
  Write('GAME OVER');
  GotoXY(1, 2);
  Write('Score: ', Score);
  Halt;
end;

procedure GameLoop;
begin
  InitBoard;
  CurrentTetrimino := RandomTetrimino;
  NextTetrimino := RandomTetrimino;
  Score := 0;
  repeat
    if KeyPressed then begin
      case ReadKey of
        #0: case ReadKey of
              #75: MoveTetrimino(CurrentTetrimino, -1, 0); // Left arrow
              #77: MoveTetrimino(CurrentTetrimino, 1, 0); // Right arrow
              #72: RotateTetrimino(CurrentTetrimino); // Up arrow
              #80: MoveTetrimino(CurrentTetrimino, 0, 1); // Down arrow
            end;
        'p', 'P': ReadKey; // Pause
        'q', 'Q': Exit; // Quit
      end;
    end;
    MoveTetrimino(CurrentTetrimino, 0, 1);
    if not CanMove(CurrentTetrimino, 0, 1) then begin
      EraseTetrimino(CurrentTetrimino);
      PlaceTetriminoOnBoard(CurrentTetrimino);
      CheckLines;
      CurrentTetrimino := NextTetrimino;
      NextTetrimino := RandomTetrimino;
      if not CanMove(CurrentTetrimino, 0, 0) then begin
        GotoXY(1, BoardHeight + 2);
        WriteLn('Game over!');
        WriteLn('Press any key to continue...');
        ReadKey;
        Exit;
      end;
    end;
    Delay(100);
  until False;
end;

begin
GameLoop;
end.