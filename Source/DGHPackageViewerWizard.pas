(**

  This module contains a class that implements the IOTAWizard and IOTAmenuWizard interfaces to
  create a wizard / expert / plug-in that can be loaded by the RAD Studio IDE to provide the
  ability to browse the packages loaded in the IDE.

  @Author  David Hoyle
  @Version 1.523
  @Date    09 Oct 2020

**)
Unit DGHPackageViewerWizard;

Interface

{$INCLUDE CompilerDefinitions.inc}
{$R ..\Images\SplashScreenImages.RES ..\Images\SplashScreenImages.RC}

Uses
  ToolsAPI,
  Windows;

Type
  (** A class to define a plug-in wizard for the RAD Studio IDE to allow the user view the packages
      loaded into the IDE. **)
  TDGHPackageViewerWizard = Class(TNotifierObject, IUnknown, IOTANotifier, IOTAWizard, IOTAMenuWizard)
  Strict Private
    Type
      (** A record to describe the version information for the plug-in. **)
      TVersionInfo = Record
        iMajor : Integer;
        iMinor : Integer;
        iBugfix : Integer;
        iBuild : Integer;
      End;
    Const
      (** A constant to describe the bug fix letters for the version information. **)
      strRevision : String = ' abcdefghijklmnopqrstuvwxyz';
  Strict Private
    FVersionInfo      : TVersionInfo;
    FSplashScreen48   : HBITMAP;
    FSplashScreen24   : HBITMAP;
    FAboutPluginIndex : Integer;
  Strict Protected
    // IOTAWizard
    Procedure Execute;
    Function  GetIDString: String;
    Function  GetName: String;
    Function  GetState: TWizardState;
    // IOTAMenuWizard
    Function  GetMenuText: String;
    // General Method
    Procedure BuildNumber(Var VersionInfo: TVersionInfo);
  Public
    Constructor Create;
    Destructor Destroy; Override;
  End;

  Procedure Register;

  Function InitWizard(Const BorlandIDEServices : IBorlandIDEServices;
    RegisterProc : TWizardRegisterProc;
    var Terminate: TWizardTerminateProc) : Boolean; StdCall;

Exports
  InitWizard Name WizardEntryPoint;

Implementation

Uses
  DGHPackageViewerForm,
  SysUtils,
  Forms;

ResourceString
  (** A resource string for the name of the plug-in in the splash screen and about box. **)
  strSplashScreenName = 'DGH Package Viewer %d.%d%s for %s';
  (** A resource string for the description and build information on the splash screen and about box. **)
  strSplashScreenBuild = 'Freeware by David Hoyle (Build %d.%d.%d.%d)';

(**

  This is a procedure to initialising the wizard interface when loading the
  package as a DLL wizard.

  @precon  None.
  @postcon Initialises the wizard.

  @nocheck MissingCONSTInParam
  @nohint  Terminate

  @param   BorlandIDEServices as an IBorlandIDEServices as a constant
  @param   RegisterProc       as a TWizardRegisterProc
  @param   Terminate          as a TWizardTerminateProc as a reference
  @return  a Boolean

**)
Function InitWizard(Const BorlandIDEServices : IBorlandIDEServices;
  RegisterProc : TWizardRegisterProc;
  var Terminate: TWizardTerminateProc) : Boolean; StdCall;

Begin
  Result := Assigned(BorlandIDEServices);
  If Result Then
    RegisterProc(TDGHPackageViewerWizard.Create);
End;

(**

  This method registers the plug-in with the RAD Studio IDE if the plug-in is built as a package.

  @precon  None.
  @postcon The plug-in is registered with the RAD Studio IDE.

**)
Procedure Register;

Begin
  RegisterPackageWizard(TDGHPackageViewerWizard.Create);
End;

(**

  This method extracts the build information from the plug-ins DLL or BPL and returns the information
  in the var parameter.

  @precon  None.
  @postcon The version information for the plug-in is returned in the var parameter.

  @param   VersionInfo as a TVersionInfo as a reference

**)
Procedure TDGHPackageViewerWizard.BuildNumber(Var VersionInfo: TVersionInfo);

Const
  iWORDMask = $FFFF;
  iShift16 = 16;

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
        VersionInfo.iMajor  := VerValue^.dwFileVersionMS Shr iShift16;
        VersionInfo.iMinor  := VerValue^.dwFileVersionMS And iWORDMask;
        VersionInfo.iBugfix := VerValue^.dwFileVersionLS Shr iShift16;
        VersionInfo.iBuild  := VerValue^.dwFileVersionLS And iWORDMask;
      Finally
        FreeMem(VerInfo, VerInfoSize);
      End;
  End;
End;

(**

  A constructor for the TDGHPackageViewerWizard class.

  @precon  None.
  @postcon Installs the splash screen entry and the about box entry into the IDE.

**)
Constructor TDGHPackageViewerWizard.Create;

ResourceString
  strPluginDescription = 'An IDE Expert to allow you to browse the loaded packages in the IDE.';
  strSKUBuild = 'SKU Build %d.%d.%d.%d';

Const
  strSplashScreen48ImgResName = 'SplashScreen48';
  strSplashScreen24ImgResName = 'SplashScreen24';

Begin
  FAboutPluginIndex := -1;
  BuildNumber(FVersionInfo);
  FSplashScreen48 := LoadBitmap(hInstance, strSplashScreen48ImgResName);
  FAboutPluginIndex := (BorlandIDEServices As IOTAAboutBoxServices).AddPluginInfo(
    Format(strSplashScreenName, [
      FVersionInfo.iMajor,
      FVersionInfo.iMinor,
      Copy(strRevision, FVersionInfo.iBugFix + 1, 1),
      Application.Title
    ]),
    strPluginDescription,
    FSplashScreen48,
    False,
    Format(strSplashScreenBuild, [
      FVersionInfo.iMajor,
      FVersionInfo.iMinor,
      FVersionInfo.iBugfix,
      FVersionInfo.iBuild
    ]),
    Format(strSKUBuild, [
      FVersionInfo.iMajor,
      FVersionInfo.iMinor,
      FVersionInfo.iBugfix,
      FVersionInfo.iBuild
    ])
  );
  FSplashScreen24 := LoadBitmap(hInstance, strSplashScreen24ImgResName);
  (SplashScreenServices As IOTASplashScreenServices).AddPluginBitmap(
    Format(strSplashScreenName, [
      FVersionInfo.iMajor,
      FVersionInfo.iMinor,
      Copy(strRevision, FVersionInfo.iBugFix + 1, 1),
      Application.Title
    ]),
    {$IFDEF D2007}
    FSplashScreen24, // 2007 and above
    {$ELSE}
    FSplashScreen48, // 2006 ONLY
    {$ENDIF}
    False,
    Format(strSplashScreenBuild, [
      FVersionInfo.iMajor,
      FVersionInfo.iMinor,
      FVersionInfo.iBugfix,
      FVersionInfo.iBuild
    ])
  );
End;

(**

  A destructor for the TDGHPackageViewerWizard class.

  @precon  None.
  @postcon Removes the About Box from the IDE.

**)
Destructor TDGHPackageViewerWizard.Destroy;

Begin
  If FAboutPluginIndex > -1 Then
    (BorlandIDEServices As IOTAAboutBoxServices).RemovePluginInfo(FAboutPluginIndex);
  Inherited Destroy;
End;

(**

  This method invokes the packages viewer.

  @precon  None.
  @postcon The package viewer is displayed.

**)
Procedure TDGHPackageViewerWizard.Execute;

Begin
  TfrmDGHPackageViewer.Execute;
End;

(**

  This is a getter method for the IDString property.

  @precon  None.
  @postcon Returns the unique ID String for the plug-in.

  @return  a String

**)
Function TDGHPackageViewerWizard.GetIDString: String;

Const
  strPluginIDString = 'DGHPackageViewerWizard.David Hoyle';

Begin
  Result := strPluginIDString;
End;

(**

  This is a getter method for the Menu Text property.

  @precon  None.
  @postcon Returns the text of the menu to invoke the Package Viewer under the Help Wizard menu.

  @return  a String

**)
Function TDGHPackageViewerWizard.GetMenuText: String;

ResourceString
  strPackageViewerMenuText = 'Package Viewer';

Begin
  Result := strPackageViewerMenuText;
End;

(**

  This is a getter method for the Name property.

  @precon  None.
  @postcon Returns the name of the wizard.

  @return  a String

**)
Function TDGHPackageViewerWizard.GetName: String;

Const
  strPluginName = 'DGHPackageViewer';

Begin
  Result := strPluginName;
End;

(**

  This is a getter method for the State property.

  @precon  None.
  @postcon Returns that the wizard is enabled.

  @return  a TWizardState

**)
Function TDGHPackageViewerWizard.GetState: TWizardState;

Begin
  Result := [wsEnabled];
End;

End.
