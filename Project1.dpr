program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Utils in 'Utils.pas',
  Unit2 in 'Unit2.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
