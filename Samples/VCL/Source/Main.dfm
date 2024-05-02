object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Busca CEP - VCL'
  ClientHeight = 761
  ClientWidth = 684
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnResize = FormResize
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
      Caption = 'Busca CEP - VCL'
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
  object gbxCEP: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 94
    Width = 678
    Height = 195
    Align = alTop
    Caption = ' Busca por CEP '
    TabOrder = 1
    DesignSize = (
      678
      195)
    object lblCEP: TLabel
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
    object bvlCEP: TBevel
      Left = 5
      Top = 55
      Width = 670
      Height = 5
      Anchors = [akTop, akRight]
      Shape = bsTopLine
    end
    object edtFiltroCEP: TMaskEdit
      Left = 45
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
      Left = 570
      Top = 25
      Width = 100
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Consultar'
      TabOrder = 1
      OnClick = btnConsultarCEPClick
    end
    object dbgCEPLogradouros: TDBGrid
      Left = 13
      Top = 65
      Width = 657
      Height = 120
      DataSource = dsLogradouros
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      ParentFont = False
      TabOrder = 2
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = [fsBold]
      Columns = <
        item
          Expanded = False
          FieldName = 'LOGRADOURO'
          Width = 150
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'COMPLEMENTO'
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'BAIRRO'
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'LOCALIDADE'
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'LOCALIDADE_IBGE'
          Width = 110
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ESTADO'
          Width = 110
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ESTADO_IBGE'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'REGIAO'
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'REGIAO_IBGE'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'CEP'
          Width = 60
          Visible = True
        end>
    end
  end
  object gbxLogradouro: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 295
    Width = 678
    Height = 245
    Align = alTop
    Caption = ' Busca por Logradouro'
    TabOrder = 2
    DesignSize = (
      678
      245)
    object Label2: TLabel
      Left = 13
      Top = 25
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
    object bvlLogradouro: TBevel
      Left = 5
      Top = 75
      Width = 670
      Height = 5
      Anchors = [akTop, akRight]
      Shape = bsTopLine
    end
    object Label3: TLabel
      Left = 237
      Top = 25
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
    object Label4: TLabel
      Left = 410
      Top = 25
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
    object btnConsultarLogradouro: TButton
      Left = 575
      Top = 42
      Width = 100
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Consultar'
      TabOrder = 3
      OnClick = btnConsultarLogradouroClick
    end
    object edtFiltroLogradouro: TEdit
      Left = 13
      Top = 44
      Width = 200
      Height = 21
      TabOrder = 0
      Text = 'Avenida Pl'#237'nio Brasil Milano'
    end
    object edtFiltroLocalidade: TEdit
      Left = 237
      Top = 44
      Width = 150
      Height = 21
      TabOrder = 1
      Text = 'Porto Alegre'
    end
    object edtFiltroUF: TEdit
      Left = 410
      Top = 44
      Width = 50
      Height = 21
      TabOrder = 2
      Text = 'RS'
    end
    object dbgLogradouros: TDBGrid
      Left = 13
      Top = 85
      Width = 657
      Height = 150
      DataSource = dsLogradouros
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      ParentFont = False
      TabOrder = 4
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = [fsBold]
      Columns = <
        item
          Expanded = False
          FieldName = 'LOGRADOURO'
          Width = 170
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'COMPLEMENTO'
          Width = 120
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'BAIRRO'
          Width = 90
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'LOCALIDADE'
          Width = 90
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'LOCALIDADE_IBGE'
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ESTADO'
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ESTADO_IBGE'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'REGIAO'
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'REGIAO_IBGE'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'CEP'
          Width = 60
          Visible = True
        end>
    end
  end
  object gbxProviders: TGroupBox
    Left = 0
    Top = 41
    Width = 684
    Height = 50
    Align = alTop
    Caption = ' Providers '
    TabOrder = 3
    object Label5: TLabel
      Left = 10
      Top = 20
      Width = 55
      Height = 13
      Caption = 'Provedor:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbxProviders: TComboBox
      Left = 80
      Top = 17
      Width = 200
      Height = 21
      Style = csDropDownList
      DropDownCount = 15
      TabOrder = 0
      TextHint = 'Selecione um provedor...'
    end
  end
  object gbxResultadoJSON: TGroupBox
    Left = 0
    Top = 543
    Width = 684
    Height = 218
    Align = alClient
    Caption = ' Resultado JSON '
    TabOrder = 4
    object mmoResultadoJSON: TMemo
      AlignWithMargins = True
      Left = 5
      Top = 18
      Width = 674
      Height = 195
      Align = alClient
      BorderStyle = bsNone
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object memLogradouros: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 480
    Top = 5
    object memLogradourosLOGRADOURO: TStringField
      DisplayLabel = 'Logradouro'
      FieldName = 'LOGRADOURO'
      Size = 200
    end
    object memLogradourosCOMPLEMENTO: TStringField
      DisplayLabel = 'Complemento'
      FieldName = 'COMPLEMENTO'
      Size = 150
    end
    object memLogradourosBAIRRO: TStringField
      DisplayLabel = 'Bairro'
      FieldName = 'BAIRRO'
      Size = 100
    end
    object memLogradourosLOCALIDADE: TStringField
      DisplayLabel = 'Localidade'
      FieldName = 'LOCALIDADE'
      Size = 100
    end
    object memLogradourosLOCALIDADE_IBGE: TIntegerField
      DisplayLabel = 'Localidade IBGE'
      FieldName = 'LOCALIDADE_IBGE'
    end
    object memLogradourosESTADO: TStringField
      DisplayLabel = 'Estado'
      FieldName = 'ESTADO'
      Size = 100
    end
    object memLogradourosESTADO_IBGE: TIntegerField
      DisplayLabel = 'Estado IBGE'
      FieldName = 'ESTADO_IBGE'
    end
    object memLogradourosREGIAO: TStringField
      DisplayLabel = 'Regi'#227'o'
      FieldName = 'REGIAO'
      Size = 50
    end
    object memLogradourosREGIAO_IBGE: TIntegerField
      DisplayLabel = 'Regi'#227'o IBGE'
      FieldName = 'REGIAO_IBGE'
    end
    object memLogradourosCEP: TStringField
      FieldName = 'CEP'
      Size = 10
    end
  end
  object dsLogradouros: TDataSource
    AutoEdit = False
    DataSet = memLogradouros
    Left = 531
    Top = 4
  end
end
