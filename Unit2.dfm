object Form2: TForm2
  Left = 256
  Top = 132
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'GL-CHUTE'
  ClientHeight = 169
  ClientWidth = 234
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 75
    Height = 16
    Caption = 'Scene width:'
  end
  object Label2: TLabel
    Left = 8
    Top = 40
    Width = 88
    Height = 16
    Caption = 'Transparence:'
  end
  object Label3: TLabel
    Left = 8
    Top = 72
    Width = 67
    Height = 16
    Caption = 'Resolution:'
  end
  object Label4: TLabel
    Left = 8
    Top = 104
    Width = 52
    Height = 16
    Caption = 'Difficulty:'
  end
  object ComboBox1: TComboBox
    Left = 160
    Top = 8
    Width = 65
    Height = 22
    Style = csOwnerDrawFixed
    ItemHeight = 16
    ItemIndex = 5
    TabOrder = 0
    Text = '6'
    Items.Strings = (
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9'
      '10')
  end
  object TrackBar1: TTrackBar
    Left = 104
    Top = 40
    Width = 121
    Height = 25
    Position = 9
    TabOrder = 1
    ThumbLength = 12
  end
  object Button1: TButton
    Left = 8
    Top = 136
    Width = 217
    Height = 25
    Caption = 'Game!'
    TabOrder = 2
    OnClick = Button1Click
  end
  object ComboBox2: TComboBox
    Left = 88
    Top = 72
    Width = 137
    Height = 22
    Style = csOwnerDrawFixed
    ItemHeight = 16
    TabOrder = 3
  end
  object ComboBox3: TComboBox
    Left = 88
    Top = 104
    Width = 137
    Height = 22
    Style = csOwnerDrawFixed
    ItemHeight = 16
    ItemIndex = 2
    TabOrder = 4
    Text = 'Moyen'
    Items.Strings = (
      'Chiant'
      'Facile'
      'Moyen'
      'Rapide'
      'Difficile'
      'Impossible')
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 96
    Top = 8
  end
end
