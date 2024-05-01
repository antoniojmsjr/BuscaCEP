{******************************************************************************}
{                                                                              }
{           BuscaCEP.Factory.pas                                               }
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
unit BuscaCEP.Factory;

interface

uses
  System.SysUtils, BuscaCEP.Types, BuscaCEP.Interfaces;

type
  TBuscaCEPProviderFactory = class sealed
  strict private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function New(const pProviderKind: TBuscaCEPProvidersKind;
                       pBuscaCEP: IBuscaCEP): IBuscaCEPProviders;
  end;

implementation

uses
  BuscaCEP.Providers.Correios, BuscaCEP.Providers.ViaCEP,
  BuscaCEP.Providers.CEPLivre, BuscaCEP.Providers.CEPAberto,
  BuscaCEP.Providers.RepublicaVirtual, BuscaCEP.Providers.CEPCerto,
  BuscaCEP.Providers.BrasilAPI, BuscaCEP.Providers.KingHost,
  BuscaCEP.Providers.Postmon;

class function TBuscaCEPProviderFactory.New(const pProviderKind: TBuscaCEPProvidersKind;
  pBuscaCEP: IBuscaCEP): IBuscaCEPProviders;
begin
  case pProviderKind of
    TBuscaCEPProvidersKind.UNKNOWN: raise Exception.Create('Provider not implemented...');
    TBuscaCEPProvidersKind.Correios: Result := TBuscaCEPProviderCorreios.Create(pBuscaCEP);
    TBuscaCEPProvidersKind.ViaCEP: Result := TBuscaCEPProviderViaCEP.Create(pBuscaCEP);
    TBuscaCEPProvidersKind.CEPLivre: Result := TBuscaCEPProviderCEPLivre.Create(pBuscaCEP);
    TBuscaCEPProvidersKind.CEPAberto: Result := TBuscaCEPProviderCEPAberto.Create(pBuscaCEP);
    TBuscaCEPProvidersKind.RepublicaVirtual: Result := TBuscaCEPProviderRepublicaVirtual.Create(pBuscaCEP);
    TBuscaCEPProvidersKind.CEPCerto: Result := TBuscaCEPProviderCEPCerto.Create(pBuscaCEP);
    TBuscaCEPProvidersKind.BrasilAPI: Result := TBuscaCEPProviderBrasilAPI.Create(pBuscaCEP);
    TBuscaCEPProvidersKind.KingHost: Result := TBuscaCEPProviderKingHost.Create(pBuscaCEP);
    TBuscaCEPProvidersKind.Postmon: Result := TBuscaCEPProviderPostmon.Create(pBuscaCEP);
  else
    raise Exception.Create('Provider not implemented...');
  end;
end;

end.
