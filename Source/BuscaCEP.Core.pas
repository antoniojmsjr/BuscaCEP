{******************************************************************************}
{                                                                              }
{           BuscaCEP.Core.pas                                                  }
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
unit BuscaCEP.Core;

interface

uses
  BuscaCEP.Interfaces, BuscaCEP.Types, REST.JSon.Types, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, System.Generics.Collections,
  System.Diagnostics;

type

  {$REGION 'TBuscaCEPProvidersCustom'}
  TBuscaCEPProvidersCustom = class(TInterfacedObject, IBuscaCEPProviders)
  strict private
    { private declarations }
    function GetID: string;
    function GetURL: string;
    function GetAPIKey: string;
    function SetAPIKey(const pAPIKey: string): IBuscaCEPProviders;
  protected
    { protected declarations }
    [Weak] //NÃO INCREMENTA O CONTADOR DE REFERÊNCIA
    FBuscaCEP: IBuscaCEP;
    FBuscaCEPFiltro: IBuscaCEPFiltro;
    FID: string;
    FURL: string;
    FAPIKey: string;
    function GetSearch: IBuscaCEPFiltro;
    function GetRequest: IBuscaCEPRequest; virtual; abstract;
  public
    { public declarations }
    constructor Create(pParent: IBuscaCEP); virtual;
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPFiltro'}
  TBuscaCEPFiltro = class(TInterfacedObject, IBuscaCEPFiltro)
  strict private
    { private declarations }
    [Weak] //NÃO INCREMENTA O CONTADOR DE REFERÊNCIA
    FBuscaCEPProviders: IBuscaCEPProviders;
    FFiltroPorCEP: Boolean;
    FFiltroPorLogradouro: Boolean;
    FCEP: string;
    FTipo: TBuscaCEPTipoLogradouroKind;
    FLogradouro: string;
    FIdentificador: string;
    FCidade: string;
    FUF: string;
    function GetFiltroPorCEP: Boolean;
    function GetFiltroPorLogradouro: Boolean;
    function GetCEP: string;
    function SetCEP(const pCEP: string): IBuscaCEPProviders;
    function GetTipo: TBuscaCEPTipoLogradouroKind;
    function SetTipo(const pTipo: TBuscaCEPTipoLogradouroKind): IBuscaCEPFiltro;
    function GetLogradouro: string;
    function SetLogradouro(const pLogradouro: string): IBuscaCEPFiltro;
    function GetIdentificador: string;
    function SetIdentificador(const pIdentificador: string): IBuscaCEPFiltro;
    function GetLocalidade: string;
    function SetLocalidade(const pLocalidade: string): IBuscaCEPFiltro;
    function GetUF: string;
    function SetUF(const pUF: string): IBuscaCEPFiltro;
    function GetEnd: IBuscaCEPProviders;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(pParent: IBuscaCEPProviders); virtual;
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPResponseCustom'}
  TBuscaCEPResponseCustom = class(TInterfacedObject, IBuscaCEPResponse)
  strict private
    { private declarations }
    FProvider: string;
    FDateTime: TDateTime;
    FRequestTime: string;
    function GetProvider: string;
    function GetDateTime: TDateTime;
    function GetRequestTime: string;
    function GetTotal: Integer;
    function GetLogradouros: TObjectList<TBuscaCEPLogradouro>;
    function ToJSONString: string;
  protected
    { protected declarations }
    FContent: string;
    FLogradouros: TObjectList<TBuscaCEPLogradouro>;
    procedure Parse; virtual; abstract;
  public
    { public declarations }
    constructor Create(const pContent: string; const pProvider: string; const pRequestTime: Integer); virtual;
    destructor Destroy; override;
    procedure AfterConstruction; override;
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPRequestCustom'}
  TBuscaCEPRequestCustom = class(TInterfacedObject, IBuscaCEPRequest)
  strict private
    { private declarations }
    function GetTimeout: Integer;
    function SetTimeout(const pMilliseconds: Integer): IBuscaCEPRequest;
    function GetProxyHost: string;
    function SetProxyHost(const pProxyHost: string): IBuscaCEPRequest;
    function GetProxyPort: Integer;
    function SetProxyPort(const pProxyPort: Integer): IBuscaCEPRequest;
    function GetProxyUserName: string;
    function SetProxyUserName(const pProxyUserName: string): IBuscaCEPRequest;
    function GetProxyPassword: string;
    function SetProxyPassword(const pProxyPassword: string): IBuscaCEPRequest;
  protected
    { protected declarations }
    [weak] //NÃO INCREMENTA O CONTADOR DE REFERÊNCIA
    FBuscaCEPProvider: IBuscaCEPProviders;
    FBuscaCEP: IBuscaCEP;
    FBuscaCEPFiltro: IBuscaCEPFiltro;
    FProvider: string;
    FRequestTime: Integer;
    FTimeout: Integer;
    FProxyHost: string;
    FProxyPort: Integer;
    FProxyUserName: string;
    FProxyPassword: string;
    function Execute: IBuscaCEPResponse; virtual; abstract;
  public
    { public declarations }
    constructor Create(pParent: IBuscaCEPProviders; pBuscaCEP: IBuscaCEP); virtual;
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPRequest'}
  TBuscaCEPRequest = class(TBuscaCEPRequestCustom)
  strict private
    { private declarations }
    procedure GetStatusResponse(pHTTPResponse: IHTTPResponse;
                                out poStatusCode: Integer;
                                out poStatusText: string);
  protected
    { protected declarations }
    FRequestHeaders: TNetHeaders;
    FHttpRequest: TNetHTTPRequest;
    FHttpClient: TNetHTTPClient;
    function Execute: IBuscaCEPResponse; override;
    function InternalExecute: IHTTPResponse; virtual;
    function GetResponse(pIHTTPResponse: IHTTPResponse): IBuscaCEPResponse; virtual; abstract;
    procedure CheckRequest; virtual;
    procedure CheckContentResponse(pIHTTPResponse: IHTTPResponse); virtual;
  public
    { public declarations }
    constructor Create(pParent: IBuscaCEPProviders; pBuscaCEP: IBuscaCEP); override;
    destructor Destroy; override;
  end;
  {$ENDREGION}

implementation

uses
  System.SysUtils, System.JSON, REST.Json, BuscaCEP.Utils, System.DateUtils;

{$REGION 'TBuscaCEPProviderCustom'}
constructor TBuscaCEPProvidersCustom.Create(pParent: IBuscaCEP);
begin
  FBuscaCEP := pParent;
  {$IF COMPILERVERSION <= 30.0} //Delphi 10 Seattle / C++Builder 10 Seattle
  FBuscaCEP._Release;
  {$ENDIF}
  FBuscaCEPFiltro := TBuscaCEPFiltro.Create(Self);
  FID := EmptyStr;
  FURL := EmptyStr;
  FAPIKey := EmptyStr;
end;

function TBuscaCEPProvidersCustom.GetAPIKey: string;
begin
  Result := FAPIKey;
end;

function TBuscaCEPProvidersCustom.GetID: string;
begin
  Result := FID;
end;

function TBuscaCEPProvidersCustom.GetSearch: IBuscaCEPFiltro;
begin
  Result := FBuscaCEPFiltro;
end;

function TBuscaCEPProvidersCustom.GetURL: string;
begin
  Result := FURL;
end;

function TBuscaCEPProvidersCustom.SetAPIKey(const pAPIKey: string): IBuscaCEPProviders;
begin
  Result := Self;
  FAPIKey := Trim(pAPIKey);
end;
{$ENDREGION}

{$REGION 'TBuscaCEPFiltro'}
constructor TBuscaCEPFiltro.Create(pParent: IBuscaCEPProviders);
begin
  FBuscaCEPProviders := pParent;
  {$IF COMPILERVERSION <= 30.0} //Delphi 10 Seattle / C++Builder 10 Seattle
  FBuscaCEPProviders._Release;
  {$ENDIF}
  FFiltroPorCEP := False;
  FFiltroPorLogradouro := False;
end;

function TBuscaCEPFiltro.GetCEP: string;
begin
  Result := FCEP;
end;

function TBuscaCEPFiltro.GetLocalidade: string;
begin
  Result := FCidade;
end;

function TBuscaCEPFiltro.GetEnd: IBuscaCEPProviders;
begin
  Result := FBuscaCEPProviders;
end;

function TBuscaCEPFiltro.GetUF: string;
begin
  Result := FUF;
end;

function TBuscaCEPFiltro.GetIdentificador: string;
begin
  Result := FIdentificador;
end;

function TBuscaCEPFiltro.GetLogradouro: string;
begin
  Result := FLogradouro;
end;

function TBuscaCEPFiltro.GetFiltroPorCEP: Boolean;
begin
  Result := FFiltroPorCEP;
end;

function TBuscaCEPFiltro.GetFiltroPorLogradouro: Boolean;
begin
  Result := FFiltroPorLogradouro;
end;

function TBuscaCEPFiltro.GetTipo: TBuscaCEPTipoLogradouroKind;
begin
  Result := FTipo;
end;

function TBuscaCEPFiltro.SetCEP(const pCEP: string): IBuscaCEPProviders;
begin
  Result := FBuscaCEPProviders;
  FCEP := Trim(pCEP);
  FFiltroPorCEP := True;
end;

function TBuscaCEPFiltro.SetLocalidade(const pLocalidade: string): IBuscaCEPFiltro;
begin
  Result := Self;
  FCidade := Trim(pLocalidade);
  FFiltroPorLogradouro := True;
end;

function TBuscaCEPFiltro.SetUF(const pUF: string): IBuscaCEPFiltro;
begin
  Result := Self;
  FUF := Trim(pUF);
  FFiltroPorLogradouro := True;
end;

function TBuscaCEPFiltro.SetIdentificador(const pIdentificador: string): IBuscaCEPFiltro;
begin
  Result := Self;
  FIdentificador := Trim(pIdentificador);
  FFiltroPorLogradouro := True;
end;

function TBuscaCEPFiltro.SetLogradouro(const pLogradouro: string): IBuscaCEPFiltro;
begin
  Result := Self;
  FLogradouro := Trim(pLogradouro);
  FFiltroPorLogradouro := True;
end;

function TBuscaCEPFiltro.SetTipo(const pTipo: TBuscaCEPTipoLogradouroKind): IBuscaCEPFiltro;
begin
  Result := Self;
  FTipo := pTipo;
  FFiltroPorLogradouro := True;
end;
{$ENDREGION}

{$REGION 'TBuscaCEPRequestCustom'}
constructor TBuscaCEPRequestCustom.Create(pParent: IBuscaCEPProviders; pBuscaCEP: IBuscaCEP);
begin
  FBuscaCEP := pBuscaCEP;
  {$IF COMPILERVERSION <= 30.0} //Delphi 10 Seattle / C++Builder 10 Seattle
  FBuscaCEP._Release;
  {$ENDIF}
  FBuscaCEPProvider := pParent;
  FBuscaCEPFiltro := FBuscaCEPProvider.Filtro;
  FProvider := FBuscaCEPProvider.ID;
  FTimeout := 15000; //15 sg
  FRequestTime := 0;
end;

function TBuscaCEPRequestCustom.GetProxyHost: string;
begin
  Result := FProxyHost;
end;

function TBuscaCEPRequestCustom.GetProxyPassword: string;
begin
  Result := FProxyPassword;
end;

function TBuscaCEPRequestCustom.GetProxyPort: Integer;
begin
  Result := FProxyPort;
end;

function TBuscaCEPRequestCustom.GetProxyUserName: string;
begin
  Result := FProxyUserName;
end;

function TBuscaCEPRequestCustom.GetTimeout: Integer;
begin
  Result := FTimeout;
end;

function TBuscaCEPRequestCustom.SetProxyHost(const pProxyHost: string): IBuscaCEPRequest;
begin
  Result := Self;
  FProxyHost := pProxyHost;
end;

function TBuscaCEPRequestCustom.SetProxyPassword(const pProxyPassword: string): IBuscaCEPRequest;
begin
  Result := Self;
  FProxyPassword := pProxyPassword;
end;

function TBuscaCEPRequestCustom.SetProxyPort(const pProxyPort: Integer): IBuscaCEPRequest;
begin
  Result := Self;
  FProxyPort := pProxyPort;
end;

function TBuscaCEPRequestCustom.SetProxyUserName(const pProxyUserName: string): IBuscaCEPRequest;
begin
  Result := Self;
  FProxyUserName := pProxyUserName;
end;

function TBuscaCEPRequestCustom.SetTimeout(const pMilliseconds: Integer): IBuscaCEPRequest;
begin
  Result := Self;
  FTimeout := pMilliseconds;
end;
{$ENDREGION}

{$REGION 'TBuscaCEPRequest'}
procedure TBuscaCEPRequest.CheckContentResponse(pIHTTPResponse: IHTTPResponse);
var
  lContent: string;
begin
  lContent := Trim(pIHTTPResponse.ContentAsString);

  // RESPOSTA COM CONTEÚDO?
  if ((pIHTTPResponse.StatusCode = 200) and lContent.IsEmpty) then
    raise EBuscaCEP.Create(TBuscaCEPExceptionKind.EXCEPTION_FILTRO_INVALID,
                           FProvider,
                           Now(),
                           'Logradouro não encontrado. Verifique os parâmetros de filtro.');
end;

procedure TBuscaCEPRequest.CheckRequest;
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
  begin
    if (FBuscaCEPFiltro.Logradouro = EmptyStr)
    or (FBuscaCEPFiltro.Localidade = EmptyStr)
    or (FBuscaCEPFiltro.UF = EmptyStr) then
    begin
      raise EBuscaCEP.Create(TBuscaCEPExceptionKind.EXCEPTION_FILTRO_INVALID,
                             FProvider,
                             Now(),
                             'O filtro por logradouro está incompleto. Informe os seguintes campos:' + sLineBreak +
                             'Logradouro/Localidade/UF');
    end;
  end;
end;

constructor TBuscaCEPRequest.Create(pParent: IBuscaCEPProviders; pBuscaCEP: IBuscaCEP);
begin
  inherited Create(pParent, pBuscaCEP);

  FHttpRequest := TNetHTTPRequest.Create(nil);
  FHttpClient := TNetHTTPClient.Create(FHttpRequest);
  FHttpRequest.Client := FHttpClient;

  FHttpClient.HandleRedirects := False;
  {$IF COMPILERVERSION >= 32.0}
  FHttpClient.SecureProtocols := [];
  FHttpClient.SecureProtocols := [THTTPSecureProtocol.TLS1,
                                  THTTPSecureProtocol.TLS11,
                                  THTTPSecureProtocol.TLS12];
  {$ENDIF}

  // PROCESSAR ARQUIVO BuscaCEP.dat
  TBuscaCEPCache.Default.Processar(FBuscaCEP.ArquivoCache);
end;

destructor TBuscaCEPRequest.Destroy;
begin
  FHttpRequest.Free;
  inherited Destroy;
end;

function TBuscaCEPRequest.Execute: IBuscaCEPResponse;
var
  lIHTTPResponse: IHTTPResponse;
  lStatusCode: Integer;
  lStatusText: String;
begin
  lStatusCode := 0;
  lStatusText := EmptyStr;

  // PARAMS
  {$IF COMPILERVERSION >= 31.0}
  FHttpRequest.ConnectionTimeout := FTimeout;
  FHttpRequest.ResponseTimeout := FTimeout;
  {$ENDIF}
  FHttpRequest.Client.ProxySettings :=
    TProxySettings.Create(FProxyHost,
                          FProxyPort,
                          FProxyUserName,
                          FProxyPassword,
                          EmptyStr);
  FHttpRequest.MethodString := 'GET';
  FHttpRequest.Client.Accept := '*/*';
  FHttpRequest.Client.UserAgent := 'BuscaCEP';

  try
    // REQUEST
    lIHTTPResponse := InternalExecute();

    if (lIHTTPResponse.StatusCode = 200) then
      Result := GetResponse(lIHTTPResponse);
  except
    on E: EBuscaCEP do
    begin
      GetStatusResponse(lIHTTPResponse, lStatusCode, lStatusText);
      raise EBuscaCEPRequest.Create(
        E.Kind,
        E.Provider,
        E.DateTime,
        FHttpRequest.URL,
        lStatusCode,
        lStatusText,
        FHttpRequest.MethodString,
        E.Message);
    end;
    on E: Exception do
    begin
      GetStatusResponse(lIHTTPResponse, lStatusCode, lStatusText);
      raise EBuscaCEPRequest.Create(
        TBuscaCEPExceptionKind.EXCEPTION_OTHERS,
        FProvider,
        Now(),
        FHttpRequest.URL,
        lStatusCode,
        lStatusText,
        FHttpRequest.MethodString,
        E.Message);
    end;
  end;
end;

procedure TBuscaCEPRequest.GetStatusResponse(pHTTPResponse: IHTTPResponse; out poStatusCode: Integer; out poStatusText: string);
begin
  poStatusCode := 0;
  poStatusText := EmptyStr;
  try
    if Assigned(pHTTPResponse) then
    begin
      poStatusCode := pHTTPResponse.StatusCode;
      poStatusText := pHTTPResponse.StatusText;
    end;
  except
  end;
end;

function TBuscaCEPRequest.InternalExecute: IHTTPResponse;
var
  lRequestTime: TStopWatch;
begin
  CheckRequest;

  // REQUISIÇÃO
  try
    try
      lRequestTime := TStopWatch.StartNew;

      Result := FHttpRequest.Execute(FRequestHeaders);
      lRequestTime.Stop;
    except
      on E: Exception do
      begin
        lRequestTime.Stop;

        if (E is ENetHTTPClientException) then
          raise EBuscaCEP.Create(TBuscaCEPExceptionKind.EXCEPTION_HTTP,
                                 FProvider, Now(), E.Message);

        raise EBuscaCEP.Create(TBuscaCEPExceptionKind.EXCEPTION_OTHERS,
                               FProvider, Now(), E.Message);
      end;
    end;
  finally
    FRequestTime := lRequestTime.ElapsedMilliseconds;
  end;

  CheckContentResponse(Result);
end;
{$ENDREGION}

{$REGION 'TBuscaCEPResponseCustom'}
constructor TBuscaCEPResponseCustom.Create(const pContent: string; const pProvider: string; const pRequestTime: Integer);
begin
  FContent := pContent;
  FProvider := pProvider;
  FDateTime := Now();
  FRequestTime := Format('%dms', [pRequestTime]);
  FLogradouros := TObjectList<TBuscaCEPLogradouro>.Create;
end;

procedure TBuscaCEPResponseCustom.AfterConstruction;
begin
  inherited;
  Parse;
end;

destructor TBuscaCEPResponseCustom.Destroy;
begin
  FLogradouros.Free;
  inherited Destroy;
end;

function TBuscaCEPResponseCustom.GetDateTime: TDateTime;
begin
  Result := FDateTime;
end;

function TBuscaCEPResponseCustom.GetLogradouros: TObjectList<TBuscaCEPLogradouro>;
begin
  Result := FLogradouros;
end;

function TBuscaCEPResponseCustom.GetProvider: string;
begin
  Result := FProvider;
end;

function TBuscaCEPResponseCustom.GetRequestTime: string;
begin
  Result := FRequestTime;
end;

function TBuscaCEPResponseCustom.GetTotal: Integer;
begin
  Result := FLogradouros.Count;
end;

function TBuscaCEPResponseCustom.ToJSONString: string;
var
  lJSONObject: TJSONObject;
  lJSONArray: TJSONArray;
  lBuscaCEPLogradouro: TBuscaCEPLogradouro;
begin
  lJSONObject := TJSONObject.Create;
  try

    lJSONObject.AddPair('provider', TJSONString.Create(FProvider));
    lJSONObject.AddPair('date_time', TJSONString.Create(DateToISO8601(FDateTime, False)));
    lJSONObject.AddPair('request_time', TJSONString.Create(FRequestTime));
    lJSONObject.AddPair('total', TJSONNumber.Create(FLogradouros.Count));

    lJSONArray := TJSONArray.Create;
    for lBuscaCEPLogradouro in FLogradouros do
      lJSONArray.Add(lBuscaCEPLogradouro.ToJSONObject);

    lJSONObject.AddPair('logradouros', lJSONArray);

    // IMPLÍCITO TEncoding.UTF8
    Result := lJSONObject.ToJSON;
  finally
    lJSONObject.Free;
  end;
end;
{$ENDREGION}

end.
