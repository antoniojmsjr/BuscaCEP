program ClientAPICEP;

uses
  Vcl.Forms,
  SelecionarLogradouro in 'Source\SelecionarLogradouro.pas' {frmSelecionarLogradouro},
  Main in 'Source\Main.pas' {frmMain},
  Utils in 'Source\Utils.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
