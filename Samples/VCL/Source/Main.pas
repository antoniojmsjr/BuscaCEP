unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Mask, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids,
  Vcl.Imaging.pngimage;

type
  TfrmMain = class(TForm)
    pnlHeader: TPanel;
    gbxCEP: TGroupBox;
    lblCEP: TLabel;
    edtFiltroCEP: TMaskEdit;
    btnConsultarCEP: TButton;
    dsLogradouros: TDataSource;
    memLogradourosLOGRADOURO: TStringField;
    memLogradourosCOMPLEMENTO: TStringField;
    memLogradourosBAIRRO: TStringField;
    memLogradourosLOCALIDADE: TStringField;
    memLogradourosLOCALIDADE_IBGE: TIntegerField;
    memLogradourosESTADO: TStringField;
    memLogradourosESTADO_IBGE: TIntegerField;
    memLogradourosREGIAO: TStringField;
    memLogradourosREGIAO_IBGE: TIntegerField;
    memLogradourosCEP: TStringField;
    gbxLogradouro: TGroupBox;
    Label2: TLabel;
    btnConsultarLogradouro: TButton;
    gbxProviders: TGroupBox;
    edtFiltroLogradouro: TEdit;
    Label3: TLabel;
    edtFiltroLocalidade: TEdit;
    Label4: TLabel;
    edtFiltroUF: TEdit;
    Label5: TLabel;
    cbxProviders: TComboBox;
    gbxResultadoJSON: TGroupBox;
    mmoResultadoJSON: TMemo;
    memLogradouros: TFDMemTable;
    Label1: TLabel;
    edtAPIKey: TEdit;
    GroupBox1: TGroupBox;
    dbgLogradouros: TDBGrid;
    imgLogo: TImage;
    pnlApp: TPanel;
    lblAppName: TLinkLabel;
    lblAppSite: TLinkLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnConsultarCEPClick(Sender: TObject);
    procedure btnConsultarLogradouroClick(Sender: TObject);
    procedure lblAppSiteLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
  private
    { Private declarations }
    function GetBuscaCEPJSON(const pJSON: string): string;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  System.Types, System.JSON, Winapi.ShellApi, BuscaCEP, BuscaCEP.Types, BuscaCEP.Interfaces;

{$R *.dfm}
{$I BuscaCEP.inc}

procedure TfrmMain.FormCreate(Sender: TObject);
var
  lRect: TRectF;
  lProvider: TBuscaCEPProvidersKind;
begin
  lRect := TRectF.Create(Screen.WorkAreaRect.TopLeft, Screen.WorkAreaRect.Width,
                         Screen.WorkAreaRect.Height);
  SetBounds(Round(lRect.Left + (lRect.Width - Width) / 2),
            0,
            Width,
            Screen.WorkAreaRect.Height);

  lblAppName.Caption := Format('BuscaCEP v%s', [BuscaCEPVersion]);
  lblAppSite.Caption := '<a href="https://github.com/antoniojmsjr/BuscaCEP">https://github.com/antoniojmsjr/BuscaCEP</a>';


  for lProvider := Low(TBuscaCEPProvidersKind) to High(TBuscaCEPProvidersKind) do
    if (lProvider <> TBuscaCEPProvidersKind.UNKNOWN) then
      cbxProviders.Items.AddObject(lProvider.AsString, TObject(lProvider));

  memLogradouros.CreateDataSet;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  if (Self.Width < 740) then
  begin
    Self.Width := 740;
    Abort;
  end;
end;

function TfrmMain.GetBuscaCEPJSON(const pJSON: string): string;
var
  lJSONObject: TJSONObject;
begin
  lJSONObject := TJSONObject.ParseJSONValue(pJSON) as TJSONObject;
  try
    Result := lJSONObject.Format(2);
  finally
    lJSONObject.Free;
  end;
end;

procedure TfrmMain.lblAppSiteLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  ShellExecute(0, nil, PChar(Link), nil, nil, 1);
end;

procedure TfrmMain.btnConsultarCEPClick(Sender: TObject);
var
  lBuscaCEPResponse: IBuscaCEPResponse;
  lBuscaCEPLogradouro: TBuscaCEPLogradouro;
  lMsgError: string;
  lBuscaCEPProvider: TBuscaCEPProvidersKind;
begin

  if (cbxProviders.ItemIndex = -1) then
  begin
    Application.MessageBox(PWideChar('Selecione um provedor para continuar com a consulta!'), 'A T E N Ç Ã O', MB_OK + MB_ICONWARNING);
    if cbxProviders.CanFocus then
      cbxProviders.SetFocus;
    Exit;
  end;

  lBuscaCEPProvider := TBuscaCEPProvidersKind(cbxProviders.Items.Objects[cbxProviders.ItemIndex]);

  memLogradouros.Close;
  memLogradouros.Open;
  mmoResultadoJSON.Clear;

  try
    lBuscaCEPResponse := TBuscaCEP.New
      .Providers[lBuscaCEPProvider]
        .SetAPIKey(edtAPIKey.Text)
        .Filtro
          .SetCEP(edtFiltroCEP.Text)
        .Request
          .SetTimeout(1000)
          .Execute;
  except
    on E: EBuscaCEPRequest do
    begin
      lMsgError := Concat(lMsgError, Format('Provider: %s', [E.Provider]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('DateTime: %s', [DateTimeTostr(E.DateTime)]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Kind: %s', [E.Kind.AsString]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('URL: %s', [E.URL]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Method: %s', [E.Method]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Status Code: %d', [E.StatusCode]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Status Text: %s', [E.StatusText]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Message: %s', [E.Message]));

      Application.MessageBox(PWideChar(lMsgError), 'A T E N Ç Ã O', MB_OK + MB_ICONERROR);
      Exit;
    end;
    on E: Exception do
    begin
      Application.MessageBox(PWideChar(E.Message), 'A T E N Ç Ã O', MB_OK + MB_ICONERROR);
      Exit;
    end;
  end;

  for lBuscaCEPLogradouro in lBuscaCEPResponse.Logradouros do
  begin
    memLogradouros.Append;
    memLogradourosLOGRADOURO.AsString := lBuscaCEPLogradouro.Logradouro;
    memLogradourosCOMPLEMENTO.AsString := lBuscaCEPLogradouro.Complemento;
    memLogradourosBAIRRO.AsString := lBuscaCEPLogradouro.Bairro;
    memLogradourosLOCALIDADE.AsString := lBuscaCEPLogradouro.Localidade.Nome;
    memLogradourosLOCALIDADE_IBGE.AsInteger := lBuscaCEPLogradouro.Localidade.IBGE;
    memLogradourosESTADO.AsString := lBuscaCEPLogradouro.Localidade.Estado.Nome;
    memLogradourosESTADO_IBGE.AsInteger := lBuscaCEPLogradouro.Localidade.Estado.IBGE;
    memLogradourosREGIAO.AsString := lBuscaCEPLogradouro.Localidade.Estado.Regiao.Nome;
    memLogradourosREGIAO_IBGE.AsInteger := lBuscaCEPLogradouro.Localidade.Estado.Regiao.IBGE;
    memLogradourosCEP.AsString := lBuscaCEPLogradouro.CEP;
    memLogradouros.Post;
  end;

  mmoResultadoJSON.Text := GetBuscaCEPJSON(lBuscaCEPResponse.ToJSONString);
end;

procedure TfrmMain.btnConsultarLogradouroClick(Sender: TObject);
var
  lBuscaCEPResponse: IBuscaCEPResponse;
  lBuscaCEPLogradouro: TBuscaCEPLogradouro;
  lMsgError: string;
  lBuscaCEPProvider: TBuscaCEPProvidersKind;
begin
  if (cbxProviders.ItemIndex = -1) then
  begin
    Application.MessageBox(PWideChar('Selecione um provedor para continuar com a consulta!'), 'A T E N Ç Ã O', MB_OK + MB_ICONWARNING);
    if cbxProviders.CanFocus then
      cbxProviders.SetFocus;
    Exit;
  end;

  lBuscaCEPProvider := TBuscaCEPProvidersKind(cbxProviders.Items.Objects[cbxProviders.ItemIndex]);

  memLogradouros.Close;
  memLogradouros.Open;
  mmoResultadoJSON.Clear;

  try
    lBuscaCEPResponse := TBuscaCEP.New
      .Providers[lBuscaCEPProvider]
        .SetAPIKey(edtAPIKey.Text)
        .Filtro
          .SetLogradouro(edtFiltroLogradouro.Text)
          .SetLocalidade(edtFiltroLocalidade.Text)
          .SetUF(edtFiltroUF.Text)
        .&End
        .Request
          .SetTimeout(1000)
          .Execute;
  except
    on E: EBuscaCEPRequest do
    begin
      lMsgError := Concat(lMsgError, Format('Provider: %s', [E.Provider]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('DateTime: %s', [DateTimeTostr(E.DateTime)]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Kind: %s', [E.Kind.AsString]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('URL: %s', [E.URL]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Method: %s', [E.Method]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Status Code: %d', [E.StatusCode]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Status Text: %s', [E.StatusText]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Message: %s', [E.Message]));

      Application.MessageBox(PWideChar(lMsgError), 'A T E N Ç Ã O', MB_OK + MB_ICONERROR);
      Exit;
    end;
    on E: Exception do
    begin
      Application.MessageBox(PWideChar(E.Message), 'A T E N Ç Ã O', MB_OK + MB_ICONERROR);
      Exit;
    end;
  end;

  for lBuscaCEPLogradouro in lBuscaCEPResponse.Logradouros do
  begin
    memLogradouros.Append;
    memLogradourosLOGRADOURO.AsString := lBuscaCEPLogradouro.Logradouro;
    memLogradourosCOMPLEMENTO.AsString := lBuscaCEPLogradouro.Complemento;
    memLogradourosBAIRRO.AsString := lBuscaCEPLogradouro.Bairro;
    memLogradourosLOCALIDADE.AsString := lBuscaCEPLogradouro.Localidade.Nome;
    memLogradourosLOCALIDADE_IBGE.AsInteger := lBuscaCEPLogradouro.Localidade.IBGE;
    memLogradourosESTADO.AsString := lBuscaCEPLogradouro.Localidade.Estado.Nome;
    memLogradourosESTADO_IBGE.AsInteger := lBuscaCEPLogradouro.Localidade.Estado.IBGE;
    memLogradourosREGIAO.AsString := lBuscaCEPLogradouro.Localidade.Estado.Regiao.Nome;
    memLogradourosREGIAO_IBGE.AsInteger := lBuscaCEPLogradouro.Localidade.Estado.Regiao.IBGE;
    memLogradourosCEP.AsString := lBuscaCEPLogradouro.CEP;
    memLogradouros.Post;
  end;

  mmoResultadoJSON.Text := GetBuscaCEPJSON(lBuscaCEPResponse.ToJSONString);
end;

end.
