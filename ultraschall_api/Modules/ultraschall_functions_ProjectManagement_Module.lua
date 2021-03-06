--[[
################################################################################
# 
# Copyright (c) 2014-2019 Ultraschall (http://ultraschall.fm)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 
################################################################################
]]

-------------------------------------
--- ULTRASCHALL - API - FUNCTIONS ---
-------------------------------------
---  Projects: Management Module  ---
-------------------------------------

if type(ultraschall)~="table" then 
  -- update buildnumber and add ultraschall as a table, when programming within this file
  local retval, string = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "Functions-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  local retval, string = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "Projectmanagement-Projectfiles-Module-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  local retval, string2 = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "API-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  if string=="" then string=10000 
  else 
    string=tonumber(string) 
    string=string+1
  end
  if string2=="" then string2=10000 
  else 
    string2=tonumber(string2)
    string2=string2+1
  end 
  reaper.BR_Win32_WritePrivateProfileString("Ultraschall-Api-Build", "Functions-Build", string, reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
  reaper.BR_Win32_WritePrivateProfileString("Ultraschall-Api-Build", "API-Build", string2, reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")  
  ultraschall={} 
  
  ultraschall.API_TempPath=reaper.GetResourcePath().."/UserPlugins/ultraschall_api/temp/"
end




function ultraschall.GetProjectFilename(proj)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProjectFilename</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>string projectfilename_with_path = ultraschall.GetProjectFilename(ReaProject proj)</functioncall>
  <description>
    Returns the filename of a currently opened project(-tab)
    
    returns nil in case of an error
  </description>
  <retvals>
    string projectfilename_with_path - the filename of the project; "", project hasn't been saved yet; nil, in case of an error
  </retvals>
  <parameters>
    ReaProject proj - a currently opened project, whose filename you want to know
  </parameters>
  <chapter_context>
    Project-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_ProjectManagement_Module.lua</source_document>
  <tags>helperfunctions, projectfiles, get, projecttab, filename</tags>
</US_DocBloc>
]]
  if ultraschall.type(proj)~="ReaProject" then ultraschall.AddErrorMessage("GetProjectFilename", "proj", "must be a valid ReaProject-object", -1) return end
  local number_of_projecttabs, projecttablist = ultraschall.GetProject_Tabs()
  for i=1, number_of_projecttabs do
    if proj==projecttablist[i][1] then
      return projecttablist[i][2]
    end
  end
end

function ultraschall.CheckForChangedProjectTabs(update)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>CheckForChangedProjectTabs</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval, integer countReorderedProj, array reorderedProj, integer countNewProj, array newProj, integer countClosedProj, array closedProj, integer countRenamedProjects, array RenamesProjects = ultraschall.CheckForChangedProjectTabs(boolean update)</functioncall>
  <description>
    Returns if projecttabs have been changed due reordering, new projects or closed projects, since last calling this function.
    Set update=true to update Ultraschall's internal project-monitoring-list or it will only return the changes since starting the API in this script or since the last time you used this function with parameter update set to true!
    
    Returns false, -1 in case of error.
  </description>
  <retvals>
    boolean retval - false, no changes in the projecttabs at all; true, either order, newprojects or closed project-changes
    integer countReorderedProj - the number of reordered projects
    array reorderedProj - ReaProjects, who got reordered within the tabs
    integer countNewProj - the number of new projects
    array newProj - the new projects as ReaProjects
    integer countClosedProj - the number of closed projects
    array closedProj - the closed projects as ReaProjects
    integer countRenamedProjects - the number of projects, who got renamed by either saving under a new filename or loading of another project
    array RenamesProjects - the renamed projects, by loading a new project or saving the project under another filename
  </retvals>
  <parameters>
    boolean update - true, update Ultraschall's internal projecttab-monitoring-list to the current state of all tabs
                   - false, don't update the internal projecttab-monitoring-list, so it will keep the "old" project-tab-state as checking-reference
  </parameters>
  <chapter_context>
    Project-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_ProjectManagement_Module.lua</source_document>
  <tags>helperfunctions, projectfiles, check, projecttab, change, order, new, closed, close</tags>
</US_DocBloc>
]]
  if type(update)~="boolean" then ultraschall.AddErrorMessage("CheckForChangedProjectTabs", "update", "Must be a boolean!", -1) return false, -1 end
  local Count, Projects = ultraschall.GetProject_Tabs()

  if ultraschall.ProjectList==nil then 
    if update==true then ultraschall.ProjectList=Projects ultraschall.ProjectCount=Count end
    return false
  end
  
  -- check the order
  local OrderRetValProj={}
  local ordercount=0
  local tempproj
  local tempproj2
  
  for a=1, ultraschall.ProjectCount do
    tempproj=ultraschall.ProjectList[a][1]
    if Projects[a]==nil then break end
    tempproj2=Projects[a][1]
    if tempproj~=tempproj2 then 
        ordercount=ordercount+1
        OrderRetValProj[ordercount]=tempproj2
    end
  end
  
  -- check for new projects
  local NewRetValProj={}
  local newprojcount=0
  local found=false
  
  for i=1, Count do
    for a=1, ultraschall.ProjectCount do
      if ultraschall.ProjectList[a][1]==Projects[i][1] then 
        found=true
        break
      end
    end
    if found==false then 
      newprojcount=newprojcount+1
      NewRetValProj[newprojcount]=Projects[i][1]
    end
    found=false
  end

  -- check for closed projects
  local ClosedRetValProj={}
  local closedprojcount=0
  local found=false
  
  for i=1, ultraschall.ProjectCount do
    for a=1, Count do
      if ultraschall.ProjectList[i][1]==Projects[a][1] then 
        found=true
        break
      end
    end
    if found==false then 
      closedprojcount=closedprojcount+1
      ClosedRetValProj[closedprojcount]=ultraschall.ProjectList[i][1]
    end
    found=false
  end
  
  -- check for changed projectnames(due saving, loading, etc)
  local ProjectNames={}
  local Projectnames_count=0
  local found=false
  
  for i=1, ultraschall.ProjectCount do
    if ultraschall.IsValidReaProject(ultraschall.ProjectList[i][1])==true and ultraschall.ProjectList[i][2]~=ultraschall.GetProjectFilename(ultraschall.ProjectList[i][1]) then
      Projectnames_count=Projectnames_count+1
      ProjectNames[Projectnames_count]=ultraschall.ProjectList[i][1]
    end
  end
  
  if update==true then ultraschall.ProjectList=Projects ultraschall.ProjectCount=Count end
  if ordercount>0 or newprojcount>0 or closedprojcount>0 or Projectnames_count>0 then
    return true, ordercount, OrderRetValProj, newprojcount, NewRetValProj, closedprojcount, ClosedRetValProj, Projectnames_count, ProjectNames
  end
  return false
end

function ultraschall.IsValidProjectStateChunk(ProjectStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsValidProjectStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.IsValidProjectStateChunk(string ProjectStateChunk)</functioncall>
  <description>
    Checks, whether ProjectStateChunk is a valid ProjectStateChunk
  </description>
  <parameters>
    string ProjectStateChunk - the string to check, if it's a valid ProjectStateChunk
  </parameters>
  <retvals>
    boolean retval - true, if it's a valid ProjectStateChunk; false, if not
  </retvals>
  <chapter_context>
    Project-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_ProjectManagement_Module.lua</source_document>
  <tags>projectfiles, rpp, projectstatechunk, statechunk, check, valid</tags>
</US_DocBloc>
]]  
  if type(ProjectStateChunk)=="string" and ProjectStateChunk:match("^<REAPER_PROJECT.*>")~=nil then return true else return false end
end


ultraschall.LastProjectStateChunk_Time=reaper.time_precise()

function ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender, temp, temp, temp, temp, temp, waittime)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>GetProjectStateChunk</slug>
    <requires>
      Ultraschall=4.00
      Reaper=5.975
      SWS=2.10.0.1
      JS=0.972
      Lua=5.3
    </requires>
    <functioncall>string ProjectStateChunk = ultraschall.GetProjectStateChunk(optional string projectfilename_with_path, optional boolean keepqrender)</functioncall>
    <description>
      Gets the ProjectStateChunk of the current active project or a projectfile.
      
      Important: when calling it too often in a row, this might fail and result in a timeout-error. 
      I tried to circumvent this, but best practice is to wait 2-3 seconds inbetween calling this function.
      This function also eats up a lot of resources, so be sparse with it in general!
      
      returns nil if getting the ProjectStateChunk took too long
    </description>
    <retvals>
      string ProjectStateChunk - the ProjectStateChunk of the current project; nil, if getting the ProjectStateChunk took too long
    </retvals>
    <parameters>
      optional string projectfilename_with_path - the filename of an rpp-projectfile, that you want to load as ProjectStateChunk; nil, to get the ProjectStateChunk from the currently active project
      optional boolean keepqrender - true, keeps the QUEUED_RENDER_OUTFILE and QUEUED_RENDER_ORIGINAL_FILENAME entries in the ProjectStateChunk, if existing; false or nil, remove them
    </parameters>
    <chapter_context>
      Project-Files
      Helper functions
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_ProjectManagement_Module.lua</source_document>
    <tags>projectmanagement, get, projectstatechunk</tags>
  </US_DocBloc>
  ]]  
    
  -- This function puts the current project into the render-queue and reads it from there.
  -- For that, 
  --    1) it gets all files in the render-queue
  --    2) it adds the current project to the renderqueue
  --    3) it waits, until Reaper has added the file to the renderqueue, reads it and deletes the file afterwards
  -- It also deals with edge-case-stuff to avoid render-dialogs/warnings popping up.
  --
  -- In Lua, this has an issue, as sometimes the filelist with EnumerateFiles isn't updated in ReaScript.
  -- Why that is is mysterious. I hope, it can be curcumvented in C++


  -- if a filename is given, read the file and check, whether it's a valid ProjectStateChunk. 
  -- If yes, return it. Otherwise error.
  local ProjectStateChunk
  if projectfilename_with_path~=nil then 
    ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path)
    if ultraschall.IsValidProjectStateChunk(ProjectStateChunk)==false then ultraschall.AddErrorMessage("GetProjectStateChunk", "projectfilename_with_path", "must be a valid ReaProject or nil", -1) return nil end
    return ProjectStateChunk
  end
  
  if ultraschall.LastProjectStateChunk_Time+3>=reaper.time_precise() then
    local i=0
    while l==nil do
      i=i+1
      if i==10000000
      then break end
    end
  end
  
  ultraschall.LastProjectStateChunk_Time=reaper.time_precise()
  
  -- get the currently focused hwnd; will be restored after function is done
  -- this is due Reaper changing the focused hwnd, when adding projects to the render-queue
  local oldfocushwnd = reaper.JS_Window_GetFocus()
      
  -- turn off renderqdelay temporarily, as otherwise this could display a render-queue-delay dialog
  -- old setting will be restored later
  local qretval, qlength = ultraschall.GetRender_QueueDelay()
  local retval = ultraschall.SetRender_QueueDelay(false, qlength)
      
  -- turn on auto-increment filename temporarily, to avoid the "filename already exists"-dialog popping up
  -- old setting will be restored later
  local old_autoincrement = ultraschall.GetRender_AutoIncrementFilename()
  ultraschall.SetRender_AutoIncrementFilename(true)  
  
  -- get all filenames currently in the render-queue
  local oldbounds, oldstartpos, oldendpos, prep_changes, files, files2, filecount, filecount2    
  filecount, files = ultraschall.GetAllFilenamesInPath(reaper.GetResourcePath().."\\QueuedRenders")
      
  -- if Projectlength=0 or CountofTracks==0, set render-settings for empty projects(workaround for that edgecase)
  -- old settings will be restored later
  if reaper.CountTracks()==0 or reaper.GetProjectLength()==0 then
    -- get old settings
    oldbounds   =reaper.GetSetProjectInfo(0, "RENDER_BOUNDSFLAG", 0, false)
    oldstartpos =reaper.GetSetProjectInfo(0, "RENDER_STARTPOS", 0, false)
    oldendpos   =reaper.GetSetProjectInfo(0, "RENDER_ENDPOS", 1, false)  
       
    -- set useful defaults that'll make adding the project to the render-queue possible always
    reaper.GetSetProjectInfo(0, "RENDER_BOUNDSFLAG", 0, true)
    reaper.GetSetProjectInfo(0, "RENDER_STARTPOS", 0, true)
    reaper.GetSetProjectInfo(0, "RENDER_ENDPOS", 1, true)
    
    -- set prep_changes to true, so we know, we need to reset these settings, later
    prep_changes=true
  end
      
  -- add current project to render-queue
  reaper.Main_OnCommand(41823,0)
  
  if tonumber(waittime)==nil then waittime=100000 end
  
  -- wait, until Reaper has added the project to the render-queue and get it's filename
  -- 
  -- there's a timeout, to avoid hanging scripts, as ReaScript doesn't always update it's filename-lists
  -- gettable using reaper.EnumerateFiles(which I'm using in GetAllFilenamesInPath)
  --
  -- other workarounds, using ls/dir in console is too slow and has possible problems with filenames 
  -- containing Unicode
  local i=0
  while l==nil do
    i=i+1
    filecount2, files2 = ultraschall.GetAllFilenamesInPath(reaper.GetResourcePath().."\\QueuedRenders")
    if filecount2~=filecount then 
      break 
    end
    if i==waittime--00
      then ultraschall.AddErrorMessage("GetProjectStateChunk", "", "timeout: Getting the ProjectStateChunk took too long for some reasons, please report this as bug to me and include the projectfile with which this happened!", -2) return end
  end
  local duplicate_count, duplicate_array, originalscount_array1, originals_array1, originalscount_array2, originals_array2 = ultraschall.GetDuplicatesFromArrays(files, files2)

   -- read found render-queued-project and delete it
  local ProjectStateChunk=ultraschall.ReadFullFile(originals_array2[1])
  os.remove(originals_array2[1])
  
  -- reset temporarily changed settings in the current project, as well as in the ProjectStateChunk itself
  if prep_changes==true then
    reaper.GetSetProjectInfo(0, "RENDER_BOUNDSFLAG", oldbounds, true)
    reaper.GetSetProjectInfo(0, "RENDER_STARTPOS", oldstartpos, true)
    reaper.GetSetProjectInfo(0, "RENDER_ENDPOS", oldendpos, true)
    retval, ProjectStateChunk = ultraschall.SetProject_RenderRange(nil, math.floor(oldbounds), math.floor(oldstartpos), math.floor(oldendpos), math.floor(reaper.GetSetProjectInfo(0, "RENDER_TAILFLAG", 0, false)), math.floor(reaper.GetSetProjectInfo(0, "RENDER_TAILMS", 0, false)), ProjectStateChunk)
  end
      
  -- remove QUEUED_RENDER_ORIGINAL_FILENAME and QUEUED_RENDER_OUTFILE-entries, if keepqrender==true
  if keepqrender~=true then
    ProjectStateChunk=string.gsub(ProjectStateChunk, "  QUEUED_RENDER_OUTFILE .-%c", "")
    ProjectStateChunk=string.gsub(ProjectStateChunk, "  QUEUED_RENDER_ORIGINAL_FILENAME .-%c", "")
  end
      
  -- reset old auto-increment-checkbox-state
  ultraschall.SetRender_AutoIncrementFilename(old_autoincrement)
      
  -- reset old hwnd-focus-state 
  reaper.JS_Window_SetFocus(oldfocushwnd)
  
  -- restore old render-qdelay-setting
  retval = ultraschall.SetRender_QueueDelay(qretval, qlength)
  
  -- return the final ProjectStateChunk
  return ProjectStateChunk
end

function ultraschall.EnumProjects(idx)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>EnumProjects</slug>
  <requires>
    Ultraschall=4.00
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>ReaProject retval, string projfn = ultraschall.EnumProjects(integer idx)</functioncall>
  <description>
    returns, ReaProject-object and projectname of a requested, opened project.
    
    Returns nil in case of an error.
  </description>
  <parameters>
    integer idx - the project to request; 1(first project-tab) to n(last project-tab), 0 for current project; -1 for currently-rendering project
  </parameters>
  <retvals>
    ReaProject retval - a ReaProject-object of the project you requested; nil, if not existing
    string projfn - the path+filename.rpp of the project. returns "" if no filename exists
  </retvals>
  <chapter_context>
    Project-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_ProjectManagement_Module.lua</source_document>
  <tags>helperfunctions, projectfiles, get, filename, project, reaproject, rendering, opened</tags>
</US_DocBloc>
--]]
  if math.type(idx)~="integer" then ultraschall.AddErrorMessage("EnumProjects","idx", "must be an integer", -1) return nil end
  if idx==0 then idx=-1
  elseif idx==-1 then idx=0x40000000
  else idx=idx-1
  end
  return reaper.EnumProjects(idx,"")
end


function ultraschall.GetProjectLength(items, markers_regions, timesig_markers, include_rec)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProjectLength</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.40
    Lua=5.3
  </requires>
  <functioncall>number project_length, number last_itemedge, number last_regionedgepos, number last_markerpos, number last_timesigmarker = ultraschall.GetProjectLength(optional boolean return_last_itemedge, optional boolean return_last_markerpos, optional boolean return_lat_timesigmarkerpos, optional boolean include_rec)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the position of the last itemedge, regionend, marker, time-signature-marker in the project.
    
    It will return -1, if no such elements are found, means: last\_markerpos=-1 if no marker has been found
    Exception when no items are found, it will return nil for last\_itemedge
    
    You can optimise the speed of the function, by setting the appropriate parameters to false.
    So if you don't need the last itemedge, setting return\_last\_itemedge=false speeds up execution massively.
    
	If you want to have the full projectlength during recording, means, including items currently recorded, set include_rec=true
	
    To do the same for projectfiles, use: [GetProject\_Length](#GetProject_Length)
  </description>
  <retvals>
    number length_of_project - the overall length of the project, including markers, regions, itemedges and time-signature-markers
    number last_itemedge - the position of the last itemedge in the project; nil, if not found
    number last_regionedgepos - the position of the last regionend in the project; -1, if not found
    number last_markerpos - the position of the last marker in the project; -1, if not found 
    number last_timesigmarker - the position of the last timesignature-marker in the project; -1, if not found
  </retvals>
  <parameters>
    optional boolean return_last_itemedge - true or nil, return the last itemedge; false, don't return it
    optional boolean return_last_markerpos - true or nil, return the last marker/regionend-position; false, don't return it 
    optional boolean return_lat_timesigmarkerpos - true or nil, return the last timesignature-marker-position; false, don't return it
	optional boolean include_rec - true, takes into account the projectlength during recording; nil or false, only the projectlength exluding currently recorded MediaItems
  </parameters>
  <chapter_context>
    Project-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_ProjectManagement_Module.lua</source_document>
  <tags>project management, get, last, position, length of project, marker, regionend, itemend, timesignaturemarker</tags>
</US_DocBloc>
--]]
  local Longest=-10000000000 -- this is a hack for MediaItems, who are stuck before ProjectStart; I hate it
  if items~=false then
    local Position, Length
    for i=0, reaper.CountMediaItems(0)-1 do
      Position=reaper.GetMediaItemInfo_Value(reaper.GetMediaItem(0,i), "D_POSITION")
      Length=reaper.GetMediaItemInfo_Value(reaper.GetMediaItem(0,i), "D_LENGTH")
      if Position+Length>Longest then Longest=Position+Length end
    end
  end
  if Longest==-10000000000 then Longest=nil end -- same hack for MediaItems, who are stuck before ProjectStart; I hate it...
  local Regionend=-1
  local Markerend=-1
  if markers_regions~=false then
    for i=0, reaper.CountProjectMarkers(0)-1 do
      local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
      if isrgn==true then
        if rgnend>Regionend then Regionend=rgnend end
      else
        if pos>Markerend then Markerend=pos end
      end
    end
  end
  local TimeSigEnd=-1
  if timesig_markers~=false then
    for i=0, reaper.CountTempoTimeSigMarkers(0)-1 do
      local retval, timepos, measurepos, beatpos, bpm, timesig_num, timesig_denom, lineartempo = reaper.GetTempoTimeSigMarker(0, i)
      if timepos>TimeSigEnd then TimeSigEnd=timepos end
    end
  end
  if include_rec==true and reaper.GetPlayState()&4~=0 and ultraschall.AnyTrackRecarmed()==true and reaper.GetPlayPosition()>reaper.GetProjectLength() then 
	return reaper.GetPlayPosition(), Longest, Regionend, Markerend, TimeSigEnd
  end
  return reaper.GetProjectLength(), Longest, Regionend, Markerend, TimeSigEnd
end

function ultraschall.GetRecentProjects()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetRecentProjects</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>integer count_of_RecentProjects, array RecentProjectsFilenamesWithPath = ultraschall.GetRecentProjects()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    returns all available recent projects, as listed in the File -> Recent projects-menu
  </description>
  <retvals>
    integer count_of_RecentProjects - the number of available recent projects
    array RecentProjectsFilenamesWithPath - the filenames of the recent projects
  </retvals>
  <chapter_context>
    Project-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_ProjectManagement_Module.lua</source_document>
  <tags>projectmanagement, get, all, recent, projects, filenames, rpp</tags>
</US_DocBloc>
]]
  local Length_of_value, Count = ultraschall.GetIniFileValue("REAPER", "numrecent", -100, reaper.get_ini_file())
  local Count=tonumber(Count)
  local RecentProjects={}
  for i=1, Count do
    if i<10 then zero="0" else zero="" end
    Length_of_value, RecentProjects[i] = ultraschall.GetIniFileValue("Recent", "recent"..zero..i, -100, reaper.get_ini_file())  
  end
  
  return Count, RecentProjects
end

function ultraschall.IsValidProjectBayStateChunk(ProjectBayStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsValidProjectBayStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.IsValidProjectBayStateChunk(string ProjectBayStateChunk)</functioncall>
  <description>
    checks, if ProjectBayStateChunk is a valid ProjectBayStateChunk
    
    returns false in case of an error
  </description>
  <parameters>
    string ProjectBayStateChunk - a string, that you want to check for being a valid ProjectBayStateChunk
  </parameters>
  <retvals>
    boolean retval - true, valid ProjectBayStateChunk; false, not a valid ProjectBayStateChunk
  </retvals>
  <chapter_context>
    Project-Management
    ProjectBay
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_ProjectManagement_Module.lua</source_document>
  <tags>project management, check, projectbaystatechunk, is valid</tags>
</US_DocBloc>
]]
  if type(ProjectBayStateChunk)~="string" then ultraschall.AddErrorMessage("IsValidProjectBayStateChunk", "ProjectBayStateChunk", "must be a string", -1) return false end
  if ProjectBayStateChunk:match("<PROJBAY.-\n  >")==nil then return false else return true end
end

function ultraschall.GetAllMediaItems_FromProjectBayStateChunk(ProjectBayStateChunk)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetAllMediaItems_FromProjectBayStateChunk</slug>
  <requires>
    Ultraschall=4.00
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer count, array MediaItemStateChunkArray = ultraschall.GetAllMediaItems_FromProjectBayStateChunk(string ProjectBayStateChunk)</functioncall>
  <description>
    returns all items from a ProjectBayStateChunk as MediaItemStateChunkArray
    
    returns -1 in case of an error
  </description>
  <parameters>
    string ProjectBayStateChunk - a string, that you want to check for being a valid ProjectBayStateChunk
  </parameters>
  <retvals>
    integer count - the number of items found in the ProjectBayStateChunk
    array MediaitemStateChunkArray - all items as ItemStateChunks in a handy array
  </retvals>
  <chapter_context>
    Project-Management
    ProjectBay
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_ProjectManagement_Module.lua</source_document>
  <tags>project management, get, projectbaystatechunk, all items, mediaitemstatechunkarray</tags>
</US_DocBloc>
]]
  if ultraschall.IsValidProjectBayStateChunk(ProjectBayStateChunk)==false then ultraschall.AddErrorMessage("GetAllMediaItems_FromProjectBayStateChunk", "ProjectBayStateChunk", "must be a valid ProjectBayStateChunk", -1) return -1 end
  local MediaItemStateChunkArray={}
  local count=0
  for k in string.gmatch(ProjectBayStateChunk, "    <DATA.-\n    >") do
    count=count+1
    MediaItemStateChunkArray[count]=string.gsub(string.gsub(k, "    <DATA", "<ITEM"),"\n%s*", "\n").."\n"
  end
  return count, MediaItemStateChunkArray
end

function ultraschall.IsTimeSelectionActive()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>IsTimeSelectionActive</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval, optional number start_of_timeselection, optional number end_of_timeselection = ultraschall.IsTimeSelectionActive(optional ReaProject Project)</functioncall>
  <description>
    Returns, if there's a time-selection and its start and endposition in a project.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, there is a time-selection; false, there isn't a time-selection
	optional number start_of_timeselection - start of the time-selection
	optional number end_of_timeselection - end of the time-selection
  </retvals>
  <parameters>
    optional ReaProject Project - the project, whose time-selection-state you want to know; 0 or nil, the current project
  </parameters>
  <chapter_context>
    Project-Management
	Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_ProjectManagement_Module.lua</source_document>
  <tags>projectmanagement, time selection, get</tags>
</US_DocBloc>
]] 
  if Project~=0 and Project~=nil and ultraschall.type(Project)~="ReaProject" then
    ultraschall.AddErrorMessage("IsTimeSelectionActive", "Project", "must be a valid ReaProject, 0 or nil(for current)", -1)
    return false
  end
  local Start, Endof = reaper.GetSet_LoopTimeRange2(Project, false, false, 0, 0, false)
  if Start==Endof then return false end
  return true, Start, Endof
end

