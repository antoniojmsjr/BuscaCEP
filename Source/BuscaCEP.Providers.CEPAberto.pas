{******************************************************************************}
{                                                                              }
{           BuscaCEP.Providers.CEPAberto.pas                                   }
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
unit BuscaCEP.Providers.CEPAberto;

interface

uses
  System.Generics.Collections, System.Net.HttpClient, BuscaCEP.Interfaces,
  BuscaCEP.Core;

type
  {$REGION 'TBuscaCEPProviderCEPAberto'}
  TBuscaCEPProviderCEPAberto = class sealed(TBuscaCEPProvidersCustom)
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

  {$REGION 'TBuscaCEPResponseCEPAberto'}
  TBuscaCEPResponseCEPAberto = class(TBuscaCEPResponseCustom)
  private
    { private declarations }
  protected
    { protected declarations }
    procedure Parse; override;
  public
    { public declarations }
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPRequestCEPAberto'}
  TBuscaCEPRequestCEPAberto = class sealed(TBuscaCEPRequest)
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
  System.JSON, System.SysUtils, System.StrUtils, System.Net.URLClient,
  System.Classes, BuscaCEP.Types, BuscaCEP.Utils;

{$REGION 'TBuscaCEPProviderCEPAberto'}
constructor TBuscaCEPProviderCEPAberto.Create(pParent: IBuscaCEP);
begin
  inherited Create(pParent);
  FID   := TBuscaCEPProvidersKind.CEPAberto.Token;
  FURL  := TBuscaCEPProvidersKind.CEPAberto.BaseURL;
end;

function TBuscaCEPProviderCEPAberto.GetRequest: IBuscaCEPRequest;
begin
  Result := TBuscaCEPRequestCEPAberto.Create(Self, FBuscaCEP);
end;
{$ENDREGION}

{$REGION 'TBuscaCEPResponseCEPAberto'}
procedure TBuscaCEPResponseCEPAberto.Parse;
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
    if not Assigned(lJSONResponse) and not (lJSONResponse is TJSONObject) then
      Exit;

    lJSONLogradouro := (lJSONResponse as TJSONObject);

    lJSONLogradouro.TryGetValue<string>('logradouro',  lAPILogradouro);
    lJSONLogradouro.TryGetValue<string>('complemento', lAPIComplemento);
    lJSONLogradouro.TryGetValue<string>('bairro',      lAPIBairro);
    lJSONLogradouro.GetValue('cidade').TryGetValue<string>('nome', lAPILocalidade);
    lJSONLogradouro.TryGetValue<string>('cep',         lAPICEP);
    lJSONLogradouro.GetValue('estado').TryGetValue<string>('sigla', lAPIUF);

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

{$REGION 'TBuscaCEPRequestCEPAberto'}
procedure TBuscaCEPRequestCEPAberto.CheckContentResponse(pIHTTPResponse: IHTTPResponse);
var
  lMessage: string;
  lContent: string;
  lJSONResponse: TJSONValue;
  lBuscaCEPExceptionKind: TBuscaCEPExceptionKind;
  lAPIMessage: string;
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

          if (lJSONResponse.ToString = '{}') then
          begin
            lMessage := 'Logradouro não encontrado. Verifique os parâmetros de filtro.';
            lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_FILTRO_NOT_FOUND;
          end;
        finally
          lJSONResponse.Free;
        end;
      end;
      400:
      begin
        lJSONResponse := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(lContent), 0);
        try
          if (lJSONResponse is TJSONObject) then
          begin
            if lJSONResponse.TryGetValue<string>('message', lAPIMessage) then
            begin
              lMessage := lAPIMessage;
              lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_REQUEST_INVALID;
            end;
          end;
        finally
          lJSONResponse.Free;
        end;
      end;
      401:
      begin
        lMessage := 'A Chave de Autenticação é obrigatória e deve ser informada.';
        lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_REQUEST_INVALID;
      end;
      403:
      begin
        lMessage := 'O limite de requisições foi atingido. Tente novamente mais tarde.';
        lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_REQUEST_INVALID;
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

procedure TBuscaCEPRequestCEPAberto.CheckRequest;
begin
  inherited CheckRequest;

  if (FBuscaCEPProvider.APIKey = EmptyStr) then
    raise EBuscaCEP.Create(TBuscaCEPExceptionKind.EXCEPTION_REQUEST_INVALID,
                           FProvider,
                           Now(),
                           'A Chave de Autenticação é obrigatória e deve ser informada.');
end;

function TBuscaCEPRequestCEPAberto.GetResource(pBuscaCEPFiltro: IBuscaCEPFiltro): string;
var
  lCEP: string;
begin
  Result := EmptyStr;
  case pBuscaCEPFiltro.FiltroPorCEP of
    True:
    begin
      // https://www.cepaberto.com/api/v3/cep?cep=90520003
      lCEP := OnlyNumber(FBuscaCEPProvider.Filtro.CEP);
      Result := Format('/api/v3/cep?cep=%s', [lCEP]);
    end;
    False:
    begin
      // https://www.cepaberto.com/api/v3/address/estado=rs&cidade=porto alegre&logradouro=plinio brasil milano
      Result := Concat(Result, '/api/v3/address?');
      Result := Concat(Result, Format('estado=%s', [pBuscaCEPFiltro.UF]), '&');
      Result := Concat(Result, Format('cidade=%s', [pBuscaCEPFiltro.Localidade]), '&');
      Result := Concat(Result, Format('logradouro=%s', [pBuscaCEPFiltro.Logradouro]));
    end;
  end;
end;

function TBuscaCEPRequestCEPAberto.GetResponse(pIHTTPResponse: IHTTPResponse): IBuscaCEPResponse;
begin
  Result := TBuscaCEPResponseCEPAberto.Create(pIHTTPResponse.ContentAsString, FProvider, FRequestTime);
end;

function TBuscaCEPRequestCEPAberto.InternalExecute: IHTTPResponse;
var
  lURL: TURI;
  lResource: string;
begin
  // RESOURCE
  lResource := GetResource(FBuscaCEPProvider.Filtro);

  //CONFORME A DOCUMENTAÇÃO DA API
  lURL := TURI.Create(Format('%s%s', [FBuscaCEPProvider.URL, lResource]));

  FRequestHeaders := [TNetHeader.Create('Authorization', 'Token token=' + FBuscaCEPProvider.APIKey)];
  FHttpRequest.URL := lURL.ToString;
  FHttpRequest.MethodString := 'GET';

  //REQUISIÇÃO
  Result := inherited InternalExecute;
end;
{$ENDREGION}

end.
