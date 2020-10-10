(**

  This module contains a class that implements the IOTAWizard and IOTAmenuWizard interfaces to
  create a wizard / expert / plug-in that can be loaded by the RAD Studio IDE to provide the
  ability to browse the packages loaded in the IDE.

  @Author  David Hoyle
  @Version 2.058
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
    FAboutPluginIndex : Integer;
  {$IFDEF D2010} Strict {$ENDIF D2010} Protected
    // IOTAWizard
    Procedure Execute;
    Function  GetIDString: String;
    Function  GetName: String;
    Function  GetState: TWizardState;
    // IOTAMenuWizard
    Function  GetMenuText: String;
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
  Forms,
  DGHPackageViewerSplashScreen,
  DGHPackageViewerFunctions,
  DGHPackageViewerResourceStrings,
  DGHPackageViewerConstants,
  DGHPackageViewerAboutBox;

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

  A constructor for the TDGHPackageViewerWizard class.

  @precon  None.
  @postcon Installs the splash screen entry and the about box entry into the IDE.

**)
Constructor TDGHPackageViewerWizard.Create;

Begin
<<<<<<< HEAD
  {$IFDEF D2005}
  FAboutPluginIndex := -1;
  BuildNumber(FVersionInfo);
  FSplashScreen48 := LoadBitmap(hInstance, 'SplashScreen48');
  With FVersionInfo Do
    FAboutPluginIndex := (BorlandIDEServices As IOTAAboutBoxServices).AddPluginInfo(
      Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1),
        Application.Title]),
     'An IDE Expert to allow you to browse the loaded packages in the IDE.',
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
=======
  FAboutPluginIndex := AddAboutBox();
  AddSplashScreen();
>>>>>>> Release/1.0d
End;

(**

  A destructor for the TDGHPackageViewerWizard class.

  @precon  None.
  @postcon Removes the About Box from the IDE.

**)
Destructor TDGHPackageViewerWizard.Destroy;

Begin
  RemoveAboutBox(FAboutPluginIndex);
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
