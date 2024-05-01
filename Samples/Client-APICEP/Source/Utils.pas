unit Utils;

interface

Type
  TLogradouroAPI = class
  strict private
    { private declarations }
    FLogradouro: string;
    FEstadoIBGE: Integer;
    FBairro: string;
    FCEP: Integer;
    FLocalidade: string;
    FComplemento: string;
    FLocalidadeIBGE: Integer;
    FEstado: string;
  protected
    { protected declarations }
  public
    { public declarations }
    property Logradouro: string read FLogradouro write FLogradouro;
    property Complemento: string read FComplemento write FComplemento;
    property Bairro: string read FBairro write FBairro;
    property Localidade: string read FLocalidade write FLocalidade;
    property LocalidadeIBGE: Integer read FLocalidadeIBGE write FLocalidadeIBGE;
    property Estado: string read FEstado write FEstado;
    property EstadoIBGE: Integer read FEstadoIBGE write FEstadoIBGE;
    property CEP: Integer read FCEP write FCEP;
  end;

  function ProcessarJSONLogradouroAPI(const pJSON: string): TLogradouroAPI;

implementation

uses
  System.JSON, System.Generics.Collections, System.SysUtils;

function ProcessarJSONLogradouroAPI(const pJSON: string): TLogradouroAPI;
var
  lJSONObject: TJSONObject;
begin
  Result := nil;
  lJSONObject := nil;
  try
    lJSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(pJSON), 0) as TJSONObject;
    if not Assigned(lJSONObject) then
      Exit;

    Result := TLogradouroAPI.Create;

    Result.Logradouro := lJSONObject.GetValue('logradouro').AsType<string>;
    Result.Complemento := lJSONObject.GetValue('complemento').AsType<string>;
    Result.Bairro := lJSONObject.GetValue('bairro').AsType<string>;
    Result.CEP := lJSONObject.GetValue('cep').AsType<Integer>;
    Result.Localidade := lJSONObject.GetValue('localidade').GetValue<string>('nome');
    Result.LocalidadeIBGE := lJSONObject.GetValue('localidade').GetValue<Integer>('ibge');
    Result.Estado := lJSONObject.GetValue('localidade').FindValue('estado').GetValue<string>('nome');
    Result.EstadoIBGE := lJSONObject.GetValue('localidade').FindValue('estado').GetValue<Integer>('ibge');
  finally
    lJSONObject.Free;
  end;
end;

end.
