//: @stopdocumentation
Unit DGHPackageViewerWizard;

Interface

{$INCLUDE ..\..\..\Library\CompilerDefinitions.inc}

{$R ..\Images\SplashScreenImages.RES ..\Images\SplashScreenImages.RC}

{$R ..\Packages\ITHelperVersionInfo.RES}

Uses
  ToolsAPI,
  Windows;

Type
  TVersionInfo = Record
    iMajor : Integer;
    iMinor : Integer;
    iBugfix : Integer;
    iBuild : Integer;
  End;

  TDGHPackageViewerWizard = Class(TInterfacedObject, IOTANotifier, IOTAWizard,
    IOTAMenuWizard)
  Strict Private
    {$IFDEF D2005}
    FVersionInfo      : TVersionInfo;
    FSplashScreen48   : HBITMAP;
    FSplashScreen24   : HBITMAP;
    FAboutPluginIndex : Integer;
    {$ENDIF}
  Strict Protected
  Public
    Constructor Create;
    Destructor Destroy; Override;
    Procedure Execute;
    Function  GetIDString: String;
    Function  GetName: String;
    Function  GetState: TWizardState;
    Procedure AfterSave;
    Procedure BeforeSave;
    Procedure Destroyed;
    Procedure Modified;
    Function  GetMenuText: String;
  End;

Procedure Register;

Implementation

Uses
  DGHPackageViewerForm,
  SysUtils,
  Forms;

{$IFDEF D2005}
Const
  strRevision : String = ' abcdefghijklmnopqrstuvwxyz';

ResourceString
  strSplashScreenName = 'DGH Package Viewer %d.%d%s for %s';
  strSplashScreenBuild = 'Freeware by David Hoyle (Build %d.%d.%d.%d)';
{$ENDIF}

Procedure Register;

Begin
  RegisterPackageWizard(TDGHPackageViewerWizard.Create);
End;

{$IFDEF D2005}
Procedure BuildNumber(Var VersionInfo: TVersionInfo);

Var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
  strBuffer: Array [0 .. MAX_PATH] Of Char;

Begin
  GetModuleFileName(hInstance, strBuffer, MAX_PATH);
  VerInfoSize := GetFileVersionInfoSize(strBuffer, Dummy);
  If VerInfoSize <> 0 Then
    Begin
      GetMem(VerInfo, VerInfoSize);
      Try
        GetFileVersionInfo(strBuffer, 0, VerInfoSize, VerInfo);
        VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
        VersionInfo.iMajor  := VerValue^.dwFileVersionMS Shr 16;
        VersionInfo.iMinor  := VerValue^.dwFileVersionMS And $FFFF;
        VersionInfo.iBugfix := VerValue^.dwFileVersionLS Shr 16;
        VersionInfo.iBuild  := VerValue^.dwFileVersionLS And $FFFF;
      Finally
        FreeMem(VerInfo, VerInfoSize);
      End;
  End;
End;
{$ENDIF}

{ TDGHPackageViewerWizard }

Procedure TDGHPackageViewerWizard.AfterSave;

Begin
End;

Procedure TDGHPackageViewerWizard.BeforeSave;

Begin
End;

Constructor TDGHPackageViewerWizard.Create;

Begin
  {$IFDEF D2005}
  FAboutPluginIndex := -1;
  BuildNumber(FVersionInfo);
  FSplashScreen48 := LoadBitmap(hInstance, 'SplashScreen48');
  With FVersionInfo Do
    FAboutPluginIndex := (BorlandIDEServices As IOTAAboutBoxServices).AddPluginInfo(
      Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1),
        Application.Title]),
     'An IDE Expert to allow you to browse the loaled packages in the IDE.',
     FSplashScreen48,
     False,
     Format(strSplashScreenBuild, [iMajor, iMinor, iBugfix, iBuild]),
     Format('SKU Build %d.%d.%d.%d', [iMajor, iMinor, iBugfix, iBuild]));
  FSplashScreen24 := LoadBitmap(hInstance, 'SplashScreen24');
  With FVersionInfo Do
    (SplashScreenServices As IOTASplashScreenServices).AddPluginBitmap(
      Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1),
        Application.Title]),
      {$IFDEF D2007}
      FSplashScreen24, // 2007 and above
      {$ELSE}
      FSplashScreen48, // 2006 ONLY
      {$ENDIF}
      False,
      Format(strSplashScreenBuild, [iMajor, iMinor, iBugfix, iBuild]));
  {$ENDIF}
End;

Destructor TDGHPackageViewerWizard.Destroy;

Begin
  {$IFDEF D2005}
  If FAboutPluginIndex > -1 Then
    (BorlandIDEServices As IOTAAboutBoxServices).RemovePluginInfo(FAboutPluginIndex);
  {$ENDIF}
  Inherited Destroy;
End;

Procedure TDGHPackageViewerWizard.Destroyed;

Begin
End;

Procedure TDGHPackageViewerWizard.Execute;

Begin
  TfrmDGHPackageViewer.Execute;
End;

Function TDGHPackageViewerWizard.GetIDString: String;

Begin
  Result := 'DGHPackageViewerWizard.David Hoyle';
End;

Function TDGHPackageViewerWizard.GetMenuText: String;

Begin
  Result := 'Package Viewer';
End;

Function TDGHPackageViewerWizard.GetName: String;

Begin
  Result := 'DGHPackageViewer';
End;

Function TDGHPackageViewerWizard.GetState: TWizardState;

Begin
  Result := [wsEnabled];
End;

Procedure TDGHPackageViewerWizard.Modified;

Begin
End;

End.
