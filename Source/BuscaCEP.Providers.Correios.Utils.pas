unit BuscaCEP.Providers.Correios.Utils;

interface

uses
  BuscaCEP.Interfaces;

function GetFORMData(pBuscaCEPFiltro: IBuscaCEPFiltro): string;

implementation

uses
  System.SysUtils, BuscaCEP.Utils, BuscaCEP.Types;

function GetFORMData(pBuscaCEPFiltro: IBuscaCEPFiltro): string;
var
  lCEP: string;
begin
  Result := EmptyStr;
  case pBuscaCEPFiltro.FiltroPorCEP of
    True:
    begin
      lCEP := OnlyNumber(pBuscaCEPFiltro.CEP);
      Result := Concat(Result , 'mensagem_alerta', '=', EmptyStr, '&');
      Result := Concat(Result , 'cep', '=', lCEP, '&');
      Result := Concat(Result , 'cepaux', '=', EmptyStr, '&');
      Result := Concat(Result , 'tipoCEP', '=', 'ALL', '&');
      Result := Concat(Result , 'captcha', '=', 'buscacep', '&');
      Result := Concat(Result , 'capt', '=', '1');
    end;
    False:
    begin
      Result := Concat(Result , 'letraLocalidade', '=', EmptyStr, '&');
      Result := Concat(Result , 'ufaux', '=', EmptyStr, '&');
      Result := Concat(Result , 'cepaux', '=', EmptyStr, '&');
      Result := Concat(Result , 'tipoCEP', '=', 'ALL', '&');
      Result := Concat(Result , 'pagina', '=', '/app/localidade_logradouro/index.php', '&');
      Result := Concat(Result , 'mensagem_alerta', '=', EmptyStr, '&');
      Result := Concat(Result , 'uf', '=', pBuscaCEPFiltro.UF, '&');
      Result := Concat(Result , 'localidade', '=', pBuscaCEPFiltro.Localidade, '&');
      Result := Concat(Result , 'tipologradouro', '=', pBuscaCEPFiltro.Tipo.AsString, '&');
      Result := Concat(Result , 'logradouro', '=', pBuscaCEPFiltro.Logradouro, '&');
      Result := Concat(Result , 'numeroLogradouro', '=', pBuscaCEPFiltro.Identificador, '&');
      Result := Concat(Result , 'captcha', '=', 'buscacep', '&');
      Result := Concat(Result , 'capt', '=', '1');
    end;
  end;
end;

end.
