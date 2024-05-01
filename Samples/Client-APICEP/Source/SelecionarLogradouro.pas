unit SelecionarLogradouro;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics,  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Datasnap.DBClient, System.JSON, Utils;

type
  TfrmSelecionarLogradouro = class(TForm)
    dbgBuscaCEP: TDBGrid;
    pnlBottom: TPanel;
    Shape1: TShape;
    Label1: TLabel;
    cdsBuscaCEPLogradouros: TClientDataSet;
    cdsBuscaCEPLogradourosLOGRADOURO: TStringField;
    cdsBuscaCEPLogradourosCOMPLEMENTO: TStringField;
    cdsBuscaCEPLogradourosBAIRRO: TStringField;
    cdsBuscaCEPLogradourosLOCALIDADE: TStringField;
    cdsBuscaCEPLogradourosLOCALIDADE_IBGE: TIntegerField;
    cdsBuscaCEPLogradourosESTADO: TStringField;
    cdsBuscaCEPLogradourosESTADO_IBGE: TIntegerField;
    dsBuscaCEPLogradouros: TDataSource;
    cdsBuscaCEPLogradourosJSON: TMemoField;
    cdsBuscaCEPLogradourosCEP: TIntegerField;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure dbgBuscaCEPDblClick(Sender: TObject);
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
  System.Generics.Collections;

{$R *.dfm}

{ TfrmSelecionarLogradouro }

procedure TfrmSelecionarLogradouro.FormCreate(Sender: TObject);
begin
  cdsBuscaCEPLogradouros.CreateDataSet;
end;

procedure TfrmSelecionarLogradouro.dbgBuscaCEPDblClick(Sender: TObject);
begin
  if cdsBuscaCEPLogradouros.IsEmpty then
    raise Exception.Create('Não existe logradouro para selecionar!');

  FLogradouroAPIJSON := cdsBuscaCEPLogradourosJSON.AsString;
  Close;
end;

procedure TfrmSelecionarLogradouro.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  cdsBuscaCEPLogradouros.Close;
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
        cdsBuscaCEPLogradouros.Append;
        cdsBuscaCEPLogradourosLOGRADOURO.AsString := lLogradouroAPI.Logradouro;
        cdsBuscaCEPLogradourosCOMPLEMENTO.AsString := lLogradouroAPI.Complemento;
        cdsBuscaCEPLogradourosBAIRRO.AsString := lLogradouroAPI.Bairro;
        cdsBuscaCEPLogradourosLOCALIDADE.AsString := lLogradouroAPI.Localidade;
        cdsBuscaCEPLogradourosLOCALIDADE_IBGE.AsInteger := lLogradouroAPI.LocalidadeIBGE;
        cdsBuscaCEPLogradourosESTADO.AsString := lLogradouroAPI.Estado;
        cdsBuscaCEPLogradourosESTADO_IBGE.AsInteger := lLogradouroAPI.EstadoIBGE;
        cdsBuscaCEPLogradourosCEP.AsInteger := lLogradouroAPI.CEP;
        cdsBuscaCEPLogradourosJSON.AsString := lJSONLogradouro.ToJSON;
        cdsBuscaCEPLogradouros.Post;
      finally
        lLogradouroAPI.Free;
      end;
    end;

  finally
    lJSONValue.Free;
  end;
end;

end.
