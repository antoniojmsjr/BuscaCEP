# BuscaCEPIBGE.exe

**BuscaCEPIBGE.exe** é um aplicativo desenvolvido para gerar o arquivo **IBGE.dat** (314kb), que contém uma lista de localidades juntamente com os códigos IBGE.

Com base nos dados importados e processados da [API de localidades](https://servicodados.ibge.gov.br/api/docs/localidades) do IBGE, o programa gera o arquivo IBGE.dat contendo uma lista organizada de localidades e seus respectivos códigos IBGE.
O arquivo IBGE.dat foi criado para ser utilizado pela biblioteca [BuscaCEP](https://github.com/antoniojmsjr/BuscaCEP) para retornar o código IBGE da localidade do logradouro.

<p align="center">
  <a href="https://github.com/antoniojmsjr/BuscaCEP/assets/20980984/07713646-d2d8-4145-b7a8-9d7cb95af646">
    <img alt="BuscaCEP - Gerar Arquivo IBGE" height="350" src="https://github.com/antoniojmsjr/BuscaCEP/assets/20980984/07713646-d2d8-4145-b7a8-9d7cb95af646">
  </a>
</p>

## Arquivo IBGE.dat

<p align="center">
  <a href="https://github.com/antoniojmsjr/BuscaCEP/assets/20980984/ad7bf8a4-7752-40af-b957-0760f238ac46">
    <img alt="Arquivo IBGE.dat" height="350" src="https://github.com/antoniojmsjr/BuscaCEP/assets/20980984/ad7bf8a4-7752-40af-b957-0760f238ac46">
  </a>
</p>

### Estrututa

| UF | CÓDIGO IBGE | LOCALIDADE | * HASH |
|---|---|---|---|
|RS|3550308|Porto Alegre|cab02944fee56ad06c1f288340ae02f1|
|SP|3550308|São Paulo|35b3cb29a9f04e415cd69c4dd2e45083|
|RJ|3304557|Rio de Janeiro|a245015dea599745f99cf43da0e882f9|

* O Hash é utilizado para otimizar a busca da localidade, e é calculado usando UF e Localidade.

```delphi
uses
BuscaCEP.Utils;
  
TBuscaCEPLocalidadesIBGE.Default.GetHashIBGE('RS', 'Porto alegre');
```

### Uso

```delphi
uses
  BuscaCEP.Utils;
```

```delphi
var
  lArquivo: string;
  lLocalidade: TBuscaCEPLocalidadeIBGE;
  lLocalidadeStr: string;
begin
  lArquivo := IncludeTrailingPathDelimiter(GetCurrentDir) + 'IBGE.dat';
  if not FileExists(lArquivo) then
    raise Exception.Create('Arquivo não localizado: ' + lArquivo);

  TBuscaCEPLocalidadesIBGE.Default.Processar(lArquivo);
  lLocalidade := TBuscaCEPLocalidadesIBGE.Default.GetLocalidade('RS', 'Porto Alegre');

  if not Assigned(lLocalidade) then
    raise Exception.Create('Localidade não encontrada.');

  lLocalidadeStr := EmptyStr;
  lLocalidadeStr := Concat(lLocalidadeStr, 'Estado: ', lLocalidade.UF, sLineBreak);
  lLocalidadeStr := Concat(lLocalidadeStr, 'Localidade: ', lLocalidade.Nome, sLineBreak);
  lLocalidadeStr := Concat(lLocalidadeStr, 'IBGE: ', IntToStr(lLocalidade.IBGE), sLineBreak);
  lLocalidadeStr := Concat(lLocalidadeStr, 'Hash: ', lLocalidade.Hash);

  ShowMessage(lLocalidadeStr);
```
