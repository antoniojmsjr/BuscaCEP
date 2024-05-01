{******************************************************************************}
{                                                                              }
{           BuscaCEP.Providers.CEPCerto.pas                                    }
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
unit BuscaCEP.Providers.CEPCerto;

interface

uses
  System.Generics.Collections, System.Net.HttpClient, BuscaCEP.Interfaces,
  BuscaCEP.Core;

type

  {$REGION 'TBuscaCEPProviderCEPCerto'}
  TBuscaCEPProviderCEPCerto = class sealed(TBuscaCEPProvidersCustom)
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

  {$REGION 'TBuscaCEPResponseCEPCerto'}
  TBuscaCEPResponseCEPCerto = class(TBuscaCEPResponseCustom)
  private
    { private declarations }
  protected
    { protected declarations }
    procedure Parse; override;
  public
    { public declarations }
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPRequestCEPCerto'}
  TBuscaCEPRequestCEPCerto = class sealed(TBuscaCEPRequest)
  private
    { private declarations }
    function GetResource(pBuscaCEPFiltro: IBuscaCEPFiltro): string;
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
  System.JSON, System.SysUtils, System.StrUtils, System.Net.URLClient,
  System.Classes, BuscaCEP.Types, BuscaCEP.Utils;

{$REGION 'TBuscaCEPProviderCEPCerto'}
constructor TBuscaCEPProviderCEPCerto.Create(pParent: IBuscaCEP);
begin
  inherited Create(pParent);
  FID   := TBuscaCEPProvidersKind.CEPCerto.Token;
  FURL  := TBuscaCEPProvidersKind.CEPCerto.BaseURL;
end;

function TBuscaCEPProviderCEPCerto.GetRequest: IBuscaCEPRequest;
begin
  Result := TBuscaCEPRequestCEPCerto.Create(Self, FBuscaCEP);
end;
{$ENDREGION}

{$REGION 'TBuscaCEPProviderCEPCerto'}
procedure TBuscaCEPResponseCEPCerto.Parse;
var
  I: Integer;
  lJSONResponse: TJSONValue;
  lJSONLogradouros: TJSONArray;
  lJSONLogradouro: TJSONObject;
  lAPILogradouro: string;
  lAPIComplemento: string;
  lAPIBairro: string;
  lAPILocalidade: string;
  lAPIUF: string;
  lAPICEP: string;
  lLocalidadeIBGE: Integer;
  lBuscaCEPLogradouro: TBuscaCEPLogradouro;
  lBuscaCEPLogradouroEstado: TBuscaCEPLogradouroEstado;
begin
  lJSONResponse := nil;
  try
    lJSONResponse := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(FContent), 0);
    if not Assigned(lJSONResponse) then
      Exit;

    if (lJSONResponse is TJSONObject) then
    begin
      lJSONLogradouro := (lJSONResponse as TJSONObject);

      lJSONLogradouro.TryGetValue<string>('logradouro',  lAPILogradouro);
      lJSONLogradouro.TryGetValue<string>('complemento', lAPIComplemento);
      lJSONLogradouro.TryGetValue<string>('bairro',      lAPIBairro);
      lJSONLogradouro.TryGetValue<string>('localidade',  lAPILocalidade);
      lJSONLogradouro.TryGetValue<string>('uf',          lAPIUF);
      lJSONLogradouro.TryGetValue<string>('cep',         lAPICEP);

      lBuscaCEPLogradouro := TBuscaCEPLogradouro.Create;

      lBuscaCEPLogradouro.Logradouro := Trim(lAPILogradouro);
      lBuscaCEPLogradouro.Complemento := Trim(lAPIComplemento);
      lBuscaCEPLogradouro.Bairro := Trim(lAPIBairro);
      lBuscaCEPLogradouro.CEP := OnlyNumber(lAPICEP);

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
    end
    else
    if (lJSONResponse is TJSONArray) then
    begin
      lJSONLogradouros := (lJSONResponse as TJSONArray);
      for I := 0 to Pred(lJSONLogradouros.Count) do
      begin
        lJSONLogradouro := (lJSONLogradouros.Items[I] as TJSONObject);

        lJSONLogradouro.TryGetValue<string>('logradouro',  lAPILogradouro);
        lJSONLogradouro.TryGetValue<string>('complemento', lAPIComplemento);
        lJSONLogradouro.TryGetValue<string>('bairro',      lAPIBairro);
        lJSONLogradouro.TryGetValue<string>('cidade',      lAPILocalidade);
        lJSONLogradouro.TryGetValue<string>('uf',          lAPIUF);
        lJSONLogradouro.TryGetValue<string>('cep',         lAPICEP);

        lBuscaCEPLogradouro := TBuscaCEPLogradouro.Create;

        lBuscaCEPLogradouro.Logradouro := Trim(lAPILogradouro);
        lBuscaCEPLogradouro.Complemento := Trim(lAPIComplemento);
        lBuscaCEPLogradouro.Bairro := Trim(lAPIBairro);
        lBuscaCEPLogradouro.CEP := OnlyNumber(lAPICEP);

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
      end;
    end;
  finally
    lJSONResponse.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TBuscaCEPRequestCEPCerto'}
procedure TBuscaCEPRequestCEPCerto.CheckContentResponse(
  pIHTTPResponse: IHTTPResponse);
var
  lMessage: string;
  lContent: string;
  lJSONResponse: TJSONValue;
  lAPIRMsg: string;
  lBuscaCEPExceptionKind: TBuscaCEPExceptionKind;
begin
  inherited CheckContentResponse(pIHTTPResponse);

  lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_UNKNOWN;
  lMessage := EmptyStr;

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

          if (lJSONResponse.ToString = '[]') then
          begin
            lMessage := 'Logradouro não localizado, verificar os parâmetros de filtro.';
            lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_FILTRO_NOT_FOUND;
            Exit;
          end;

          if (lJSONResponse is TJSONObject) then
          begin
            if lJSONResponse.TryGetValue<string>('msg', lAPIRMsg) then
            begin
              lMessage := lAPIRMsg;
              lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_FILTRO_NOT_FOUND;
            end;
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

function TBuscaCEPRequestCEPCerto.GetResource(
  pBuscaCEPFiltro: IBuscaCEPFiltro): string;
var
  lCEP: string;
  lUF: string;
  lLocalidade: string;
  lLogradouro: string;
begin
  Result := EmptyStr;
  case pBuscaCEPFiltro.FiltroPorCEP of
    True:
    begin
      // https://www.cepcerto.com/ws/json/cep
      lCEP := OnlyNumber(FBuscaCEPProvider.Filtro.CEP);
      Result := Format('/ws/json/%s', [lCEP]);
    end;
    False:
    begin
      lUF := Trim(pBuscaCEPFiltro.UF);
      lLocalidade := Trim(pBuscaCEPFiltro.Localidade);
      lLocalidade := ReplaceStr(lLocalidade, ' ', '-');
      lLogradouro := Trim(pBuscaCEPFiltro.Logradouro);
      lLogradouro := ReplaceStr(lLogradouro, ' ', '-');

      // https://www.cepcerto.com/ws/json-endereco/uf/cidade/logradouro
      Result := Concat(Result, '/ws/json-endereco/');
      Result := Concat(Result, Format('%s', [lUF]), '/');
      Result := Concat(Result, Format('%s', [lLocalidade]), '/');
      Result := Concat(Result, Format('%s', [lLogradouro]));
    end;
  end;
end;

function TBuscaCEPRequestCEPCerto.GetResponse(
  pIHTTPResponse: IHTTPResponse): IBuscaCEPResponse;
begin
  Result := TBuscaCEPResponseCEPCerto.Create(pIHTTPResponse.ContentAsString, FProvider);
end;

function TBuscaCEPRequestCEPCerto.InternalExecute: IHTTPResponse;
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
