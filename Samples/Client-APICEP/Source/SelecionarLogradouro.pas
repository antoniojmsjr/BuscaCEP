unit SelecionarLogradouro;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics,  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls,
  Vcl.ExtCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids, Utils;

type
  TfrmSelecionarLogradouro = class(TForm)
    pnlBottom: TPanel;
    Shape1: TShape;
    Label1: TLabel;
    dsLogradouros: TDataSource;
    dbgCEPLogradouros: TDBGrid;
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
    memLogradourosJSON: TMemoField;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure dbgCEPLogradourosDblClick(Sender: TObject);
  private
    { Private declarations }
    FLogradouroAPIJSON: string;
    procedure CarregarLogradouros(const pJSONLogradouros: string);
  public
    { Public declarations }
    class procedure GetLogradouro(const pOwner: TComponent; const pJSONLogradouros: string;
                                  out poJSONLogradouro: string);
  end;

implementation

uses
  System.Generics.Collections, System.JSON;

{$R *.dfm}

{ TfrmSelecionarLogradouro }

procedure TfrmSelecionarLogradouro.FormCreate(Sender: TObject);
begin
  memLogradouros.CreateDataSet;
end;

procedure TfrmSelecionarLogradouro.dbgCEPLogradourosDblClick(Sender: TObject);
begin
  if memLogradouros.IsEmpty then
    raise Exception.Create('Não existe logradouro para selecionar!');

  FLogradouroAPIJSON := memLogradourosJSON.AsString;
  Close;
end;

procedure TfrmSelecionarLogradouro.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  memLogradouros.Close;
end;

class procedure TfrmSelecionarLogradouro.GetLogradouro(const pOwner: TComponent;
  const pJSONLogradouros: string; out poJSONLogradouro: string);
var
  lForm: TfrmSelecionarLogradouro;
begin
  lForm := TfrmSelecionarLogradouro.Create(pOwner);
  try
    lForm.CarregarLogradouros(pJSONLogradouros);

    lForm.ShowModal;
    poJSONLogradouro := lForm.FLogradouroAPIJSON;
  finally
    lForm.Free;
  end;
end;

procedure TfrmSelecionarLogradouro.CarregarLogradouros(
  const pJSONLogradouros: string);
var
  lJSONValue: TJSONValue;
  lJSONLogradouros: TJSONArray;
  lJSONLogradouro: TJSONObject;
  I: Integer;
  lLogradouroAPI: TLogradouroAPI;
begin
  lJSONValue := nil;
  try
    lJSONValue := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(pJSONLogradouros), 0);
    if not Assigned(lJSONValue) then
      Exit;

    if not lJSONValue.TryGetValue<TJSONArray>('logradouros', lJSONLogradouros) then
      Exit;

    for I := 0 to Pred(lJSONLogradouros.Count) do
    begin
      lJSONLogradouro := (lJSONLogradouros.Items[I] as TJSONObject);

      lLogradouroAPI := ProcessarJSONLogradouroAPI(lJSONLogradouro.ToString);
      if not Assigned(lLogradouroAPI) then
        Continue;

      try
        memLogradouros.Append;
        memLogradourosLOGRADOURO.AsString := lLogradouroAPI.Logradouro;
        memLogradourosCOMPLEMENTO.AsString := lLogradouroAPI.Complemento;
        memLogradourosBAIRRO.AsString := lLogradouroAPI.Bairro;
        memLogradourosLOCALIDADE.AsString := lLogradouroAPI.Localidade;
        memLogradourosLOCALIDADE_IBGE.AsInteger := lLogradouroAPI.LocalidadeIBGE;
        memLogradourosESTADO.AsString := lLogradouroAPI.Estado;
        memLogradourosESTADO_IBGE.AsInteger := lLogradouroAPI.EstadoIBGE;
        memLogradourosCEP.AsInteger := lLogradouroAPI.CEP;
        memLogradourosJSON.AsString := lJSONLogradouro.ToJSON;
        memLogradouros.Post;
      finally
        lLogradouroAPI.Free;
      end;
    end;

  finally
    lJSONValue.Free;
  end;

  memLogradouros.First;
end;

end.
