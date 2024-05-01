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
  object dbgBuscaCEP: TDBGrid
    Left = 0
    Top = 0
    Width = 694
    Height = 145
    Align = alTop
    DataSource = dsBuscaCEPLogradouros
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ParentFont = False
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = [fsBold]
    OnDblClick = dbgBuscaCEPDblClick
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
        FieldName = 'CEP'
        Width = 70
        Visible = True
      end>
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 145
    Width = 694
    Height = 26
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlBottom'
    ShowCaption = False
    TabOrder = 1
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
      ExplicitLeft = 0
      ExplicitTop = 6
      ExplicitWidth = 684
      ExplicitHeight = 26
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
  object cdsBuscaCEPLogradouros: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 227
    Top = 68
    object cdsBuscaCEPLogradourosLOGRADOURO: TStringField
      DisplayLabel = 'Logradouro'
      FieldName = 'LOGRADOURO'
      Size = 200
    end
    object cdsBuscaCEPLogradourosCOMPLEMENTO: TStringField
      DisplayLabel = 'Complemento'
      FieldName = 'COMPLEMENTO'
      Size = 150
    end
    object cdsBuscaCEPLogradourosBAIRRO: TStringField
      DisplayLabel = 'Bairro'
      FieldName = 'BAIRRO'
      Size = 100
    end
    object cdsBuscaCEPLogradourosLOCALIDADE: TStringField
      DisplayLabel = 'Localidade'
      FieldName = 'LOCALIDADE'
      Size = 100
    end
    object cdsBuscaCEPLogradourosLOCALIDADE_IBGE: TIntegerField
      DisplayLabel = 'Localidade IBGE'
      FieldName = 'LOCALIDADE_IBGE'
    end
    object cdsBuscaCEPLogradourosESTADO: TStringField
      DisplayLabel = 'Estado'
      FieldName = 'ESTADO'
      Size = 100
    end
    object cdsBuscaCEPLogradourosESTADO_IBGE: TIntegerField
      DisplayLabel = 'Estado IBGE'
      FieldName = 'ESTADO_IBGE'
    end
    object cdsBuscaCEPLogradourosCEP: TIntegerField
      FieldName = 'CEP'
    end
    object cdsBuscaCEPLogradourosJSON: TMemoField
      FieldName = 'JSON'
      BlobType = ftMemo
    end
  end
  object dsBuscaCEPLogradouros: TDataSource
    AutoEdit = False
    DataSet = cdsBuscaCEPLogradouros
    Left = 291
    Top = 68
  end
end
