(**
  
  This module contains resources strings for use throughout the application.

  @Author  David Hoyle
  @Version 1.115
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
Unit DGHPackageViewerResourceStrings;

Interface

ResourceString
  (** A resource string for the name of the plug-in in the splash screen and about box. **)
  strSplashScreenName = 'DGH Package Viewer %d.%d%s for %s';
  (** A resource string for the description and build information on the splash screen and about box. **)
  strSplashScreenBuild = 'Freeware by David Hoyle (Build %d.%d.%d.%d)';
  (** A resource string to describe the purpose of the plug-in. **)
  strPluginDescription = 'An IDE Expert to allow you to browse the loaded packages in the IDE.';
  (** A resource string for the build reference. **)
  strSKUBuild = 'SKU Build %d.%d.%d.%d';

Implementation

End.
