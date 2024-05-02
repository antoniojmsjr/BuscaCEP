object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Client - API CEP'
  ClientHeight = 561
  ClientWidth = 684
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 684
    Height = 41
    Align = alTop
    Caption = 'pnlHeader'
    Color = clHighlight
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
    object lblHeader: TLabel
      AlignWithMargins = True
      Left = 1
      Top = 11
      Width = 682
      Height = 29
      Margins.Left = 0
      Margins.Top = 10
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      Alignment = taCenter
      Caption = 'Client - API CEP'
      Color = 14120960
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      ExplicitWidth = 132
      ExplicitHeight = 19
    end
  end
  object gbxEndereco: TGroupBox
    Left = 0
    Top = 96
    Width = 684
    Height = 325
    Align = alTop
    Caption = ' Endere'#231'o '
    TabOrder = 1
    DesignSize = (
      684
      325)
    object Label1: TLabel
      Left = 13
      Top = 30
      Width = 20
      Height = 13
      Caption = 'CEP'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Bevel1: TBevel
      Left = 7
      Top = 120
      Width = 670
      Height = 15
      Anchors = [akLeft, akTop, akRight]
      Shape = bsTopLine
    end
    object Label4: TLabel
      Left = 13
      Top = 65
      Width = 65
      Height = 13
      Caption = 'Logradouro'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 237
      Top = 65
      Width = 60
      Height = 13
      Caption = 'Localidade'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label6: TLabel
      Left = 410
      Top = 65
      Width = 14
      Height = 13
      Caption = 'UF'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtFiltroCEP: TMaskEdit
      Left = 55
      Top = 27
      Width = 100
      Height = 21
      EditMask = '00000\-999;0;_'
      MaxLength = 9
      TabOrder = 0
      Text = '90520003'
      TextHint = 'Informe o CEP...'
    end
    object btnConsultarCEP: TButton
      Left = 170
      Top = 25
      Width = 100
      Height = 25
      Caption = 'Consultar CEP'
      TabOrder = 1
      OnClick = btnConsultarCEPClick
    end
    object edtLogradouro: TLabeledEdit
      Left = 13
      Top = 155
      Width = 300
      Height = 21
      EditLabel.Width = 55
      EditLabel.Height = 13
      EditLabel.Caption = 'Logradouro'
      TabOrder = 2
    end
    object edtNumero: TLabeledEdit
      Left = 345
      Top = 155
      Width = 65
      Height = 21
      EditLabel.Width = 37
      EditLabel.Height = 13
      EditLabel.Caption = 'N'#250'mero'
      TabOrder = 3
    end
    object edtComplemento: TLabeledEdit
      Left = 435
      Top = 155
      Width = 150
      Height = 21
      EditLabel.Width = 65
      EditLabel.Height = 13
      EditLabel.Caption = 'Complemento'
      TabOrder = 4
    end
    object edtBairro: TLabeledEdit
      Left = 13
      Top = 203
      Width = 300
      Height = 21
      EditLabel.Width = 28
      EditLabel.Height = 13
      EditLabel.Caption = 'Bairro'
      TabOrder = 5
    end
    object edtLocalidade: TLabeledEdit
      Left = 13
      Top = 249
      Width = 300
      Height = 21
      EditLabel.Width = 50
      EditLabel.Height = 13
      EditLabel.Caption = 'Localidade'
      TabOrder = 6
    end
    object edtLocalidadeIBGE: TLabeledEdit
      Left = 345
      Top = 249
      Width = 65
      Height = 21
      EditLabel.Width = 76
      EditLabel.Height = 13
      EditLabel.Caption = 'Localidade IBGE'
      TabOrder = 7
    end
    object edtEstado: TLabeledEdit
      Left = 13
      Top = 295
      Width = 300
      Height = 21
      EditLabel.Width = 33
      EditLabel.Height = 13
      EditLabel.Caption = 'Estado'
      TabOrder = 8
    end
    object edtEstadoIBGE: TLabeledEdit
      Left = 345
      Top = 295
      Width = 65
      Height = 21
      EditLabel.Width = 59
      EditLabel.Height = 13
      EditLabel.Caption = 'Estado IBGE'
      TabOrder = 9
    end
    object btnConsultarLogradouro: TButton
      Left = 480
      Top = 82
      Width = 130
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Consultar Logradouro'
      TabOrder = 10
      OnClick = btnConsultarLogradouroClick
    end
    object edtFiltroLogradouro: TEdit
      Left = 13
      Top = 84
      Width = 200
      Height = 21
      TabOrder = 11
      Text = 'Avenida Pl'#237'nio Brasil Milano'
    end
    object edtFiltroLocalidade: TEdit
      Left = 237
      Top = 84
      Width = 150
      Height = 21
      TabOrder = 12
      Text = 'Porto Alegre'
    end
    object edtFiltroUF: TEdit
      Left = 410
      Top = 84
      Width = 50
      Height = 21
      TabOrder = 13
      Text = 'RS'
    end
  end
  object gbxResultadoJSON: TGroupBox
    Left = 0
    Top = 421
    Width = 684
    Height = 140
    Align = alClient
    Caption = ' Resultado JSON '
    TabOrder = 2
    object mmoResultadoJSON: TMemo
      AlignWithMargins = True
      Left = 5
      Top = 18
      Width = 674
      Height = 117
      Align = alClient
      BorderStyle = bsNone
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object gbxIdentificacaoAPI: TGroupBox
    Left = 0
    Top = 41
    Width = 684
    Height = 55
    Align = alTop
    Caption = ' Identifica'#231#227'o da API '
    TabOrder = 3
    object Label2: TLabel
      Left = 13
      Top = 25
      Width = 29
      Height = 13
      Caption = 'Host:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 200
      Top = 25
      Width = 27
      Height = 13
      Caption = 'Port:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAPIHost: TEdit
      Left = 55
      Top = 22
      Width = 100
      Height = 21
      TabOrder = 0
      Text = 'http://localhost'
    end
    object edtAPIPort: TEdit
      Left = 245
      Top = 22
      Width = 50
      Height = 21
      TabOrder = 1
      Text = '9000'
    end
  end
  object NetHTTPClient: TNetHTTPClient
    Asynchronous = False
    ConnectionTimeout = 60000
    ResponseTimeout = 60000
    HandleRedirects = True
    AllowCookies = True
    UserAgent = 'Embarcadero URI Client/1.0'
    Left = 432
    Top = 9
  end
  object NetHTTPRequest: TNetHTTPRequest
    Asynchronous = False
    ConnectionTimeout = 60000
    ResponseTimeout = 60000
    Client = NetHTTPClient
    Left = 512
    Top = 9
  end
end
