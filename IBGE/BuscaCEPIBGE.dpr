program BuscaCEPIBGE;

uses
  Vcl.Forms,
  Main in 'Main.pas' {frmMain};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'BuscaCEP - Gerar Arquivo IBGE';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
