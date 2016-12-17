object frmDGHPackageViewer: TfrmDGHPackageViewer
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Package Viewer'
  ClientHeight = 373
  ClientWidth = 515
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    515
    373)
  PixelsPerInch = 96
  TextHeight = 16
  object tvPackages: TTreeView
    Left = 8
    Top = 8
    Width = 499
    Height = 326
    Anchors = [akLeft, akTop, akRight, akBottom]
    HideSelection = False
    Indent = 19
    ParentShowHint = False
    ReadOnly = True
    RowSelect = True
    ShowHint = True
    SortType = stText
    TabOrder = 0
    OnAdvancedCustomDrawItem = tvPackagesAdvancedCustomDrawItem
    OnChange = tvPackagesChange
  end
  object btnLoad: TBitBtn
    Left = 8
    Top = 340
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&Load'
    Enabled = False
    TabOrder = 1
    OnClick = btnLoadClick
  end
end
