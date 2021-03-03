object MainForm: TMainForm
  Left = 257
  Top = 113
  BorderStyle = bsSingle
  Caption = 'Inverter Test'
  ClientHeight = 498
  ClientWidth = 727
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  DesignSize = (
    727
    498)
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 711
    Height = 482
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object Label3: TLabel
      Left = 624
      Top = 50
      Width = 26
      Height = 13
      Caption = 'Time:'
    end
    object TimeReceived: TLabel
      Left = 680
      Top = 50
      Width = 6
      Height = 13
      Caption = '0'
    end
    object OnBus: TLabel
      Left = 8
      Top = 48
      Width = 36
      Height = 13
      Caption = 'Off Bus'
    end
    object TPDOA1: TLabel
      Left = 96
      Top = 168
      Width = 40
      Height = 13
      Caption = 'TPDOA1'
    end
    object TPDOA2: TLabel
      Left = 96
      Top = 187
      Width = 40
      Height = 13
      Caption = 'TPDOA2'
    end
    object TPDOA3: TLabel
      Left = 96
      Top = 205
      Width = 40
      Height = 13
      Caption = 'TPDOA3'
    end
    object TPDOA4: TLabel
      Left = 96
      Top = 224
      Width = 40
      Height = 13
      Caption = 'TPDOA4'
    end
    object TPDOA5: TLabel
      Left = 96
      Top = 243
      Width = 40
      Height = 13
      Caption = 'TPDOA5'
    end
    object TPDOA6: TLabel
      Left = 96
      Top = 262
      Width = 40
      Height = 13
      Caption = 'TPDOA6'
    end
    object TPDOA7: TLabel
      Left = 96
      Top = 281
      Width = 40
      Height = 13
      Caption = 'TPDOA7'
    end
    object Label1: TLabel
      Left = 11
      Top = 168
      Width = 33
      Height = 13
      Caption = 'TPDO1'
    end
    object Label4: TLabel
      Left = 11
      Top = 281
      Width = 33
      Height = 13
      Caption = 'TPDO7'
    end
    object Label5: TLabel
      Left = 11
      Top = 262
      Width = 33
      Height = 13
      Caption = 'TPDO6'
    end
    object Label6: TLabel
      Left = 11
      Top = 243
      Width = 33
      Height = 13
      Caption = 'TPDO5'
    end
    object Label7: TLabel
      Left = 11
      Top = 224
      Width = 33
      Height = 13
      Caption = 'TPDO4'
    end
    object Label8: TLabel
      Left = 11
      Top = 205
      Width = 33
      Height = 13
      Caption = 'TPDO3'
    end
    object Label9: TLabel
      Left = 11
      Top = 187
      Width = 33
      Height = 13
      Caption = 'TPDO2'
    end
    object Label10: TLabel
      Left = 11
      Top = 337
      Width = 30
      Height = 13
      Caption = 'Speed'
    end
    object Label2: TLabel
      Left = 11
      Top = 376
      Width = 33
      Height = 13
      Caption = 'StateA'
    end
    object StateA: TLabel
      Left = 64
      Top = 376
      Width = 33
      Height = 13
      Caption = 'StateA'
    end
    object StateB: TLabel
      Left = 64
      Top = 395
      Width = 37
      Height = 13
      Caption = 'Label11'
    end
    object Label12: TLabel
      Left = 11
      Top = 395
      Width = 32
      Height = 13
      Caption = 'StateB'
    end
    object CanDevices: TComboBox
      Left = 3
      Top = 20
      Width = 145
      Height = 21
      Style = csDropDownList
      TabOrder = 0
      OnChange = CanDevicesChange
    end
    object Output: TListBox
      Left = 223
      Top = 20
      Width = 378
      Height = 452
      ItemHeight = 13
      TabOrder = 1
    end
    object goOnBus: TButton
      Left = 3
      Top = 67
      Width = 75
      Height = 25
      Caption = 'Go on bus'
      TabOrder = 2
      OnClick = goOnBusClick
    end
    object Clear: TButton
      Left = 620
      Top = 19
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 3
      OnClick = ClearClick
    end
    object StartInv: TButton
      Left = 620
      Top = 378
      Width = 75
      Height = 25
      Caption = 'Startup'
      Enabled = False
      TabOrder = 4
      OnClick = StartInvClick
    end
    object Run: TButton
      Left = 620
      Top = 409
      Width = 75
      Height = 25
      Caption = 'Run Motor'
      Enabled = False
      TabOrder = 5
      OnClick = RunClick
    end
    object Stop: TButton
      Left = 620
      Top = 440
      Width = 75
      Height = 25
      Caption = 'Stop'
      TabOrder = 6
      OnClick = StopClick
    end
    object AccelL: TEdit
      Left = 96
      Top = 334
      Width = 121
      Height = 21
      NumbersOnly = True
      TabOrder = 7
      Text = '0'
    end
    object FaultReset: TButton
      Left = 620
      Top = 332
      Width = 75
      Height = 25
      Caption = 'Reset Fault'
      Enabled = False
      TabOrder = 8
      OnClick = RunClick
    end
    object HVReady: TCheckBox
      Left = 11
      Top = 417
      Width = 97
      Height = 17
      Caption = 'HVReady'
      Enabled = False
      TabOrder = 9
    end
  end
  object Timer1: TTimer
    Interval = 20
    OnTimer = Timer1Timer
    Left = 120
    Top = 104
  end
end
