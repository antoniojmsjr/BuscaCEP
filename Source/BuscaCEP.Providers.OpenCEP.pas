unit BuscaCEP.Providers.OpenCEP;

interface

uses
  System.Generics.Collections, System.Net.HttpClient, BuscaCEP.Interfaces,
  BuscaCEP.Core;

type

  {$REGION 'TBuscaCEPProviderOpenCEP'}
  TBuscaCEPProviderOpenCEP = class sealed(TBuscaCEPProvidersCustom)
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

  {$REGION 'TBuscaCEPResponseOpenCEP'}
  TBuscaCEPResponseOpenCEP = class(TBuscaCEPResponseCustom)
  private
    { private declarations }
  protected
    { protected declarations }
    procedure Parse; override;
  public
    { public declarations }
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPRequestOpenCEP'}
  TBuscaCEPRequestOpenCEP = class sealed(TBuscaCEPRequest)
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
  System.Classes, System.NetEncoding, System.RegularExpressions, BuscaCEP.Types,
  BuscaCEP.Utils;

{$REGION 'TBuscaCEPProviderOpenCEP'}
constructor TBuscaCEPProviderOpenCEP.Create(pParent: IBuscaCEP);
begin
  inherited Create(pParent);
  FID   := TBuscaCEPProvidersKind.OpenCEP.Token;
  FURL  := TBuscaCEPProvidersKind.OpenCEP.BaseURL;
end;

function TBuscaCEPProviderOpenCEP.GetRequest: IBuscaCEPRequest;
begin
  Result := TBuscaCEPRequestOpenCEP.Create(Self, FBuscaCEP);
end;
{$ENDREGION}

{$REGION 'TBuscaCEPResponseOpenCEP'}
procedure TBuscaCEPResponseOpenCEP.Parse;
var
  lJSONResponse: TJSONValue;
  lJSONLogradouro: TJSONObject;
  lAPILogradouro: string;
  lAPIComplemento: string;
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

    lJSONLogradouro := (lJSONResponse as TJSONObject);

    lJSONLogradouro.TryGetValue<string>('cep',         lAPICEP);
    lJSONLogradouro.TryGetValue<string>('logradouro',  lAPILogradouro);
    lJSONLogradouro.TryGetValue<string>('complemento', lAPIComplemento);
    lJSONLogradouro.TryGetValue<string>('bairro',      lAPIBairro);
    lJSONLogradouro.TryGetValue<string>('localidade',  lAPILocalidade);
    lJSONLogradouro.TryGetValue<string>('uf',          lAPIUF);

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
    TBuscaCEPCache.Default.GetCodigos(lAPIUF, lAPILocalidade, lLocalidadeIBGE, lLocalidadeDDD);
    lBuscaCEPLogradouro.Localidade :=
      TBuscaCEPLogradouroLocalidade.Create(lLocalidadeIBGE,
                                           lLocalidadeDDD,
                                           lAPILocalidade,
                                           lBuscaCEPLogradouroEstado);

    FLogradouros.Add(lBuscaCEPLogradouro);
  finally
    lJSONResponse.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TBuscaCEPRequestOpenCEP'}
procedure TBuscaCEPRequestOpenCEP.CheckContentResponse(pIHTTPResponse: IHTTPResponse);
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
        finally
          lJSONResponse.Free;
        end;
      end;
      404:
      begin
        lMessage := 'Logradouro não encontrado. Verifique os parâmetros de filtro.';
        lBuscaCEPExceptionKind := TBuscaCEPExceptionKind.EXCEPTION_FILTRO_NOT_FOUND;
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

procedure TBuscaCEPRequestOpenCEP.CheckRequest;
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
      raise EBuscaCEP.Create(TBuscaCEPExceptionKind.EXCEPTION_FILTRO_INVALID,
                             FProvider,
                             Now(),
                             'O provedor não oferece busca por logradouro.');
end;

function TBuscaCEPRequestOpenCEP.GetResource(pBuscaCEPFiltro: IBuscaCEPFiltro): string;
var
  lCEP: string;
begin
  // https://opencep.com/v1/90520003.json
  lCEP := OnlyNumber(FBuscaCEPProvider.Filtro.CEP);
  Result := Format('/v1/%s.%s', [lCEP, 'json']);
end;

function TBuscaCEPRequestOpenCEP.GetResponse(pIHTTPResponse: IHTTPResponse): IBuscaCEPResponse;
begin
  Result := TBuscaCEPResponseOpenCEP.Create(pIHTTPResponse.ContentAsString, FProvider, FRequestTime);
end;

function TBuscaCEPRequestOpenCEP.InternalExecute: IHTTPResponse;
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
