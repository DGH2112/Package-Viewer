(**

  This module contains a class which repesents a form for browsing the packages loaded into the
  RAD Studio IDE in a tree format.

  @Author  David Hoyle
  @Version 1.0
  @Date    17 Dec 2016

  @stopdocumentation

**)
Unit DGHPackageViewerForm;

Interface

Uses
  ToolsAPI,
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ComCtrls,
  StdCtrls,
  Buttons;

{$INCLUDE CompilerDefinitions.inc}


Type
  TfrmDGHPackageViewer = Class(TForm)
    tvPackages: TTreeView;
    btnLoad: TBitBtn;
    btnFind: TBitBtn;
    dlgFind: TFindDialog;
    Procedure FormCreate(Sender: TObject);
    Procedure FormDestroy(Sender: TObject);
    Procedure FormShow(Sender: TObject);
    Procedure btnLoadClick(Sender: TObject);
    Procedure tvPackagesChange(Sender: TObject; Node: TTreeNode);
    Procedure tvPackagesAdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; Stage: TCustomDrawStage; Var PaintImages,
      DefaultDraw: Boolean);
    procedure btnFindClick(Sender: TObject);
    procedure dlgFindFind(Sender: TObject);
  Private
    {Private declarations}
    Procedure LoadSettings;
    Procedure SaveSettings;
    Procedure IteratePackages;
    {$IFDEF DXE00}
    Procedure ProcessPackageInfo(Parent: TTreeNode; APackage: IOTAPackageInfo);
    {$ENDIF}
    Procedure ProcessComponents(PS: IOTAPAckageServices; iPackage: Integer; P: TTreeNode);
  Public
    {Public declarations}
    Class Procedure Execute;
  End;

Implementation

{$R *.dfm}

Uses
  Registry,
  {$IFDEF DXE00}
  RegularExpressions,
  {$ENDIF}
  DGHPackageViewerProgressForm;

Const
  strRegistryKey = 'Software\Season''s Fall\Package Viewer\';

{TfrmDGHPackageViewer}

Procedure TfrmDGHPackageViewer.btnFindClick(Sender: TObject);

Begin
  dlgFind.Execute(Handle);
End;

Procedure TfrmDGHPackageViewer.btnLoadClick(Sender: TObject);

{$IFDEF DXE00}
  Function HasComponents(Node : TTreeNode) : Boolean;

  Var
    N : TTreeNode;

  Begin
    Result := False;
    N := Node.GetFirstChild;
    While N <> Nil Do
      Begin
        If CompareText(N.Text, 'Components') = 0 Then
          Begin
            Result := True;
            Break;
          End;
        N := Node.GetNextChild(N);
      End;
  End;

Var
  Node: TTreeNode;
  iPackage: Integer;
  APackage: IOTAPackageInfo;
{$ENDIF}

Begin
  {$IFDEF DXE00}
  Node := tvPackages.Selected;
  If (Node <> Nil) And (Node.Data <> Nil) Then
    Begin
      iPackage := Integer(Node.Data);
      APackage := (BorlandIDEServices As IOTAPAckageServices).Package[iPackage];
      APackage.Loaded := Not APackage.Loaded;
      If Not HasComponents(Node) Then
        Begin
          Node.Expand(False);
          ProcessComponents((BorlandIDEServices As IOTAPAckageServices), iPackage, Node);
        End;
      tvPackagesChange(tvPackages, Node);
      tvPackages.Invalidate;
    End;
  {$ENDIF}
End;

Procedure TfrmDGHPackageViewer.dlgFindFind(Sender: TObject);

Var
  N: TTreeNode;
  {$IFDEF DXE00}
  RE : TRegEx;
  {$ENDIF}

Begin
  {$IFDEF DXE00}
  RE.Create(dlgFind.FindText);
  {$ENDIF}
  N := tvPackages.Selected;
  If N = Nil Then
    N := tvPackages.Items.GetFirstNode;
  N := N.GetNext;
  While N <> Nil Do
    Begin
      {$IFDEF DXE00}
      If RE.IsMatch(N.Text) Then
      {$ELSE}
      If Pos(LowerCase(dlgFind.FindText), LowerCase(N.Text)) > 0 Then
      {$ENDIF}
        Begin
          tvPackages.Selected := N;
          N.Focused := True;
          Break;
        End;
      N := N.GetNext;
    End;
  If N = Nil Then
    ShowMessage(Format('Find text "%s" not found!', [dlgFind.FindText]));
End;

Class Procedure TfrmDGHPackageViewer.Execute;

Var
  frm: TfrmDGHPackageViewer;

Begin
  frm := TfrmDGHPackageViewer.Create(Application.MainForm);
  Try
    frm.ShowModal;
  Finally
    frm.Free;
  End;
End;

Procedure TfrmDGHPackageViewer.ProcessComponents(PS: IOTAPAckageServices;
  iPackage: Integer; P: TTreeNode);

Var
  N: TTreeNode;
  iComponent: Integer;

Begin
  If PS.ComponentCount[iPackage] > 0 Then
    Begin
      N := tvPackages.Items.AddChildObject(P, 'Components', Nil);
      For iComponent := 0 To PS.ComponentCount[iPackage] - 1 Do
        tvPackages.Items.AddChildObject(N, PS.ComponentNames[iPackage, iComponent], Nil);
    End;
End;

Procedure TfrmDGHPackageViewer.FormCreate(Sender: TObject);

Begin
  {$IFDEF D2006}
  DoubleBuffered := True;
  {$IFDEF D2009}
  tvPackages.ParentDoubleBuffered := True;
  {$ENDIF}
  {$ENDIF}
  LoadSettings;
End;

Procedure TfrmDGHPackageViewer.FormDestroy(Sender: TObject);

Begin
  SaveSettings;
End;

Procedure TfrmDGHPackageViewer.FormShow(Sender: TObject);

Begin
  IteratePackages; //This performs better here.
End;

Procedure TfrmDGHPackageViewer.IteratePackages;

Var
  PS: IOTAPAckageServices;
  iPackage: Integer;
  P: TTreeNode;
  frm: TfrmDGHPackageViewerProgress;

Begin
  tvPackages.Items.BeginUpdate;
  Try
    PS := (BorlandIDEServices As IOTAPAckageServices);
    frm := TfrmDGHPackageViewerProgress.Create(Application.MainForm);
    Try
      frm.ShowProgress(PS.PackageCount);
      For iPackage := 0 To PS.PackageCount - 1 Do
        Begin
          P := tvPackages.Items.AddChildObject(Nil, PS.PackageNames[iPackage],
            TObject(iPackage));
          ProcessComponents(PS, iPackage, P);
          {$IFDEF DXE00}
          ProcessPackageInfo(P, PS.Package[iPackage]);
          {$ENDIF}
          frm.UpdateProgress(Succ(iPackage));
        End;
      frm.HideProgress;
    Finally
      frm.Free;
    End;
    tvPackages.AlphaSort(True);
  Finally
    tvPackages.Items.EndUpdate;
  End;
End;

Procedure TfrmDGHPackageViewer.LoadSettings;

Var
  R: TRegIniFile;

Begin
  R := TRegIniFile.Create(strRegistryKey);
  Try
    Top := R.ReadInteger('Setup', 'Top', 100);
    Left := R.ReadInteger('Setup', 'Left', 100);
    Height := R.ReadInteger('Setup', 'Height', Height);
    Width := R.ReadInteger('Setup', 'Width', Width);
  Finally
    R.Free;
  End;
End;

{$IFDEF DXE00}
Procedure TfrmDGHPackageViewer.ProcessPackageInfo(Parent: TTreeNode;
  APackage: IOTAPackageInfo);

  Procedure AddStringList(N: TTreeNode; sl: TStringList; strListName: String);

  Var
    i: Integer;
    M: TTreeNode;

  Begin
    M := tvPackages.Items.AddChildObject(N, strListName, Nil);
    For i := 0 To sl.Count - 1 Do
      tvPackages.Items.AddChild(M, sl[i]);
  End;

Const
  strBoolean: Array [False .. True] Of String = ('False', 'True');
  strProducer: Array [Low(TOTAPackageProducer) .. High(TOTAPackageProducer)] Of String = (
    'ppOTAUnknown', 'ppOTADelphi', 'ppOTABCB');
  strConsumer: Array [Low(TOTAPackageConsumer) .. High(TOTAPackageConsumer)] Of String = (
    'pcOTAUnknown', 'pcOTADelphi', 'pcOTABCB', 'pcOTABoth');

Var
  sl: TStringList;
  N: TTreeNode;

Begin
  N := tvPackages.Items.AddChildObject(Parent, 'Properties', Nil);
  tvPackages.Items.AddChildObject(N, Format('FileName: %s', [APackage.FileName]), Nil);
  tvPackages.Items.AddChildObject(N, Format('Name: %s', [APackage.Name]), Nil);
  tvPackages.Items.AddChildObject(N, Format('Run-Time Only: %s',
    [strBoolean[APackage.RuntimeOnly]]), Nil);
  tvPackages.Items.AddChildObject(N, Format('Design-Time Only: %s',
    [strBoolean[APackage.DesigntimeOnly]]), Nil);
  tvPackages.Items.AddChildObject(N, Format('IDE Package: %s',
    [strBoolean[APackage.IDEPackage]]), Nil);
  tvPackages.Items.AddChildObject(N, Format('Loaded: %s',
    [strBoolean[APackage.Loaded]]), Nil);
  tvPackages.Items.AddChildObject(N, Format('Description: %s',
    [APackage.Description]), Nil);
  tvPackages.Items.AddChildObject(N, Format('SymbolFileName: %s',
    [APackage.SymbolFileName]), Nil);
  tvPackages.Items.AddChildObject(N, Format('Producer : %s',
    [strProducer[APackage.Producer]]), Nil);
  tvPackages.Items.AddChildObject(N, Format('Consumer : %s',
    [strConsumer[APackage.Consumer]]), Nil);
  sl := TStringList.Create;
  Try
    APackage.GetContainsList(sl);
    AddStringList(N, sl, 'Contains');
    APackage.GetRequiresList(sl);
    AddStringList(N, sl, 'Requires');
    APackage.GetImplicitList(sl);
    AddStringList(N, sl, 'Implicit');
    APackage.GetRequiredByList(sl);
    AddStringList(N, sl, 'Required By');
  Finally
    sl.Free;
  End;
End;
{$ENDIF}


Procedure TfrmDGHPackageViewer.SaveSettings;

Var
  R: TRegIniFile;

Begin
  R := TRegIniFile.Create(strRegistryKey);
  Try
    R.WriteInteger('Setup', 'Top', Top);
    R.WriteInteger('Setup', 'Left', Left);
    R.WriteInteger('Setup', 'Height', Height);
    R.WriteInteger('Setup', 'Width', Width);
  Finally
    R.Free;
  End;
End;

Procedure TfrmDGHPackageViewer.tvPackagesAdvancedCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage; Var PaintImages,
  DefaultDraw: Boolean);

{$IFDEF DXE00}
Var
  APackage: IOTAPackageInfo;
  iPackage: Integer;
{$ENDIF}

Begin
  DefaultDraw := True;
  {$IFDEF DXE00}
  If Node.Data <> Nil Then
    Begin
      iPackage := Integer(Node.Data);
      APackage := (BorlandIDEServices As IOTAPAckageServices).Package[iPackage];
      If APackage.Loaded Then
        Sender.Canvas.font.Color := clWindowText
      Else
        Sender.Canvas.font.Color := clGrayText;
    End;
  {$ENDIF}
End;

Procedure TfrmDGHPackageViewer.tvPackagesChange(Sender: TObject; Node: TTreeNode);

{$IFDEF DXE00}
Var
  APackage: IOTAPackageInfo;
  iPackage: Integer;
{$ENDIF}

Begin
  btnLoad.Enabled := Node.Data <> Nil;
  {$IFDEF DXE00}
  If Node.Data <> Nil Then
    Begin
      iPackage := Integer(Node.Data);
      APackage := (BorlandIDEServices As IOTAPAckageServices).Package[iPackage];
      If APackage.Loaded Then
        btnLoad.Caption := '&Unload'
      Else
        btnLoad.Caption := '&Load';
    End;
  {$ENDIF}
End;

End.
