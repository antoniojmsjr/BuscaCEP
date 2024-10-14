{******************************************************************************}
{                                                                              }
{           BuscaCEP.Providers.Correios.pas                                    }
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
unit BuscaCEP.Providers.Correios;

interface

uses
  System.Generics.Collections, System.Net.HttpClient, BuscaCEP.Interfaces,
  BuscaCEP.Core;

type

  {$REGION 'TBuscaCEPProviderCorreios'}
  TBuscaCEPProviderCorreios = class sealed(TBuscaCEPProvidersCustom)
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

  {$REGION 'TBuscaCEPResponseCorreios'}
  TBuscaCEPResponseCorreios = class(TBuscaCEPResponseCustom)
  private
    { private declarations }
    function GetLogradouro(const pLogradouro: string): string;
    function GetComplemento(const pLogradouro: string): string;
  protected
    { protected declarations }
    procedure Parse; override;
  public
    { public declarations }
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPRequestCorreios'}
  TBuscaCEPRequestCorreios = class sealed(TBuscaCEPRequest)
  private
    { private declarations }
    function GetFORMData(pBuscaCEPFiltro: IBuscaCEPFiltro): string;
    procedure GetResource(pBuscaCEPFiltro: IBuscaCEPFiltro;
                          out poResource: string;
                          out poReferer: string);
  protected
    { protected declarations }
    function InternalExecute: IHTTPResponse; override;
    function GetResponse(pIHTTPResponse: IHTTPResponse): IBuscaCEPResponse; override;
    procedure CheckContentResponse(pIHTTPResponse: IHTTPResponse); override;
  public
    { public declarations }
  end;
  {$ENDREGION}

implementation

uses
  System.JSON, System.SysUtils, System.Net.URLClient, System.Classes,
  BuscaCEP.Types, BuscaCEP.Utils, BuscaCEP.Providers.Correios.Utils;

{$REGION 'TBuscaCEPProviderCorreios'}
constructor TBuscaCEPProviderCorreios.Create(pParent: IBuscaCEP);
begin
  inherited Create(pParent);
  FID   := TBuscaCEPProvidersKind.Correios.Token;
  FURL  := TBuscaCEPProvidersKind.Correios.BaseURL;
end;

function TBuscaCEPProviderCorreios.GetRequest: IBuscaCEPRequest;
begin
  Result := TBuscaCEPRequestCorreios.Create(Self, FBuscaCEP);
end;
{$ENDREGION}

{$REGION 'TBuscaCEPResponseCorreios'}
function TBuscaCEPResponseCorreios.GetComplemento(const pLogradouro: string): string;
var
  lPosComplemento: Integer;
begin
  Result := EmptyStr;
  lPosComplemento := Pos(' - ', pLogradouro);

  if (lPosComplemento > 0) then
    Result := Trim(Copy(pLogradouro, (lPosComplemento + 2), (Length(pLogradouro))));
end;

function TBuscaCEPResponseCorreios.GetLogradouro(const pLogradouro: string): string;
var
  lPosComplemento: Integer;
begin
  Result := Trim(pLogradouro);
  lPosComplemento := Pos(' - ', pLogradouro);

  if (lPosComplemento > 0) then
    Delete(Result, lPosComplemento, (lPosComplemento + Length(pLogradouro)));

  Result := Trim(Result);
end;

procedure TBuscaCEPResponseCorreios.Parse;
var
  I: Integer;
  lJSONResponse: TJSONValue;
  lJSONLogradouros: TJSONArray;
  lJSONLogradouro: TJSONObject;
  lAPILogradouro: string;
  lAPIUnidade: string;
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

    lJSONResponse.TryGetValue<TJSONArray>('dados', lJSONLogradouros);
    if not Assigned(lJSONLogradouros) then
      Exit;

    for I := 0 to Pred(lJSONLogradouros.Count) do
    begin
      lJSONLogradouro := (lJSONLogradouros.Items[I] as TJSONObject);

      lJSONLogradouro.TryGetValue<string>('logradouroDNEC', lAPILogradouro);
      lJSONLogradouro.TryGetValue<string>('nomeUnidade',    lAPIUnidade);
      lJSONLogradouro.TryGetValue<string>('bairro',         lAPIBairro);
      lJSONLogradouro.TryGetValue<string>('localidade',     lAPILocalidade);
      lJSONLogradouro.TryGetValue<string>('uf',             lAPIUF);
      lJSONLogradouro.TryGetValue<string>('cep',            lAPICEP);

      lBuscaCEPLogradouro := TBuscaCEPLogradouro.Create;

      lBuscaCEPLogradouro.Logradouro := GetLogradouro(lAPILogradouro);
      lBuscaCEPLogradouro.Complemento := GetComplemento(lAPILogradouro);
      lBuscaCEPLogradouro.Unidade := Trim(lAPIUnidade);
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
    end;
  finally
    lJSONResponse.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TBuscaCEPRequestCorreios'}
procedure TBuscaCEPRequestCorreios.CheckContentResponse(pIHTTPResponse: IHTTPResponse);
var
  lMessage: string;
  lContent: string;
  lJSONResponse: TJSONValue;
  lAPIMensagem: string;
  lAPITotal: Integer;
  lAPIDados: TJSONArray;
  lRequisicaoInvalida: Boolean;
  lBuscaCEPExceptionKind: TBuscaCEPExceptionKind;
begin
  inherited CheckContentResponse(pIHTTPResponse);

  lAPITotal := 0;
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

          lJSONResponse.TryGetValue('mensagem', lAPIMensagem);
          lJSONResponse.TryGetValue('total', lAPITotal);
          lJSONResponse.TryGetValue('dados', lAPIDados);

          // REQUISIÇÃO INVÁLIDA E DEVOLVE A MENSAGEM DA API PARA O CLIENTE
          lRequisicaoInvalida := (Assigned(lAPIDados) and (lAPIDados.Count = 0) and (lAPITotal = 0));
          if lRequisicaoInvalida then
          begin
            lMessage := lAPIMensagem;
            lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_FILTRO_NOT_FOUND;
          end;
        finally
          lJSONResponse.Free;
        end;
      end;
      302:
      begin
        lMessage := 'O filtro informado é inválido.';
        lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_FILTRO_INVALID;
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

function TBuscaCEPRequestCorreios.GetFORMData(pBuscaCEPFiltro: IBuscaCEPFiltro): string;
begin
  Result := BuscaCEP.Providers.Correios.Utils.GetFORMData(pBuscaCEPFiltro);
end;

procedure TBuscaCEPRequestCorreios.GetResource(pBuscaCEPFiltro: IBuscaCEPFiltro; out poResource: string; out poReferer: string);
begin
  if pBuscaCEPFiltro.FiltroPorCEP then
  begin
    poResource := '/app/cep/carrega-cep.php';
    poReferer := 'https://buscacepinter.correios.com.br/app/cep/index.php';
  end
  else
  begin
    poResource := '/app/localidade_logradouro/carrega-localidade-logradouro.php';
    poReferer := 'https://buscacepinter.correios.com.br/app/localidade_logradouro/index.php';
  end;
end;

function TBuscaCEPRequestCorreios.GetResponse(pIHTTPResponse: IHTTPResponse): IBuscaCEPResponse;
begin
  Result := TBuscaCEPResponseCorreios.Create(pIHTTPResponse.ContentAsString, FProvider, FRequestTime);
end;

function TBuscaCEPRequestCorreios.InternalExecute: IHTTPResponse;
var
  lURL: TURI;
  lResource: string;
  lReferer: string;
  lBody: TStringStream;
begin
  // RESOURCE
  GetResource(FBuscaCEPProvider.Filtro, lResource, lReferer);

  // CONFORME A DOCUMENTAÇÃO DA API
  lURL := TURI.Create(Format('%s%s', [FBuscaCEPProvider.URL, lResource]));

  FHttpRequest.URL := lURL.ToString;
  FHttpRequest.MethodString := 'POST';

  FHttpRequest.Client.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
  FHttpRequest.Client.Accept := '*/*';
  FHttpRequest.Client.AcceptEncoding := 'gzip, deflate';
  FHttpRequest.Client.AcceptLanguage := 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7';
  FHttpRequest.Client.ContentType := 'application/x-www-form-urlencoded; charset=UTF-8';
  FHttpRequest.Client.CustomHeaders['referer'] := lReferer;
  FHttpRequest.Client.CustomHeaders['sec-ch-ua'] := '"Google Chrome";v="123", "Not:A-Brand";v="8", "Chromium";v="123"';
  FHttpRequest.Client.CustomHeaders['Sec-ch-ua-platform'] := '"Windows"';
  FHttpRequest.Client.CustomHeaders['Sec-Fetch-Dest'] := 'empty';
  FHttpRequest.Client.CustomHeaders['Sec-Fetch-Mode'] := 'cors';
  FHttpRequest.Client.CustomHeaders['Sec-Fetch-Site'] := 'same-origin';
  FHttpRequest.Client.CustomHeaders['Cache-Control'] := 'no-store, no-cache, must-revalidate';
  FHttpRequest.Client.CustomHeaders['cookie'] := 'buscacep=gfeimes3q1lclr06u08g9ku5td; LBprdint2=3275358218.47873.0000; LBprdExt1=701038602.47873.0000';

  lBody := TStringStream.Create(EmptyStr, TEncoding.UTF8);
  try
    lBody.WriteString(GetFORMData(FBuscaCEPProvider.Filtro));
    lBody.Position := 0;
    FHttpRequest.SourceStream := lBody;

    // REQUISIÇÃO
    Result := inherited InternalExecute;
  finally
    lBody.Free;
  end;
end;
{$ENDREGION}

end.
