{******************************************************************************}
{                                                                              }
{           BuscaCEP.Types.pas                                                 }
{                                                                              }
{           Copyright (C) Antônio José Medeiros Schneider Júnior               }
{                                                                              }
{           https://github.com/antoniojmsjr/BuscaCEP                           }
{                                                                              }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  Licensed under the Apache License, Version 2.0 (the "License");             }
{  you may not use this file except in compliance with the License.            }
{  You may obtain a copy of the License at                                     }
{                                                                              }
{      http://www.apache.org/licenses/LICENSE-2.0                              }
{                                                                              }
{  Unless required by applicable law or agreed to in writing, software         }
{  distributed under the License is distributed on an "AS IS" BASIS,           }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{  See the License for the specific language governing permissions and         }
{  limitations under the License.                                              }
{                                                                              }
{******************************************************************************}
unit BuscaCEP.Types;

interface

uses
  System.SysUtils, REST.Json.Types, System.JSON;

type

  {$REGION 'TBuscaCEPProvidersKind'}

  {$SCOPEDENUMS ON}
  TBuscaCEPProvidersKind = (UNKNOWN,
                            Correios,
                            CEPAberto,
                            ViaCEP,
                            CEPLivre,
                            RepublicaVirtual,
                            CEPCerto,
                            BrasilAPI,
                            KingHost,
                            Postmon,
                            OpenCEP,
                            ApiCEP,
                            BrasilAberto);
  {$SCOPEDENUMS OFF}

  {$ENDREGION}

  {$REGION 'TBuscaCEPProvidersKindHelper'}
  TBuscaCEPProvidersKindHelper = record helper for TBuscaCEPProvidersKind
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    function AsString: string;
    function AsInteger: Integer;
    function Token: string;
    function BaseURL: string;
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPExceptionKind'}

  {$SCOPEDENUMS ON}
  TBuscaCEPExceptionKind = (EXCEPTION_UNKNOWN,
                            EXCEPTION_OTHERS,
                            EXCEPTION_HTTP,
                            EXCEPTION_RESPONSE_INVALID,
                            EXCEPTION_REQUEST_INVALID,
                            EXCEPTION_FILTRO_INVALID,
                            EXCEPTION_FILTRO_NOT_FOUND);
  {$SCOPEDENUMS OFF}

  {$ENDREGION}

  {$REGION 'TTBuscaCEPExceptionKindKindHelper'}
  TTBuscaCEPExceptionKindKindHelper = record helper for TBuscaCEPExceptionKind
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    function AsString: string;
    function AsInteger: Integer;
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPTipoLogradouroKind'}

  {$SCOPEDENUMS ON}
  TBuscaCEPTipoLogradouroKind = (Todos,
                                 Aeroporto,
                                 Alameda,
                                 Area,
                                 Avenida,
                                 Chacara,
                                 Colonia,
                                 Condominio,
                                 Conjunto,
                                 Distrito,
                                 Esplanada,
                                 Estacao,
                                 Estrada,
                                 Favela,
                                 Fazenda,
                                 Feira,
                                 Jardim,
                                 Ladeira,
                                 Lago,
                                 Lagoa,
                                 Largo,
                                 Loteamento,
                                 Morro,
                                 Nucleo,
                                 Parque,
                                 Passarela,
                                 Patio,
                                 Praca,
                                 Quadra,
                                 Recanto,
                                 Residencial,
                                 Rodovia,
                                 Rua,
                                 Setor,
                                 Sitio,
                                 Travessa,
                                 Trecho,
                                 Trevo,
                                 Via,
                                 Viaduto,
                                 Viela,
                                 Vila);
  {$SCOPEDENUMS OFF}

  {$ENDREGION}

  {$REGION 'TBuscaCEPTipoLogradouroKindHelper'}
  TBuscaCEPTipoLogradouroKindHelper = record helper for TBuscaCEPTipoLogradouroKind
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    function AsString: string;
    function AsInteger: Integer;
  end;
  {$ENDREGION}

  {$REGION 'EBuscaCEP'}
  EBuscaCEP = class(Exception)
  strict private
    { private declarations }
    FKind: TBuscaCEPExceptionKind;
    FProvider: string;
    FDateTime: TDateTime;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(const pKind: TBuscaCEPExceptionKind;
                       const pProvider: string;
                       const pDateTime: TDateTime;
                       const pMessage: string);
    property Kind: TBuscaCEPExceptionKind read FKind;
    property Provider: string read FProvider;
    property DateTime: TDateTime read FDateTime;
  end;
  {$ENDREGION}

  {$REGION 'EBuscaCEPRequest'}
  EBuscaCEPRequest = class sealed(EBuscaCEP)
  strict private
    { private declarations }
    FStatusCode: Integer;
    FStatusText: string;
    FURL: string;
    FMethod: string;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(const pKind: TBuscaCEPExceptionKind;
                       const pProvider: string;
                       const pDateTime: TDateTime;
                       const pURL: string;
                       const pStatusCode: Integer;
                       const pStatusText: string;
                       const pMethod: string;
                       const pMessage: string);
    property URL: string read FURL;
    property StatusCode: Integer read FStatusCode;
    property StatusText: string read FStatusText;
    property Method: string read FMethod;
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPLogradouroRegiao'}
  TBuscaCEPLogradouroRegiao = class
  strict private
    { private declarations }
    [JsonName('ibge')]
    FIBGE: Integer;
    [JsonName('nome')]
    FNome: string;
    [JsonName('sigla')]
    FSigla: string;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(const pIBGE: Integer; const pRegiao: string; const pSigla: string); overload;
    procedure Assign(const pSource: TBuscaCEPLogradouroRegiao);
    property IBGE: Integer read FIBGE;
    property Nome: string read FNome;
    property Sigla: string read FSigla;
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPLogradouroEstado'}
  TBuscaCEPLogradouroEstado = class
  strict private
    { private declarations }
    [JsonName('ibge')]
    FIBGE: Integer;
    [JsonName('nome')]
    FNome: string;
    [JsonName('sigla')]
    FSigla: string;
    [JsonName('regiao')]
    FRegiao: TBuscaCEPLogradouroRegiao;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(const pIBGE: Integer; const pEstado: string;
                       const pSigla: string; const pRegiao: TBuscaCEPLogradouroRegiao); overload;
    destructor Destroy; override;
    procedure Assign(const pSource: TBuscaCEPLogradouroEstado);
    property IBGE: Integer read FIBGE;
    property Nome: string read FNome;
    property Sigla: string read FSigla;
    property Regiao: TBuscaCEPLogradouroRegiao read FRegiao;
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPLogradouroLocalidade'}
  TBuscaCEPLogradouroLocalidade = class
  strict private
    { private declarations }
    [JsonName('ibge')]
    FIBGE: Integer;
    [JsonName('ddd')]
    FDDD: Integer;
    [JsonName('nome')]
    FNome: string;
    [JsonName('estado')]
    FEstado: TBuscaCEPLogradouroEstado;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(const pIBGE: Integer;
                       const pDDD: Integer;
                       const pLocalidade: string;
                       const pEstado: TBuscaCEPLogradouroEstado); overload;
    destructor Destroy; override;
    property IBGE: Integer read FIBGE;
    property DDD: Integer read FDDD;
    property Nome: string read FNome;
    property Estado: TBuscaCEPLogradouroEstado read FEstado;
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPLogradouro'}
  TBuscaCEPLogradouro = class
  private
    { private declarations }
    [JsonName('logradouro')]
    FLogradouro: string;
    [JsonName('complemento')]
    FComplemento: string;
    [JsonName('unidade')]
    FUnidade: string;
    [JsonName('bairro')]
    FBairro: string;
    [JsonName('cep')]
    FCEP: string;
    [JsonName('localidade')]
    FLocalidade: TBuscaCEPLogradouroLocalidade;
  protected
    { protected declarations }
  public
    { public declarations }
    destructor Destroy; override;
    function ToJSONObject: TJSONObject;
    property Logradouro: string read FLogradouro write FLogradouro;
    property Complemento: string read FComplemento write FComplemento;
    property Unidade: string read FUnidade write FUnidade;
    property Bairro: string read FBairro write FBairro;
    property Localidade: TBuscaCEPLogradouroLocalidade read FLocalidade write FLocalidade;
    property CEP: string read FCEP write FCEP;
  end;
  {$ENDREGION}

implementation

uses
  BuscaCEP.Utils, REST.Json;

{$REGION 'TBuscaCEPProvidersKindHelper'}
function TBuscaCEPProvidersKindHelper.AsInteger: Integer;
begin
  Result := Ord(Self);
end;

function TBuscaCEPProvidersKindHelper.AsString: string;
begin
  case Self of
    TBuscaCEPProvidersKind.UNKNOWN:      Result := 'UNKNOWN';
    TBuscaCEPProvidersKind.Correios:     Result := 'Correios';
    TBuscaCEPProvidersKind.CEPAberto:    Result := 'CEPAberto';
    TBuscaCEPProvidersKind.ViaCEP:       Result := 'ViaCEP';
    TBuscaCEPProvidersKind.CEPLivre:     Result := 'CEPLivre';
    TBuscaCEPProvidersKind.RepublicaVirtual: Result := 'RepublicaVirtual';
    TBuscaCEPProvidersKind.CEPCerto:     Result := 'CEPCerto';
    TBuscaCEPProvidersKind.BrasilAPI:    Result := 'BrasilAPI';
    TBuscaCEPProvidersKind.KingHost:     Result := 'KingHost';
    TBuscaCEPProvidersKind.Postmon:      Result := 'Postmon';
    TBuscaCEPProvidersKind.OpenCEP:      Result := 'OpenCEP';
    TBuscaCEPProvidersKind.ApiCEP:       Result := 'ApiCEP';
    TBuscaCEPProvidersKind.BrasilAberto: Result := 'BrasilAberto';
  end;
end;

function TBuscaCEPProvidersKindHelper.Token: string;
begin
  case Self of
    TBuscaCEPProvidersKind.UNKNOWN:      Result := '#UNKNOWN';
    TBuscaCEPProvidersKind.Correios:     Result := '#CORREIOS';
    TBuscaCEPProvidersKind.CEPAberto:    Result := '#CEP_ABERTO';
    TBuscaCEPProvidersKind.ViaCEP:       Result := '#VIA_CEP';
    TBuscaCEPProvidersKind.CEPLivre:     Result := '#CEP_LIVRE';
    TBuscaCEPProvidersKind.RepublicaVirtual: Result := '#REPUBLICA_VIRTUAL';
    TBuscaCEPProvidersKind.CEPCerto:     Result := '#CEP_CERTO';
    TBuscaCEPProvidersKind.BrasilAPI:    Result := '#BRASIL_API';
    TBuscaCEPProvidersKind.KingHost:     Result := '#KINGHOST';
    TBuscaCEPProvidersKind.Postmon:      Result := '#POSTMON';
    TBuscaCEPProvidersKind.OpenCEP:      Result := '#OPEN_CEP';
    TBuscaCEPProvidersKind.ApiCEP:       Result := '#API_CEP';
    TBuscaCEPProvidersKind.BrasilAberto: Result := '#BRASIL_ABERTO';
  end;
end;
function TBuscaCEPProvidersKindHelper.BaseURL: string;
begin
  case Self of
    TBuscaCEPProvidersKind.UNKNOWN:      Result := '';
    TBuscaCEPProvidersKind.Correios:     Result := 'https://buscacepinter.correios.com.br';
    TBuscaCEPProvidersKind.CEPAberto:    Result := 'https://www.cepaberto.com';
    TBuscaCEPProvidersKind.ViaCEP:       Result := 'https://viacep.com.br';
    TBuscaCEPProvidersKind.CEPLivre:     Result := 'https://ceplivre.com.br';
    TBuscaCEPProvidersKind.RepublicaVirtual: Result := 'http://cep.republicavirtual.com.br';
    TBuscaCEPProvidersKind.CEPCerto:     Result := 'https://www.cepcerto.com';
    TBuscaCEPProvidersKind.BrasilAPI:    Result := 'https://brasilapi.com.br';
    TBuscaCEPProvidersKind.KingHost:     Result := 'https://webservice.kinghost.net';
    TBuscaCEPProvidersKind.Postmon:      Result := 'https://api.postmon.com.br';
    TBuscaCEPProvidersKind.OpenCEP:      Result := 'https://opencep.com';
    TBuscaCEPProvidersKind.ApiCEP:       Result := 'https://cdn.apicep.com';
    TBuscaCEPProvidersKind.BrasilAberto: Result := 'https://api.brasilaberto.com';
  end;
end;

{$ENDREGION}

{$REGION 'TTBuscaCEPExceptionKindKindHelper'}
function TTBuscaCEPExceptionKindKindHelper.AsInteger: Integer;
begin
  Result := Ord(Self);
end;

function TTBuscaCEPExceptionKindKindHelper.AsString: string;
begin
  case Self of
    TBuscaCEPExceptionKind.EXCEPTION_UNKNOWN:           Result := 'EXCEPTION_UNKNOWN';
    TBuscaCEPExceptionKind.EXCEPTION_OTHERS:            Result := 'EXCEPTION_OTHERS';
    TBuscaCEPExceptionKind.EXCEPTION_HTTP:              Result := 'EXCEPTION_HTTP';
    TBuscaCEPExceptionKind.EXCEPTION_RESPONSE_INVALID:  Result := 'EXCEPTION_RESPONSE_INVALID';
    TBuscaCEPExceptionKind.EXCEPTION_REQUEST_INVALID:   Result := 'EXCEPTION_REQUEST_INVALID';
    TBuscaCEPExceptionKind.EXCEPTION_FILTRO_INVALID:    Result := 'EXCEPTION_FILTRO_INVALID';
    TBuscaCEPExceptionKind.EXCEPTION_FILTRO_NOT_FOUND:  Result := 'EXCEPTION_FILTRO_NOT_FOUND';
  end;
end;
{$ENDREGION}

{$REGION 'TBuscaCEPTipoLogradouroKindHelper'}
function TBuscaCEPTipoLogradouroKindHelper.AsInteger: Integer;
begin
  Result := Ord(Self);
end;

function TBuscaCEPTipoLogradouroKindHelper.AsString: string;
begin
  case Self of
    TBuscaCEPTipoLogradouroKind.Todos: Result := '';
    TBuscaCEPTipoLogradouroKind.Aeroporto: Result := 'Aeroporto';
    TBuscaCEPTipoLogradouroKind.Alameda: Result := 'Alameda';
    TBuscaCEPTipoLogradouroKind.Area: Result := 'Área';
    TBuscaCEPTipoLogradouroKind.Avenida: Result := 'Avenida';
    TBuscaCEPTipoLogradouroKind.Chacara: Result := 'Chácara';
    TBuscaCEPTipoLogradouroKind.Colonia: Result := 'Colônia';
    TBuscaCEPTipoLogradouroKind.Condominio: Result := 'Condomínio';
    TBuscaCEPTipoLogradouroKind.Conjunto: Result := 'Conjunto';
    TBuscaCEPTipoLogradouroKind.Distrito: Result := 'Distrito';
    TBuscaCEPTipoLogradouroKind.Esplanada: Result := 'Esplanada';
    TBuscaCEPTipoLogradouroKind.Estacao: Result := 'Estação';
    TBuscaCEPTipoLogradouroKind.Estrada: Result := 'Estrada';
    TBuscaCEPTipoLogradouroKind.Favela: Result := 'Favela';
    TBuscaCEPTipoLogradouroKind.Fazenda: Result := 'Fazenda';
    TBuscaCEPTipoLogradouroKind.Feira: Result := 'Feira';
    TBuscaCEPTipoLogradouroKind.Jardim: Result := 'Jardim';
    TBuscaCEPTipoLogradouroKind.Ladeira: Result := 'Ladeira';
    TBuscaCEPTipoLogradouroKind.Lago: Result := 'Lago';
    TBuscaCEPTipoLogradouroKind.Lagoa: Result := 'Lagoa';
    TBuscaCEPTipoLogradouroKind.Largo: Result := 'Largo';
    TBuscaCEPTipoLogradouroKind.Loteamento: Result := 'Loteamento';
    TBuscaCEPTipoLogradouroKind.Morro: Result := 'Morro';
    TBuscaCEPTipoLogradouroKind.Nucleo: Result := 'Núcleo';
    TBuscaCEPTipoLogradouroKind.Parque: Result := 'Parque';
    TBuscaCEPTipoLogradouroKind.Passarela: Result := 'Passarela';
    TBuscaCEPTipoLogradouroKind.Patio: Result := 'Pátio';
    TBuscaCEPTipoLogradouroKind.Praca: Result := 'Praça';
    TBuscaCEPTipoLogradouroKind.Quadra: Result := 'Quadra';
    TBuscaCEPTipoLogradouroKind.Recanto: Result := 'Recanto';
    TBuscaCEPTipoLogradouroKind.Residencial: Result := 'Residencial';
    TBuscaCEPTipoLogradouroKind.Rodovia: Result := 'Rodovia';
    TBuscaCEPTipoLogradouroKind.Rua: Result := 'Rua';
    TBuscaCEPTipoLogradouroKind.Setor: Result := 'Setor';
    TBuscaCEPTipoLogradouroKind.Sitio: Result := 'Sítio';
    TBuscaCEPTipoLogradouroKind.Travessa: Result := 'Travessa';
    TBuscaCEPTipoLogradouroKind.Trecho: Result := 'Trecho';
    TBuscaCEPTipoLogradouroKind.Trevo: Result := 'Trevo';
    TBuscaCEPTipoLogradouroKind.Via: Result := 'Via';
    TBuscaCEPTipoLogradouroKind.Viaduto: Result := 'Viaduto';
    TBuscaCEPTipoLogradouroKind.Viela: Result := 'Viela';
    TBuscaCEPTipoLogradouroKind.Vila: Result := 'Vila';
  end;
end;
{$ENDREGION}

{$REGION 'EBuscaCEP'}
constructor EBuscaCEP.Create(
  const pKind: TBuscaCEPExceptionKind; const pProvider: string;
  const pDateTime: TDateTime; const pMessage: string);
begin
  inherited Create(pMessage);
  FKind := pKind;
  FProvider := pProvider;
  FDateTime := pDateTime;
end;
{$ENDREGION}

{$REGION 'EBuscaCEPRequest'}
constructor EBuscaCEPRequest.Create(
  const pKind: TBuscaCEPExceptionKind;
  const pProvider: string; const pDateTime: TDateTime;
  const pURL: string; const pStatusCode: Integer;
  const pStatusText: string; const pMethod: string;
  const pMessage: string);
begin
  inherited Create(pKind, pProvider, pDateTime, pMessage);

  FURL := pURL;
  FStatusCode := pStatusCode;
  FStatusText := pStatusText;
  FMethod := pMethod;
end;
{$ENDREGION}

{$REGION 'TBuscaCEPLogradouroRegiao'}
constructor TBuscaCEPLogradouroRegiao.Create(const pIBGE: Integer;
  const pRegiao: string; const pSigla: string);
begin
  FIBGE := pIBGE;
  FNome := Trim(pRegiao);
  FSigla := Trim(pSigla);
end;

procedure TBuscaCEPLogradouroRegiao.Assign(
  const pSource: TBuscaCEPLogradouroRegiao);
begin
  Self.FIBGE := pSource.IBGE;
  Self.FNome := Trim(pSource.Nome);
  Self.FSigla := Trim(pSource.Sigla);
end;
{$ENDREGION}

{$REGION 'TBuscaCEPLogradouroEstado'}
constructor TBuscaCEPLogradouroEstado.Create(const pIBGE: Integer; const pEstado: string;
  const pSigla: string; const pRegiao: TBuscaCEPLogradouroRegiao);
begin
  FIBGE := pIBGE;
  FNome := Trim(pEstado);
  FSigla := Trim(pSigla);
  FRegiao := pRegiao;
end;

destructor TBuscaCEPLogradouroEstado.Destroy;
begin
  FRegiao.Free;
  inherited Destroy;
end;

procedure TBuscaCEPLogradouroEstado.Assign(
  const pSource: TBuscaCEPLogradouroEstado);
begin
  Self.FIBGE := pSource.IBGE;
  Self.FNome := Trim(pSource.Nome);
  Self.FSigla := Trim(pSource.Sigla);
  if Assigned(Self.FRegiao) then
    FreeAndNil(Self.FRegiao);
  Self.FRegiao := TBuscaCEPLogradouroRegiao.Create;
  Self.FRegiao.Assign(pSource.Regiao);
end;
{$ENDREGION}

{$REGION 'TBuscaCEPLogradouroLocalidade'}
constructor TBuscaCEPLogradouroLocalidade.Create(const pIBGE: Integer;
  const pDDD: Integer; const pLocalidade: string;
  const pEstado: TBuscaCEPLogradouroEstado);
begin
  FIBGE := pIBGE;
  FDDD := pDDD;
  FNome := Trim(pLocalidade);
  FEstado := pEstado;
end;

destructor TBuscaCEPLogradouroLocalidade.Destroy;
begin
  FEstado.Free;
  inherited Destroy;
end;
{$ENDREGION}

{$REGION 'TBuscaCEPLogradouro'}
destructor TBuscaCEPLogradouro.Destroy;
begin
  FLocalidade.Free;
  inherited Destroy;
end;

function TBuscaCEPLogradouro.ToJSONObject: TJSONObject;
begin
  Result := TJson.ObjectToJsonObject(Self);
end;
{$ENDREGION}

end.
