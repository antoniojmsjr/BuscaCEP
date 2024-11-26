program BuscaCEPVCL;

uses
  Vcl.Forms,
  Main in 'Source\Main.pas' {frmMain},
  BuscaCEP.Core in '..\..\Source\BuscaCEP.Core.pas',
  BuscaCEP.Factory in '..\..\Source\BuscaCEP.Factory.pas',
  BuscaCEP.Interfaces in '..\..\Source\BuscaCEP.Interfaces.pas',
  BuscaCEP in '..\..\Source\BuscaCEP.pas',
  BuscaCEP.Providers.ApiCEP in '..\..\Source\BuscaCEP.Providers.ApiCEP.pas',
  BuscaCEP.Providers.Awesomeapi in '..\..\Source\BuscaCEP.Providers.Awesomeapi.pas',
  BuscaCEP.Providers.BrasilAberto in '..\..\Source\BuscaCEP.Providers.BrasilAberto.pas',
  BuscaCEP.Providers.BrasilAPI in '..\..\Source\BuscaCEP.Providers.BrasilAPI.pas',
  BuscaCEP.Providers.CEPAberto in '..\..\Source\BuscaCEP.Providers.CEPAberto.pas',
  BuscaCEP.Providers.CEPCerto in '..\..\Source\BuscaCEP.Providers.CEPCerto.pas',
  BuscaCEP.Providers.CEPLivre in '..\..\Source\BuscaCEP.Providers.CEPLivre.pas',
  BuscaCEP.Providers.Correios in '..\..\Source\BuscaCEP.Providers.Correios.pas',
  BuscaCEP.Providers.Correios.Utils in '..\..\Source\BuscaCEP.Providers.Correios.Utils.pas',
  BuscaCEP.Providers.KingHost in '..\..\Source\BuscaCEP.Providers.KingHost.pas',
  BuscaCEP.Providers.OpenCEP in '..\..\Source\BuscaCEP.Providers.OpenCEP.pas',
  BuscaCEP.Providers.Postmon in '..\..\Source\BuscaCEP.Providers.Postmon.pas',
  BuscaCEP.Providers.RepublicaVirtual in '..\..\Source\BuscaCEP.Providers.RepublicaVirtual.pas',
  BuscaCEP.Providers.ViaCEP in '..\..\Source\BuscaCEP.Providers.ViaCEP.pas',
  BuscaCEP.Types in '..\..\Source\BuscaCEP.Types.pas',
  BuscaCEP.Utils in '..\..\Source\BuscaCEP.Utils.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Busca CEP - VCL';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
