{******************************************************************************}
{                                                                              }
{           BuscaCEP.Interfaces.pas                                            }
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
unit BuscaCEP.Interfaces;

interface

uses
  BuscaCEP.Types, System.SysUtils, REST.Json.Types, System.Generics.Collections;

type

  IBuscaCEPProviders = interface;
  IBuscaCEPRequest = interface;
  IBuscaCEPResponse = interface;

  IBuscaCEP = interface
    ['{7FAF6DFF-4B8C-409A-8B51-5C38643ECD8D}']
    function GetProviders(const Provider: TBuscaCEPProvidersKind): IBuscaCEPProviders;
    function GetArquivoIBGE: string;
    function SetArquivoIBGE(const ArquivoIBGE: string): IBuscaCEP;

    property Providers[const Provider: TBuscaCEPProvidersKind]: IBuscaCEPProviders read GetProviders;
    property ArquivoIBGE: string read GetArquivoIBGE;
  end;

  IBuscaCEPFiltro = interface
    ['{C13D16F8-F62B-477B-A93B-B3A1811065CF}']
    function GetFiltroPorCEP: Boolean;
    function GetFiltroPorLogradouro: Boolean;
    function GetCEP: string;
    function SetCEP(const CEP: string): IBuscaCEPProviders;
    function GetTipo: TBuscaCEPTipoLogradouroKind;
    function SetTipo(const Tipo: TBuscaCEPTipoLogradouroKind): IBuscaCEPFiltro;
    function GetLogradouro: string;
    function SetLogradouro(const Logradouro: string): IBuscaCEPFiltro;
    function GetIdentificador: string;
    function SetIdentificador(const Identificador: string): IBuscaCEPFiltro;
    function GetLocalidade: string;
    function SetLocalidade(const Localidade: string): IBuscaCEPFiltro;
    function GetUF: string;
    function SetUF(const UF: string): IBuscaCEPFiltro;
    function GetEnd: IBuscaCEPProviders;

    property FiltroPorCEP: Boolean read GetFiltroPorCEP;
    property FiltroPorLogradouro: Boolean read GetFiltroPorLogradouro;
    property CEP: string read GetCEP;
    property Tipo: TBuscaCEPTipoLogradouroKind read GetTipo;
    property Logradouro: string read GetLogradouro;
    property Identificador: string read GetIdentificador;
    property Localidade: string read GetLocalidade;
    property UF: string read GetUF;
    property &End: IBuscaCEPProviders read GetEnd;
  end;

  IBuscaCEPProviders = interface
    ['{3DC5C329-8779-4DE0-BF99-005B8EC0B415}']
    function GetID: string;
    function GetURL: string;
    function GetAPIKey: string;
    function GetSearch: IBuscaCEPFiltro;
    function GetRequest: IBuscaCEPRequest;
    function SetAPIKey(const APIKey: string): IBuscaCEPProviders;

    property ID: string read GetID;
    property URL: string read GetURL;
    property APIKey: string read GetAPIKey;
    property Filtro: IBuscaCEPFiltro read GetSearch;
    property Request: IBuscaCEPRequest read GetRequest;
  end;

  IBuscaCEPRequest = interface
    ['{36EB2AC6-1084-4189-9773-788F3CA77133}']
    function GetTimeout: Integer;
    function SetTimeout(const Milliseconds: Integer): IBuscaCEPRequest;
    function GetProxyHost: string;
    function SetProxyHost(const ProxyHost: string): IBuscaCEPRequest;
    function GetProxyPort: Integer;
    function SetProxyPort(const ProxyPort: Integer): IBuscaCEPRequest;
    function GetProxyUserName: string;
    function SetProxyUserName(const ProxyUserName: string): IBuscaCEPRequest;
    function GetProxyPassword: string;
    function SetProxyPassword(const ProxyPassword: string): IBuscaCEPRequest;
    function Execute: IBuscaCEPResponse;

    property Timeout: Integer read GetTimeout;
    property ProxyHost: string read GetProxyHost;
    property ProxyPort: Integer read GetProxyPort;
    property ProxyUserName: string read GetProxyUserName;
    property ProxyPassword: string read GetProxyPassword;
  end;

  IBuscaCEPResponse = interface
    ['{59F068C8-54EE-4D45-BA74-47F375C0CB43}']
    function GetProvider: string;
    function GetDateTime: TDateTime;
    function GetTotal: Integer;
    function GetLogradouros: TObjectList<TBuscaCEPLogradouro>;
    function ToJSONString: string;

    property Provider: string read GetProvider;
    property DateTime: TDateTime read GetDateTime;
    property Total: Integer read GetTotal;
    property Logradouros: TObjectList<TBuscaCEPLogradouro> read GetLogradouros;
  end;

implementation

end.
