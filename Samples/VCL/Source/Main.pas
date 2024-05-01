unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Mask, Data.DB, Datasnap.DBClient, Vcl.Grids, Vcl.DBGrids,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent;

type
  TfrmMain = class(TForm)
    pnlHeader: TPanel;
    lblHeader: TLabel;
    gbxBuscaCEP: TGroupBox;
    Label1: TLabel;
    Bevel1: TBevel;
    edtBuscaCEP: TMaskEdit;
    btnBuscaCEPConsultarCEP: TButton;
    dbgBuscaCEP: TDBGrid;
    cdsBuscaCEPLogradouros: TClientDataSet;
    dsBuscaCEPLogradouros: TDataSource;
    cdsBuscaCEPLogradourosLOGRADOURO: TStringField;
    cdsBuscaCEPLogradourosCOMPLEMENTO: TStringField;
    cdsBuscaCEPLogradourosBAIRRO: TStringField;
    cdsBuscaCEPLogradourosLOCALIDADE: TStringField;
    cdsBuscaCEPLogradourosLOCALIDADE_IBGE: TIntegerField;
    cdsBuscaCEPLogradourosESTADO: TStringField;
    cdsBuscaCEPLogradourosESTADO_IBGE: TIntegerField;
    cdsBuscaCEPLogradourosREGIAO: TStringField;
    cdsBuscaCEPLogradourosREGIAO_IBGE: TIntegerField;
    cdsBuscaCEPLogradourosCEP: TStringField;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Bevel2: TBevel;
    btnBuscaCEPConsultarLogradouro: TButton;
    GroupBox2: TGroupBox;
    edtBuscaCEPLogradouro: TEdit;
    Label3: TLabel;
    edtBuscaCEPLocalidade: TEdit;
    Label4: TLabel;
    edtBuscaCEPUF: TEdit;
    Label5: TLabel;
    cbxProviders: TComboBox;
    GroupBox3: TGroupBox;
    mmoResultadoJSON: TMemo;
    dbgBuscaCEPLogradouro: TDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnBuscaCEPConsultarCEPClick(Sender: TObject);
    procedure btnBuscaCEPConsultarLogradouroClick(Sender: TObject);
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
  System.Types, System.JSON, BuscaCEP, BuscaCEP.Types, BuscaCEP.Interfaces;

{$R *.dfm}

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

  for lProvider := Low(TBuscaCEPProvidersKind) to High(TBuscaCEPProvidersKind) do
    if (lProvider <> TBuscaCEPProvidersKind.UNKNOWN) then
      cbxProviders.Items.AddObject(lProvider.AsString, TObject(lProvider));

  cdsBuscaCEPLogradouros.CreateDataSet;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  if (Self.Width < 700) then
  begin
    Self.Width := 700;
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

procedure TfrmMain.btnBuscaCEPConsultarCEPClick(Sender: TObject);
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

  cdsBuscaCEPLogradouros.Close;
  dbgBuscaCEP.DataSource := dsBuscaCEPLogradouros;
  dbgBuscaCEPLogradouro.DataSource := nil;
  mmoResultadoJSON.Clear;

  try
    lBuscaCEPResponse := TBuscaCEP.New
      .Providers[lBuscaCEPProvider]
        .Filtro
          .SetCEP(edtBuscaCEP.Text)
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

  cdsBuscaCEPLogradouros.Close;
  cdsBuscaCEPLogradouros.CreateDataSet;
  for lBuscaCEPLogradouro in lBuscaCEPResponse.Logradouros do
  begin
    cdsBuscaCEPLogradouros.Append;
    cdsBuscaCEPLogradourosLOGRADOURO.AsString := lBuscaCEPLogradouro.Logradouro;
    cdsBuscaCEPLogradourosCOMPLEMENTO.AsString := lBuscaCEPLogradouro.Complemento;
    cdsBuscaCEPLogradourosBAIRRO.AsString := lBuscaCEPLogradouro.Bairro;
    cdsBuscaCEPLogradourosLOCALIDADE.AsString := lBuscaCEPLogradouro.Localidade.Nome;
    cdsBuscaCEPLogradourosLOCALIDADE_IBGE.AsInteger := lBuscaCEPLogradouro.Localidade.IBGE;
    cdsBuscaCEPLogradourosESTADO.AsString := lBuscaCEPLogradouro.Localidade.Estado.Nome;
    cdsBuscaCEPLogradourosESTADO_IBGE.AsInteger := lBuscaCEPLogradouro.Localidade.Estado.IBGE;
    cdsBuscaCEPLogradourosREGIAO.AsString := lBuscaCEPLogradouro.Localidade.Estado.Regiao.Nome;
    cdsBuscaCEPLogradourosREGIAO_IBGE.AsInteger := lBuscaCEPLogradouro.Localidade.Estado.Regiao.IBGE;
    cdsBuscaCEPLogradourosCEP.AsString := lBuscaCEPLogradouro.CEP;
    cdsBuscaCEPLogradouros.Post;
  end;

  mmoResultadoJSON.Text := GetBuscaCEPJSON(lBuscaCEPResponse.ToJSONString);
end;

procedure TfrmMain.btnBuscaCEPConsultarLogradouroClick(Sender: TObject);
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

  cdsBuscaCEPLogradouros.Close;
  dbgBuscaCEP.DataSource := nil;
  dbgBuscaCEPLogradouro.DataSource := dsBuscaCEPLogradouros;
  mmoResultadoJSON.Clear;

  try
    lBuscaCEPResponse := TBuscaCEP.New
      .Providers[lBuscaCEPProvider]
        .Filtro
          .SetLogradouro(edtBuscaCEPLogradouro.Text)
          .SetLocalidade(edtBuscaCEPLocalidade.Text)
          .SetUF(edtBuscaCEPUF.Text)
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

  cdsBuscaCEPLogradouros.Close;
  cdsBuscaCEPLogradouros.CreateDataSet;
  for lBuscaCEPLogradouro in lBuscaCEPResponse.Logradouros do
  begin
    cdsBuscaCEPLogradouros.Append;
    cdsBuscaCEPLogradourosLOGRADOURO.AsString := lBuscaCEPLogradouro.Logradouro;
    cdsBuscaCEPLogradourosCOMPLEMENTO.AsString := lBuscaCEPLogradouro.Complemento;
    cdsBuscaCEPLogradourosBAIRRO.AsString := lBuscaCEPLogradouro.Bairro;
    cdsBuscaCEPLogradourosLOCALIDADE.AsString := lBuscaCEPLogradouro.Localidade.Nome;
    cdsBuscaCEPLogradourosLOCALIDADE_IBGE.AsInteger := lBuscaCEPLogradouro.Localidade.IBGE;
    cdsBuscaCEPLogradourosESTADO.AsString := lBuscaCEPLogradouro.Localidade.Estado.Nome;
    cdsBuscaCEPLogradourosESTADO_IBGE.AsInteger := lBuscaCEPLogradouro.Localidade.Estado.IBGE;
    cdsBuscaCEPLogradourosREGIAO.AsString := lBuscaCEPLogradouro.Localidade.Estado.Regiao.Nome;
    cdsBuscaCEPLogradourosREGIAO_IBGE.AsInteger := lBuscaCEPLogradouro.Localidade.Estado.Regiao.IBGE;
    cdsBuscaCEPLogradourosCEP.AsString := lBuscaCEPLogradouro.CEP;
    cdsBuscaCEPLogradouros.Post;
  end;

  mmoResultadoJSON.Text := GetBuscaCEPJSON(lBuscaCEPResponse.ToJSONString);
end;

end.
