(**
  
  This module defines a DLL to be loaded into the RAD Studio IDE as a plug-in. This plug-in allow the
  user to view all the packages loaded into the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.029
  @Date    09 Oct 2020

  @nocheck EmptyBeginEnd
  
**)
Library DGHPackageViewer;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

{$R 'ITHelperVersionInfo.res' 'ITHelperVersionInfo.RC'}

uses
  System.SysUtils,
  System.Classes,
  DGHPackageViewerForm in 'Source\DGHPackageViewerForm.pas' {frmDGHPackageViewer},
  DGHPackageViewerProgressForm in 'Source\DGHPackageViewerProgressForm.pas' {frmDGHPackageViewerProgress},
  DGHPackageViewerWizard in 'Source\DGHPackageViewerWizard.pas',
  DGHPackageViewerSplashScreen in 'Source\DGHPackageViewerSplashScreen.pas',
  DGHPackageViewerFunctions in 'Source\DGHPackageViewerFunctions.pas',
  DGHPackageViewerResourceStrings in 'Source\DGHPackageViewerResourceStrings.pas',
  DGHPackageViewerConstants in 'Source\DGHPackageViewerConstants.pas',
  DGHPackageViewerAboutBox in 'Source\DGHPackageViewerAboutBox.pas';

{$R *.res}

{$INCLUDE 'Source\CompilerDefinitions.inc'}
{$INCLUDE 'Source\LibrarySuffixes.inc'}

Begin

End.
