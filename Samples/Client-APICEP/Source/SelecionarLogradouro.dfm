object frmSelecionarLogradouro: TfrmSelecionarLogradouro
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Logradouros'
  ClientHeight = 171
  ClientWidth = 694
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TPanel
    Left = 0
    Top = 145
    Width = 694
    Height = 26
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlBottom'
    ShowCaption = False
    TabOrder = 0
    object Shape1: TShape
      AlignWithMargins = True
      Left = 2
      Top = 2
      Width = 690
      Height = 22
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alClient
      Pen.Style = psDashDotDot
      ExplicitTop = 4
      ExplicitHeight = 167
    end
    object Label1: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 686
      Height = 18
      Margins.Left = 5
      Margins.Top = 5
      Align = alClient
      Caption = 'Duplo clique para selecionar o logradouro...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 242
      ExplicitHeight = 13
    end
  end
  object dbgCEPLogradouros: TDBGrid
    Left = 0
    Top = 0
    Width = 694
    Height = 145
    Align = alTop
    DataSource = dsLogradouros
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ParentFont = False
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = [fsBold]
    OnDblClick = dbgCEPLogradourosDblClick
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
  object dsLogradouros: TDataSource
    AutoEdit = False
    DataSet = memLogradouros
    Left = 291
    Top = 68
  end
  object memLogradouros: TFDMemTable
    FieldDefs = <>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 232
    Top = 69
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
    object memLogradourosJSON: TMemoField
      FieldName = 'JSON'
      BlobType = ftMemo
    end
  end
end
