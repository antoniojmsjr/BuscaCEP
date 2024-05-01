{******************************************************************************}
{                                                                              }
{           BuscaCEP.Providers.KingHost.pas                                    }
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
unit BuscaCEP.Providers.Kinghost;

interface

uses
  System.Generics.Collections, System.Net.HttpClient, BuscaCEP.Interfaces,
  BuscaCEP.Core;

type

  {$REGION 'TBuscaCEPProviderKingHost'}
  TBuscaCEPProviderKingHost = class sealed(TBuscaCEPProvidersCustom)
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

  {$REGION 'TBuscaCEPResponseKingHost'}
  TBuscaCEPResponseKingHost = class(TBuscaCEPResponseCustom)
  private
    { private declarations }
    FCEP: string;
  protected
    { protected declarations }
    procedure Parse; override;
  public
    { public declarations }
    constructor Create(const pContent: string; const pProvider: string; const pCEP: string); reintroduce;
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPRequestKingHost'}
  TBuscaCEPRequestKingHost = class sealed(TBuscaCEPRequest)
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

{$REGION 'TBuscaCEPProviderKingHost'}
constructor TBuscaCEPProviderKingHost.Create(pParent: IBuscaCEP);
begin
  inherited Create(pParent);
  FID   := TBuscaCEPProvidersKind.Kinghost.Token;
  FURL  := TBuscaCEPProvidersKind.Kinghost.BaseURL;
end;

function TBuscaCEPProviderKingHost.GetRequest: IBuscaCEPRequest;
begin
  Result := TBuscaCEPRequestKingHost.Create(Self, FBuscaCEP);
end;
{$ENDREGION}

{$REGION 'TBuscaCEPResponseKingHost'}
constructor TBuscaCEPResponseKingHost.Create(const pContent, pProvider,
  pCEP: string);
begin
  inherited Create(pContent, pProvider);
  FCEP := Trim(OnlyNumber(pCEP));
end;

procedure TBuscaCEPResponseKingHost.Parse;
var
  lJSONResponse: TJSONValue;
  lJSONLogradouro: TJSONObject;
  lAPITipoLogradouro: string;
  lAPILogradouro: string;
  lAPIBairro: string;
  lAPILocalidade: string;
  lAPIUF: string;
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

    lJSONLogradouro.TryGetValue<string>('tipo_logradouro',  lAPITipoLogradouro);
    lJSONLogradouro.TryGetValue<string>('logradouro',       lAPILogradouro);
    lJSONLogradouro.TryGetValue<string>('bairro',           lAPIBairro);
    lJSONLogradouro.TryGetValue<string>('cidade',           lAPILocalidade);
    lJSONLogradouro.TryGetValue<string>('uf',               lAPIUF);

    lBuscaCEPLogradouro := TBuscaCEPLogradouro.Create;

    lBuscaCEPLogradouro.Logradouro := Trim(Trim(lAPITipoLogradouro) + ' ' + Trim(lAPILogradouro));
    lBuscaCEPLogradouro.Complemento := EmptyStr;
    lBuscaCEPLogradouro.Bairro := Trim(lAPIBairro);
    lBuscaCEPLogradouro.CEP := FCEP; // API NÃO DEVOLVE O CEP NO JSON

    lAPIUF := Trim(lAPIUF);
    lBuscaCEPLogradouroEstado := TBuscaCEPLogradouroEstado.Create;
    lBuscaCEPLogradouroEstado.Assign(TBuscaCEPEstados.Default.GetEstado(lAPIUF));

    lAPILocalidade := Trim(lAPILocalidade);
    lLocalidadeIBGE := TBuscaCEPLocalidadesIBGE.Default.GetCodigoIBGE(lAPIUF, lAPILocalidade);
    lBuscaCEPLogradouro.Localidade :=
      TBuscaCEPLogradouroLocalidade.Create(lLocalidadeIBGE,
                                           lAPILocalidade,
                                           lBuscaCEPLogradouroEstado);

    FLogradouros.Add(lBuscaCEPLogradouro);
  finally
    lJSONResponse.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TBuscaCEPRequestKingHost'}
procedure TBuscaCEPRequestKingHost.CheckContentResponse(
  pIHTTPResponse: IHTTPResponse);
var
  lMessage: string;
  lContent: string;
  lJSONResponse: TJSONValue;
  lAPIResultado: Integer;
  lBuscaCEPExceptionKind: TBuscaCEPExceptionKind;
begin
  lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_UNKNOWN;
  lMessage := EmptyStr;

  // CHAVE NÃO INFORMADA
  // XML RETORNADO NO ENCONDING ISO-8859-1
  try
    if (pIHTTPResponse.HeaderValue['Content-Type'] = 'text/xml') then
    begin
      lMessage := 'Chave de Autenticação é inválida/não autorizada.';
      lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_REQUEST_INVALID;
      Exit;
    end;
  finally
    if (lMessage <> EmptyStr) then
      raise EBuscaCEP.Create(lBuscaCEPExceptionKind,
                             FProvider,
                             Now(),
                             lMessage);
  end;

  inherited CheckContentResponse(pIHTTPResponse);

  lContent := Trim(pIHTTPResponse.ContentAsString);
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
            Exit;
          end;

          lJSONResponse.TryGetValue<integer>('resultado', lAPIResultado);
          if (lAPIResultado = 0) then
          begin
            lMessage := 'Logradouro não localizado, verificar os parâmetros de filtro.';
            lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_FILTRO_NOT_FOUND;
          end;
        finally
          lJSONResponse.Free;
        end;
      end;
    else
    begin
      lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_REQUEST_INVALID;
      lMessage := lContent;
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

procedure TBuscaCEPRequestKingHost.CheckRequest;
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
                             'CEP informado é inválido.');
    end;
  end;

  // BUSCA POR LOGRADOURO
  if (FBuscaCEPFiltro.FiltroPorLogradouro = True)then
      raise EBuscaCEP.Create(TBuscaCEPExceptionKind.EXCEPTION_FILTRO_INVALID,
                             FProvider,
                             Now(),
                             'Provedor não possui busca por logradouro.');

  if (FBuscaCEPProvider.APIKey = EmptyStr) then
    raise EBuscaCEP.Create(TBuscaCEPExceptionKind.EXCEPTION_REQUEST_INVALID,
                           FProvider,
                           Now(),
                           'Chave de Autenticação é obrigatório e deve ser informado.');
end;

function TBuscaCEPRequestKingHost.GetResource(
  pBuscaCEPFiltro: IBuscaCEPFiltro): string;
var
  lCEP: string;
begin
  Result := EmptyStr;

  // https://webservice.kinghost.net/web_cep.php?auth=999999999999999999999999999999999999&formato=json&cep=90520003
  lCEP := OnlyNumber(FBuscaCEPProvider.Filtro.CEP);
  Result := Concat(Result, '/web_cep.php?');
  Result := Concat(Result, Format('auth=%s', [FBuscaCEPProvider.APIKey]), '&');
  Result := Concat(Result, Format('formato=%s', ['json']), '&');
  Result := Concat(Result, Format('cep=%s', [lCEP]));
end;

function TBuscaCEPRequestKingHost.GetResponse(
  pIHTTPResponse: IHTTPResponse): IBuscaCEPResponse;
begin
  Result := TBuscaCEPResponseKingHost.Create(
    pIHTTPResponse.ContentAsString, FProvider, FBuscaCEPProvider.Filtro.CEP);
end;

function TBuscaCEPRequestKingHost.InternalExecute: IHTTPResponse;
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
