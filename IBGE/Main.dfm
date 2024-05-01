object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'BuscaCEP - Gerar Arquivo IBGE'
  ClientHeight = 356
  ClientWidth = 494
  Color = clBtnFace
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
  object Label1: TLabel
    Left = 99
    Top = 91
    Width = 106
    Height = 13
    Caption = 'Total de registros: '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblTotalRegistros: TLabel
    Left = 215
    Top = 91
    Width = 12
    Height = 13
    Caption = '...'
  end
  object Label2: TLabel
    Left = 99
    Top = 110
    Width = 98
    Height = 13
    Caption = 'Local do arquivo: '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblLocalArquivo: TLabel
    Left = 215
    Top = 110
    Width = 12
    Height = 13
    Caption = '...'
  end
  object Bevel1: TBevel
    Left = 8
    Top = 136
    Width = 478
    Height = 9
    Shape = bsTopLine
  end
  object Label3: TLabel
    Left = 73
    Top = 171
    Width = 8
    Height = 13
    Caption = '+'
  end
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 494
    Height = 41
    Align = alTop
    Caption = 'pnlHeader'
    Color = clHighlight
    ParentBackground = False
    ShowCaption = False
    TabOrder = 6
    object lblHeader: TLabel
      AlignWithMargins = True
      Left = 1
      Top = 11
      Width = 492
      Height = 29
      Margins.Left = 0
      Margins.Top = 10
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      Alignment = taCenter
      Caption = 'BuscaCEP - Gerar Arquivo IBGE'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 255
      ExplicitHeight = 19
    end
  end
  object btnGerarArquivo: TButton
    Left = 99
    Top = 55
    Width = 300
    Height = 25
    Caption = 'Gerar arquivo IBGE'
    TabOrder = 0
    OnClick = btnGerarArquivoClick
  end
  object edtUF: TLabeledEdit
    Left = 8
    Top = 168
    Width = 50
    Height = 21
    EditLabel.Width = 13
    EditLabel.Height = 13
    EditLabel.Caption = 'UF'
    TabOrder = 1
    Text = 'RS'
  end
  object edtLocalidade: TLabeledEdit
    Left = 95
    Top = 168
    Width = 253
    Height = 21
    EditLabel.Width = 50
    EditLabel.Height = 13
    EditLabel.Caption = 'Localidade'
    TabOrder = 2
    Text = 'Porto Alegre'
  end
  object Button1: TButton
    Left = 370
    Top = 166
    Width = 110
    Height = 25
    Caption = 'Calcular Hash'
    TabOrder = 3
    OnClick = Button1Click
  end
  object Panel1: TPanel
    Left = 8
    Top = 249
    Width = 340
    Height = 100
    BevelOuter = bvNone
    Caption = 'Panel1'
    Color = clWhite
    ParentBackground = False
    ShowCaption = False
    TabOrder = 7
    object Shape1: TShape
      Left = 0
      Top = 0
      Width = 340
      Height = 100
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
      Width = 334
      Height = 94
      Align = alClient
      BorderStyle = bsNone
      Lines.Strings = (
        'O hash '#233' criado usando a fun'#231#227'o '
        '"BuscaCEP.Utils.TBuscaCEPLocalidadesIBGE.Default.GetHashIBGE" '
        'passando UF e Localidade.'
        ''
        'Ex: '
        'BuscaCEP.Utils.TBuscaCEPLocalidadesIBGE.Default.GetHashIBGE'
        '('#39'RS'#39', '#39'Porto Alegre'#39');')
      TabOrder = 0
      ExplicitTop = 4
    end
  end
  object Button2: TButton
    Left = 370
    Top = 213
    Width = 110
    Height = 25
    Caption = 'Localizar Hash'
    TabOrder = 5
    OnClick = Button2Click
  end
  object edtHash: TLabeledEdit
    Left = 8
    Top = 215
    Width = 340
    Height = 21
    EditLabel.Width = 73
    EditLabel.Height = 13
    EditLabel.Caption = 'Hash Calculado'
    TabOrder = 4
  end
  object NetHTTPClient: TNetHTTPClient
    Asynchronous = False
    ConnectionTimeout = 60000
    ResponseTimeout = 60000
    HandleRedirects = True
    AllowCookies = True
    UserAgent = 'Embarcadero URI Client/1.0'
    Left = 152
    Top = 11
  end
  object NetHTTPRequest: TNetHTTPRequest
    Asynchronous = False
    ConnectionTimeout = 60000
    ResponseTimeout = 60000
    Client = NetHTTPClient
    Left = 240
    Top = 11
  end
  object mtIBGE: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 344
    Top = 11
    object mtIBGEESTADO_IBGE: TIntegerField
      FieldName = 'ESTADO_IBGE'
    end
    object mtIBGEESTADO_UF: TStringField
      FieldName = 'ESTADO_UF'
      Size = 2
    end
    object mtIBGELOCALIDADE_IBGE: TIntegerField
      FieldName = 'LOCALIDADE_IBGE'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
    end
    object mtIBGELOCALIDADE_NOME: TStringField
      FieldName = 'LOCALIDADE_NOME'
      Size = 200
    end
    object mtIBGEHASH: TStringField
      FieldName = 'HASH'
      Size = 35
    end
  end
end
