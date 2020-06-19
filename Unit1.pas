unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, StrUtils;

type
  TForm1 = class(TForm)
    memInput: TMemo;
    btnSave: TButton;
    dlgSave: TSaveDialog;
    procedure btnSaveClick(Sender: TObject);
    procedure memInputKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    function Explode(s, d: string; n: integer): string;
    function ASMtoInt(s: string): integer;
    procedure SendByte(b: integer);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  myfile: file;
  outarray: array of byte;
  outpos: integer;

implementation

{$R *.dfm}

procedure TForm1.btnSaveClick(Sender: TObject);
var i, j: integer;
  line, sub: string;
begin
  SetLength(outarray,4194304); // Set output to 4MB max.
  outpos := 0;    
  for i := 0 to memInput.Lines.Count-1 do
    memInput.Lines[i] := AdjustLineBreaks(memInput.Lines[i],tlbsCRLF); // Fix nonstandard line breaks.
  for i := 0 to memInput.Lines.Count-1 do
    begin
    line := memInput.Lines[i]; // Get line.
    line := Explode(line,';',0); // Strip comment.
    line := StringReplace(line,#9,'',[rfReplaceAll]); // Strip tabs. 
    line := StringReplace(line,'"',#39,[rfReplaceAll]); // Replace double with single quotes.
    { Byte size data (includes strings). }
    if AnsiPos('dc.b',line) <> 0 then
      begin
      line := Explode(line,'dc.b',1); // Strip dc.b
      j := 0;
      while Explode(line,',',j) <> '' do
        begin
        sub := Explode(line,',',j); // Get substring.
        if AnsiPos(#39,sub) <> 0 then // Check for quotes (substring is string).
          begin
          sub := Explode(sub,#39,1); // Strip quotes.
          Move(sub[1],outarray[outpos],Length(sub)); // Copy string to output.
          outpos := outpos+Length(sub);
          end
        else SendByte(ASMtoInt(sub)); // Quotes not found (substring is number); Copy byte to output.
        inc(j);
        end;
      end;
    { Word size data. }
    if AnsiPos('dc.w',line) <> 0 then
      begin
      line := Explode(line,'dc.w',1); // Strip dc.w
      j := 0;
      while Explode(line,',',j) <> '' do
        begin
        sub := Explode(line,',',j); // Get substring.
        SendByte(ASMtoInt(sub) shr 8); // Copy high byte to output.
        SendByte(ASMtoInt(sub)); // Copy low byte to output.
        inc(j);
        end;
      end;   
    { Longword size data. }
    if AnsiPos('dc.l',line) <> 0 then
      begin
      line := Explode(line,'dc.l',1); // Strip dc.l
      j := 0;
      while Explode(line,',',j) <> '' do
        begin
        sub := Explode(line,',',j); // Get substring.
        SendByte(ASMtoInt(sub) shr 24); // Copy highest byte to output.
        SendByte(ASMtoInt(sub) shr 16); // Copy next byte to output.
        SendByte(ASMtoInt(sub) shr 8); // Copy next byte to output.
        SendByte(ASMtoInt(sub)); // Copy low byte to output.
        inc(j);
        end;
      end;
    end;
  if dlgSave.Execute then
    begin
    AssignFile(myfile,dlgSave.FileName); // Create output file.
    ReWrite(myfile,1);
    BlockWrite(myfile,outarray[0],outpos); // Copy output to file.
    CloseFile(myfile);
    end;
end;

{ Replicate MediaWiki's "explode" string function. }
function TForm1.Explode(s, d: string; n: integer): string;
var n2: integer;
begin
  if (AnsiPos(d,s) = 0) and ((n = 0) or (n = -1)) then result := s // Output full string if delimiter not found.
  else
    begin
    if n > -1 then // Check for negative substring.
      begin
      s := s+d;
      n2 := n;
      end
    else
      begin
      d := AnsiReverseString(d);
      s := AnsiReverseString(s)+d; // Reverse string for negative.
      n2 := (n*-1)-1;
      end;
    while n2 > 0 do
      begin
      Delete(s,1,AnsiPos(d,s)+Length(d)-1); // Trim earlier substrings and delimiters.
      dec(n2);
      end;
    Delete(s,AnsiPos(d,s),Length(s)-AnsiPos(d,s)+1); // Trim later substrings and delimiters.
    if n < 0 then s := AnsiReverseString(s); // Un-reverse string if negative.
    result := s;
    end;
end;

{ Convert ASM number (decimal/hex/binary) to integer. }
function TForm1.ASMtoInt(s: string): integer;
var b, r: integer;
begin
  if AnsiPos('%',s) <> 0 then // Check for % prefix, which means binary.
    begin
    r := 0;
    s := StringReplace(Trim(s),'%','',[rfReplaceAll]); // Remove spaces and % sign.
    for b := 1 to Length(s) do
      r := r+(StrtoInt(s[b]) shl (Length(s)-b)); // Get each bit and add to result.
    result := r;
    end
  else
    begin
    if TryStrtoInt(s,b) = true then result := StrtoInt(s)
    else result := 0;
    end;
end;

{ Send byte to output array and increment counter. }
procedure TForm1.SendByte(b: integer);
begin
  outarray[outpos] := b and $ff;
  inc(outpos);
end;

procedure TForm1.memInputKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = ^A then
    begin
    memInput.SelectAll; // Enable select all with Ctrl+A.
    Key := #0;
    end;
end;

end.
