# BuscaCEPCache.exe

**BuscaCEPCache.exe** é um aplicativo desenvolvido para *geração* do arquivo **BuscaCEP.dat** (335kb) que contém uma lista de localidades juntamente com os códigos *IBGE* e o *DDD(Discagem Direta à Distância)*.

Com base nos dados importados da [API de localidades](https://servicodados.ibge.gov.br/api/docs/localidades) e nos dados obtidos do site da [Anatel](https://www.anatel.gov.br/dadosabertos/PDA/Codigo_Nacional/PGCN.csv), é gerado o arquivo **BuscaCEP.dat**, que contém uma lista organizada de localidades, seus respectivos códigos IBGE e os códigos DDD correspondentes.

> [!NOTE]
> O arquivo BuscaCEP.dat foi criado para ser utilizado pela biblioteca [BuscaCEP](https://github.com/antoniojmsjr/BuscaCEP) para retornar os códigos IBGE e o DDD da localidade do logradouro.

<p align="center">
  <a href="https://github.com/user-attachments/assets/fe8a62ea-4825-40b7-85ab-f7ef7ef7ee0c">
    <img alt="BuscaCEP - Gerar Arquivo Cache" height="450" src="https://github.com/user-attachments/assets/fe8a62ea-4825-40b7-85ab-f7ef7ef7ee0c">
  </a>
</p>

## Arquivo BuscaCEP.dat
<p align="center">
  <a href="https://github.com/user-attachments/assets/c1b25b71-1ef6-4383-a353-5cdf71f4ec74">
    <img alt="Arquivo BuscaCEP.dat" height="400" src="https://github.com/user-attachments/assets/c1b25b71-1ef6-4383-a353-5cdf71f4ec74">
  </a>
</p>

### Estrututa

| UF | DDD | CÓDIGO IBGE | LOCALIDADE | * HASH |
|---|---|---|---|---|
|RS|51|3550308|Porto Alegre|cab02944fee56ad06c1f288340ae02f1|
|SP|11|3550308|São Paulo|35b3cb29a9f04e415cd69c4dd2e45083|
|RJ|21|3304557|Rio de Janeiro|a245015dea599745f99cf43da0e882f9|

\* O hash é utilizado para otimizar a busca dos dados e é calculado com base na **UF** e na **Localidade**.


```delphi
uses
BuscaCEP.Utils;
  
TBuscaCEPCache.Default.GetHash('RS', 'Porto alegre');
```

### Uso

```delphi
uses
  BuscaCEP.Utils;
```

```delphi
var
  lArquivo: string;
  lLocalidade: TBuscaCEPCacheLocalidade;
  lLocalidadeStr: string;
begin
  lArquivo := IncludeTrailingPathDelimiter(GetCurrentDir) + 'BuscaCEP.dat';
  if not FileExists(lArquivo) then
    raise Exception.Create('Arquivo não localizado: ' + lArquivo);

  // PROCESSAMENTO DO ARQUIVO BuscaCEP.dat
  TBuscaCEPCache.Default.Processar(lArquivo);

  // LOCALIZAÇÃO DA LOCALIDADE
  lLocalidade := TBuscaCEPCache.Default.GetLocalidade('RS', 'Porto Alegre');

  if not Assigned(lLocalidade) then
    raise Exception.Create('Localidade não encontrada.');

  lLocalidadeStr := EmptyStr;
  lLocalidadeStr := Concat(lLocalidadeStr, 'Estado: ', lLocalidade.UF, sLineBreak);
  lLocalidadeStr := Concat(lLocalidadeStr, 'Localidade: ', lLocalidade.Nome, sLineBreak);
  lLocalidadeStr := Concat(lLocalidadeStr, 'IBGE: ', IntToStr(lLocalidade.IBGE), sLineBreak);
  lLocalidadeStr := Concat(lLocalidadeStr, 'DDD: ', IntToStr(lLocalidade.DDD), sLineBreak);
  lLocalidadeStr := Concat(lLocalidadeStr, 'Hash: ', lLocalidade.Hash);

  ShowMessage(lLocalidadeStr);
```
