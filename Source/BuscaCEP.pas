{******************************************************************************}
{                                                                              }
{           BuscaCEP.pas                                                       }
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
unit BuscaCEP;

interface

uses
  System.SysUtils, System.Classes, BuscaCEP.Types, BuscaCEP.Interfaces;

type

  {$REGION 'TBuscaCEP'}
  TBuscaCEP = class sealed(TInterfacedObject, IBuscaCEP)
  strict private
    { private declarations }
    FArquivoCache: string;
    FBuscaCEPProviders: IBuscaCEPProviders;
    function GetProviders(const pProvider: TBuscaCEPProvidersKind): IBuscaCEPProviders;
    function GetArquivoCache: string;
    function SetArquivoCache(const pArquivoCache: string): IBuscaCEP;
    function GetVersion: string;
    constructor Create;
  protected
    { protected declarations }
  public
    { public declarations }
    class function New: IBuscaCEP;
  end;
  {$ENDREGION}

implementation

uses
  BuscaCEP.Factory;

{$I BuscaCEP.inc}

{$REGION 'TBuscaCEP'}
class function TBuscaCEP.New: IBuscaCEP;
begin
  Result := Self.Create();
end;

constructor TBuscaCEP.Create;
begin
  {$IFDEF MSWINDOWS}
  FArquivoCache := IncludeTrailingPathDelimiter(GetCurrentDir) + 'BuscaCEP.dat';
  {$ENDIF}
end;

function TBuscaCEP.GetArquivoCache: string;
begin
  Result := FArquivoCache;
end;

function TBuscaCEP.SetArquivoCache(const pArquivoCache: string): IBuscaCEP;
begin
  Result := Self;
  FArquivoCache := pArquivoCache;
end;

function TBuscaCEP.GetProviders(const pProvider: TBuscaCEPProvidersKind): IBuscaCEPProviders;
begin
  if not Assigned(FBuscaCEPProviders) then
    FBuscaCEPProviders := TBuscaCEPProviderFactory.New(pProvider, Self);
  Result := FBuscaCEPProviders;
end;

function TBuscaCEP.GetVersion: string;
begin
  Result := BuscaCEPVersion;
end;
{$ENDREGION}

end.
