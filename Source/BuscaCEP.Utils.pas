{******************************************************************************}
{                                                                              }
{           BuscaCEP.Utils.pas                                                 }
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
unit BuscaCEP.Utils;

{$IFDEF RELEASE}
{$ASSERTIONS OFF}
{$ENDIF}

interface

uses
  System.Generics.Collections, SyncObjs, BuscaCEP.Types;

Type

  {$REGION 'TBuscaCEPEstados'}
  TBuscaCEPEstados = class
  strict private
    { private declarations }
  class var
    FLock: TCriticalSection;
    FInstance: TBuscaCEPEstados;
    class constructor Create;
    class destructor Destroy;
    class function GetDefault: TBuscaCEPEstados; static;
  private
    FEstados: TObjectDictionary<string, TBuscaCEPLogradouroEstado>;
    procedure Initialize;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create;
    destructor Destroy; override;
    function GetEstado(const pUF: string): TBuscaCEPLogradouroEstado;
    class property Default: TBuscaCEPEstados read GetDefault;
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPLocalidadeIBGE'}
  TBuscaCEPCacheLocalidade = class
  strict private
    { private declarations }
    FUF: string;
    FIBGE: Integer;
    FDDD: Integer;
    FNome: string;
    FHash: string;
  protected
    { protected declarations }
  public
    { public declarations }
    function Add(const pTexto: string): TBuscaCEPCacheLocalidade;
    property UF: string read FUF;
    property IBGE: Integer read FIBGE;
    property DDD: Integer read FDDD;
    property Nome: string read FNome;
    property Hash: string read FHash;
  end;
  {$ENDREGION}

  {$REGION 'TBuscaCEPCache'}
  TBuscaCEPCache = class
  strict private
    { private declarations }
  class var
    FLock: TCriticalSection;
    FInstance: TBuscaCEPCache;
    class constructor Create;
    class destructor Destroy;
    class function GetDefault: TBuscaCEPCache; static;
  private
    FLocalidades: TObjectDictionary<string, TBuscaCEPCacheLocalidade>;
    FArquivoCache: string;
    FArquivoCacheCarregado: Boolean;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create;
    destructor Destroy; override;
    procedure Processar(const pBuscaCEPCache: string);
    function GetLocalidade(const pHash: string): TBuscaCEPCacheLocalidade; overload;
    function GetLocalidade(const pUF: string; const pLocalidade: string): TBuscaCEPCacheLocalidade; overload;
    function GetHash(const pUF: string; const pLocalidade: string): string;
    procedure GetCodigos(const pUF: string; const pLocalidade: string; out pCodigoIBGE: Integer; out pCodigoDDD: Integer);
    function GetCodigoIBGE(const pUF: string; const pLocalidade: string): Integer;
    function GetCodigoDDD(const pUF: string; const pLocalidade: string): Integer;
    class property Default: TBuscaCEPCache read GetDefault;
  end;
  {$ENDREGION}

function OnlyNumber(const pString: string): string;
function FormatCEP(const pCEP: string): string;

implementation

uses
  System.StrUtils, System.SysUtils, System.Classes, System.Hash, System.Character;

function GetHashLocalidadeIBGE(const pUF: string; const pLocalidade: string): string; forward;

{$REGION 'TBuscaCEPEstados'}
constructor TBuscaCEPEstados.Create;
begin
  FEstados := TObjectDictionary<string, TBuscaCEPLogradouroEstado>.Create([doOwnsValues], 1024);
end;

destructor TBuscaCEPEstados.Destroy;
begin
  FreeAndNil(FEstados);
  inherited Destroy;
end;

class constructor TBuscaCEPEstados.Create;
begin
  FLock := TCriticalSection.Create;
end;

class destructor TBuscaCEPEstados.Destroy;
begin
  FreeAndNil(FInstance);
  FreeAndNil(FLock);
end;

class function TBuscaCEPEstados.GetDefault: TBuscaCEPEstados;
begin
  if not Assigned(FInstance) then
  begin
    FLock.Enter;
    try
      if not Assigned(FInstance) then
      begin
        FInstance := TBuscaCEPEstados.Create;
        FInstance.Initialize;
      end;
    finally
      FLock.Leave;
    end;
  end;
  Result := FInstance;
end;

function TBuscaCEPEstados.GetEstado(const pUF: string): TBuscaCEPLogradouroEstado;
var
  lUF: string;
begin
  lUF := UpperCase(pUF);
  FEstados.TryGetValue(lUF, Result);
end;

procedure TBuscaCEPEstados.Initialize;
begin
  //NORTE
  FEstados.Add('RO', TBuscaCEPLogradouroEstado.Create(11, 'Rondônia', 'RO',
                                               TBuscaCEPLogradouroRegiao.Create(1, 'Norte', 'N')));
  FEstados.Add('AC', TBuscaCEPLogradouroEstado.Create(12, 'Acre', 'AC',
                                               TBuscaCEPLogradouroRegiao.Create(1, 'Norte', 'N')));
  FEstados.Add('AM', TBuscaCEPLogradouroEstado.Create(13, 'Amazonas', 'AM',
                                               TBuscaCEPLogradouroRegiao.Create(1, 'Norte', 'N')));
  FEstados.Add('RR', TBuscaCEPLogradouroEstado.Create(14, 'Roraima', 'RR',
                                               TBuscaCEPLogradouroRegiao.Create(1, 'Norte', 'N')));
  FEstados.Add('PA', TBuscaCEPLogradouroEstado.Create(15, 'Pará', 'PA',
                                               TBuscaCEPLogradouroRegiao.Create(1, 'Norte', 'N')));
  FEstados.Add('AP', TBuscaCEPLogradouroEstado.Create(16, 'Amapá', 'AP',
                                               TBuscaCEPLogradouroRegiao.Create(1, 'Norte', 'N')));
  FEstados.Add('TO', TBuscaCEPLogradouroEstado.Create(17, 'Tocantins', 'TO',
                                               TBuscaCEPLogradouroRegiao.Create(1, 'Norte', 'N')));

  //NORDESTE
  FEstados.Add('MA', TBuscaCEPLogradouroEstado.Create(21, 'Maranhão', 'MA',
                                               TBuscaCEPLogradouroRegiao.Create(2, 'Nordeste', 'NE')));
  FEstados.Add('PI', TBuscaCEPLogradouroEstado.Create(22, 'Piauí', 'PI',
                                               TBuscaCEPLogradouroRegiao.Create(2, 'Nordeste', 'NE')));
  FEstados.Add('CE', TBuscaCEPLogradouroEstado.Create(23, 'Ceará', 'CE',
                                               TBuscaCEPLogradouroRegiao.Create(2, 'Nordeste', 'NE')));
  FEstados.Add('RN', TBuscaCEPLogradouroEstado.Create(24, 'Rio Grande do Norte', 'RN',
                                               TBuscaCEPLogradouroRegiao.Create(2, 'Nordeste', 'NE')));
  FEstados.Add('PB', TBuscaCEPLogradouroEstado.Create(25, 'Paraíba', 'PB',
                                               TBuscaCEPLogradouroRegiao.Create(2, 'Nordeste', 'NE')));
  FEstados.Add('PE', TBuscaCEPLogradouroEstado.Create(26, 'Pernambuco', 'PE',
                                               TBuscaCEPLogradouroRegiao.Create(2, 'Nordeste', 'NE')));
  FEstados.Add('AL', TBuscaCEPLogradouroEstado.Create(27, 'Alagoas', 'AL',
                                               TBuscaCEPLogradouroRegiao.Create(2, 'Nordeste', 'NE')));
  FEstados.Add('SE', TBuscaCEPLogradouroEstado.Create(28, 'Sergipe', 'SE',
                                               TBuscaCEPLogradouroRegiao.Create(2, 'Nordeste', 'NE')));
  FEstados.Add('BA', TBuscaCEPLogradouroEstado.Create(29, 'Bahia', 'BA',
                                               TBuscaCEPLogradouroRegiao.Create(2, 'Nordeste', 'NE')));

  //SUDESTE
  FEstados.Add('MG', TBuscaCEPLogradouroEstado.Create(31, 'Minas Gerais', 'MG',
                                               TBuscaCEPLogradouroRegiao.Create(3, 'Sudeste', 'SE')));
  FEstados.Add('ES', TBuscaCEPLogradouroEstado.Create(32, 'Espírito Santo', 'ES',
                                               TBuscaCEPLogradouroRegiao.Create(3, 'Sudeste', 'SE')));
  FEstados.Add('RJ', TBuscaCEPLogradouroEstado.Create(33, 'Rio de Janeiro', 'RJ',
                                               TBuscaCEPLogradouroRegiao.Create(3, 'Sudeste', 'SE')));
  FEstados.Add('SP', TBuscaCEPLogradouroEstado.Create(35, 'São Paulo', 'SP',
                                               TBuscaCEPLogradouroRegiao.Create(3, 'Sudeste', 'SE')));

  //SUL
  FEstados.Add('PR', TBuscaCEPLogradouroEstado.Create(41, 'Paraná', 'PR',
                                               TBuscaCEPLogradouroRegiao.Create(4, 'Sul', 'S')));
  FEstados.Add('SC', TBuscaCEPLogradouroEstado.Create(42, 'Santa Catarina', 'SC',
                                               TBuscaCEPLogradouroRegiao.Create(4, 'Sul', 'S')));
  FEstados.Add('RS', TBuscaCEPLogradouroEstado.Create(43, 'Rio Grande do Sul', 'RS',
                                               TBuscaCEPLogradouroRegiao.Create(4, 'Sul', 'S')));

  //CENTRO-OESTE
  FEstados.Add('MS', TBuscaCEPLogradouroEstado.Create(50, 'Mato Grosso do Sul', 'MS',
                                               TBuscaCEPLogradouroRegiao.Create(5, 'Centro-Oeste', 'CO')));
  FEstados.Add('MT', TBuscaCEPLogradouroEstado.Create(51, 'Mato Grosso', 'MT',
                                               TBuscaCEPLogradouroRegiao.Create(5, 'Centro-Oeste', 'CO')));
  FEstados.Add('GO', TBuscaCEPLogradouroEstado.Create(52, 'Goiás', 'GO',
                                               TBuscaCEPLogradouroRegiao.Create(5, 'Centro-Oeste', 'CO')));
  FEstados.Add('DF', TBuscaCEPLogradouroEstado.Create(53, 'Distrito Federal', 'DF',
                                               TBuscaCEPLogradouroRegiao.Create(5, 'Centro-Oeste', 'CO')));
end;
{$ENDREGION}

{$REGION 'TBuscaCEPCacheLocalidade'}
function TBuscaCEPCacheLocalidade.Add(const pTexto: string): TBuscaCEPCacheLocalidade;
var
  lValues: TArray<string>;
begin
  Result := Self;

  // RO|069|1100015|Alta Floresta D'Oeste|91d3d0bbdda98e15bed18dd5b625f319
  lValues := pTexto.Split(['|']);

  FUF   := lValues[0];
  FDDD := StrToIntDef(lValues[1], 0);
  FIBGE := StrToIntDef(lValues[2], 0);
  FNome := lValues[3];
  FHash := lValues[4];
end;
{$ENDREGION}

{$REGION 'TBuscaCEPCache'}
constructor TBuscaCEPCache.Create;
begin
  FArquivoCacheCarregado := False;
  FLocalidades := TObjectDictionary<string, TBuscaCEPCacheLocalidade>.Create([doOwnsValues], 1024);
end;

destructor TBuscaCEPCache.Destroy;
begin
  FreeAndNil(FLocalidades);
  inherited Destroy;
end;

class constructor TBuscaCEPCache.Create;
begin
  FLock := TCriticalSection.Create;
end;

class destructor TBuscaCEPCache.Destroy;
begin
  FreeAndNil(FInstance);
  FreeAndNil(FLock);
end;

class function TBuscaCEPCache.GetDefault: TBuscaCEPCache;
begin
  if not Assigned(FInstance) then
  begin
    FLock.Enter;
    try
      if not Assigned(FInstance) then
        FInstance := TBuscaCEPCache.Create;
    finally
      FLock.Leave;
    end;
  end;
  Result := FInstance;
end;

function TBuscaCEPCache.GetCodigoDDD(const pUF: string; const pLocalidade: string): Integer;
var
  lLocalidade: TBuscaCEPCacheLocalidade;
begin
  Result := 0;

  lLocalidade := GetLocalidade(pUF, pLocalidade);
  if Assigned(lLocalidade) then
    Result := lLocalidade.DDD;
end;

function TBuscaCEPCache.GetCodigoIBGE(const pUF: string; const pLocalidade: string): Integer;
var
  lLocalidade: TBuscaCEPCacheLocalidade;
begin
  Result := 0;

  lLocalidade := GetLocalidade(pUF, pLocalidade);
  if Assigned(lLocalidade) then
    Result := lLocalidade.IBGE;
end;

procedure TBuscaCEPCache.GetCodigos(const pUF: string; const pLocalidade: string;
  out pCodigoIBGE: Integer; out pCodigoDDD: Integer);
var
  lLocalidade: TBuscaCEPCacheLocalidade;
begin
  pCodigoDDD := 0;
  pCodigoIBGE := 0;

  lLocalidade := GetLocalidade(pUF, pLocalidade);
  if Assigned(lLocalidade) then
  begin
    pCodigoDDD := lLocalidade.DDD;
    pCodigoIBGE := lLocalidade.IBGE;
  end;
end;

function TBuscaCEPCache.GetLocalidade(const pUF: string; const pLocalidade: string): TBuscaCEPCacheLocalidade;
var
  lHash: string;
begin
  Result := nil;

  // ARQUIVO BuscaCEP.dat
  Assert(FArquivoCacheCarregado, 'Arquivo BuscaCEP.dat não processado.');

  lHash := GetHash(pUF, pLocalidade);
  FLocalidades.TryGetValue(lHash, Result);
end;

function TBuscaCEPCache.GetHash(const pUF: string; const pLocalidade: string): string;
begin
  Result := GetHashLocalidadeIBGE(pUF, pLocalidade);
end;

function TBuscaCEPCache.GetLocalidade(const pHash: string): TBuscaCEPCacheLocalidade;
begin
  Result := nil;

  // ARQUIVO BuscaCEP.dat
  Assert(FArquivoCacheCarregado, 'Arquivo BuscaCEP.dat não processado.');

  FLocalidades.TryGetValue(pHash, Result);
end;

procedure TBuscaCEPCache.Processar(const pBuscaCEPCache: string);
var
  lFile: TextFile;
  lText: string;
  lLocalidade: TBuscaCEPCacheLocalidade;
begin
  if FArquivoCacheCarregado then
    Exit;

  FArquivoCache := Trim(pBuscaCEPCache);
  if not FileExists(FArquivoCache) then
    Exit;

  FLock.Enter;
  try
    AssignFile(lFile, FArquivoCache);
    try
      Reset(lFile);
      Readln(lFile, lText); //IGNORA A 1º LINHA

      FArquivoCacheCarregado := True;

      while not Eof(lFile) do
      begin
        Readln(lFile, lText);

        lLocalidade := TBuscaCEPCacheLocalidade.Create.Add(lText);
        try
          FLocalidades.Add(lLocalidade.Hash, lLocalidade);
        except
          on E: EListError do
            raise Exception.Create('Falha ao processar o arquivo "BuscaCEP.dat": ' + sLineBreak +
                                   'Hash: ' + lLocalidade.Hash + sLineBreak +
                                   E.Message);
          on E: Exception do
            raise Exception.Create('Falha ao processar o arquivo "BuscaCEP.dat": ' + E.Message);
        end;
      end;
    finally
      CloseFile(lFile);
    end;
  finally
    FLock.Leave;
  end;
end;
{$ENDREGION}

function OnlyNumber(const pString: string): string;
var
  I: Integer;
  lChar: Char;
begin
  Result := EmptyStr;
  for I := Low(pString) to High(pString) do
  begin
    lChar := pString[I];
    if lChar.IsDigit then
      Result := (Result + lChar);
  end;
  Result := Trim(Result);
end;

function FormatCEP(const pCEP: string): string;
begin
  Result := Copy(pCEP, 1, 5) + '-' + Copy(pCEP, 6, 3);
end;

function ReplaceCharacter(const pChar: Char): Char;
begin
  // https://www.ascii-code.com/
  case Byte(pChar) of
    192..198 : Result := 'A';
    199      : Result := 'C';
    200..203 : Result := 'E';
    204..207 : Result := 'I';
    208      : Result := 'D';
    209      : Result := 'N';
    210..214 : Result := 'O';
    215      : Result := 'x';
    216, 248 : Result := '0';
    217..220 : Result := 'U';
    221      : Result := 'Y';
    222, 254 : Result := 'b';
    223      : Result := 'B';
    224..230 : Result := 'a';
    231      : Result := 'c';
    232..235 : Result := 'e';
    236..239 : Result := 'i';
    240, 242..246 : Result := 'o';
    247      : Result := '/';
    241      : Result := 'n';
    249..252 : Result := 'u';
    253, 255 : Result := 'y';
  else
    Result := pChar;
  end;
end;

function ReplaceCharacters(const pString: string): string;
var
  lLetraInput: Char;
  lLetraOutput: Char;
begin
  Result := '';

  for lLetraInput in pString do
  begin
    if (Byte(lLetraInput) in [0..64, 91..96, 123..191]) then
      Continue;

    lLetraOutput := ReplaceCharacter(lLetraInput);
    Result := (Result + lLetraOutput);
  end;
end;

function GetHashLocalidadeIBGE(const pUF: string; const pLocalidade: string): string;
var
  lUF: string;
  lLocalidade: string;
begin
  lUF := Trim(pUF);
  lUF := LowerCase(lUF);
  lLocalidade := Trim(pLocalidade);
  lLocalidade := ReplaceCharacters(lLocalidade);
  lLocalidade := LowerCase(lLocalidade);

  Result := THashMD5.GetHashString(lUF + lLocalidade);
end;

end.
