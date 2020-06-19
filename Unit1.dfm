object Form1: TForm1
  Left = 192
  Top = 124
  BorderStyle = bsDialog
  Caption = '68k Quick Data Assembler by Hivebrain'
  ClientHeight = 633
  ClientWidth = 841
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object memInput: TMemo
    Left = 8
    Top = 8
    Width = 665
    Height = 617
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
    OnKeyPress = memInputKeyPress
  end
  object btnSave: TButton
    Left = 680
    Top = 8
    Width = 153
    Height = 161
    Caption = 'Compile and Save...'
    TabOrder = 1
    OnClick = btnSaveClick
  end
  object dlgSave: TSaveDialog
    Left = 680
    Top = 176
  end
end
