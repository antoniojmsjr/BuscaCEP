unit Routes;

interface

uses
  Horse;

procedure RegisterRoutes;

implementation

uses
  BuscaCEP, BuscaCEP.Types, BuscaCEP.Interfaces, System.SysUtils, System.JSON;

procedure GetPing(pRequest: THorseRequest; pResponse: THorseResponse);
begin
  pResponse.Send('pong');
end;

procedure GetLogradouros(pRequest: THorseRequest; pResponse: THorseResponse);
var
  lParamCEP: string;
  lParamUF: string;
  lParamLocalidade: string;
  lParamLogradouro: string;
  lBuscaPorCEP: Boolean;
  lBuscaCEPResponse: IBuscaCEPResponse;
  lBuscaCEPFiltro: IBuscaCEPFiltro;
  lMessage: string;
  lJSONObject: TJSONObject;
begin
  Writeln(pRequest.RawWebRequest.RawPathInfo + '?' + pRequest.RawWebRequest.Query);

  lBuscaPorCEP := False;

  // BUSCA POR CEP?
  if pRequest.Query.ContainsKey('cep') then
  begin
    lParamCEP := Trim(pRequest.Query.Field('cep').AsString);
    if (lParamCEP = EmptyStr) then
    begin
      lMessage := Format('{"%s": "%s"}', ['message', 'Informe o CEP para consulta!']);
      lJSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(lMessage), 0) as TJSONObject;
      pResponse.Send<TJSONObject>(lJSONObject).Status(400);
      Exit;
    end;

    lBuscaPorCEP := True;
  end
  else
  begin // BUSCA POR LOGRADOURO?
    lParamUF := Trim(pRequest.Query.Field('uf').AsString);
    lParamLocalidade := Trim(pRequest.Query.Field('localidade').AsString);
    lParamLogradouro := Trim(pRequest.Query.Field('logradouro').AsString);

    if (lParamUF = EmptyStr) or (lParamLocalidade = EmptyStr) and (lParamLogradouro = EmptyStr) then
    begin
      lMessage := Format('{"%s": "%s"}', ['message', 'Informe o CEP ou logradouro para consulta!']);
      lJSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(lMessage), 0) as TJSONObject;
      pResponse.Send<TJSONObject>(lJSONObject).Status(400);
      Exit;
    end;
  end;

  try
    lBuscaCEPFiltro := TBuscaCEP.New
      .Providers[TBuscaCEPProvidersKind.Correios] // BUSCA USANDO API DOS CORREIOS
        .Filtro;

    case lBuscaPorCEP of
      True:
      begin
        lBuscaCEPResponse := lBuscaCEPFiltro
          .SetCEP(lParamCEP)
        .Request
          .SetTimeout(10000)
          .Execute;
      end;
      False:
      begin
        lBuscaCEPResponse := lBuscaCEPFiltro
          .SetUF(lParamUF)
          .SetLocalidade(lParamLocalidade)
          .SetLogradouro(lParamLogradouro)
        .&End
        .Request
          .SetTimeout(10000)
          .Execute;
      end;
    end;

    lJSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(lBuscaCEPResponse.ToJSONString), 0) as TJSONObject;
    pResponse.Send<TJSONObject>(lJSONObject).Status(200);
  except
    on E: EBuscaCEPRequest do
    begin
      lMessage := Format('{"%s": "%s"}', ['message', E.Message]);
      lJSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(lMessage), 0) as TJSONObject;
      case E.Kind of
        TBuscaCEPExceptionKind.EXCEPTION_OTHERS,
        TBuscaCEPExceptionKind.EXCEPTION_HTTP,
        TBuscaCEPExceptionKind.EXCEPTION_RESPONSE_INVALID: pResponse.Send<TJSONObject>(lJSONObject).Status(500);
        TBuscaCEPExceptionKind.EXCEPTION_REQUEST_INVALID,
        TBuscaCEPExceptionKind.EXCEPTION_FILTRO_INVALID: pResponse.Send<TJSONObject>(lJSONObject).Status(400);
        TBuscaCEPExceptionKind.EXCEPTION_FILTRO_NOT_FOUND: pResponse.Send<TJSONObject>(lJSONObject).Status(404);
      end;
    end;
    on E: Exception do
    begin
      lMessage := Format('{"%s": "%s"}', ['message', E.Message]);
      lJSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(lMessage), 0) as TJSONObject;
      pResponse.Send<TJSONObject>(lJSONObject).Status(500);
    end;
  end;
end;

procedure RegisterRoutes;
begin
  THorse.Get('/ping', GetPing);
  THorse.Get('/logradouros', GetLogradouros);
end;

end.
