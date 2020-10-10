(**
  
  This module contains the code to add a splash screen entry to the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.038
  @Date    10 Oct 2020
  
**)
Unit DGHPackageViewerSplashScreen;

Interface

{$INCLUDE CompilerDefinitions.inc}

  Procedure AddSplashScreen();

Implementation

Uses
  ToolsAPI,
  SysUtils,
  Forms,
  Windows,
  DGHPackageViewerFunctions,
  DGHPackageViewerResourceStrings,
  DGHPackageViewerConstants;

(**

  This method adds a splash screen entry to the RAD Studio IDE.

  @precon  None.
  @postcon The entry appears on the RAD Studio IDE splash screen.

**)
Procedure AddSplashScreen();

Const
  {$IFDEF D2007}
  strDGHPackageViewerSplashScreenBitMap = 'SplashScreen24';
  {$ELSE}
  strDGHPackageViewerSplashScreenBitMap = 'SplashScreen48';
  {$ENDIF}

Var
  VersionInfo : TVersionInfo;
  bmSplashScreen: HBITMAP;
  SSS : IOTASplashScreenServices;
  
Begin
  BuildNumber(VersionInfo);
  bmSplashScreen := LoadBitmap(hInstance, strDGHPackageViewerSplashScreenBitMap);
  If Supports(SplashScreenServices, IOTASplashScreenServices, SSS) Then
    SSS.AddPluginBitmap(
      Format(strSplashScreenName, [
        VersionInfo.iMajor,
        VersionInfo.iMinor,
        Copy(strRevision, VersionInfo.iBugFix + 1, 1),
        Application.Title
      ]),
      bmSplashScreen,
      {$IFDEF DEBUG}
      True
      {$ELSE}
      False
      {$ENDIF DEBUG},
      Format(strSplashScreenBuild, [
        VersionInfo.iMajor,
        VersionInfo.iMinor,
        VersionInfo.iBugfix,
        VersionInfo.iBuild
      ])
    );
End;

End.
