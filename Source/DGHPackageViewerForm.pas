(**

  This module contains a class which represents a form for browsing the packages loaded into the
  RAD Studio IDE in a tree format.

  @Author  David Hoyle
  @Version 1.817
  @Date    10 Oct 2020

  @license

    Package Viewer is a RAD Studio plug-in for browsing packages loaded into the IDE.
    
    Copyright (C) 2020  David Hoyle (https://github.com/DGH2112/Browse-and-Doc-It/)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
  Buttons,
  Themes;

{$INCLUDE CompilerDefinitions.inc}

Type
  (** A class to represent the package viewer form. **)
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
  Strict Private
    {$IFDEF DXE102}
    FStyleServices : TCustomStyleServices;
    {$ENDIF DXE102}
  Strict Protected
    Procedure LoadSettings;
    Procedure SaveSettings;
    Procedure IteratePackages;
    {$IFDEF DXE00}
    Procedure ProcessPackageInfo(Const Parent: TTreeNode; Const APackage: IOTAPackageInfo);
    {$ENDIF}
    Procedure ProcessComponents(Const PS: IOTAPAckageServices; Const iPackage: Integer;
      Const P: TTreeNode);
  Public
    Class Procedure Execute;
  End;

Implementation

{$R *.dfm}

Uses
  Registry,
  {$IFDEF DXE00}
  RegularExpressions,
  {$ENDIF}
  DGHPackageViewerProgressForm, DGHPackageViewerFunctions;

Const
  (** A constant to define the registry key under which the package viewer loads and saves its
      settings. **)
  strRegistryKey = 'Software\Season''s Fall\Package Viewer\';
  (** A constant for the Registry Section Name for the form settings. **)
  strSetupINISection = 'Setup';
  (** A constant for the Registry INI Key for the forms Top setting. **)
  strTopINIKey = 'Top';
  (** A constant for the Registry INI Key for the forms Left setting. **)
  strLeftINIKey = 'Left';
  (** A constant for the Registry INI Key for the forms Height setting. **)
  strHeightINIKey = 'Height';
  (** A constant for the Registry INI Key for the forms Width setting. **)
  strWidthINIKey = 'Width';

(**

  This is an on click event handler for the Find button.

  @precon  None.
  @postcon Displays the find dialogue.

  @param   Sender as a TObject

**)
Procedure TfrmDGHPackageViewer.btnFindClick(Sender: TObject);

Begin
  dlgFind.Execute(Handle);
End;

(**

  This is an on click event handler for the Load button.

  @precon  None.
  @postcon Loads and Unloads the selected package in the treeview.

  @param   Sender as a TObject

**)
Procedure TfrmDGHPackageViewer.btnLoadClick(Sender: TObject);

{$IFDEF DXE00}
  (**

    This function returns true if the selected treeview node has components.

    @precon  Node must be a valid instance or nil.
    @postcon Returns true if the selected treeview node has components.

    @param   Node as a TTreeNode as a constant
    @return  a Boolean

  **)
  Function HasComponents(Const Node : TTreeNode) : Boolean;

  ResourceString
    strComponents = 'Components';

  Var
    N : TTreeNode;

  Begin
    Result := False;
    N := Node.GetFirstChild;
    While Assigned(N) Do
      Begin
        If CompareText(N.Text, strComponents) = 0 Then
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
  If Assigned(Node) And Assigned(Node.Data) Then
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

(**

  This method is an on find event handler for the find dialogue.

  @precon  None.
  @postcon Attempts to find the text in the find dialogue in the treeview. Depending upon which version
           of RAD Studio you are using, it will either search using plain text or regular expressions
           if they are available.

  @param   Sender as a TObject

**)
Procedure TfrmDGHPackageViewer.dlgFindFind(Sender: TObject);

ResourceString
  strFindTextNotFound = 'Find text "%s" not found!';

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
    ShowMessage(Format(strFindTextNotFound, [dlgFind.FindText]));
End;

(**

  This method displays the package viewer form.

  @precon  None.
  @postcon The package viewer form is displayed.

**)
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

(**

  This is an On Form Create Event Handler for the TfrmDGHPackageViewer class.

  @precon  None.
  @postcon Sets double buffering if available and loads the forms settings.

  @param   Sender as a TObject

**)
Procedure TfrmDGHPackageViewer.FormCreate(Sender: TObject);

{$IFDEF DXE102}
Var
  ITS : IOTAIDEThemingServices;
{$ENDIF DXE102}
  
Begin
  DoubleBuffered := True;
  {$IFDEF D2009}
  tvPackages.ParentDoubleBuffered := True;
  {$ENDIF}
  LoadSettings;
  TPackageViewerFunctions.RegisterFormClassForTheming(TfrmDGHPackageViewer);
  TPackageViewerFunctions.ApplyTheming(Self);
  {$IFDEF DXE102}
  FStyleServices := Nil;
  If Supports(BorlandIDEServices, IOTAIDEThemingServices, ITS) Then
    If ITS.IDEThemingEnabled Then
      FStyleServices := ITS.StyleServices;
  {$ENDIF DXE102}
End;

(**

  This is an On Form Destroy Event Handler for the TfrmDGHPackageViewer class.

  @precon  None.
  @postcon Saves the forms settings.

  @param   Sender as a TObject

**)
Procedure TfrmDGHPackageViewer.FormDestroy(Sender: TObject);

Begin
  SaveSettings;
End;

(**

  This is an on show event handler for the form.

  @precon  None.
  @postcon Starts the process of iterating through the packages and building the treeview.

  @param   Sender as a TObject

**)
Procedure TfrmDGHPackageViewer.FormShow(Sender: TObject);

Begin
  IteratePackages; //: @note This performs better here.
End;

(**

  This method iterates through the packages in the IDE and outputting the information to the treeview.

  @precon  None.
  @postcon The treeview is populated with the package information.

**)
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

(**

  This methods loads the position and size of the form.

  @precon  None.
  @postcon The forms position and size are set from the registry.

**)
Procedure TfrmDGHPackageViewer.LoadSettings;

Const
  iDefaultTop = 100;
  iDefaultLeft = 100;

Var
  R: TRegIniFile;

Begin
  R := TRegIniFile.Create(strRegistryKey);
  Try
    Top := R.ReadInteger(strSetupINISection, strTopINIKey, iDefaultTop);
    Left := R.ReadInteger(strSetupINISection, strLeftINIKey, iDefaultLeft);
    Height := R.ReadInteger(strSetupINISection, strHeightINIKey, Height);
    Width := R.ReadInteger(strSetupINISection, strWidthINIKey, Width);
  Finally
    R.Free;
  End;
End;

(**

  This method processes and outputs the components for the given indexed package.

  @precon  PS and P must be valid instances.
  @postcon The components in the packages are output to the treeview.

  @param   PS       as an IOTAPAckageServices as a constant
  @param   iPackage as an Integer as a constant
  @param   P        as a TTreeNode as a constant

**)
Procedure TfrmDGHPackageViewer.ProcessComponents(Const PS: IOTAPAckageServices;
  Const iPackage: Integer; Const P: TTreeNode);

ResourceString
  strComponents = 'Components';

Var
  N: TTreeNode;
  iComponent: Integer;

Begin
  If PS.ComponentCount[iPackage] > 0 Then
    Begin
      N := tvPackages.Items.AddChildObject(P, strComponents, Nil);
      For iComponent := 0 To PS.ComponentCount[iPackage] - 1 Do
        tvPackages.Items.AddChildObject(N, PS.ComponentNames[iPackage, iComponent], Nil);
    End;
End;

{$IFDEF DXE00}
(**

  This method outputs the package information for the given package.

  @precon  Parent and APackage must be valid instances.
  @postcon The package information is output to the treeview under the given parent node.

  @param   Parent   as a TTreeNode as a constant
  @param   APackage as an IOTAPackageInfo as a constant

**)
Procedure TfrmDGHPackageViewer.ProcessPackageInfo(Const Parent: TTreeNode;
  Const APackage: IOTAPackageInfo);

  (**

    This procedure outputs the item in a string list as individual nodes in the treeview under a new
    parent node.

    @precon  N and sl must be valid instances.
    @postcon The string list contents are output as a branch in the treeview.

    @param   N           as a TTreeNode as a constant
    @param   sl          as a TStringList as a constant
    @param   strListName as a String as a constant

  **)
  Procedure AddStringList(Const N: TTreeNode; Const sl: TStringList; Const strListName: String);

  Var
    i: Integer;
    M: TTreeNode;

  Begin
    M := tvPackages.Items.AddChildObject(N, strListName, Nil);
    For i := 0 To sl.Count - 1 Do
      tvPackages.Items.AddChild(M, sl[i]);
  End;

ResourceString
  strProperties = 'Properties';
  strFileName = 'FileName: %s';
  strName = 'Name: %s';
  strRunTimeOnly = 'Run-Time Only: %s';
  strDesignTimeOnly = 'Design-Time Only: %s';
  strIDEPackage = 'IDE Package: %s';
  strLoaded = 'Loaded: %s';
  strDescription = 'Description: %s';
  strSymbolFileName = 'Symbol Filename: %s';
  strProducerName = 'Producer : %s';
  strConsumerName = 'Consumer : %s';
  strContains = 'Contains';
  strRequires = 'Requires';
  strImplicit = 'Implicit';
  strRequiredBy = 'Required By';

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
  N := tvPackages.Items.AddChildObject(Parent, strProperties, Nil);
  tvPackages.Items.AddChildObject(N, Format(strFileName, [APackage.FileName]), Nil);
  tvPackages.Items.AddChildObject(N, Format(strName, [APackage.Name]), Nil);
  tvPackages.Items.AddChildObject(N, Format(strRunTimeOnly, [strBoolean[APackage.RuntimeOnly]]), Nil);
  tvPackages.Items.AddChildObject(N, Format(strDesignTimeOnly, [strBoolean[APackage.DesigntimeOnly]]), Nil);
  tvPackages.Items.AddChildObject(N, Format(strIDEPackage, [strBoolean[APackage.IDEPackage]]), Nil);
  tvPackages.Items.AddChildObject(N, Format(strLoaded, [strBoolean[APackage.Loaded]]), Nil);
  tvPackages.Items.AddChildObject(N, Format(strDescription, [APackage.Description]), Nil);
  tvPackages.Items.AddChildObject(N, Format(strSymbolFileName, [APackage.SymbolFileName]), Nil);
  tvPackages.Items.AddChildObject(N, Format(strProducerName, [strProducer[APackage.Producer]]), Nil);
  tvPackages.Items.AddChildObject(N, Format(strConsumerName, [strConsumer[APackage.Consumer]]), Nil);
  sl := TStringList.Create;
  Try
    APackage.GetContainsList(sl);
    AddStringList(N, sl, strContains);
    APackage.GetRequiresList(sl);
    AddStringList(N, sl, strRequires);
    APackage.GetImplicitList(sl);
    AddStringList(N, sl, strImplicit);
    APackage.GetRequiredByList(sl);
    AddStringList(N, sl, strRequiredBy);
  Finally
    sl.Free;
  End;
End;
{$ENDIF}


(**

  This method saves the forms size and position.

  @precon  None.
  @postcon The forms size and position are saved to the registry.

**)
Procedure TfrmDGHPackageViewer.SaveSettings;

Var
  R: TRegIniFile;

Begin
  R := TRegIniFile.Create(strRegistryKey);
  Try
    R.WriteInteger(strSetupINISection, strTopINIKey, Top);
    R.WriteInteger(strSetupINISection, strLeftINIKey, Left);
    R.WriteInteger(strSetupINISection, strHeightINIKey, Height);
    R.WriteInteger(strSetupINISection, strWidthINIKey, Width);
  Finally
    R.Free;
  End;
End;

(**

  This is an owner draw method for the treeview.

  @precon  None.
  @postcon Draw unloaded packages with grey text.

  @param   Sender      as a TCustomTreeView
  @param   Node        as a TTreeNode
  @param   State       as a TCustomDrawState
  @param   Stage       as a TCustomDrawStage
  @param   PaintImages as a Boolean as a reference
  @param   DefaultDraw as a Boolean as a reference

**)
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
  If Assigned(Node.Data) Then
    Begin
      iPackage := Integer(Node.Data);
      APackage := (BorlandIDEServices As IOTAPAckageServices).Package[iPackage];
      Sender.Brush.Color := clWindow;
      If APackage.Loaded Then
        Sender.Canvas.Font.Color := clWindowText
      Else
        Sender.Canvas.Font.Color := clGrayText;
      {$IFDEF DXE102}
      If Assigned(FStyleServices) Then
        Begin
          Sender.Canvas.Brush.Color := FStyleServices.GetSystemColor(Sender.Canvas.Brush.Color);
          Sender.Canvas.Font.Color := FStyleServices.GetSystemColor(Sender.Canvas.Font.Color);
        End;
      {$ENDIF DXE102}
    End;
  {$ENDIF}
End;

(**

  This is an on change event handler for the Package treeview control.

  @precon  None.
  @postcon Updates the availability of the Load/Unload button and its caption.

  @param   Sender as a TObject
  @param   Node   as a TTreeNode

**)
Procedure TfrmDGHPackageViewer.tvPackagesChange(Sender: TObject; Node: TTreeNode);

{$IFDEF DXE00}
ResourceString
  strUnload = '&Unload';
  strLoad = '&Load';

Var
  APackage: IOTAPackageInfo;
  iPackage: Integer;
{$ENDIF}

Begin
  btnLoad.Enabled := Assigned(Node.Data);
  {$IFDEF DXE00}
  If Node.Data <> Nil Then
    Begin
      iPackage := Integer(Node.Data);
      APackage := (BorlandIDEServices As IOTAPAckageServices).Package[iPackage];
      If APackage.Loaded Then
        btnLoad.Caption := strUnload
      Else
        btnLoad.Caption := strLoad;
    End;
  {$ENDIF}
End;

End.
