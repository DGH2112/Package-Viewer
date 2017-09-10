object frmDGHPackageViewer: TfrmDGHPackageViewer
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Package Viewer'
  ClientHeight = 373
  ClientWidth = 502
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
    502
    373)
  PixelsPerInch = 96
  TextHeight = 16
  object tvPackages: TTreeView
    Left = 8
    Top = 8
    Width = 486
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
  object btnFind: TBitBtn
    Left = 419
    Top = 340
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Find'
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
      7777777777777777777700000777770000070F000777770F00070F000777770F
      0007000000070000000700F000000F00000700F000700F00000700F000700F00
      00077000000000000077770F00070F0007777700000700000777777000777000
      77777770F07770F0777777700077700077777777777777777777}
    TabOrder = 2
    OnClick = btnFindClick
  end
  object dlgFind: TFindDialog
    Options = [frFindNext, frHideMatchCase, frHideWholeWord, frHideUpDown]
    OnFind = dlgFindFind
    Left = 64
    Top = 48
  end
end
