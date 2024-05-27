{******************************************************************************}
{                                                                              }
{           BuscaCEP.Providers.ViaCEP.pas                                      }
{                                                                              }
{           Copyright (C) Ant�nio Jos� Medeiros Schneider J�nior               }
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
unit BuscaCEP.Providers.ViaCEP;

interface

uses
  System.Generics.Collections, System.Net.HttpClient, BuscaCEP.Interfaces,
  BuscaCEP.Core;

type

  {$REGION 'TBuscaCEPProviderViaCEP'}
  TBuscaCEPProviderViaCEP = class sealed(TBuscaCEPProvidersCustom)
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

  {$REGION 'TBuscaCEPResponseViaCEP'}
  TBuscaCEPResponseViaCEP = class(TBuscaCEPResponseCustom)
  private
    { private declarations }
  protected
    { protected declarations }
    procedure Parse; override;
  public
    { public declarations }
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPRequestViaCEP'}
  TBuscaCEPRequestViaCEP = class sealed(TBuscaCEPRequest)
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
  System.JSON, System.SysUtils, System.Net.URLClient, System.Classes,
  BuscaCEP.Types, BuscaCEP.Utils;

{$REGION 'TBuscaCEPProviderViaCEP'}
constructor TBuscaCEPProviderViaCEP.Create(pParent: IBuscaCEP);
begin
  inherited Create(pParent);
  FID   := TBuscaCEPProvidersKind.ViaCEP.Token;
  FURL  := TBuscaCEPProvidersKind.ViaCEP.BaseURL;
end;

function TBuscaCEPProviderViaCEP.GetRequest: IBuscaCEPRequest;
begin
  Result := TBuscaCEPRequestViaCEP.Create(Self, FBuscaCEP);
end;
{$ENDREGION}

{$REGION 'TBuscaCEPResponseViaCEP'}
procedure TBuscaCEPResponseViaCEP.Parse;
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
      lJSONLogradouro.TryGetValue<Integer>('ibge',       lLocalidadeIBGE);

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
        lJSONLogradouro.TryGetValue<string>('localidade',  lAPILocalidade);
        lJSONLogradouro.TryGetValue<string>('uf',          lAPIUF);
        lJSONLogradouro.TryGetValue<string>('cep',         lAPICEP);
        lJSONLogradouro.TryGetValue<Integer>('ibge',       lLocalidadeIBGE);

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

{$REGION 'TBuscaCEPRequestViaCEP'}
procedure TBuscaCEPRequestViaCEP.CheckContentResponse(
  pIHTTPResponse: IHTTPResponse);
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
            lMessage := 'JSON inv�lido';
            lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_RESPONSE_INVALID;
            Exit;
          end;

          if (lJSONResponse.ToString = '[]') then
          begin
            lMessage := 'Logradouro n�o localizado, verificar os par�metros de filtro.';
            lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_FILTRO_NOT_FOUND;
            Exit;
          end;

          if (lJSONResponse is TJSONObject) then
          begin
            if Assigned(lJSONResponse.FindValue('erro')) then
            begin
              lMessage := 'Logradouro n�o localizado, verificar os par�metros de filtro.';
              lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_FILTRO_NOT_FOUND;
            end;
          end;
        finally
          lJSONResponse.Free;
        end;
      end;
      400:
      begin
        lMessage := 'Requisi��o inv�lida, verificar os par�metros de filtro.';
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

function TBuscaCEPRequestViaCEP.GetResource(
  pBuscaCEPFiltro: IBuscaCEPFiltro): string;
var
  lCEP: string;
begin
  Result := EmptyStr;
  case pBuscaCEPFiltro.FiltroPorCEP of
    True:
    begin
      // viacep.com.br/ws/90520003/jso
      lCEP := OnlyNumber(FBuscaCEPProvider.Filtro.CEP);
      Result := Format('/ws/%s/json', [lCEP]);
    end;
    False:
    begin
      // viacep.com.br/ws/RS/Porto Alegre/Domingos+Jose/json/
      Result := Concat(Result, '/ws/');
      Result := Concat(Result, Format('%s', [pBuscaCEPFiltro.UF]), '/');
      Result := Concat(Result, Format('%s', [pBuscaCEPFiltro.Localidade]), '/');
      Result := Concat(Result, Format('%s', [pBuscaCEPFiltro.Logradouro]), '/');
      Result := Concat(Result, 'json');
    end;
  end;
end;

function TBuscaCEPRequestViaCEP.GetResponse(
  pIHTTPResponse: IHTTPResponse): IBuscaCEPResponse;
begin
  Result := TBuscaCEPResponseViaCEP.Create(pIHTTPResponse.ContentAsString, FProvider, FRequestTime);
end;

function TBuscaCEPRequestViaCEP.InternalExecute: IHTTPResponse;
var
  lURL: TURI;
  lResource: string;
begin
  // RESOURCE
  lResource := GetResource(FBuscaCEPProvider.Filtro);

  //CONFORME A DOCUMENTA��O DA API
  lURL := TURI.Create(Format('%s%s', [FBuscaCEPProvider.URL, lResource]));

  FHttpRequest.URL := lURL.ToString;
  FHttpRequest.MethodString := 'GET';

  //REQUISI��O
  Result := inherited InternalExecute;
end;
{$ENDREGION}

end.
