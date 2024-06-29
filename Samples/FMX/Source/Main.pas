unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListBox, FMX.EditBox,
  FMX.NumberBox, FMX.Edit, System.Rtti, FMX.Grid.Style, FMX.ScrollBox, FMX.Grid,
  FMX.Memo, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope;

type
  TfrmMain = class(TForm)
    rctHeader: TRectangle;
    gbxProviders: TGroupBox;
    Label1: TLabel;
    cbxProviders: TComboBox;
    gbxCEP: TGroupBox;
    lblCEP: TLabel;
    edtFiltroCEP: TEdit;
    linCEP: TLine;
    grdLogradouros: TGrid;
    gbxResultadoJSON: TGroupBox;
    mmoResultadoJSON: TMemo;
    memLogradouros: TFDMemTable;
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
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    imgLogo: TImage;
    procedure edtFiltroCEPKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure btnConsultarCEPClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
  System.JSON, BuscaCEP, BuscaCEP.Types, BuscaCEP.Interfaces;

{$R *.fmx}

procedure TfrmMain.FormCreate(Sender: TObject);
var
  lProvider: TBuscaCEPProvidersKind;
begin
  for lProvider := Low(TBuscaCEPProvidersKind) to High(TBuscaCEPProvidersKind) do
    if (lProvider <> TBuscaCEPProvidersKind.UNKNOWN) then
      cbxProviders.Items.AddObject(lProvider.AsString, TObject(lProvider));

  memLogradouros.CreateDataSet;
end;

procedure TfrmMain.edtFiltroCEPKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if not CharInSet(KeyChar, ['-', '0'..'9']) then
    KeyChar := #0;

  if ((KeyChar = '-') AND (edtFiltroCEP.Text.IndexOf('-') > -1)) then
    KeyChar := #0;
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
    ShowMessage('Selecione um provedor para continuar com a consulta!');
    if cbxProviders.CanFocus then
      cbxProviders.SetFocus;
    Exit;
  end;

  lBuscaCEPProvider := TBuscaCEPProvidersKind(cbxProviders.Items.Objects[cbxProviders.ItemIndex]);

  memLogradouros.Close;
  mmoResultadoJSON.Lines.Clear;

  try
    lBuscaCEPResponse := TBuscaCEP.New
      .Providers[lBuscaCEPProvider]
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

      ShowMessage(lMsgError);
      Exit;
    end;
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Exit;
    end;
  end;

  memLogradouros.Close;
  memLogradouros.CreateDataSet;
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

end.
