{******************************************************************************}
{                                                                              }
{           BuscaCEP.Providers.RepublicaVirtual.pas                            }
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
unit BuscaCEP.Providers.RepublicaVirtual;

interface

uses
  System.Generics.Collections, System.Net.HttpClient, BuscaCEP.Interfaces,
  BuscaCEP.Core;

type

  {$REGION 'TBuscaCEPProviderRepublicaVirtual'}
  TBuscaCEPProviderRepublicaVirtual = class sealed(TBuscaCEPProvidersCustom)
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

  {$REGION 'TBuscaCEPResponseRepublicaVirtual'}
  TBuscaCEPResponseRepublicaVirtual = class(TBuscaCEPResponseCustom)
  private
    { private declarations }
    FCEP: string;
  protected
    { protected declarations }
    procedure Parse; override;
  public
    { public declarations }
    constructor Create(const pContent: string; const pProvider: string;
                       const pRequestTime: Integer; const pCEP: string); reintroduce;
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPRequestRepublicaVirtual'}
  TBuscaCEPRequestRepublicaVirtual = class sealed(TBuscaCEPRequest)
  private
    { private declarations }
    function GetMessageStatusCode403(const pContent: string): string;
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
  System.Classes, System.NetEncoding, System.RegularExpressions, BuscaCEP.Types,
  BuscaCEP.Utils;

{$REGION 'TBuscaCEPProviderRepublicaVirtual'}
constructor TBuscaCEPProviderRepublicaVirtual.Create(pParent: IBuscaCEP);
begin
  inherited Create(pParent);
  FID   := TBuscaCEPProvidersKind.RepublicaVirtual.Token;
  FURL  := TBuscaCEPProvidersKind.RepublicaVirtual.BaseURL;
end;

function TBuscaCEPProviderRepublicaVirtual.GetRequest: IBuscaCEPRequest;
begin
  Result := TBuscaCEPRequestRepublicaVirtual.Create(Self, FBuscaCEP);
end;
{$ENDREGION}

{$REGION 'TBuscaCEPResponseRepublicaVirtual'}
constructor TBuscaCEPResponseRepublicaVirtual.Create(const pContent: string;
  const pProvider: string; const pRequestTime: Integer; const pCEP: string);
begin
  inherited Create(pContent, pProvider, pRequestTime);
  FCEP := OnlyNumber(pCEP);
end;

procedure TBuscaCEPResponseRepublicaVirtual.Parse;
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
    lBuscaCEPLogradouro.Unidade := EmptyStr;
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

{$REGION 'TBuscaCEPRequestRepublicaVirtual'}
procedure TBuscaCEPRequestRepublicaVirtual.CheckContentResponse(
  pIHTTPResponse: IHTTPResponse);
var
  lMessage: string;
  lContent: string;
  lJSONResponse: TJSONValue;
  lAPIResultado: Integer;
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
      403:
      begin
        lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_REQUEST_INVALID;
        lContent := TNetEncoding.URL.Decode(lContent);
        lMessage := GetMessageStatusCode403(lContent);
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

procedure TBuscaCEPRequestRepublicaVirtual.CheckRequest;
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
end;

function TBuscaCEPRequestRepublicaVirtual.GetMessageStatusCode403(
  const pContent: string): string;
var
  lRegEx: TRegEx;
  lMatch: TMatch;
begin
  Result := pContent;

  if (Pos('logradouro=', pContent) = 0) then
    Exit;

  lRegEx := TRegEx.Create('&logradouro=([^;]+)');
  lMatch := lRegEx.Match(pContent);

  if not lMatch.Success then
    Exit;

  Result := Trim(lMatch.Groups[1].Value);
end;

function TBuscaCEPRequestRepublicaVirtual.GetResource(
  pBuscaCEPFiltro: IBuscaCEPFiltro): string;
var
  lCEP: string;
begin
  // http://cep.republicavirtual.com.br/web_cep.php?cep=90520003&formato=json
  lCEP := OnlyNumber(FBuscaCEPProvider.Filtro.CEP);
  Result := Format('/web_cep.php?cep=%s&formato=%s', [lCEP, 'json']);
end;

function TBuscaCEPRequestRepublicaVirtual.GetResponse(
  pIHTTPResponse: IHTTPResponse): IBuscaCEPResponse;
begin
  Result := TBuscaCEPResponseRepublicaVirtual.Create(
    pIHTTPResponse.ContentAsString, FProvider, FRequestTime, FBuscaCEPProvider.Filtro.CEP);
end;

function TBuscaCEPRequestRepublicaVirtual.InternalExecute: IHTTPResponse;
var
  lURL: TURI;
  lResource: string;
begin
  // RESOURCE
  lResource := GetResource(FBuscaCEPProvider.Filtro);

  //CONFORME A DOCUMENTAÇÃO DA API
  lURL := TURI.Create(Format('%s%s', [FBuscaCEPProvider.URL, lResource]));

  FHttpRequest.URL := lURL.ToString;
  FHttpRequest.MethodString := 'GET';

  //REQUISIÇÃO
  Result := inherited InternalExecute;
end;
{$ENDREGION}

end.
