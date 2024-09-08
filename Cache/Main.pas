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
  CURL_DDD = 'https://www.anatel.gov.br/dadosabertos/PDA/Codigo_Nacional/PGCN.csv';

type
  TfrmMain = class(TForm)
    pnlHeader: TPanel;
    lblHeader: TLabel;
    NetHTTPClient: TNetHTTPClient;
    NetHTTPRequest: TNetHTTPRequest;
    mtCache: TFDMemTable;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    lblIBGETotalRegistros: TLabel;
    Label4: TLabel;
    lblDDDTotalRegistros: TLabel;
    btnGerarArquivo: TButton;
    Bevel1: TBevel;
    mtCacheUF_IBGE: TIntegerField;
    mtCacheUF_SIGLA: TStringField;
    mtCacheLOCALIDADE_IBGE: TIntegerField;
    mtCacheLOCALIDADE_NOME: TStringField;
    mtCacheDDD: TIntegerField;
    mtCacheHASH: TStringField;
    lblArquivoCache: TLabel;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    edtUF: TLabeledEdit;
    edtLocalidade: TLabeledEdit;
    Button1: TButton;
    Button2: TButton;
    edtHash: TLabeledEdit;
    Panel1: TPanel;
    Shape1: TShape;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure btnGerarArquivoClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    function RequestIBGE: IHTTPResponse;
    function RequestDDD: IHTTPResponse;
    procedure ParseIBGE(const pContent: string);
    procedure ParseDDD(const pContent: string);
    procedure GerarArquivoCache;
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

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  mtCache.CreateDataSet;
end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  edtHash.Text := TBuscaCEPCache.Default.GetHash(edtUF.Text, edtLocalidade.Text);
end;

procedure TfrmMain.Button2Click(Sender: TObject);
var
  lArquivo: string;
  lLocalidade: TBuscaCEPCacheLocalidade;
  lLocalidadeStr: string;
begin
  lArquivo := IncludeTrailingPathDelimiter(GetCurrentDir) + 'BuscaCEP.dat';
  if not FileExists(lArquivo) then
    raise Exception.Create('Arquivo não localizado: ' + lArquivo);

  if (Trim(edtHash.Text) = EmptyStr) then
  begin
    Button1.SetFocus;
    raise Exception.Create('Hash não calculado!');
  end;

  TBuscaCEPCache.Default.Processar(lArquivo);
  lLocalidade := TBuscaCEPCache.Default.GetLocalidade(edtHash.Text);

  if not Assigned(lLocalidade) then
    raise Exception.Create('Localidade não encontrada.');

  lLocalidadeStr := EmptyStr;
  lLocalidadeStr := Concat(lLocalidadeStr, 'Estado: ', lLocalidade.UF, sLineBreak);
  lLocalidadeStr := Concat(lLocalidadeStr, 'Localidade: ', lLocalidade.Nome, sLineBreak);
  lLocalidadeStr := Concat(lLocalidadeStr, 'DDD: ', IntToStr(lLocalidade.DDD), sLineBreak);
  lLocalidadeStr := Concat(lLocalidadeStr, 'IBGE: ', IntToStr(lLocalidade.IBGE), sLineBreak);
  lLocalidadeStr := Concat(lLocalidadeStr, 'Hash: ', lLocalidade.Hash);

  ShowMessage(lLocalidadeStr);
end;

procedure TfrmMain.GerarArquivoCache;
var
  lFile: TextFile;
  lArquivo: string;
  lTexto: string;
begin
  lArquivo := IncludeTrailingPathDelimiter(GetCurrentDir) + 'BuscaCEP.dat';

  if mtCache.IsEmpty then
    Exit;

  AssignFile(lFile, lArquivo);
  try
    Rewrite(lFile);

    lTexto := Format('DATA/HORA GERAÇÃO=%s|TOTAL REGISTROS: %d', [
                     FormatDateTime('dd/mm/yyyy hh:nn:ss', Now),
                     mtCache.RecordCount]);
    Writeln(lFile, lTexto);

    mtCache.First;
    while not mtCache.Eof do
    begin
      // UF|DDD|CÓDIGO IBGE|LOCALIDADE|HASH

      lTexto := Format('%s|%s|%s|%s|%s', [mtCacheUF_SIGLA.AsString,
                                          Format('%.3d', [mtCacheDDD.AsInteger]),
                                          mtCacheLOCALIDADE_IBGE.AsString,
                                          mtCacheLOCALIDADE_NOME.AsString,
                                          mtCacheHASH.AsString]);
      Writeln(lFile, lTexto);

      mtCache.Next;
    end;
  finally
    CloseFile(lFile);
  end;

  if FileExists(lArquivo) then
  begin
    lblArquivoCache.Caption := lArquivo;
    ShowMessage('Arquivo Gerado!');
  end;
end;

procedure TfrmMain.btnGerarArquivoClick(Sender: TObject);
var
  lResponse: IHTTPResponse;
begin
  lResponse := RequestIBGE;
  ParseIBGE(lResponse.ContentAsString);

  lResponse := RequestDDD;
  ParseDDD(lResponse.ContentAsString(TEncoding.ANSI));

  mtCache.IndexFieldNames := 'UF_IBGE';
  mtCache.IndexesActive := True;
  GerarArquivoCache;
end;

procedure TfrmMain.ParseDDD(const pContent: string);
var
  I: Integer;
  lArquivo: TStrings;
  lLinha: string;
  lValores: TArray<string>;
  lUF_Sigla: string;
  lLocalidade_IBGE: Integer;
  lLocalidade_Nome: string;
  lDDD: Integer;
begin
  Application.ProcessMessages;

  lArquivo := TStringList.Create;
  try
    lArquivo.Text := pContent;

    lblDDDTotalRegistros.Caption := Format('Total de DDD: %.3d', [lArquivo.Count-1]);

    mtCache.IndexFieldNames := 'LOCALIDADE_IBGE';
    mtCache.IndexesActive := True;

    for I := 0 to Pred(lArquivo.Count) do
    begin
      if (I = 0) then
        Continue;

      // Código IBGE;UF;MUNICiPIO;CoDIGO_NACIONAL
      // 2919553;BA;LUIS EDUARDO MAGALHAES;77
      lLinha := lArquivo[I];
      lValores := lLinha.Split([';']);

      lLocalidade_IBGE := StrToIntDef(lValores[0], 0);
      lUF_Sigla := lValores[1];
      lLocalidade_Nome := lValores[2];
      lDDD := StrToIntDef(lValores[3], 0);

      if mtCache.FindKey([lLocalidade_IBGE]) then
      begin
        mtCache.Edit;
        mtCacheDDD.AsInteger := lDDD;
        mtCache.Post;
      end;
    end;
  finally
    lArquivo.Free;
  end;
end;

procedure TfrmMain.ParseIBGE(const pContent: string);
var
  I: Integer;
  lJSONValue: TJSONValue;
  lJSONObject: TJSONObject;
  lJSONArray: TJSONArray;
  lUF_IBGE: Integer;
  lUF_Sigla: string;
  lLocalidade_IBGE: Integer;
  lLocalidade_Nome: string;
  lHash: string;
begin
  mtCache.Close;
  mtCache.CreateDataSet;
  mtCache.IndexesActive := False;

  lJSONValue := nil;
  try
    lJSONValue := TJSONObject.ParseJSONValue(pContent);
    if not Assigned(lJSONValue) then
      raise Exception.Create('JSON IBGE inválido!');

    lJSONArray := (lJSONValue as TJSONArray);
    lblIBGETotalRegistros.Caption := Format('Total de Localidades: %.3d', [lJSONArray.Count]);

    Application.ProcessMessages;

    for I := 0 to Pred(lJSONArray.Count) do
    begin
      lJSONObject := lJSONArray.Items[I] as TJSONObject;
      lJSONObject.TryGetValue('UF-id', lUF_IBGE);
      lJSONObject.TryGetValue('UF-sigla', lUF_Sigla);
      lJSONObject.TryGetValue('municipio-id', lLocalidade_IBGE);
      lJSONObject.TryGetValue('municipio-nome', lLocalidade_Nome);

      mtCache.Append;

      mtCacheUF_IBGE.AsInteger := lUF_IBGE;
      mtCacheUF_SIGLA.AsString := lUF_Sigla;
      mtCacheLOCALIDADE_IBGE.AsInteger := lLocalidade_IBGE;
      mtCacheLOCALIDADE_NOME.AsString := lLocalidade_Nome;

      lHash := TBuscaCEPCache.Default.GetHash(lUF_Sigla, lLocalidade_Nome);
      mtCacheHASH.AsString := lHash;

      mtCache.Post;
    end;
  finally
    lJSONValue.Free;
  end;
end;

function TfrmMain.RequestDDD: IHTTPResponse;
begin
  NetHTTPRequest.URL := CURL_DDD;
  NetHTTPRequest.AcceptEncoding := 'gzip, deflate';
  NetHTTPRequest.MethodString := 'GET';

  Result := NetHTTPRequest.Execute();
end;

function TfrmMain.RequestIBGE: IHTTPResponse;
begin
  NetHTTPRequest.URL := CURL_IBGE;
  NetHTTPRequest.AcceptEncoding := 'gzip, deflate';
  NetHTTPRequest.MethodString := 'GET';

  Result := NetHTTPRequest.Execute();
end;

end.
