unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, Vcl.StdCtrls,
  Vcl.ExtCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids;

const
  CURL_IBGE = 'https://servicodados.ibge.gov.br/api/v1/localidades/municipios?view=nivelado';

type
  TfrmMain = class(TForm)
    pnlHeader: TPanel;
    lblHeader: TLabel;
    NetHTTPClient: TNetHTTPClient;
    NetHTTPRequest: TNetHTTPRequest;
    btnGerarArquivo: TButton;
    mtIBGE: TFDMemTable;
    mtIBGELOCALIDADE_IBGE: TIntegerField;
    mtIBGELOCALIDADE_NOME: TStringField;
    mtIBGEESTADO_UF: TStringField;
    Label1: TLabel;
    lblTotalRegistros: TLabel;
    Label2: TLabel;
    lblLocalArquivo: TLabel;
    mtIBGEESTADO_IBGE: TIntegerField;
    mtIBGEHASH: TStringField;
    Bevel1: TBevel;
    edtUF: TLabeledEdit;
    edtLocalidade: TLabeledEdit;
    Label3: TLabel;
    Button1: TButton;
    Panel1: TPanel;
    Shape1: TShape;
    Memo1: TMemo;
    Button2: TButton;
    edtHash: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnGerarArquivoClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    function RequestIBGE: IHTTPResponse;
    procedure ParseJSON(const pJSON: string);
    procedure GerarArquivoIBGE;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  System.JSON, System.Generics.Collections, System.Hash, BuscaCEP.Utils;

{$R *.dfm}

{ TfrmMain }

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  edtHash.Text := TBuscaCEPLocalidadesIBGE.Default.GetHashIBGE(edtUF.Text, edtLocalidade.Text);
end;

procedure TfrmMain.Button2Click(Sender: TObject);
var
  lArquivo: string;
  lLocalidade: TBuscaCEPLocalidadeIBGE;
  lLocalidadeStr: string;
begin
  lArquivo := IncludeTrailingPathDelimiter(GetCurrentDir) + 'IBGE.dat';
  if not FileExists(lArquivo) then
    raise Exception.Create('Arquivo não localizado: ' + lArquivo);

  if (Trim(edtHash.Text) = EmptyStr) then
    raise Exception.Create('Hash não calculado!');

  TBuscaCEPLocalidadesIBGE.Default.Processar(lArquivo);
  lLocalidade := TBuscaCEPLocalidadesIBGE.Default.GetLocalidade(edtHash.Text);

  if not Assigned(lLocalidade) then
    raise Exception.Create('Localidade não encontrada.');

  lLocalidadeStr := EmptyStr;
  lLocalidadeStr := Concat(lLocalidadeStr, 'Estado: ', lLocalidade.UF, sLineBreak);
  lLocalidadeStr := Concat(lLocalidadeStr, 'Localidade: ', lLocalidade.Nome, sLineBreak);
  lLocalidadeStr := Concat(lLocalidadeStr, 'IBGE: ', IntToStr(lLocalidade.IBGE), sLineBreak);
  lLocalidadeStr := Concat(lLocalidadeStr, 'Hash: ', lLocalidade.Hash);

  ShowMessage(lLocalidadeStr);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  mtIBGE.CreateDataSet;
end;

procedure TfrmMain.GerarArquivoIBGE;
var
  lFile: TextFile;
  lArquivo: string;
  lTexto: string;
begin
  lArquivo := IncludeTrailingPathDelimiter(GetCurrentDir) + 'IBGE.dat';

  if mtIBGE.IsEmpty then
    Exit;

  AssignFile(lFile, lArquivo);
  try
    Rewrite(lFile);

    lTexto := Format('DATA/HORA GERAÇÃO=%s|TOTAL REGISTROS: %d', [
                     FormatDateTime('dd/mm/yyyy hh:nn:ss', Now),
                     mtIBGE.RecordCount]);
    Writeln(lFile, lTexto);

    mtIBGE.First;
    while not mtIBGE.Eof do
    begin
      // UF|CÓDIGO IBGE|LOCALIDADE|HASH

      lTexto := Format('%s|%s|%s|%s', [mtIBGEESTADO_UF.AsString,
                                       mtIBGELOCALIDADE_IBGE.AsString,
                                       mtIBGELOCALIDADE_NOME.AsString,
                                       mtIBGEHASH.AsString]);
      Writeln(lFile, lTexto);

      mtIBGE.Next;
    end;
  finally
    CloseFile(lFile);
  end;

  if FileExists(lArquivo) then
  begin
    lblLocalArquivo.Caption := lArquivo;
    ShowMessage('Arquivo Gerado!');
  end;
end;

procedure TfrmMain.btnGerarArquivoClick(Sender: TObject);
var
  lResponseIBGE: IHTTPResponse;
begin
  lResponseIBGE := RequestIBGE;
  ParseJSON(lResponseIBGE.ContentAsString);
  GerarArquivoIBGE;
end;

procedure TfrmMain.ParseJSON(const pJSON: string);
var
  I: Integer;
  lJSONValue: TJSONValue;
  lJSONObject: TJSONObject;
  lJSONArray: TJSONArray;
  lUFID: Integer;
  lUFSigla: string;
  lMunicipioID: Integer;
  lMunicipioNome: string;
  lHash: string;
begin
  mtIBGE.Close;
  mtIBGE.CreateDataSet;
  mtIBGE.IndexesActive := False;

  lJSONValue := nil;
  try
    lJSONValue := TJSONObject.ParseJSONValue(pJSON);
    if not Assigned(lJSONValue) then
      raise Exception.Create('JSON IBGE inválido!');

    lJSONArray := (lJSONValue as TJSONArray);
    lblTotalRegistros.Caption := Format('%.3d', [lJSONArray.Count]);

    Application.ProcessMessages;

    for I := 0 to Pred(lJSONArray.Count) do
    begin
      lJSONObject := lJSONArray.Items[I] as TJSONObject;
      lJSONObject.TryGetValue('UF-id', lUFID);
      lJSONObject.TryGetValue('UF-sigla', lUFSigla);
      lJSONObject.TryGetValue('municipio-id', lMunicipioID);
      lJSONObject.TryGetValue('municipio-nome', lMunicipioNome);

      mtIBGE.Append;
      mtIBGEESTADO_IBGE.AsInteger := lUFID;
      mtIBGEESTADO_UF.AsString := lUFSigla;
      mtIBGELOCALIDADE_IBGE.AsInteger := lMunicipioID;
      mtIBGELOCALIDADE_NOME.AsString := lMunicipioNome;
      lHash := TBuscaCEPLocalidadesIBGE.Default.GetHashIBGE(lUFSigla, lMunicipioNome);
      mtIBGEHASH.AsString := lHash;
      mtIBGE.Post;
    end;
  finally
    lJSONValue.Free;
  end;

  mtIBGE.IndexFieldNames := 'ESTADO_IBGE';
  mtIBGE.IndexesActive := True;
end;

function TfrmMain.RequestIBGE: IHTTPResponse;
begin
  NetHTTPRequest.URL := CURL_IBGE;
  NetHTTPRequest.AcceptEncoding := 'gzip, deflate';
  NetHTTPRequest.MethodString := 'GET';

  Result := NetHTTPRequest.Execute()
end;

end.
