{******************************************************************************}
{                                                                              }
{           BuscaCEP.Providers.CEPLivre.pas                                    }
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
unit BuscaCEP.Providers.CEPLivre;

interface

uses
  System.Generics.Collections, System.Net.HttpClient, BuscaCEP.Interfaces,
  BuscaCEP.Core;

type
  {$REGION 'TBuscaCEPProviderCEPLivre'}
  TBuscaCEPProviderCEPLivre = class sealed(TBuscaCEPProvidersCustom)
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

  {$REGION 'TBuscaCEPResponseCEPLivre'}
  TBuscaCEPResponseCEPLivre = class(TBuscaCEPResponseCustom)
  private
    { private declarations }
  protected
    { protected declarations }
    procedure Parse; override;
  public
    { public declarations }
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPRequestCEPLivre'}
  TBuscaCEPRequestCEPLivre = class sealed(TBuscaCEPRequest)
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

{$REGION 'TBuscaCEPProviderCEPLivre'}
constructor TBuscaCEPProviderCEPLivre.Create(pParent: IBuscaCEP);
begin
  inherited Create(pParent);
  FID   := TBuscaCEPProvidersKind.CEPLivre.Token;
  FURL  := TBuscaCEPProvidersKind.CEPLivre.BaseURL;
end;

function TBuscaCEPProviderCEPLivre.GetRequest: IBuscaCEPRequest;
begin
  Result := TBuscaCEPRequestCEPLivre.Create(Self, FBuscaCEP);
end;
{$ENDREGION}

{$REGION 'TBuscaCEPResponseCEPLivre'}
procedure TBuscaCEPResponseCEPLivre.Parse;
var
  lContent: string;
  lContentCEPs: TStrings;
  lLinha: string;
  lLogradouros: TArray<string>;
  I: Integer;
  lLocalidadeDDD: Integer;
  lLocalidadeIBGE: Integer;
  lBuscaCEPLogradouro: TBuscaCEPLogradouro;
  lBuscaCEPLogradouroEstado: TBuscaCEPLogradouroEstado;
  lAPIUF: string;
  lAPILocalidade: string;
begin
  lContent := StringReplace(FContent, '"', '', [rfReplaceAll]);
  lContentCEPs := TStringList.Create;
  try
    lContentCEPs.Text := lContent;

    // IGNORAR A 1º LINHA(HEADER)
    for I := 1 to Pred(lContentCEPs.Count) do
    begin
      lLinha := lContentCEPs[I];

      // "tp_logradouro","tp_logradouro_id","logradouro","bairro","cidade","ufsigla","ufnome","id_estado_ibge","cep"
      lLogradouros := SplitString(lLinha, ',');

      lBuscaCEPLogradouro := TBuscaCEPLogradouro.Create;

      lBuscaCEPLogradouro.Logradouro := Trim(lLogradouros[0] + ' ' + lLogradouros[2]);
      lBuscaCEPLogradouro.Complemento := EmptyStr;
      lBuscaCEPLogradouro.Unidade := EmptyStr;
      lBuscaCEPLogradouro.Bairro := Trim(lLogradouros[3]);
      lBuscaCEPLogradouro.CEP := OnlyNumber(lLogradouros[8]);

      lAPIUF := Trim(lLogradouros[5]);
      lBuscaCEPLogradouroEstado := TBuscaCEPLogradouroEstado.Create;
      lBuscaCEPLogradouroEstado.Assign(TBuscaCEPEstados.Default.GetEstado(lAPIUF));

      lAPILocalidade := Trim(lLogradouros[4]);
      TBuscaCEPCache.Default.GetCodigos(lAPIUF, lAPILocalidade, lLocalidadeIBGE, lLocalidadeDDD);
      lBuscaCEPLogradouro.Localidade :=
        TBuscaCEPLogradouroLocalidade.Create(lLocalidadeIBGE,
                                             lLocalidadeDDD,
                                             lAPILocalidade,
                                             lBuscaCEPLogradouroEstado);

      FLogradouros.Add(lBuscaCEPLogradouro);                            
    end;
  finally
    lContentCEPs.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TBuscaCEPRequestCEPLivre'}
procedure TBuscaCEPRequestCEPLivre.CheckContentResponse(
  pIHTTPResponse: IHTTPResponse);
var
  lMessage: string;
  lContent: string;
  lContentCEPs: TStrings;
  lBuscaCEPExceptionKind: TBuscaCEPExceptionKind;
begin
  lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_UNKNOWN;
  lMessage := EmptyStr;

  lContent := Trim(pIHTTPResponse.ContentAsString);
  try
    case pIHTTPResponse.StatusCode of
      200:
      begin
        if (lContent = EmptyStr) then
        begin
          lMessage := 'Logradouro não localizado, verificar os parâmetros de filtro.';
          lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_FILTRO_NOT_FOUND;
          Exit;
        end;

        lContentCEPs := TStringList.Create;
        try
          lContentCEPs.Text := lContent;
          if (lContentCEPs.Count = 1) then
          begin
            lMessage := 'Logradouro não localizado, verificar os parâmetros de filtro.';
            lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_FILTRO_NOT_FOUND;
          end;
        finally
          lContentCEPs.Free;
        end;
      end;
      400:
      begin
        lMessage := 'Filtro informado é inválido.';
        lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_FILTRO_INVALID;
      end;
      403:
      begin
        lMessage := 'Verificar se a chave de autenticação é válida.';
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

procedure TBuscaCEPRequestCEPLivre.CheckRequest;
begin
  inherited CheckRequest;

  if (FBuscaCEPProvider.APIKey = EmptyStr) then
    raise EBuscaCEP.Create(TBuscaCEPExceptionKind.EXCEPTION_REQUEST_INVALID,
                           FProvider,
                           Now(),
                           'Chave de Autenticação é obrigatório e deve ser informado.');
end;

function TBuscaCEPRequestCEPLivre.GetResource(
  pBuscaCEPFiltro: IBuscaCEPFiltro): string;
var
  lCEP: string;
begin
  Result := EmptyStr;
  case pBuscaCEPFiltro.FiltroPorCEP of
    True:
    begin
      // https://ceplivre.com.br/consultar/cep/APIKey/01311-000/json
      lCEP := OnlyNumber(FBuscaCEPProvider.Filtro.CEP);
      lCEP := FormatCEP(lCEP);

      Result := Concat(Result, '/consultar/cep/');
      Result := Concat(Result, Format('%s/', [FBuscaCEPProvider.APIKey]));
      Result := Concat(Result, Format('%s/', [lCEP]));
      Result := Concat(Result, 'csv');
    end;
    False:
    begin
      // https://ceplivre.com.br/consultar/logradouro/APIKey/paulista/csv
      Result := Concat(Result, '/consultar/logradouro/');
      Result := Concat(Result, Format('%s/', [FBuscaCEPProvider.APIKey]));
      Result := Concat(Result, Format('%s/', [pBuscaCEPFiltro.Logradouro]));
      Result := Concat(Result, 'csv');
    end;
  end;
end;

function TBuscaCEPRequestCEPLivre.GetResponse(
  pIHTTPResponse: IHTTPResponse): IBuscaCEPResponse;
begin
  Result := TBuscaCEPResponseCEPLivre.Create(pIHTTPResponse.ContentAsString, FProvider, FRequestTime);
end;

function TBuscaCEPRequestCEPLivre.InternalExecute: IHTTPResponse;
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
