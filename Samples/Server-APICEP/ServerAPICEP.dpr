program ServerAPICEP;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Jhonson,
  System.SysUtils,
  Routes in 'Source\Routes.pas';

begin
  THorse.Use(Jhonson());

  {$IFDEF MSWINDOWS}
  IsConsole := False;
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  RegisterRoutes;

  THorse.Listen(9000,
    procedure
    begin
      Writeln('Servidor de Aplicação - BuscaCEP API');
      Writeln(Format('Server is runing on %s:%d', [THorse.Host, THorse.Port]));
      Writeln('');
      Readln;
    end);
end.
