object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'BuscaCEP - Gerar Arquivo Cache'
  ClientHeight = 461
  ClientWidth = 459
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 459
    Height = 41
    Align = alTop
    Caption = 'pnlHeader'
    Color = clHighlight
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
    ExplicitWidth = 494
    object lblHeader: TLabel
      AlignWithMargins = True
      Left = 1
      Top = 11
      Width = 457
      Height = 29
      Margins.Left = 0
      Margins.Top = 10
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      Alignment = taCenter
      Caption = 'BuscaCEP - Gerar Arquivo de Cache'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 289
      ExplicitHeight = 19
    end
  end
  object GroupBox1: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 44
    Width = 453
    Height = 168
    Align = alTop
    Caption = ' Gera'#231#227'o do arquivo de Cache '
    TabOrder = 1
    ExplicitLeft = 0
    ExplicitTop = 43
    ExplicitWidth = 449
    object Label1: TLabel
      AlignWithMargins = True
      Left = 7
      Top = 22
      Width = 439
      Height = 13
      Margins.Left = 5
      Margins.Top = 7
      Margins.Right = 5
      Align = alTop
      Caption = 'C'#243'digo IBGE'
      Color = cl3DLight
      ParentColor = False
      Transparent = False
      ExplicitLeft = 9
      ExplicitTop = 45
      ExplicitWidth = 480
    end
    object lblIBGETotalRegistros: TLabel
      AlignWithMargins = True
      Left = 7
      Top = 43
      Width = 439
      Height = 13
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Align = alTop
      Caption = 'Total de Localidades: '
      Color = clWindow
      ParentColor = False
      Transparent = True
      ExplicitLeft = 9
      ExplicitWidth = 435
    end
    object Label4: TLabel
      AlignWithMargins = True
      Left = 7
      Top = 66
      Width = 439
      Height = 13
      Margins.Left = 5
      Margins.Top = 7
      Margins.Right = 5
      Align = alTop
      Caption = 'C'#243'digo DDD'
      Color = cl3DLight
      ParentColor = False
      Transparent = False
      ExplicitWidth = 57
    end
    object lblDDDTotalRegistros: TLabel
      AlignWithMargins = True
      Left = 7
      Top = 87
      Width = 439
      Height = 13
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Align = alTop
      Caption = 'Total de DDD:'
      Color = clWindow
      ParentColor = False
      Transparent = True
      ExplicitLeft = 9
      ExplicitWidth = 435
    end
    object Bevel1: TBevel
      AlignWithMargins = True
      Left = 7
      Top = 108
      Width = 439
      Height = 3
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Align = alTop
      Shape = bsTopLine
      ExplicitLeft = 3
      ExplicitTop = 106
    end
    object lblArquivoCache: TLabel
      Left = 7
      Top = 115
      Width = 12
      Height = 13
      Caption = '...'
    end
    object btnGerarArquivo: TButton
      Left = 142
      Top = 136
      Width = 300
      Height = 25
      Caption = 'Gerar arquivo de Cache'
      TabOrder = 0
      OnClick = btnGerarArquivoClick
    end
  end
  object GroupBox2: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 218
    Width = 453
    Height = 240
    Align = alClient
    Caption = ' Teste e valida'#231#227'o do arquivo de cache '
    TabOrder = 2
    ExplicitLeft = 1
    ExplicitTop = 208
    ExplicitWidth = 449
    ExplicitHeight = 280
    object Label3: TLabel
      Left = 73
      Top = 40
      Width = 13
      Height = 20
      Caption = '+'
    end
    object edtUF: TLabeledEdit
      Left = 10
      Top = 40
      Width = 50
      Height = 21
      EditLabel.Width = 13
      EditLabel.Height = 13
      EditLabel.Caption = 'UF'
      TabOrder = 0
      Text = 'RS'
    end
    object edtLocalidade: TLabeledEdit
      Left = 99
      Top = 40
      Width = 218
      Height = 21
      EditLabel.Width = 50
      EditLabel.Height = 13
      EditLabel.Caption = 'Localidade'
      TabOrder = 1
      Text = 'Porto Alegre'
    end
    object Button1: TButton
      Left = 332
      Top = 38
      Width = 110
      Height = 25
      Caption = 'Calcular Hash'
      TabOrder = 2
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 332
      Top = 91
      Width = 110
      Height = 25
      Caption = 'Localizar Hash'
      TabOrder = 3
      OnClick = Button2Click
    end
    object edtHash: TLabeledEdit
      Left = 10
      Top = 93
      Width = 305
      Height = 21
      EditLabel.Width = 73
      EditLabel.Height = 13
      EditLabel.Caption = 'Hash Calculado'
      TabOrder = 4
    end
    object Panel1: TPanel
      Left = 10
      Top = 150
      Width = 432
      Height = 80
      BevelOuter = bvNone
      Caption = 'Panel1'
      Color = clWhite
      ParentBackground = False
      ShowCaption = False
      TabOrder = 5
      object Shape1: TShape
        Left = 0
        Top = 0
        Width = 432
        Height = 80
        Align = alClient
        Pen.Style = psDot
        ExplicitLeft = 8
        ExplicitTop = 82
        ExplicitWidth = 337
        ExplicitHeight = 47
      end
      object Memo1: TMemo
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 426
        Height = 74
        Align = alClient
        BorderStyle = bsNone
        Lines.Strings = (
          'O hash '#233' criado usando a fun'#231#227'o '
          
            '"BuscaCEP.Utils.TBuscaCEPCache.Default.GetHash" passando UF e Lo' +
            'calidade.'
          ''
          'Ex: '
          
            'BuscaCEP.Utils.TBuscaCEPCache.Default.GetHash('#39'RS'#39', '#39'Porto Alegr' +
            'e'#39');')
        TabOrder = 0
        ExplicitLeft = 0
        ExplicitHeight = 104
      end
    end
  end
  object NetHTTPClient: TNetHTTPClient
    Asynchronous = False
    ConnectionTimeout = 60000
    ResponseTimeout = 60000
    HandleRedirects = True
    AllowCookies = True
    UserAgent = 'Embarcadero URI Client/1.0'
    Left = 304
    Top = 11
  end
  object NetHTTPRequest: TNetHTTPRequest
    Asynchronous = False
    ConnectionTimeout = 60000
    ResponseTimeout = 60000
    Client = NetHTTPClient
    Left = 352
    Top = 11
  end
  object mtCache: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 408
    Top = 11
    object mtCacheUF_IBGE: TIntegerField
      FieldName = 'UF_IBGE'
    end
    object mtCacheUF_SIGLA: TStringField
      FieldName = 'UF_SIGLA'
      Size = 2
    end
    object mtCacheLOCALIDADE_IBGE: TIntegerField
      FieldName = 'LOCALIDADE_IBGE'
    end
    object mtCacheLOCALIDADE_NOME: TStringField
      FieldName = 'LOCALIDADE_NOME'
      Size = 100
    end
    object mtCacheDDD: TIntegerField
      FieldName = 'DDD'
    end
    object mtCacheHASH: TStringField
      FieldName = 'HASH'
      Size = 50
    end
  end
end
