unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Unit1, StdCtrls, ComCtrls, ExtCtrls;

type
  TForm2 = class(TForm)
    ComboBox1: TComboBox;
    TrackBar1: TTrackBar;
    Button1: TButton;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
  public
    Initial_device_mode:TDeviceMode;
    Id_Timer,Id_Initial_device_mode:integer;
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
const
  vitesses:array[0..1,0..5] of single=((50000,100000,200000,300000,450000,600000),(40000,50000,60000,70000,90000,200000));
begin
  if combobox2.itemindex<>Id_Initial_device_mode then begin
    ShowWindow(FindWindow('Shell_TrayWnd',nil),SW_HIDE);
    ChangeDisplaySettings(pdevicemode(combobox2.Items.objects[combobox2.itemindex])^,CDS_UPDATEREGISTRY);
    ShowWindow(FindWindow('Shell_TrayWnd',nil),SW_RESTORE);
  end;
  application.ProcessMessages;
  Application.CreateForm(TForm1,Form1);
  form1.Show;
  form1.Blend:=TrackBar1.Position/TrackBar1.Max;
  form1.MaxH:=combobox1.ItemIndex+1;
  form1.Dv:=vitesses[0,combobox3.ItemIndex];
  form1.DeltaV:=vitesses[1,combobox3.ItemIndex];
  form1.MainLoop;
  if combobox2.itemindex<>Id_Initial_device_mode then begin
    ShowWindow(FindWindow('Shell_TrayWnd',nil),SW_HIDE);
    ChangeDisplaySettings(initial_device_mode,CDS_UPDATEREGISTRY);
    ShowWindow(FindWindow('Shell_TrayWnd',nil),SW_RESTORE);
  end;
  showmessage('BOOM!!!'#13'Score: '+inttostr(Score));
end;

procedure TForm2.FormCreate(Sender: TObject);
var
  d:TDevicemode;
  p:^TDeviceMode;
  a,n:integer;
begin
  Id_Timer:=1;
  n:=0;
  while EnumDisplaySettings(nil,n,d) do begin
    new(p);
    p^:=d;
    a:=combobox2.items.AddObject(inttostr(d.dmPelsWidth)+'x'+inttostr(d.dmPelsheight)+'@'+inttostr(d.dmBitsPerPel),TObject(p));
    {$WARNINGS OFF}
    if (d.dmPelsWidth=screen.width) and (d.dmPelsheight=screen.height) and (d.dmbitsperpel=GetDeviceCaps(form2.canvas.handle,BITSPIXEL)) then begin
      combobox2.ItemIndex:=a;
      initial_device_mode:=d;
      id_initial_device_mode:=a;
    end;
    {$WARNINGS ON}
    inc(n);
  end;
end;

procedure TForm2.Timer1Timer(Sender: TObject);
const
  s1:string='GL-CHUTE';
  s2:string='gl-chute';
begin
  caption:=copy(s2,1,Id_Timer-1)+copy(s1,Id_Timer,1)+copy(s2,Id_Timer+1,8-Id_Timer);
  inc(Id_Timer);
  if Id_Timer=9 then Id_Timer:=1;
end;

end.
