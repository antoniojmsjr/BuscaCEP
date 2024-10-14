{******************************************************************************}
{                                                                              }
{           BuscaCEP.Providers.Postmon.pas                                     }
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
unit BuscaCEP.Providers.Postmon;

interface

uses
  System.Generics.Collections, System.Net.HttpClient, BuscaCEP.Interfaces,
  BuscaCEP.Core;

type

  {$REGION 'TBuscaCEPProviderPostmon'}
  TBuscaCEPProviderPostmon = class sealed(TBuscaCEPProvidersCustom)
  private
    { private declarations }
  protected
    { protected declarations }
    function GetRequest: IBuscaCEPRequest; override;
  public
    { public declarations }
    constructor Create(pParent: IBuscaCEP); override;
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPResponsePostmon'}
  TBuscaCEPResponsePostmon = class(TBuscaCEPResponseCustom)
  private
    { private declarations }
  protected
    { protected declarations }
    procedure Parse; override;
  public
    { public declarations }
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPRequestPostmon'}
  TBuscaCEPRequestPostmon = class sealed(TBuscaCEPRequest)
  private
    { private declarations }
    function GetResource(pBuscaCEPFiltro: IBuscaCEPFiltro): string;
  protected
    { protected declarations }
    function InternalExecute: IHTTPResponse; override;
    function GetResponse(pIHTTPResponse: IHTTPResponse): IBuscaCEPResponse; override;
    procedure CheckRequest; override;
    procedure CheckContentResponse(pIHTTPResponse: IHTTPResponse); override;
  public
    { public declarations }
  end;
  {$ENDREGION}

implementation

uses
  System.JSON, System.SysUtils, System.Net.URLClient, System.Classes,
  BuscaCEP.Types, BuscaCEP.Utils;

{$REGION 'TBuscaCEPProviderPostmon'}
constructor TBuscaCEPProviderPostmon.Create(pParent: IBuscaCEP);
begin
  inherited Create(pParent);
  FID   := TBuscaCEPProvidersKind.Postmon.Token;
  FURL  := TBuscaCEPProvidersKind.Postmon.BaseURL;
end;

function TBuscaCEPProviderPostmon.GetRequest: IBuscaCEPRequest;
begin
  Result := TBuscaCEPRequestPostmon.Create(Self, FBuscaCEP);
end;
{$ENDREGION}

{$REGION 'TBuscaCEPResponsePostmon'}
procedure TBuscaCEPResponsePostmon.Parse;
var
  lJSONResponse: TJSONValue;
  lJSONLogradouro: TJSONObject;
  lAPILogradouro: string;
  lAPIComplemento: string;
  lAPIBairro: string;
  lAPILocalidade: string;
  lAPIUF: string;
  lAPICEP: string;
  lLocalidadeDDD: Integer;
  lLocalidadeIBGE: Integer;
  lBuscaCEPLogradouro: TBuscaCEPLogradouro;
  lBuscaCEPLogradouroEstado: TBuscaCEPLogradouroEstado;
begin
  lJSONResponse := nil;
  try
    lJSONResponse := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(FContent), 0);
    if not Assigned(lJSONResponse) then
      Exit;

    lJSONLogradouro := (lJSONResponse as TJSONObject);

    lJSONLogradouro.TryGetValue<string>('logradouro',  lAPILogradouro);
    lJSONLogradouro.TryGetValue<string>('complemento', lAPIComplemento);
    lJSONLogradouro.TryGetValue<string>('bairro',      lAPIBairro);
    lJSONLogradouro.TryGetValue<string>('cidade',      lAPILocalidade);
    lJSONLogradouro.TryGetValue<string>('estado',      lAPIUF);
    lJSONLogradouro.TryGetValue<string>('cep',         lAPICEP);

    lBuscaCEPLogradouro := TBuscaCEPLogradouro.Create;

    lBuscaCEPLogradouro.Logradouro := Trim(lAPILogradouro);
    lBuscaCEPLogradouro.Complemento := Trim(lAPIComplemento);
    lBuscaCEPLogradouro.Unidade := EmptyStr;
    lBuscaCEPLogradouro.Bairro := Trim(lAPIBairro);
    lBuscaCEPLogradouro.CEP := OnlyNumber(lAPICEP);

    lAPIUF := Trim(lAPIUF);
    lBuscaCEPLogradouroEstado := TBuscaCEPLogradouroEstado.Create;
    lBuscaCEPLogradouroEstado.Assign(TBuscaCEPEstados.Default.GetEstado(lAPIUF));

    lAPILocalidade := Trim(lAPILocalidade);
    TBuscaCEPCache.Default.GetCodigos(lAPIUF, lAPILocalidade, lLocalidadeIBGE, lLocalidadeDDD);
    lBuscaCEPLogradouro.Localidade :=
      TBuscaCEPLogradouroLocalidade.Create(lLocalidadeIBGE,
                                           lLocalidadeDDD,
                                           lAPILocalidade,
                                           lBuscaCEPLogradouroEstado);

    FLogradouros.Add(lBuscaCEPLogradouro);
  finally
    lJSONResponse.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TBuscaCEPRequestPostmon'}
procedure TBuscaCEPRequestPostmon.CheckContentResponse(pIHTTPResponse: IHTTPResponse);
var
  lMessage: string;
  lContent: string;
  lJSONResponse: TJSONValue;
  lBuscaCEPExceptionKind: TBuscaCEPExceptionKind;
begin
  inherited CheckContentResponse(pIHTTPResponse);

  lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_UNKNOWN;
  lMessage := EmptyStr;

  lContent := pIHTTPResponse.ContentAsString;
  try
    case pIHTTPResponse.StatusCode of
      200:
      begin
        lJSONResponse := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(lContent), 0);
        try
          if not Assigned(lJSONResponse) then
          begin
            lMessage := 'JSON inválido';
            lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_RESPONSE_INVALID;
            Exit;
          end;

          if not (lJSONResponse is TJSONObject) then
          begin
            lMessage := 'JSON inválido, não é um TJSONObject.';
            lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_RESPONSE_INVALID;
          end;
        finally
          lJSONResponse.Free;
        end;
      end;
      404:
      begin
        lMessage := 'Logradouro não encontrado. Verifique os parâmetros de filtro.';
        lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_FILTRO_NOT_FOUND;
      end;
      503:
      begin
        lMessage := 'Servidor indisponível!';
        lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_FILTRO_NOT_FOUND;
      end;
    else
    begin
      lMessage := lContent;
      lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_REQUEST_INVALID;
    end;
    end;
  finally
    if (lMessage <> EmptyStr) then
      raise EBuscaCEP.Create(lBuscaCEPExceptionKind,
                             FProvider,
                             Now(),
                             lMessage);
  end;
end;

procedure TBuscaCEPRequestPostmon.CheckRequest;
var
  lCEP: string;
begin
  if  (FBuscaCEPFiltro.FiltroPorCEP = False)
  and (FBuscaCEPFiltro.FiltroPorLogradouro = False) then
  begin
    raise EBuscaCEP.Create(TBuscaCEPExceptionKind.EXCEPTION_FILTRO_INVALID,
                           FProvider,
                           Now(),
                           'Informe um filtro para consulta.');
  end;

  // BUSCA POR CEP
  if (FBuscaCEPFiltro.FiltroPorCEP = True)then
  begin
    lCEP := OnlyNumber(FBuscaCEPFiltro.CEP);

    if ((lCEP.IsEmpty = True)
    or (Length(lCEP) < 8)) then
    begin
      raise EBuscaCEP.Create(TBuscaCEPExceptionKind.EXCEPTION_FILTRO_INVALID,
                             FProvider,
                             Now(),
                             'O CEP informado é inválido.');
    end;
  end;

  // BUSCA POR LOGRADOURO
  if (FBuscaCEPFiltro.FiltroPorLogradouro = True)then
      raise EBuscaCEP.Create(TBuscaCEPExceptionKind.EXCEPTION_FILTRO_INVALID,
                             FProvider,
                             Now(),
                             'O provedor não oferece busca por logradouro.');
end;

function TBuscaCEPRequestPostmon.GetResource(pBuscaCEPFiltro: IBuscaCEPFiltro): string;
var
  lCEP: string;
begin
  Result := EmptyStr;

  // https://api.postmon.com.br/v1/cep/90520003
  lCEP := OnlyNumber(FBuscaCEPProvider.Filtro.CEP);
  Result := Format('/v1/cep/%s', [lCEP]);
end;

function TBuscaCEPRequestPostmon.GetResponse(pIHTTPResponse: IHTTPResponse): IBuscaCEPResponse;
begin
  Result := TBuscaCEPResponsePostmon.Create(pIHTTPResponse.ContentAsString, FProvider, FRequestTime);
end;

function TBuscaCEPRequestPostmon.InternalExecute: IHTTPResponse;
var
  lURL: TURI;
  lResource: string;
begin
  // RESOURCE
  lResource := GetResource(FBuscaCEPProvider.Filtro);

  // CONFORME A DOCUMENTAÇÃO DA API
  lURL := TURI.Create(Format('%s%s', [FBuscaCEPProvider.URL, lResource]));

  FHttpRequest.URL := lURL.ToString;
  FHttpRequest.MethodString := 'GET';

  // REQUISIÇÃO
  Result := inherited InternalExecute;
end;
{$ENDREGION}

end.
