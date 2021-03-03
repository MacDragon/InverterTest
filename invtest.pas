unit invtest;

interface

{$Define HPF20}

uses
//  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
//  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, CanChanEx, Vcl.ExtCtrls,
//  Vcl.Mask;
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, CanChanEx, ExtCtrls,
  Mask, System.Diagnostics, RTTI;

type
  TMainForm = class(TForm)
    goOnBus: TButton;
    Output: TListBox;
    GroupBox1: TGroupBox;
    CanDevices: TComboBox;
    Label3: TLabel;
    TimeReceived: TLabel;
    Clear: TButton;
    OnBus: TLabel;
    StartInv: TButton;
    Run: TButton;
    Stop: TButton;
    TPDOA1: TLabel;
    TPDOA2: TLabel;
    TPDOA3: TLabel;
    TPDOA4: TLabel;
    TPDOA5: TLabel;
    TPDOA6: TLabel;
    TPDOA7: TLabel;
    Timer1: TTimer;
    Label1: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    AccelL: TEdit;
    Label10: TLabel;
    Label2: TLabel;
    StateA: TLabel;
    StateB: TLabel;
    Label12: TLabel;
    FaultReset: TButton;
    HVReady: TCheckBox;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure goOnBusClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure CanDevicesChange(Sender: TObject);
    procedure StartInvClick(Sender: TObject);
    procedure RunClick(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    StartTime: TDateTime;
    CanChannel1: TCanChannelEx;
    CANFail : Boolean;

    MainStatus : Integer;

    RunMotor : Boolean;
    RunPDO : Boolean;

    SendPos : Integer;
    SendTime : TStopwatch;
    SendType : byte;
    SendSize : integer;
    SendBuffer: array[0..4095] of byte;
    ReceiveSize : Integer;

    StatusA : Word;
    StatusB : Word;
    responseA, responseB  : word;

    InverterOnline : Boolean;

    procedure CanChannel1CanRx(Sender: TObject);
    procedure sendNMT(state, id : byte);
    procedure sendSDO(id : byte; idx : word; sub : byte; data : longint);

    procedure sendSpeed(id : byte; cmd : word; vel : longint);

    procedure sendINV(msg0, msg1, msg2, msg3 : byte);

  public
    { Public declarations }
    function CanSend(id: Longint; var msg; dlc, flags: Cardinal): integer;
    procedure PopulateList;
  end;

var
  MainForm: TMainForm;
  HighVoltageReady : Boolean;
  HighVoltageAllowed : Array[1..4] of Boolean;

implementation

uses DateUtils, canlib, consts;

{$R *.dfm}

const

  turnonV = 50;

  NMTOperational = $1;
  NMTStop = $2;
  NMTPreOp = $80;
  NMTReset = $81;
  NMTResetComm = $82;

  TERR_id  = $80;

  TPDO1_id = $180;
  TPDO2_id = $1C0;
  TPDO3_id = $240;
  TPDO4_id = $280;
  TPDO5_id = $2C0;
  TPDO6_id = $340;
  TPDO7_id = $380;

  RPDO1_id = $200;
  RPDO2_id = $300;
  RPDO3_id = $400;
  RPDO4_id = $500;


  SDORX_id = $580; // 5c0 = INV B
  SDOTX_id = $600; // 640 = inv B

  // 640 SDO1_rx

  //SDO4RX_id =  $541;    // ?

  {

  // unknown sdo to inv b on shutdown from mobile?
 0    00000640         8  40  40  60  00  00  00  00  00   46393.662374 R
 0    00000640         8  80  40  60  00  00  00  04  05   46394.770134 R



 // fault reset
 0    00000640         8  40  40  60  00  00  00  00  00   46615.779624 R
 0    000005C0         8  4B  40  60  00  0F  00  00  00   46615.779994 R
 0    00000640         8  22  40  60  00  00  00  00  00   46615.807494 R
 0    000005C0         8  60  40  60  00  00  00  00  00   46615.807704 R
 0    00000640         8  40  40  60  00  00  00  00  00   46615.831524 R
 0    000005C0         8  4B  40  60  00  00  00  00  00   46615.831764 R
 0    00000640         8  22  40  60  00  80  00  00  00   46615.856594 R
 0    000005C0         8  60  40  60  00  00  00  00  00   46615.856854 R

 0    00000601         8  A0  0A  27  01  08  00  00  00   46615.878944 R
 0    00000581         8  C6  0A  27  01  0E  00  00  00   46615.879314 R
 0    00000601         8  A3  00  00  00  00  00  00  00   46615.884144 R
 0    00000581         8  01  00  01  29  02  03  05  00   46615.884404 R
 0    00000581         8  82  00  28  C0  00  00  D1  DB   46615.885354 R

 0    00000601         8  A2  02  08  00  00  00  00  00   46615.889174 R
 0    00000581         8  C1  00  00  00  00  00  00  00   46615.889434 R
 0    00000601         8  A1  00  00  00  00  00  00  00   46615.893944 R



 // get status
 0    00000640         8  40  41  60  00  00  00  00  00   46700.995504 R
 0    000005C0         8  4B  41  60  00  60  C0  00  00   46700.995774 R
 0    00000640         8  40  00  29  05  00  00  00  00   46701.018414 R
 0    000005C0         8  43  00  29  05  00  00  00  00   46701.018734 R
 0    00000640         8  40  00  29  07  00  00  00  00   46701.044494 R
 0    000005C0         8  4B  00  29  07  00  00  00  00   46701.044684 R
 0    00000640         8  40  00  29  0A  00  00  00  00   46701.066494 R
 0    000005C0         8  43  00  29  0A  DC  7D  FF  B7   46701.066864 R
 0    00000640         8  40  00  29  0B  00  00  00  00   46701.093404 R
 0    000005C0         8  4B  00  29  0B  73  01  00  00   46701.093584 R
 0    00000620         8  40  40  40  0A  00  00  00  00   46701.117434 R
 0    000005A0         8  43  40  40  0A  00  00  00  40   46701.120454 R
 0    00000620         8  40  40  40  0B  00  00  00  00   46701.143454 R
 0    000005A0         8  43  40  40  0B  FD  00  FC  B0   46701.145334 R
 0    00000640         8  40  01  29  0F  00  00  00  00   46701.169414 R
 0    000005C0         8  4B  01  29  0F  00  00  00  00   46701.169624 R
 0    00000640         8  40  03  20  00  00  00  00  00   46701.194464 R
 0    000005C0         8  43  03  20  00  33  4B  C9  89   46701.194934 R
 0    00000620         8  40  03  20  00  00  00  00  00   46701.219394 R
 0    000005A0         8  43  03  20  00  A3  EC  DC  29   46701.220394 R




  // power on sequence:
  APPC sends MC config at startup.

  // restore parameter set



  // switch to private can    -- not needed now, set off already.

0    00000620         8  22  04  40  01     D2  04  00  00   43411.836154 R

SDOtx to id 32.         [cmd][index][sub]  [value]

34

// reply
0    000005A0         8  60      04  40  01  00  00  00  00   43411.837734 R
                         [cmd?]  [index][sub][nul]

  turn motor on

         // configuring RDO's
         // create a state machine to walk through these?
 0    00000640         8  22  42  60  00  00  00  00  00    4256.640260 R
 0    000005C0         8  60  42  60  00  00  00  00  00    4256.640470 R
 0    00000640         8  22  48  60  00  20  03  00  00    4256.663160 R
 0    000005C0         8  60  48  60  00  00  00  00  00    4256.663380 R
 0    00000640         8  40  48  60  00  00  00  00  00    4256.691180 R
 0    000005C0         8  43  48  60  00  20  03  00  00    4256.691420 R
 0    00000640         8  22  49  60  00  E0  FC  FF  FF    4256.715210 R
 0    000005C0         8  60  49  60  00  00  00  00  00    4256.715360 R
 0    00000640         8  40  49  60  00  00  00  00  00    4256.735280 R
 0    000005C0         8  43  49  60  00  E0  FC  FF  FF    4256.735450 R
 0    00000640         8  22  76  60  00  8A  39  00  00    4256.759180 R
 0    000005C0         8  60  76  60  00  00  00  00  00    4256.759400 R
 0    00000640         8  40  76  60  00  00  00  00  00    4256.783200 R
 0    000005C0         8  43  76  60  00  8A  39  00  00    4256.783490 R
 0    00000640         8  22  71  60  00  00  00  00  00    4256.809260 R
 0    000005C0         8  60  71  60  00  00  00  00  00    4256.809440 R
 0    00000640         8  22  72  60  00  DC  05  00  00    4256.835140 R
 0    000005C0         8  60  72  60  00  00  00  00  00    4256.835300 R
 0    00000640         8  40  72  60  00  00  00  00  00    4256.858210 R
 0    000005C0         8  4B  72  60  00  DC  05  00  00    4256.858470 R
 0    00000640         8  22  87  60  00  88  13  00  00    4256.883180 R
 0    000005C0         8  60  87  60  00  00  00  00  00    4256.883440 R
 0    00000640         8  40  87  60  00  00  00  00  00    4256.907130 R
 0    000005C0         8  43  87  60  00  88  13  00  00    4256.907480 R
 0    00000640         8  22  F6  60  00  00  00  00  00    4256.931160 R
 0    000005C0         8  60  F6  60  00  00  00  00  00    4256.931440 R
 0    00000640         8  40  F6  60  00  00  00  00  00    4256.956220 R
 0    000005C0         8  43  F6  60  00  00  00  00  00    4256.956650 R
 0    00000640         8  22  26  29  01  00  00  00  00    4256.980170 R
 0    000005C0         8  60  26  29  01  00  00  00  00    4256.980330 R
 0    00000640         8  40  26  29  01  00  00  00  00    4257.001200 R
 0    000005C0         8  4B  26  29  01  00  00  00  00    4257.001620 R
 0    00000640         8  22  26  29  02  00  00  00  00    4257.024170 R
 0    000005C0         8  60  26  29  02  00  00  00  00    4257.024370 R
 0    00000640         8  40  26  29  02  00  00  00  00    4257.049160 R
 0    000005C0         8  4B  26  29  02  00  00  00  00    4257.049330 R
 0    00000640         8  22  10  29  01  01  00  00  00    4257.082170 R
 0    000005C0         8  60  10  29  01  00  00  00  00    4257.082530 R
 0    00000640         8  40  73  60  00  00  00  00  00    4257.105250 R
 0    000005C0         8  4B  73  60  00  DE  05  00  00    4257.105390 R
 0    00000640         8  22  60  60  00  02  00  00  00    4257.131210 R
 0    000005C0         8  60  60  60  00  00  00  00  00    4257.131400 R
 0    00000640         8  40  73  60  00  00  00  00  00    4257.152150 R
 0    000005C0         8  4B  73  60  00  DE  05  00  00    4257.152370 R
 0    00000640         8  22  73  60  00  DE  05  00  00    4257.175220 R
 0    000005C0         8  60  73  60  00  00  00  00  00    4257.175430 R
 0    00000640         8  40  73  60  00  00  00  00  00    4257.197170 R
 0    000005C0         8  4B  73  60  00  DE  05  00  00    4257.197430 R
 0    00000640         8  22  01  29  07  01  00  00  00    4257.221190 R
 0    000005C0         8  60  01  29  07  00  00  00  00    4257.221380 R
 0    00000640         8  22  E2  60  00  C4  09  00  00    4257.243180 R
 0    000005C0         8  60  E2  60  00  00  00  00  00    4257.243400 R
 0    00000640         8  40  E2  60  00  00  00  00  00    4257.266140 R
 0    000005C0         8  4B  E2  60  00  C4  09  00  00    4257.266300 R
 0    00000640         8  22  E0  60  00  00  00  00  00    4257.293270 R
 0    000005C0         8  60  E0  60  00  00  00  00  00    4257.293490 R
 0    00000640         8  40  E1  60  00  00  00  00  00    4257.319150 R
 0    000005C0         8  4B  E1  60  00  00  00  00  00    4257.319310 R
 0    00000640         8  22  E1  60  00  00  00  00  00    4257.344150 R
 0    000005C0         8  60  E1  60  00  00  00  00  00    4257.344400 R
 0    00000640         8  40  E1  60  00  00  00  00  00    4257.368150 R
 0    000005C0         8  4B  E1  60  00  00  00  00  00    4257.368330 R
 0    00000640         8  22  E4  60  00  88  13  00  00    4257.392160 R
 0    000005C0         8  60  E4  60  00  00  00  00  00    4257.392400 R
 0    00000640         8  40  E4  60  00  00  00  00  00    4257.417330 R
 0    000005C0         8  43  E4  60  00  88  13  00  00    4257.417490 R
 0    00000640         8  22  E3  60  00  DC  05  00  00    4257.443170 R
 0    000005C0         8  60  E3  60  00  00  00  00  00    4257.443350 R
 0    00000640         8  40  E3  60  00  00  00  00  00    4257.467150 R
 0    000005C0         8  4B  E3  60  00  DC  05  00  00    4257.467670 R
 0    00000640         8  40  40  60  00  00  00  00  00    4257.494180 R
 0    000005C0         8  4B  40  60  00  00  00  00  00    4257.494530 R
 0    00000640         8  22  40  60  00  06  00  00  00    4257.517320 R
 0    000005C0         8  60  40  60  00  00  00  00  00    4257.517760 R
 0    00000640         8  40  40  60  00  00  00  00  00    4257.539160 R
 0    000005C0         8  4B  40  60  00  06  00  00  00    4257.539360 R
 0    00000640         8  22  40  60  00  0F  00  00  00    4257.563150 R
 0    000005C0         8  60  40  60  00  00  00  00  00    4257.563430 R





             // quick stop

 0    00000640         8  40  40  60  00  00  00  00  00   42961.856504 R
 0    000005C0         8  4B  40  60  00  0F  00  00  00   42961.856724 R
 0    00000640         8  22  40  60  00  0B  00  00  00   42961.885534 R
 0    000005C0         8  60  40  60  00  00  00  00  00   42961.885754 R



             /// halt


 0    00000640         8  40  40  60  00  00  00  00  00   43028.600774 R
 0    000005C0         8  4B  40  60  00  0F  00  00  00   43028.601004 R
 0    00000640         8  40  40  60  00  00  00  00  00   43028.628324 R
 0    000005C0         8  4B  40  60  00  0F  00  00  00   43028.628554 R
 0    00000640         8  22  40  60  00  0F  01  00  00   43028.654474 R
 0    000005C0         8  60  40  60  00  00  00  00  00   43028.654924 R



 // halt off



 0    00000640         8  40  40  60  00  00  00  00  00   43050.167674 R
 0    000005C0         8  4B  40  60  00  0F  01  00  00   43050.167964 R
 0    00000640         8  40  40  60  00  00  00  00  00   43050.187754 R
 0    000005C0         8  4B  40  60  00  0F  01  00  00   43050.188144 R
 0    00000640         8  22  40  60  00  0F  00  00  00   43050.213674 R
 0    000005C0         8  60  40  60  00  00  00  00  00   43050.213884 R








               turn motor off

                0    00000640         8  40  40  60  00  00  00  00  00    4173.059080 R
 0    000005C0         8  4B  40  60  00  0F  00  00  00    4173.059290 R
 0    00000640         8  22  40  60  00  06  00  00  00    4173.083030 R
 0    000005C0         8  60  40  60  00  00  00  00  00    4173.083260 R
 0    00000640         8  40  40  60  00  00  00  00  00    4173.107050 R
 0    000005C0         8  4B  40  60  00  06  00  00  00    4173.107280 R
 0    00000640         8  22  40  60  00  00  00  00  00    4173.129360 R
 0    000005C0         8  60  40  60  00  00  00  00  00    4173.129810 R





 // errors


 0    000000A0         8  20  82  11  00  00  00  00  00   43107.038304 R
 0    000000A0         8  00  00  00  00  00  00  00  00   43107.003274 R




  }

  INVA_id = 1;
  INVB_id = 64;
  APPC_id = 32;


  // sdo1+32   -- set to private can control via sdo
  // sdo2+32

  // switch to private can control.





{$IfDef HPF19}
  PDMReceived = 0;
  BMSReceived = 1;
  InverterReceived	= 2;
  InverterLReceived	= 2;
  FLeftSpeedReceived	= 3;
  FRightSpeedReceived =	4;
  PedalADCReceived	= 5;
  IVTReceived = 6;
  InverterRReceived = 7;
{$EndIf}

{$IfDef HPF20}
  PDMReceived = 6;
  BMSReceived = 5;
  Inverter1Received	= 0;
  Inverter2Received	= 2;
  PedalADCReceived	= 4;
  IVTReceived = 8;
 // InverterRReceived = 7;
{$EndIf}

  BrakeFErrorBit = 0;
  BrakeRErrorBit = 1;
  Coolant1ErrorBit = 2;
  Coolant2ErrorBit = 3;
  SteeringAngleErrorBit	= 4;
  AccelLErrorBit = 5;
  AccelRErrorBit = 6;
  ADCholdingbit	= 7;

  InverterLErrorBit	= 9;
  InverterRErrorBit	= 10;

  BMSVoltageErrorBit = 11;

  var
    badvalue : byte;


  type
    DeviceStatus = (OFFLINE, BOOTUP, STOPPED, PREOPERATIONAL, OPERATIONAL, INERROR, UNKNOWN);


function GetInverterState ( status : Word ) : DeviceStatus;// status 104, failed to turn on HV 200, failure of encoders/temp
begin
	// establish current state machine position from return status.
	if ( ( Status and $4F ) = $40) then // 64
	begin // Switch on disabled
		result := BOOTUP; //1;
	end
	else if ( ( Status and $6F ) = $21 ) then // 49
	begin // Ready to switch on
		result := STOPPED;//2;
	end
	else if ( ( Status and $6F ) = $23 ) then // 51
	begin // Switched on. HV?
		result := PREOPERATIONAL;//3;
	end
	else if ( ( Status and $6F ) = $27 ) then // 55
	begin // Operation enabled.
		result := OPERATIONAL;//4;
	end
	else if ( ( ( Status and $6F ) = $07 )
			 or ( ( Status and $1F ) = $13 ) )   then
	begin // Quick Stop Active
		result := INERROR; // -1;
	end
	else if  ( ( ( Status and $4F ) = $0F )
			 or ( ( Status and $4F ) = $05 ) ) then
  begin // fault reaction active, will move to fault status next
		result := INERROR; // -2;
	end
	else if  ( ( ( Status and $4F ) = $04 )
			 or ( ( Status and $08 ) = $04 ) ) then
	begin // fault status
		result := INERROR;//-99;
		// send reset
	end else
	begin // unknown state
		result := UNKNOWN; // state 0 will request reset to enter State 1,
		// will fall here at start of loop and if unknown status.
	end
end;



function IntToBinStr(num: integer): string;
var
  i: integer;
begin
  for i := 0 to 31 do
    Result := IntToStr((num shr i) and 1)+Result;
end;


function TMainForm.CanSend(id: Longint; var msg; dlc, flags: Cardinal): integer;
var exception : Boolean;
begin
  exception := false;
  with CanChannel1 do
  begin
    try
      Check(Write(id, msg, dlc, flags), 'Write failed');
    except
      if not CANFail then
        Output.Items.Add('Error Sending to CAN');
      exception := true;
      goOnBusClick(nil);
    end;
    if exception then CANFail := true else CANFail := false;
  end;
  result := 0;
end;


procedure TMainForm.PopulateList;
var
  i : Integer;
  p : AnsiString;
begin
  SetLength(p, 64);
  CanDevices.Items.clear;
  CanChannel1.Options := [ccNoVirtual];
  for i := 0 to CanChannel1.ChannelCount - 1 do
  begin
    if ansipos('Virtual', CanChannel1.ChannelNames[i]) = 0 then  // don't populate virtual channels.
      CanDevices.Items.Add(CanChannel1.ChannelNames[i]);
  end;
  if CanDevices.Items.Count > 0 then
    CanDevices.ItemIndex := 0;
end;

procedure TMainForm.goOnBusClick(Sender: TObject);
var
  formattedDateTime : String;
begin
  with CanChannel1 do begin
    if not Active then begin
      Bitrate := canBITRATE_1M;
      Channel := CanDevices.ItemIndex;
      //  TCanChanOption = (ccNotExclusive, ccNoVirtual, ccAcceptLargeDLC);
      //  TCanChanOptions = set of TCanChanOption;
      Options := [ccNotExclusive];
      Open;
    //  SetHardwareFilters($20, canFILTER_SET_CODE_STD);
    //  SetHardwareFilters($FE, canFILTER_SET_MASK_STD);
      OnCanRx := CanChannel1CanRx;
      BusActive := true;
      CanDevices.Enabled := false;
      onBus.Caption := 'On bus';
      goOnBus.Caption := 'Go off bus';
      StartTime := Now;

      MainStatus := 0;

      Output.Items.Add('Ready.');
    end
    else
    begin

      BusActive := false;

      onBus.Caption := 'Off bus';
      goOnBus.Caption := 'Go on bus';
      CanDevices.Enabled := true;
      Close;
       Output.Items.Add('Offline.');
    end;

  //  if Active then Label1.Caption := 'Active' else Label1.Caption := 'Inactive';

  end;
end;

procedure TMainForm.CanDevicesChange(Sender: TObject);
begin
   CanChannel1.Channel := CanDevices.ItemIndex;
end;

procedure TMainForm.ClearClick(Sender: TObject);
begin
  Output.Clear;
end;


procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  with CanChannel1 do
  begin
  try
        BusActive := false;
        onBus.Caption := 'Off bus';
        goOnBus.Caption := 'Go on bus';
        CanDevices.Enabled := true;
  except

  end;
        Close;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RunMotor := false;
  try
    CanChannel1 := TCanChannelEx.Create(Self);
  except
     ShowMessage('Error initialisiting, are KVASER drivers installed?');
     Application.Terminate();
  end;
  CanChannel1.Channel := 0;
  CANFail := false;
  RunPDO := false;
  Output.clear;
end;

procedure TMainForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = chr(27) then Close; //  close window on hitting Esc
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  PopulateList;
end;




procedure TMainForm.StartInvClick(Sender: TObject);
var
  openDialog : topendialog;    // Open dialog variable
  F: TFileStream;
begin
  with CanChannel1 do
  begin
    if Active then
    begin
      Output.Items.Add('Putting inverters to ready state?');

      //sendSDO(APPC_id, $4004, 1, 1234);    // disable APPC PDO to take manual control

   //   sendNMT(  NMTOperational, $0 );

      RunPDO := true;
    end;
  end;

end;

procedure TMainForm.RunClick(Sender: TObject);
var
  msg: array[0..7] of byte;
begin
  with CanChannel1 do
  begin
    if Active then
    begin
      Output.Items.Add('Running motors?');
      RunMotor := true;
      SendTime := TStopwatch.StartNew;
    end;
  end;
end;


procedure TMainForm.StopClick(Sender: TObject);
var
  msg: array[0..7] of byte;
begin
  msg[0] := 11;
  with CanChannel1 do
  begin
    if Active then
    begin
      Output.Items.Add('Stopping?');
      RunMotor := false;
     // sendNMT(  NMTStop, $0 );
    end;
  end;
end;


// returns response to send inverter based on current state.
function InverterStateMachine( State, Inverter : Word ) : Word;
var
  TXState : Word ;
begin
	// first check for fault status, and issue reset.

	TXState := 0; // default  do nothing state.
	// process regular state machine sequence
	case GetInverterState(State) of
    OFFLINE :
      begin // state 0: Not ready to switch on, no can message. Internal state only at startup.
			  HighVoltageAllowed[Inverter] := false;  // High Voltage is not allowed
			  TXState := $80; //0b1000 0000; // send bit 128 reset message to enter state 1 in case in fault. - fault reset.
      end;

    BOOTUP :
      begin// State 1: Switch on Disabled.
        HighVoltageAllowed[Inverter] := false;
        TXState := $06;// 0b0000 0110; // send 0110 shutdown message to request move to State 2.
      end;

    STOPPED :
      begin // State 2: Ready to switch on
         // We are ready to turn on, so allow high voltage.
        // we are in state 2, process.
        // process shutdown request here, to move to move to state 1.
        if ( HighVoltageReady ) then
        begin  // TS enable button pressed and both inverters are marked HV ready proceed to state 3.
          HighVoltageAllowed[Inverter] := true;
          TXState := $07; //0b000 0111; // request Switch on message, State 3..
        end else
        begin
          HighVoltageAllowed[Inverter] := false;
          TXState := $06; //0b0000 0110; // no change, continue to request State 2.
        end;
			end;

		  PREOPERATIONAL :
        begin // State 3: Switched on   <---- check this case.
          // we are powered on, so allow high voltage.
          if ( HighVoltageReady ) then // IdleState ) <-
          begin  // TS enable button has been pressed, proceed to request power on if all inverters on.
          HighVoltageAllowed[Inverter] := true;
          TXState := $0F;// 0b0000 1111; // Request Enable operation, State 4.
          end
          else if ( not HighVoltageReady ) then
          begin  // return to switched on state.
          HighVoltageAllowed[Inverter] := false;
          TXState := $06; //0b0000 0110; // 0b00000000; // request Disable Voltage, drop to ready state., alternately Quick Stop 0b00000010
          end
          else
          begin   // no change, continue to request State 3.
          TXState := $07; //0b0000 0111;
          end;
			  end;

		  OPERATIONAL :
        begin// State 4: Operation Enable
			 // we are powered on, so allow high voltage.
    {		if ( CarState.HighVoltageReady ) //  && OperationalState == TSActiveState)
          begin  // no longer in RTDM mode, but still got HV, so drop to idle.
            HighVoltageAllowed = 1;
            TXState = 0b00000111; // request state 3: Switched on.
          end;
          else }
          if ( not HighVoltageReady ) then
          begin  // full motor stop has been requested
            HighVoltageAllowed[Inverter] := false; // drop back to ready to switch on.
            TXState := $06;// 0b0000 0110;//0b00000000; // request Disable Voltage., alternately Quick Stop 0b00000010 - test to see if any difference in behaviour.
          end
          else
          begin  // no change, continue to request operation.
            TXState := $0F;// 0b0000 1111;
            HighVoltageAllowed[Inverter] := true;
          end;
			  end;

	//	case -1 : //5 Quick Stop Active - Fall through to default to reset state.

	//	case -2 : //98 Fault Reason Active

	//	case -99 : //99 Fault

        INERROR:
        begin
          // unknown identifier encountered, ignore. Shouldn't be possible to get here due to filters.
          HighVoltageAllowed[Inverter] := false;
          TXState := $80; //0b1000 0000; // 128
          //TXState = 0b00000000; // 0
        end;
  end;

	//  offset 0 length 32: power
	result := TXState;
end;



// timer to handle inverter PDO's, to keep under the 100ms timeout.
procedure TMainForm.Timer1Timer(Sender: TObject);
var
  vel : LongInt;
  curstate : DeviceStatus;
begin

  if InverterOnline then
  begin
    vel := 0;

    if ( HighVoltageAllowed[1] ) then
    begin

    end;

    curstate := GetInverterState(StatusA);

    // only run the state machine request to state that we currently want.
    // we always want to be at least pre operational unless in error.
    if curstate < PREOPERATIONAL or runmotor then
    begin
      responseA := InverterStateMachine( curstate, 1 );
    end;


    if RunMotor then  // only send a speed value if run has been requested.
       vel := 100;

    // send the actual RDO to satisfy inverter timeout
    sendSpeed(INVA_id, responseA, vel);

    StateA.Caption := TRttiEnumerationType.GetName(GetInverterState(StatusA));
    StateB.Caption := TRttiEnumerationType.GetName(GetInverterState(StatusB));
  end else
  begin
    responseA := 0;
    responseB := 0;
  end;

  end;

end;

procedure TMainForm.sendNMT( state, id : byte );
var
  msg: array[0..7] of byte;
begin
    msg[0] := state;
    msg[1] := id;
    MainForm.Output.Items.Add('NMTSend('+IntToStr(state)+' '+IntToStr(id)+')');
    RunPDO := false;
    MainForm.CanSend($0, msg, 2, 0);
end;



procedure TMainForm.sendSDO(id : byte; idx : word; sub : byte; data : longint);
var
  msg: array[0..7] of byte;
begin
    msg[0] := $22;
    msg[2] := idx shr 8;
    msg[1] := idx;
    msg[3] := sub;
    msg[7] := data shr 24;
    msg[6] := data shr 16;
    msg[5] := data shr 8;
    msg[4] := data;

    MainForm.Output.Items.Add('SDOSend()');
    MainForm.CanSend(SDOTX_id+id, msg, 8, 0);
end;


procedure TMainForm.sendSpeed(id : byte; cmd : word; vel : longint);
var
  msg: array[0..7] of byte;
begin
    msg[0] := cmd shr 8;
    msg[1] := cmd;

    msg[7] := 0; // torque
    msg[6] := 0; // torque

    msg[2] := vel shr 24;    // speed
    msg[3] := vel shr 16;
    msg[4] := vel shr 8;
    msg[5] := vel;

    MainForm.Output.Items.Add('VelSend()');
    MainForm.CanSend(RPDO1_id+id, msg, 8, 0);
end;


procedure TMainForm.sendInv(msg0, msg1, msg2, msg3 : byte );
var
  msg: array[0..7] of byte;
begin
    msg[0] := msg0;
    msg[1] := msg1;
    msg[2] := msg2;
    msg[3] := msg3;
    MainForm.Output.Items.Add('IVTSend('+IntToStr(msg[0] )+','+IntToStr(msg[1] )+','+
                            IntToStr(msg[2] )+','+  IntToStr(msg[3] )+')');
    MainForm.CanSend($411, msg, 8, 0);
end;

procedure TMainForm.CanChannel1CanRx(Sender: TObject);
var
  dlc, flag, time: cardinal;
  msg, msgout: array[0..7] of byte;
  i : integer;
  status : cardinal;
  id: longint;
  formattedDateTime, str : string;
  val1, val2, val3, val4 : longint;
begin
//  Output.Items.BeginUpdate;
  with CanChannel1 do
  begin
    while Read(id, msg, dlc, flag, time) >= 0 do
    begin
      DateTimeToString(formattedDateTime, 'hh:mm:ss.zzzzzz', SysUtils.Now);
      if flag = $20 then
      begin
        Output.Items.Add('Error Frame');
        if Output.TopIndex > Output.Items.Count - 2 then
        Output.TopIndex := Output.Items.Count - 1;

      end
      else
      begin
        for i := 0 to 7 do
        msgout[i] := 0;

        case id of

          TERR_id+INVA_id,  TERR_id+INVB_id,  TERR_id+APPC_id :
          begin
         //   Output.Items.Add('Error received.');
          end;

          //TPDO 1 - actual values from device
          TPDO1_id+INVA_id :
          begin
            val1 :=  msg[0]+msg[1]*256;   // voltage
            val2 :=  msg[2]+msg[3]*256;   // temp


            if val1/16 > turnonV then
                HighVoltageReady := true
            else
                HighVoltageReady := false;


            HVReady.Checked := HighVoltageReady;

            str := FloatToStrF(real(val1)/16, ffFixed, 4,0)+'v '+FloatToStrF(real(val2)/16, ffFixed, 8, 1)+'c';

            if ( id-TPDO1_id = INVA_id) then
              TPDOA1.Caption := str;
          end;

          //TPDO 2 - status from inverter A
          TPDO2_id+INVA_id :
          begin
            // Drive Profile Inverter A statusword
            val1 := msg[0]+msg[1] shl 8;

            StatusA := val1;

            InverterOnline := true;

            // we've seen the inverter on bus, enable the startup button to get to ready to turn on state.
            if not StartInv.Enabled then StartInv.Enabled := true;

            // Inverter A Supervision: latched status 1
            val2 := msg[2]+msg[3] shl 8 + msg[4] shl 16 + msg[5] shl 24;
            // Inverter A Supervision: latched status 2
            val3 := msg[6]+msg[7] shl 8;

            str := IntToStr(val1) + ' ' + IntToStr(val2 ) + ' ' + IntToStr(val3);

            if ( id-TPDO2_id = INVA_id) then
              TPDOA2.Caption := str;
          end;


          TPDO3_id+INVA_id :
          begin
            // Drive Profile Inverter A vl velocity actual value
            val1 := msg[0]+msg[1] shl 8 + msg[2] shl 16 + msg[3] shl 24;
            // tq torque actual value
            val2 := msg[4]+msg[5] shl 8;
            // tq current actual value
            val3 := msg[6]+msg[7] shl 8;
            str := IntToStr(val1) + ' ' + IntToStr(val2 ) + ' ' + IntToStr(val3);

            if ( id-TPDO3_id = INVA_id) then
              TPDOA3.Caption := str;
          end;

          TPDO4_id+INVA_id :
          begin
            // Motor A: Temperature
            val1 := msg[0]+msg[1] shl 8;
            // Motor A: powerActFiltered
            val2 := msg[2]+msg[3] shl 8;
            // Motor A: volSActFiltered
            val3 := msg[4]+msg[5] shl 8;
            // Power Module A: Temperature
            val4 := msg[6]+msg[7] shl 8;

            str := IntToStr(val1) + ' ' + IntToStr(val2 ) + ' ' + IntToStr(val3);

            if ( id-TPDO4_id = INVA_id) then
              TPDOA4.Caption := str;
          end;


          SDORX_id .. SDORX_id+64 :
          begin

             Output.Items.Add('SDO received on id '+IntToStr(id));
          end;

                  { Output.Items.Add('IVTReceive('+ IntToStr(msg[0])+','+IntToStr(msg[1])+','+IntToStr(msg[2])
                      +','+IntToStr(msg[3])+','+ IntToStr(msg[4])+','+IntToStr(msg[5]) +
                      ','+ IntToStr(msg[6])+','+IntToStr(msg[7])
                      +') : ' + formattedDateTime);    }
        end;
      end;
    end;
  end;

end;

end.
