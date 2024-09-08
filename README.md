![Maintained YES](https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=flat-square&color=important)
![Memory Leak Verified YES](https://img.shields.io/badge/Memory%20Leak%20Verified%3F-yes-green.svg?style=flat-square&color=important)
![Release](https://img.shields.io/github/v/release/antoniojmsjr/BuscaCEP?label=Latest%20release&style=flat-square&color=important)
![Stars](https://img.shields.io/github/stars/antoniojmsjr/BuscaCEP.svg?style=flat-square)
![Forks](https://img.shields.io/github/forks/antoniojmsjr/BuscaCEP.svg?style=flat-square)
![Issues](https://img.shields.io/github/issues/antoniojmsjr/BuscaCEP.svg?style=flat-square&color=blue)</br>
![Compatibility](https://img.shields.io/badge/Compatibility-VCL,%20Firemonkey-3db36a?style=flat-square)
![Delphi Supported Versions](https://img.shields.io/badge/Delphi%20Supported%20Versions-XE7%20and%20newer-3db36a?style=flat-square)

</br>
<p align="center">
  <a href="https://github.com/antoniojmsjr/BuscaCEP/blob/main/Image/Logo.png">
    <img alt="IPGeolocation" height="120" width="600" src="https://github.com/antoniojmsjr/BuscaCEP/blob/main/Image/Logo.png">
  </a>
</p>
</br>

# BuscaCEP

**BuscaCEP** é uma biblioteca de consulta de endereço online, que permite consulta por CEP (Código de Endereçamento Postal) ou por logradouro (UF, Localidade e Logradouro). 

Implementado na linguagem `Delphi`, utiliza o conceito de [fluent interface](https://en.wikipedia.org/wiki/Fluent_interface) para guiar no uso da biblioteca, desenvolvida para oferecer praticidade e eficiência, a BuscaCEP integra os principais players do mercado: [Correios](https://buscacepinter.correios.com.br/app/endereco/index.php), [ViaCEP](https://viacep.com.br/), [BrasilAPI](https://brasilapi.com.br/), entre outros.

Essa biblioteca é ideal para desenvolvedores Delphi que buscam uma solução robusta, flexível e eficiente para integrar consultas de endereço online em suas aplicações.

#### Recursos:

* Consulta Abrangente: BuscaCEP permite consultar tanto por *CEP* quanto por *logradouro*, flexibilizando a obtenção das informações de endereço.
* Consulta Detalhada: Com BuscaCEP as informações do endereço são completas, incluindo: *logradouro, complemento, bairro, CEP, localidade, estado, região, código IBGE e código DDD*.
* Código IBGE: Com BuscaCEP o código IBGE é fornecido de forma *off-line* através do arquivo *IBGE.dat* disponibilizado junto com a biblioteca.
* Integração com Principais Players: Integrado com os principais serviços de consulta de CEP do Brasil: *[Correios](https://buscacepinter.correios.com.br/app/endereco/index.php), [ViaCEP](https://viacep.com.br/), [BrasilAPI](https://brasilapi.com.br/)*, entre outros. 
* Facilidade de Integração: Com uma interface amigável e documentação detalhada, a BuscaCEP é fácil de integrar em qualquer projeto.
* Exemplos de uso: Repositório com diversos exemplos de uso da biblioteca, por exemplo, VCL, FMX e um servidor de aplicação em [(Horse)](https://github.com/HashLoad/horse) simulando uma API de endereços.
</br>

## ⚙️ Instalação Automatizada

Utilizando o [**Boss**](https://github.com/HashLoad/boss/releases/latest) (Dependency manager for Delphi) é possível instalar a biblioteca de forma automatizada.

```
boss install https://github.com/antoniojmsjr/BuscaCEP
```

## ⚙️ Instalação Manual

Se você optar por instalar manualmente, basta adicionar as seguintes pastas ao seu projeto, em *Project > Options > Delphi Compiler > Target > All Configurations > Search path*

```
..\BuscaCEP\Source
```

## :beginner: Provedores Homologados

| Provedor | Usa APIKey? | Busca por CEP? | * Busca por Logradouro? |
|---|---|---|---|
| [Correios](https://buscacepinter.correios.com.br/app/cep/index.php) | NÃO | SIM | SIM |
| [Via CEP](https://viacep.com.br) | NÃO | SIM | SIM |
| [Brasil API](https://brasilapi.com.br) | NÃO | SIM | NÃO | SIM|
| [CEP Aberto](https://www.cepaberto.com) | SIM | SIM | SIM |
| [Republica Virtual](https://www.republicavirtual.com.br/cep) | NÃO | SIM | NÃO |
| [CEP Certo](https://www.cepcerto.com) | NÃO | SIM | SIM |
| [KingHost](https://king.host) | SIM | SIM | NÃO |
| [Postmon](https://postmon.com.br) | NÃO | SIM | NÃO |
| [CEP Livre](https://ceplivre.com.br) | SIM | SIM | SIM |
| [Open CEP](https://opencep.com) | SIM | SIM | SIM |
| [API CEP](https://apicep.com) | SIM | SIM | SIM |
| [Brasil Aberto](https://brasilaberto.com) | SIM | SIM | SIM |

\* Para consultar usando o logradouro são necessários três parâmetros obrigatórios (UF, Cidade e Logradouro).</br>

## :globe_with_meridians: Arquivo de Cache(BuscaCEP.dat)

Para disponibilizar o código IBGE e o código DDD da localidade no retorno da consulta, foi criado o arquivo **BuscaCEP.dat** com base na [API de localidades](https://servicodados.ibge.gov.br/api/docs/localidades) do IBGE e no site da [Anatel](https://www.anatel.gov.br/dadosabertos/PDA/Codigo_Nacional/PGCN.csv).

* O arquivo dever ser usado junto ao aplicativo ou ser definido na biblioteca.
* Esse arquivo pode ser atualizado usando o projeto [BuscaCEPCache](https://github.com/antoniojmsjr/BuscaCEP/tree/main/Cache).

## ⚡️ Uso da biblioteca

Os exemplos estão disponíveis na pasta do projeto:

```
..\BuscaCEP\Samples
```

**Consulta por CEP**

```delphi
uses
  BuscaCEP, BuscaCEP.Types, BuscaCEP.Interfaces, System.SysUtils;
```
```delphi
var
  lBuscaCEPResponse: IBuscaCEPResponse;
  lMsgError: string;
begin
  try
    lBuscaCEPResponse := TBuscaCEP.New
      //.SetArquivoCache() [OPCIONAL]
      .Providers[TBuscaCEPProvidersKind.Correios]
        //.SetAPIKey() [CONFORME O PROVEDOR]
        .Filtro
          .SetCEP('90520-003')
        .Request
          //.SetTimeout() [OPCIONAL]
          .Execute;
  except
    on E: EBuscaCEPRequest do
    begin
      lMsgError := Concat(lMsgError, Format('Provider: %s', [E.Provider]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('DateTime: %s', [DateTimeTostr(E.DateTime)]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Kind: %s', [E.Kind.AsString]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('URL: %s', [E.URL]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Method: %s', [E.Method]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Status Code: %d', [E.StatusCode]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Status Text: %s', [E.StatusText]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Message: %s', [E.Message]));

      Application.MessageBox(PWideChar(lMsgError), 'A T E N Ç Ã O', MB_OK + MB_ICONERROR);
      Exit;
    end;
    on E: Exception do
    begin
      Application.MessageBox(PWideChar(E.Message), 'A T E N Ç Ã O', MB_OK + MB_ICONERROR);
      Exit;
    end;
  end;
end;
```

**Consulta por Logradouro**

```delphi
uses
  BuscaCEP, BuscaCEP.Types, BuscaCEP.Interfaces, System.SysUtils;
```
```delphi
var
  lBuscaCEPResponse: IBuscaCEPResponse;
  lMsgError: string;
begin
  try
    lBuscaCEPResponse := TBuscaCEP.New
      //.SetArquivoCache() [OPCIONAL]
      .Providers[TBuscaCEPProvidersKind.Correios]
        //.SetAPIKey() [CONFORME O PROVEDOR]
        .Filtro
          .SetLogradouro('Avenida Plínio Brasil Milano')
          .SetLocalidade('Porto Alegre')
          .SetUF('RS')
        .&End
        .Request
          //.SetTimeout() [OPCIONAL]
          .Execute;
  except
    on E: EBuscaCEPRequest do
    begin
      lMsgError := Concat(lMsgError, Format('Provider: %s', [E.Provider]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('DateTime: %s', [DateTimeTostr(E.DateTime)]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Kind: %s', [E.Kind.AsString]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('URL: %s', [E.URL]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Method: %s', [E.Method]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Status Code: %d', [E.StatusCode]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Status Text: %s', [E.StatusText]), sLineBreak);
      lMsgError := Concat(lMsgError, Format('Message: %s', [E.Message]));

      Application.MessageBox(PWideChar(lMsgError), 'A T E N Ç Ã O', MB_OK + MB_ICONERROR);
      Exit;
    end;
    on E: Exception do
    begin
      Application.MessageBox(PWideChar(E.Message), 'A T E N Ç Ã O', MB_OK + MB_ICONERROR);
      Exit;
    end;
  end;
end;
```

**Resultado da Consulta [IBuscaCEPResponse]**

```delphi
uses
  BuscaCEP.Types, BuscaCEP.Interfaces;
```
```delphi
var
  lBuscaCEPResponse: IBuscaCEPResponse;
  lBuscaCEPLogradouro: TBuscaCEPLogradouro;
begin
  for lBuscaCEPLogradouro in lBuscaCEPResponse.Logradouros do
  begin
    lBuscaCEPLogradouro.Logradouro;
    lBuscaCEPLogradouro.Complemento;
    lBuscaCEPLogradouro.Unidade;
    lBuscaCEPLogradouro.Bairro;
    lBuscaCEPLogradouro.Localidade.Nome;
    lBuscaCEPLogradouro.Localidade.IBGE;
    lBuscaCEPLogradouro.Localidade.DDD;
    lBuscaCEPLogradouro.Localidade.Estado.Nome;
    lBuscaCEPLogradouro.Localidade.Estado.IBGE;
    lBuscaCEPLogradouro.Localidade.Estado.Sigla;
    lBuscaCEPLogradouro.Localidade.Estado.Regiao.Nome;
    lBuscaCEPLogradouro.Localidade.Estado.Regiao.IBGE;
    lBuscaCEPLogradouro.Localidade.Estado.Regiao.Sigla;
    lBuscaCEPLogradouro.CEP;
  end;
```

**Resultado da Consulta [JSON]**
```json
{
  "provider": "#CORREIOS",
  "date_time": "2024-05-01T02:35:14.772-03:00",
  "request_time": "75ms",
  "total": 1,
  "logradouros": [
    {
      "logradouro": "Avenida Plínio Brasil Milano",
      "complemento": "de 1947 ao fim - lado ímpar",
      "unidade": "",
      "bairro": "Passo da Areia",
      "cep": "90520003",
      "localidade": {
        "ibge": 4314902,
        "ddd": 51,
        "nome": "Porto Alegre",
        "estado": {
          "ibge": 43,
          "nome": "Rio Grande do Sul",
          "sigla": "RS",
          "regiao": {
            "ibge": 4,
            "nome": "Sul",
            "sigla": "S"
          }
        }
      }
    }
  ]
}
```
#### Exemplo compilado

* VCL
* VCL Client
* VCL Server [(Horse)](https://github.com/HashLoad/horse)

Download: [Demos.zip](https://github.com/user-attachments/files/16923690/Demos.zip)

https://github.com/user-attachments/assets/292bdcf4-87fd-4504-838f-1be9fbd3148e

https://github.com/antoniojmsjr/BuscaCEP/assets/20980984/8e04fcfd-938b-49ea-ba14-c58e78864db4

## :warning: Licença
`BuscaCEP` is free and open-source software licensed under the [![License](https://img.shields.io/badge/license-Apache%202-blue.svg)](https://github.com/antoniojmsjr/BuscaCEP/blob/master/LICENSE)
