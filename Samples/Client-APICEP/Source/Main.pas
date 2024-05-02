unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Mask, System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent;

type
  TfrmMain = class(TForm)
    pnlHeader: TPanel;
    lblHeader: TLabel;
    gbxEndereco: TGroupBox;
    Label1: TLabel;
    edtFiltroCEP: TMaskEdit;
    btnConsultarCEP: TButton;
    Bevel1: TBevel;
    edtLogradouro: TLabeledEdit;
    edtNumero: TLabeledEdit;
    edtComplemento: TLabeledEdit;
    edtBairro: TLabeledEdit;
    edtLocalidade: TLabeledEdit;
    edtLocalidadeIBGE: TLabeledEdit;
    edtEstado: TLabeledEdit;
    gbxResultadoJSON: TGroupBox;
    mmoResultadoJSON: TMemo;
    edtEstadoIBGE: TLabeledEdit;
    NetHTTPClient: TNetHTTPClient;
    NetHTTPRequest: TNetHTTPRequest;
    gbxIdentificacaoAPI: TGroupBox;
    Label2: TLabel;
    edtAPIHost: TEdit;
    Label3: TLabel;
    edtAPIPort: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    btnConsultarLogradouro: TButton;
    edtFiltroLogradouro: TEdit;
    edtFiltroLocalidade: TEdit;
    edtFiltroUF: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnConsultarCEPClick(Sender: TObject);
    procedure btnConsultarLogradouroClick(Sender: TObject);
  private
    { Private declarations }
    function GetResponse(pHTTPResponse: IHTTPResponse): string;
    function ConsultarCEP(const pCEP: string): string;
    function ConsultarLogradouro(const pUF: string;
                                 const pLocalidade: string;
                                 const pLogradouro: string): string;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  System.Types, System.JSON, SelecionarLogradouro, Utils;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
var
  lRect: TRectF;
begin
  lRect := TRectF.Create(Screen.WorkAreaRect.TopLeft, Screen.WorkAreaRect.Width,
                         Screen.WorkAreaRect.Height);
  SetBounds(Round(lRect.Left + (lRect.Width - Width) / 2),
            0,
            Width,
            Screen.WorkAreaRect.Height);
end;

procedure TfrmMain.btnConsultarCEPClick(Sender: TObject);
var
  lJSONLogradouros: string;
  lJSONLogradouro: string;
  lJSONObject: TJSONObject;
  lLogradouroAPI: TLogradouroAPI;
begin
  // CONSULTA NO SERVIDOR DE APLICA플O - BUSCACEP API
  lJSONLogradouros := ConsultarCEP(edtFiltroCEP.Text);

  if (lJSONLogradouros =  EmptyStr) then
    Exit;

  // SELECIONAR LOGRADOURO
  TfrmSelecionarLogradouro.GetLogradouro(Self, lJSONLogradouros, lJSONLogradouro);

  lJSONObject := nil;
  try
    lJSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(lJSONLogradouro), 0) as TJSONObject;
    if not Assigned(lJSONObject) then
      Exit;

    mmoResultadoJSON.Text := lJSONObject.Format(2);
  finally
    lJSONObject.Free;
  end;

  lLogradouroAPI := ProcessarJSONLogradouroAPI(lJSONLogradouro);
  if not Assigned(lLogradouroAPI) then
    Exit;

  try
    edtLogradouro.Text := lLogradouroAPI.Logradouro;
    edtBairro.Text := lLogradouroAPI.Bairro;
    edtLocalidade.Text := lLogradouroAPI.Localidade;
    edtLocalidadeIBGE.Text := IntToStr(lLogradouroAPI.LocalidadeIBGE);
    edtEstado.Text := lLogradouroAPI.Estado;
    edtEstadoIBGE.Text := IntToStr(lLogradouroAPI.EstadoIBGE);
  finally
    lLogradouroAPI.Free;
  end;
end;

procedure TfrmMain.btnConsultarLogradouroClick(Sender: TObject);
var
  lJSONLogradouros: string;
  lJSONLogradouro: string;
  lJSONObject: TJSONObject;
  lLogradouroAPI: TLogradouroAPI;
begin
  // CONSULTA NO SERVIDOR DE APLICA플O - BUSCACEP API
  lJSONLogradouros := ConsultarLogradouro(edtFiltroUF.Text, edtFiltroLocalidade.Text, edtFiltroLogradouro.Text);

  if (lJSONLogradouros =  EmptyStr) then
    Exit;

  // SELECIONAR LOGRADOURO
  TfrmSelecionarLogradouro.GetLogradouro(Self, lJSONLogradouros, lJSONLogradouro);

  lJSONObject := nil;
  try
    lJSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(lJSONLogradouro), 0) as TJSONObject;
    if not Assigned(lJSONObject) then
      Exit;

    mmoResultadoJSON.Text := lJSONObject.Format(2);
  finally
    lJSONObject.Free;
  end;

  lLogradouroAPI := ProcessarJSONLogradouroAPI(lJSONLogradouro);
  if not Assigned(lLogradouroAPI) then
    Exit;

  try
    edtLogradouro.Text := lLogradouroAPI.Logradouro;
    edtBairro.Text := lLogradouroAPI.Bairro;
    edtLocalidade.Text := lLogradouroAPI.Localidade;
    edtLocalidadeIBGE.Text := IntToStr(lLogradouroAPI.LocalidadeIBGE);
    edtEstado.Text := lLogradouroAPI.Estado;
    edtEstadoIBGE.Text := IntToStr(lLogradouroAPI.EstadoIBGE);
  finally
    lLogradouroAPI.Free;
  end;
end;

function TfrmMain.ConsultarCEP(const pCEP: string): string;
var
  lURL: TURI;
  lHTTPResponse: IHTTPResponse;
begin
  NetHTTPRequest.Client.SecureProtocols := [];
  NetHTTPRequest.Client.SecureProtocols := [THTTPSecureProtocol.TLS1,
                                            THTTPSecureProtocol.TLS11,
                                            THTTPSecureProtocol.TLS12];

  // CONFORME A DOCUMENTA플O DA API
  lURL := TURI.Create(Format('%s:%s/logradouros?cep=%s', [
                      edtAPIHost.Text,
                      edtAPIPort.Text,
                      pCEP]));

  NetHTTPRequest.URL := lURL.ToString;
  NetHTTPRequest.MethodString := 'GET';
  NetHTTPRequest.Client.Accept := '*/*';
  NetHTTPRequest.Client.UserAgent := 'Client - API CEP';

  // REQUISI플O
  try
    lHTTPResponse := NetHTTPRequest.Execute();
  except
    on E: ENetHTTPClientException do
    begin
      raise Exception.Create('Erro HTTP: ' + E.Message);
    end;
    on E: Exception do
      raise Exception.Create(E.Message);
  end;

  Result := Trim(GetResponse(lHTTPResponse));
end;

function TfrmMain.ConsultarLogradouro(const pUF: string;
  const pLocalidade: string; const pLogradouro: string): string;
var
  lURL: TURI;
  lHTTPResponse: IHTTPResponse;
begin
  NetHTTPRequest.Client.SecureProtocols := [];
  NetHTTPRequest.Client.SecureProtocols := [THTTPSecureProtocol.TLS1,
                                            THTTPSecureProtocol.TLS11,
                                            THTTPSecureProtocol.TLS12];

  // CONFORME A DOCUMENTA플O DA API
  lURL := TURI.Create(Format('%s:%s/logradouros?uf=%s&localidade=%s&logradouro=%s', [
                      edtAPIHost.Text,
                      edtAPIPort.Text,
                      pUF, pLocalidade, pLogradouro]));

  NetHTTPRequest.URL := lURL.ToString;
  NetHTTPRequest.MethodString := 'GET';
  NetHTTPRequest.Client.Accept := '*/*';
  NetHTTPRequest.Client.UserAgent := 'Client - API CEP';

  // REQUISI플O
  try
    lHTTPResponse := NetHTTPRequest.Execute();
  except
    on E: ENetHTTPClientException do
    begin
      raise Exception.Create('Erro HTTP: ' + E.Message);
    end;
    on E: Exception do
      raise Exception.Create(E.Message);
  end;

  Result := Trim(GetResponse(lHTTPResponse));
end;

function TfrmMain.GetResponse(pHTTPResponse: IHTTPResponse): string;
var
  lJSONObject: TJSONObject;
  lMessage: string;
begin
  case pHTTPResponse.StatusCode of
    200:
    begin
      Result := pHTTPResponse.ContentAsString;
    end;
  else
  begin
    lJSONObject := nil;
    try
      lJSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(pHTTPResponse.ContentAsString), 0) as TJSONObject;
      if not Assigned(lJSONObject) then
        raise Exception.Create(pHTTPResponse.ContentAsString);

      if lJSONObject.TryGetValue('message', lMessage) then
        raise Exception.CreateFmt('Status code: %d - %s', [pHTTPResponse.StatusCode, lMessage]);
    finally
      lJSONObject.Free;
    end;
  end;
  end;
end;

end.
