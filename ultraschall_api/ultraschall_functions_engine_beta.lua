--[[
################################################################################
# 
# Copyright (c) 2014-2020 Ultraschall (http://ultraschall.fm)
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


if type(ultraschall)~="table" then 
  -- update buildnumber and add ultraschall as a table, when programming within this file
  local retval, string = reaper.BR_Win32_GetPrivateProfileString("Ultraschall-Api-Build", "Functions-Build", "", reaper.GetResourcePath().."/UserPlugins/ultraschall_api/IniFiles/ultraschall_api.ini")
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
  dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
end
    
function ultraschall.ApiBetaFunctionsTest()
    -- tell the api, that the beta-functions are activated
    ultraschall.functions_beta_works="on"
end

  


--ultraschall.ShowErrorMessagesInReascriptConsole(true)

--ultraschall.WriteValueToFile()

--ultraschall.AddErrorMessage("func","parm","desc",2)




function ultraschall.GetProject_RenderOutputPath(projectfilename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetProject_RenderOutputPath</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string render_output_directory = ultraschall.GetProject_RenderOutputPath(string projectfilename_with_path)</functioncall>
  <description>
    returns the output-directory for rendered files of a project.

    Doesn't return the correct output-directory for queued-projects!
    
    returns nil in case of an error
  </description>
  <parameters>
    string projectfilename_with_path - the projectfilename with path, whose renderoutput-directories you want to know
  </parameters>
  <retvals>
    string render_output_directory - the output-directory for projects
  </retvals>
  <chapter_context>
    Project-Files
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>render management, get, project, render, outputpath</tags>
</US_DocBloc>
]]
  if type(projectfilename_with_path)~="string" then ultraschall.AddErrorMessage("GetProject_RenderOutputPath", "projectfilename_with_path", "must be a string", -1) return nil end
  if reaper.file_exists(projectfilename_with_path)==false then ultraschall.AddErrorMessage("GetProject_RenderOutputPath", "projectfilename_with_path", "file does not exist", -2) return nil end
  local ProjectStateChunk=ultraschall.ReadFullFile(projectfilename_with_path)
  local QueueRendername=ProjectStateChunk:match("(QUEUED_RENDER_OUTFILE.-)\n")
  local QueueRenderProjectName=ProjectStateChunk:match("(QUEUED_RENDER_ORIGINAL_FILENAME.-)\n")
  local OutputRender, RenderPattern, RenderFile
  
  if QueueRendername~=nil then
    QueueRendername=QueueRendername:match(" \"(.-)\" ")
    QueueRendername=ultraschall.GetPath(QueueRendername)
  end
  
  if QueueRenderProjectName~=nil then
    QueueRenderProjectName=QueueRenderProjectName:match(" (.*)")
    QueueRenderProjectName=ultraschall.GetPath(QueueRenderProjectName)
  end


  RenderFile=ProjectStateChunk:match("(RENDER_FILE.-)\n")
  if RenderFile~=nil then
    RenderFile=RenderFile:match("RENDER_FILE (.*)")
    RenderFile=string.gsub(RenderFile,"\"","")
  end
  
  RenderPattern=ProjectStateChunk:match("(RENDER_PATTERN.-)\n")
  if RenderPattern~=nil then
    RenderPattern=RenderPattern:match("RENDER_PATTERN (.*)")
    if RenderPattern~=nil then
      RenderPattern=string.gsub(RenderPattern,"\"","")
    end
  end

  -- get the normal render-output-directory
  if RenderPattern~=nil and RenderFile~=nil then
    if ultraschall.DirectoryExists2(RenderFile)==true then
      OutputRender=RenderFile
    else
      OutputRender=ultraschall.GetPath(projectfilename_with_path)..ultraschall.Separator..RenderFile
    end
  elseif RenderFile~=nil then
    OutputRender=ultraschall.GetPath(RenderFile)    
  else
    OutputRender=ultraschall.GetPath(projectfilename_with_path)
  end


  -- get the potential RenderQueue-renderoutput-path
  -- not done yet...todo
  -- that way, I may be able to add the currently opened projects as well...
--[[
  if RenderPattern==nil and (RenderFile==nil or RenderFile=="") and
     QueueRenderProjectName==nil and QueueRendername==nil then
    QueueOutputRender=ultraschall.GetPath(projectfilename_with_path)
  elseif RenderPattern~=nil and RenderFile~=nil then
    if ultraschall.DirectoryExists2(RenderFile)==true then
      QueueOutputRender=RenderFile
    end
  end
  --]]
  
  OutputRender=string.gsub(OutputRender,"\\\\", "\\")
  
  return OutputRender, QueueOutputRender
end

--A="c:\\Users\\meo\\Desktop\\trss\\20Januar2019\\rec\\rec3.RPP"

--B,C=ultraschall.GetProject_RenderOutputPath()


function ultraschall.ResolveRenderPattern(renderpattern)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ResolveRenderPattern</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string resolved_renderpattern = ultraschall.ResolveRenderPattern(string render_pattern)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    resolves a render-pattern into its render-filename(without extension).

    returns nil in case of an error    
  </description>
  <parameters>
    string render_pattern - the render-pattern, that you want to resolve into its render-filename
  </parameters>
  <retvals>
    string resolved_renderpattern - the resolved renderpattern, that is used for a render-filename.
                                  - just add extension and path to it.
                                  - Stems will be rendered to path/resolved_renderpattern-XXX.ext
                                  -    where XXX is a number between 001(usually for master-track) and 999
  </retvals>
  <chapter_context>
    Rendering Projects
    Assistance functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>rendermanagement, resolve, renderpattern, filename</tags>
</US_DocBloc>
]]
  if type(renderpattern)~="string" then ultraschall.AddErrorMessage("ResolveRenderPattern", "renderpattern", "must be a string", -1) return nil end
  if renderpattern=="" then return "" end
  local TempProject=ultraschall.Api_Path.."misc/tempproject.RPP"
  local TempFolder=ultraschall.Api_Path.."misc/"
  TempFolder=string.gsub(TempFolder, "\\", ultraschall.Separator)
  TempFolder=string.gsub(TempFolder, "/", ultraschall.Separator)
  
  ultraschall.SetProject_RenderFilename(TempProject, "")
  ultraschall.SetProject_RenderPattern(TempProject, renderpattern)
  ultraschall.SetProject_RenderStems(TempProject, 0)
  
  reaper.Main_OnCommand(41929,0)
  reaper.Main_openProject(TempProject)
  
  A,B=ultraschall.GetProjectStateChunk()
  reaper.Main_SaveProject(0,false)
  reaper.Main_OnCommand(40860,0)
  if B==nil then B="" end
  
  count, split_string = ultraschall.SplitStringAtLineFeedToArray(B)

  for i=1, count do
    split_string[i]=split_string[i]:match("\"(.-)\"")
  end
  if split_string[1]==nil then split_string[1]="" end
  return string.gsub(split_string[1], TempFolder, ""):match("(.-)%.")
end

--for i=1, 10 do
--  O=ultraschall.ResolveRenderPattern("I would find a way $day")
--end

ultraschall.ShowLastErrorMessage()


function ultraschall.InsertMediaItemArray2(position, MediaItemArray, trackstring)
  
--ToDo: Die Möglichkeit die Items in andere Tracks einzufügen. Wenn trackstring 1,3,5 ist, die Items im MediaItemArray
--      in 1,2,3 sind, dann landen die Items aus track 1 in track 1, track 2 in track 3, track 3 in track 5
--
-- Beta 3 Material
  
  if type(position)~="number" then return -1 end
  local trackstring,AA,AAA=ultraschall.RemoveDuplicateTracksInTrackstring(trackstring)
  if trackstring==-1 then return -1 end
  local count=1
  local i
  if type(MediaItemArray)~="table" then return -1 end
  local NewMediaItemArray={}
  local _count, individual_values = ultraschall.CSV2IndividualLinesAsArray(trackstring) 
  local ItemStart=reaper.GetProjectLength()+1
  while MediaItemArray[count]~=nil do
    local ItemStart_temp=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_POSITION")
    if ItemStart>ItemStart_temp then ItemStart=ItemStart_temp end
    count=count+1
  end
  count=1
  while MediaItemArray[count]~=nil do
    local ItemStart_temp=reaper.GetMediaItemInfo_Value(MediaItemArray[count], "D_POSITION")
    local MediaTrack=reaper.GetMediaItem_Track(MediaItemArray[count])
    --nur einfügen, wenn mediaitem aus nem Track stammt, der in trackstring vorkommt
    i=1
    while individual_values[i]~=nil do
--    reaper.MB("Yup"..i,individual_values[i],0)
    if reaper.GetTrack(0,individual_values[i]-1)==reaper.GetMediaItem_Track(MediaItemArray[count]) then 
    NewMediaItemArray[count]=ultraschall.InsertMediaItem_MediaItem(position+(ItemStart_temp-ItemStart),MediaItemArray[count],MediaTrack)
    end
    i=i+1
    end
    count=count+1
  end  
--  TrackArray[count]=reaper.GetMediaItem_Track(MediaItem)
--  MediaItem reaper.AddMediaItemToTrack(MediaTrack tr)
end

--C,CC=ultraschall.GetAllMediaItemsBetween(1,60,"1,3",false)
--A,B=reaper.GetItemStateChunk(CC[1], "", true)
--reaper.ShowConsoleMsg(B)
--ultraschall.InsertMediaItemArray(82, CC, "4,5")

--tr = reaper.GetTrack(0, 1)
--MediaItem=reaper.AddMediaItemToTrack(tr)
--Aboolean=reaper.SetItemStateChunk(CC[1], PUH, true)
--PCM_source=reaper.PCM_Source_CreateFromFile("C:\\Recordings\\01-te.flac")
--boolean=reaper.SetMediaItemTake_Source(MediaItem_Take, PCM_source)
--reaper.SetMediaItemInfo_Value(MediaItem, "D_POSITION", "1")
--ultraschall.InsertMediaItemArray(0,CC)


function ultraschall.RippleDrag_Start(position, trackstring, deltalength)
  A,MediaItemArray = ultraschall.GetMediaItemsAtPosition(position, trackstring)
  ultraschall.ChangeDeltaLengthOfMediaItems_FromArray(MediaItemArray, deltalength)
  C,CC=ultraschall.GetAllMediaItemsBetween(position, reaper.GetProjectLength(), trackstring, false)
  for i=C, 1, -1 do
    for j=A, 1, -1 do
--      reaper.MB(j,"",0)
      if MediaItemArray[j]==CC[i] then  table.remove(CC, i) end 
    end
  end
  ultraschall.ChangePositionOfMediaItems_FromArray(CC, deltalength)
end

--ultraschall.RippleDrag_Start(13,"1,2,3",-1)

function ultraschall.RippleDragSection_Start(startposition, endposition, trackstring, newoffset)
end

function ultraschall.RippleDrag_StartOffset(position, trackstring, newoffset)
--unfertig und buggy
  A,MediaItemArray = ultraschall.GetMediaItemsAtPosition(position, trackstring)
  ultraschall.ChangeOffsetOfMediaItems_FromArray(MediaItemArray, newoffset)
  ultraschall.ChangeDeltaLengthOfMediaItems_FromArray(MediaItemArray, -newoffset)
  C,CC=ultraschall.GetAllMediaItemsBetween(position, reaper.GetProjectLength(), trackstring, false)
  for i=C, 1, -1 do
    for j=A, 1, -1 do
--      reaper.MB(j,"",0)
      if MediaItemArray[j]==CC[i] then  table.remove(CC, i) end 
    end
  end
  ultraschall.ChangePositionOfMediaItems_FromArray(CC, newoffset)
end

--ultraschall.RippleDrag_StartOffset(13,"2",10)

--A=ultraschall.CreateRenderCFG_MP3CBR(1, 4, 10)
--B=ultraschall.CreateRenderCFG_MP3CBR(1, 10, 10)
--L,L2,L3,L4=ultraschall.RenderProject_RenderCFG(nil, "c:\\Reaper-Internal-Docs.mp3", 0, 10, false, true, true,A)
--L,L1,L2,L3,L4=ultraschall.RenderProjectRegions_RenderCFG(nil, "c:\\Reaper-Internal-Docs.mp3", 1, false, false, true, true,A)
--L=reaper.IsProjectDirty(0)

--outputchannel, post_pre_fader, volume, pan, mute, phase, source, unknown, automationmode = ultraschall.GetTrackHWOut(0, 1)

--count, MediaItemArray_selected = ultraschall.GetAllSelectedMediaItems() -- get old selection
--A=ultraschall.PutMediaItemsToClipboard_MediaItemArray(MediaItemArray_selected)

---------------------------
---- Routing Snapshots ----
---------------------------

function ultraschall.SetRoutingSnapshot(snapshot_nr)
end

function ultraschall.RecallRoutingSnapshot(snapshot_nr)
end

function ultraschall.ClearRoutingSnapshot(snapshot_nr)
end




function ultraschall.RippleDragSection_StartOffset(position,trackstring)
end

function ultraschall.RippleDrag_End(position,trackstring)

end

function ultraschall.RippleDragSection_End(position,trackstring)
end



--ultraschall.ShowLastErrorMessage()

function ultraschall.GetProjectReWireClient(projectfilename_with_path)
--To Do
-- ProjectSettings->Advanced->Rewire Client Settings
end

function ultraschall.GetLastEnvelopePoint(Envelopeobject)
end

function ultraschall.GetAllTrackEnvelopes_EnvelopePointArray(tracknumber)
--returns all track-envelopes from tracknumber as EnvelopePointArray
end

function ultraschall.GetAllTrackEnvelopes_EnvelopePointArray2(MediaTrack)
--returns all track-envelopes from MediaTrack as EnvelopePointArray
end



function ultraschall.OnlyMediaItemsInBothMediaItemArrays()
end

function ultraschall.OnlyMediaItemsInOneMediaItemArray()
end

function ultraschall.GetMediaItemTake_StateChunk(MediaItem, idx)
--returns an rppxml-statechunk for a MediaItemTake (not existing yet in Reaper!), for the idx'th take of MediaItem

--number reaper.GetMediaItemTakeInfo_Value(MediaItem_Take take, string parmname)
--MediaItem reaper.GetMediaItemTake_Item(MediaItem_Take take)

--[[Get parent item of media item take

integer reaper.GetMediaItemTake_Peaks(MediaItem_Take take, number peakrate, number starttime, integer numchannels, integer numsamplesperchannel, integer want_extra_type, reaper.array buf)
Gets block of peak samples to buf. Note that the peak samples are interleaved, but in two or three blocks (maximums, then minimums, then extra). Return value has 20 bits of returned sample count, then 4 bits of output_mode (0xf00000), then a bit to signify whether extra_type was available (0x1000000). extra_type can be 115 ('s') for spectral information, which will return peak samples as integers with the low 15 bits frequency, next 14 bits tonality.

PCM_source reaper.GetMediaItemTake_Source(MediaItem_Take take)
Get media source of media item take

MediaTrack reaper.GetMediaItemTake_Track(MediaItem_Take take)
Get parent track of media item take


MediaItem_Take reaper.GetMediaItemTakeByGUID(ReaProject project, string guidGUID)
--]]
end

function ultraschall.GetAllMediaItemTake_StateChunks(MediaItem)
--returns an array with all rppxml-statechunk for all MediaItemTakes of a MediaItem.
end


function ultraschall.SetReaScriptConsole_FontStyle(style)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>SetReaScriptConsole_FontStyle</slug>
    <requires>
      Ultraschall=4.1
      Reaper=5.965
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.SetReaScriptConsole_FontStyle(integer style)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      If the ReaScript-console is opened, you can change the font-style of it.
      You can choose between 19 different styles, with 3 being of fixed character length. It will change the next time you output text to the ReaScriptConsole.
      
      If you close and reopen the Console, you need to set the font-style again!
      
      You can only have one style active in the console!
      
      Returns false in case of an error
    </description>
    <retvals>
      boolean retval - true, displaying was successful; false, displaying wasn't successful
    </retvals>
    <parameters>
      integer length - the font-style used. There are 19 different ones.
                      - fixed-character-length:
                      -     1,  fixed, console
                      -     2,  fixed, console alt
                      -     3,  thin, fixed
                      - 
                      - normal from large to small:
                      -     4-8
                      -     
                      - bold from largest to smallest:
                      -     9-14
                      - 
                      - thin:
                      -     15, thin
                      - 
                      - underlined:
                      -     16, underlined, thin
                      -     17, underlined
                      -     18, underlined
                      - 
                      - symbol:
                      -     19, symbol
    </parameters>
    <chapter_context>
      User Interface
      Miscellaneous
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>ultraschall_functions_engine.lua</source_document>
    <tags>user interface, reascript, console, font, style</tags>
  </US_DocBloc>
  ]]
  if math.type(style)~="integer" then ultraschall.AddErrorMessage("SetReaScriptConsole_FontStyle", "style", "must be an integer", -1) return false end
  if style>19 or style<1 then ultraschall.AddErrorMessage("SetReaScriptConsole_FontStyle", "style", "must be between 1 and 17", -2) return false end
  local reascript_console_hwnd = ultraschall.GetReaScriptConsoleWindow()
  if reascript_console_hwnd==nil then return false end
  local styles={32,33,36,31,214,37,218,1606,4373,3297,220,3492,3733,3594,35,1890,2878,3265,4392}
  local Textfield=reaper.JS_Window_FindChildByID(reascript_console_hwnd, 1177)
  reaper.JS_WindowMessage_Send(Textfield, "WM_SETFONT", styles[style] ,0,0,0)
  return true
end
--reaper.ClearConsole()
--ultraschall.SetReaScriptConsole_FontStyle(1)
--reaper.ShowConsoleMsg("ABCDEFGhijklmnop\n123456789.-,!\"§$%&/()=\n----------\nOOOOOOOOOO")




--a,b=reaper.EnumProjects(-1,"")
--A=ultraschall.ReadFullFile(b)

--Mespotine



--[[
hwnd = ultraschall.GetPreferencesHWND()
hwnd2 = reaper.JS_Window_FindChildByID(hwnd, 1110)

--reaper.JS_Window_Move(hwnd2, 110,11)


for i=-1000, 10 do
  A,B,C,D=reaper.JS_WindowMessage_Post(hwnd2, "TVHT_ONITEM", i,i,i,i)
end
--]]


function ultraschall.get_action_context_MediaItemDiff(exlude_mousecursorsize, x, y)
-- TODO:: nice to have feature: when mouse is above crossfades between two adjacent items, return this state as well as a boolean
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>get_action_context_MediaItemDiff</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.975
    Lua=5.3
  </requires>
  <functioncall>MediaItem MediaItem, MediaItem_Take MediaItem_Take, MediaItem MediaItem_unlocked, boolean Item_moved, number StartDiffTime, number EndDiffTime, number LengthDiffTime, number OffsetDiffTime = ultraschall.get_action_context_MediaItemDiff(optional boolean exlude_mousecursorsize, optional integer x, optional integer y)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the currently clicked MediaItem, Take as well as the difference of position, end, length and startoffset since last time calling this function.
    Good for implementing ripple-drag/editing-functions, whose position depends on changes in the currently clicked MediaItem.
    Repeatedly call this (e.g. in a defer-cycle) to get all changes made, during dragging position, length or offset of the MediaItem underneath mousecursor.
    
    This function takes into account the size of the start/end-drag-mousecursor, that means: if mouse-position is within 3 pixels before start/after end of the item, it will get the correct MediaItem. 
    This is a workaround, as the mouse-cursor changes to dragging and can still affect the MediaItem, even though the mouse at this position isn't above a MediaItem anymore.
    To be more strict, set exlude_mousecursorsize to true. That means, it will only detect MediaItems directly beneath the mousecursor. If the mouse isn't above a MediaItem, this function will ignore it, even if the mouse could still affect the MediaItem.
    If you don't understand, what that means: simply omit exlude_mousecursorsize, which should work in almost all use-cases. If it doesn't work as you want, try setting it to true and see, whether it works now.    
    
    returns nil in case of an error
  </description>
  <retvals>
    MediaItem MediaItem - the MediaItem at the current mouse-position; nil if not found
    MediaItem_Take MediaItem_Take - the MediaItem_Take underneath the mouse-cursor
    MediaItem MediaItem_unlocked - if the MediaItem isn't locked, you'll get a MediaItem here. If it is locked, this retval is nil
    boolean Item_moved - true, the item was moved; false, only a part(either start or end or offset) of the item was moved
    number StartDiffTime - if the start of the item changed, this is the difference;
                         -   positive, the start of the item has been changed towards the end of the project
                         -   negative, the start of the item has been changed towards the start of the project
                         -   0, no changes to the itemstart-position at all
    number EndDiffTime - if the end of the item changed, this is the difference;
                         -   positive, the end of the item has been changed towards the end of the project
                         -   negative, the end of the item has been changed towards the start of the project
                         -   0, no changes to the itemend-position at all
    number LengthDiffTime - if the length of the item changed, this is the difference;
                         -   positive, the length is longer
                         -   negative, the length is shorter
                         -   0, no changes to the length of the item
    number OffsetDiffTime - if the offset of the item-take has changed, this is the difference;
                         -   positive, the offset has been changed towards the start of the project
                         -   negative, the offset has been changed towards the end of the project
                         -   0, no changes to the offset of the item-take
                         - Note: this is the offset of the take underneath the mousecursor, which might not be the same size, as the MediaItem itself!
                         - So changes to the offset maybe changes within the MediaItem or the start of the MediaItem!
                         - This could be important, if you want to affect other items with rippling.
  </retvals>
  <parameters>
    optional boolean exlude_mousecursorsize - false or nil, get the item underneath, when it can be affected by the mouse-cursor(dragging etc): when in doubt, use this
                                            - true, get the item underneath the mousecursor only, when mouse is strictly above the item,
                                            -       which means: this ignores the item when mouse is not above it, even if the mouse could affect the item
    optional integer x - nil, use the current x-mouseposition; otherwise the x-position in pixels
    optional integer y - nil, use the current y-mouseposition; otherwise the y-position in pixels
  </parameters>
  <chapter_context>
    API-Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, get, action, context, difftime, item, mediaitem, offset, length, end, start, locked, unlocked</tags>
</US_DocBloc>
--]]
  if x~=nil and math.type(x)~="integer" then ultraschall.AddErrorMessage("get_action_context_MediaItemDiff", "x", "must be either nil or an integer", -1) return nil end
  if y~=nil and math.type(y)~="integer" then ultraschall.AddErrorMessage("get_action_context_MediaItemDiff", "y", "must be either nil or an integer", -2) return nil end
  if (x~=nil and y==nil) or (y~=nil and x==nil) then ultraschall.AddErrorMessage("get_action_context_MediaItemDiff", "x or y", "must be either both nil or both an integer!", -3) return nil end
  local MediaItem, MediaItem_Take, MediaItem_unlocked
  local StartDiffTime, EndDiffTime, Item_moved, LengthDiffTime, OffsetDiffTime
  if x==nil and y==nil then x,y=reaper.GetMousePosition() end
  MediaItem, MediaItem_Take = reaper.GetItemFromPoint(x, y, true)
  MediaItem_unlocked = reaper.GetItemFromPoint(x, y, false)
  if MediaItem==nil and exlude_mousecursorsize~=true then
    MediaItem, MediaItem_Take = reaper.GetItemFromPoint(x+3, y, true)
    MediaItem_unlocked = reaper.GetItemFromPoint(x+3, y, false)
  end
  if MediaItem==nil and exlude_mousecursorsize~=true then
    MediaItem, MediaItem_Take = reaper.GetItemFromPoint(x-3, y, true)
    MediaItem_unlocked = reaper.GetItemFromPoint(x-3, y, false)
  end
  
  -- crossfade-stuff
  -- example-values for crossfade-parts
  -- Item left: 811 -> 817 , Item right: 818 -> 825
  --               6           7
  -- first:  get, if the next and previous items are at each other/crossing; if nothing -> no crossfade
  -- second: get, if within the aforementioned pixel-ranges, there's another item
  --              6 pixels for the one before the current item
  --              7 pixels for the next item
  -- third: if yes: crossfade-area, else: no crossfade area
  --[[
  -- buggy: need to know the length of the crossfade, as the aforementioned attempt would work only
  --        if the items are adjacent but not if they overlap
  --        also need to take into account, what if zoomed out heavily, where items might be only
  --        a few pixels wide
  
  if MediaItem~=nil then
    ItemNumber = reaper.GetMediaItemInfo_Value(MediaItem, "IP_ITEMNUMBER")
    ItemTrack  = reaper.GetMediaItemInfo_Value(MediaItem, "P_TRACK")
    ItemBefore = reaper.GetTrackMediaItem(ItemTrack, ItemNumber-1)
    ItemAfter = reaper.GetTrackMediaItem(ItemTrack, ItemNumber+1)
    if ItemBefore~=nil then
      ItemBefore_crossfade=reaper.GetMediaItemInfo_Value(ItemBefore, "D_POSITION")+reaper.GetMediaItemInfo_Value(ItemBefore, "D_LENGTH")>=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
    end
  end
  --]]
  
  if ultraschall.get_action_context_MediaItem_old~=MediaItem then
    StartDiffTime=0
    EndDiffTime=0
    LengthDiffTime=0
    OffsetDiffTime=0
    if MediaItem~=nil then
      ultraschall.get_action_context_MediaItem_Start=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
      ultraschall.get_action_context_MediaItem_End=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")+reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
      ultraschall.get_action_context_MediaItem_Length=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
      ultraschall.get_action_context_MediaItem_Offset=reaper.GetMediaItemTakeInfo_Value(MediaItem_Take, "D_STARTOFFS")
    end
  else
    if MediaItem~=nil then      
      StartDiffTime=ultraschall.get_action_context_MediaItem_Start
      EndDiffTime=ultraschall.get_action_context_MediaItem_End
      LengthDiffTime=ultraschall.get_action_context_MediaItem_Length
      OffsetDiffTime=ultraschall.get_action_context_MediaItem_Offset
      
      ultraschall.get_action_context_MediaItem_Start=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
      ultraschall.get_action_context_MediaItem_End=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")+reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
      ultraschall.get_action_context_MediaItem_Length=reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
      ultraschall.get_action_context_MediaItem_Offset=reaper.GetMediaItemTakeInfo_Value(MediaItem_Take, "D_STARTOFFS")
      
      Item_moved=(ultraschall.get_action_context_MediaItem_Start~=StartDiffTime
              and ultraschall.get_action_context_MediaItem_End~=EndDiffTime)
              
      StartDiffTime=ultraschall.get_action_context_MediaItem_Start-StartDiffTime
      EndDiffTime=ultraschall.get_action_context_MediaItem_End-EndDiffTime
      LengthDiffTime=ultraschall.get_action_context_MediaItem_Length-LengthDiffTime
      OffsetDiffTime=ultraschall.get_action_context_MediaItem_Offset-OffsetDiffTime
      
    end    
  end
  ultraschall.get_action_context_MediaItem_old=MediaItem

  return MediaItem, MediaItem_Take, MediaItem_unlocked, Item_moved, StartDiffTime, EndDiffTime, LengthDiffTime, OffsetDiffTime
end

--a,b,c,d,e,f,g,h,i=ultraschall.get_action_context_MediaItemDiff(exlude_mousecursorsize, x, y)



function ultraschall.TracksToColorPattern(colorpattern, startingcolor, direction)
end


function ultraschall.GetTrackPositions()
  -- only possible, when tracks can be seen...
  -- no windows above them are allowed :/
  local Arrange_view, timeline, TrackControlPanel = ultraschall.GetHWND_ArrangeViewAndTimeLine()
  local retval, left, top, right, bottom = reaper.JS_Window_GetClientRect(Arrange_view)
  local Tracks={}
  local x=left+2
  local OldItem=nil
  local Counter=0
  local B
  for y=top, bottom do
    A,B=reaper.GetTrackFromPoint(x,y)
    if OldItem~=A and A~=nil then
      Counter=Counter+1
      Tracks[Counter]={}
      Tracks[Counter][tostring(A)]=A
      Tracks[Counter]["Track_Top"]=y
      Tracks[Counter]["Track_Bottom"]=y
      OldItem=A
    elseif A==OldItem and A~=nil and B==0 then
      Tracks[Counter]["Track_Bottom"]=y
    elseif A==OldItem and A~=nil and B==1 then
      if Tracks[Counter]["Env_Top"]==nil then
        Tracks[Counter]["Env_Top"]=y
      end
      Tracks[Counter]["Env_Bottom"]=y
    elseif A==OldItem and A~=nil and B==2 then
      if Tracks[Counter]["TrackFX_Top"]==nil then
        Tracks[Counter]["TrackFX_Top"]=y
      end
      Tracks[Counter]["TrackFX_Bottom"]=y
    end
  end
  return Counter, Tracks
end

--A,B=ultraschall.GetTrackPositions()

function ultraschall.GetAllTrackHeights()
  -- can't calculate the dependency between zoom and trackheight... :/
  HH=reaper.SNM_GetIntConfigVar("defvzoom", -999)
  Heights={}
  for i=0, reaper.CountTracks(0) do
    Heights[i+1], heightstate2, unknown = ultraschall.GetTrackHeightState(i)
   -- if Heights[i+1]==0 then Heights[i+1]=HH end
  end

end

--ultraschall.GetAllTrackHeights()



--[[
A=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
--print2(22)
B=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
--print2(22)
C=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
D=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
E=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
F=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
G=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
H=ultraschall.GetProjectStateChunk(projectfilename_with_path, keepqrender)
--]]


function ultraschall.GetTrackEnvelope_ClickStates()
-- how to get the connection to clicked envelopepoint, when mouse moves away from the item while retaining click(moving underneath the item for dragging)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackEnvelope_ClickState</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.981
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>boolean clickstate, number position, MediaTrack track, TrackEnvelope envelope, integer EnvelopePointIDX = ultraschall.GetTrackEnvelope_ClickState()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Returns the currently clicked Envelopepoint and TrackEnvelope, as well as the current timeposition.
    
    Works only, if the mouse is above the EnvelopePoint while having it clicked!
    
    Returns false, if no envelope is clicked at
  </description>
  <retvals>
    boolean clickstate - true, an envelopepoint has been clicked; false, no envelopepoint has been clicked
    number position - the position, at which the mouse has clicked
    MediaTrack track - the track, from which the envelope and it's corresponding point is taken from
    TrackEnvelope envelope - the TrackEnvelope, in which the clicked envelope-point lies
    integer EnvelopePointIDX - the id of the clicked EnvelopePoint
  </retvals>
  <chapter_context>
    Envelope Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>envelope management, get, clicked, envelope, envelopepoint</tags>
</US_DocBloc>
--]]
  -- TODO: Has an issue, if the mousecursor drags the item, but moves above or underneath the item(if item is in first or last track).
  --       Even though the item is still clicked, it isn't returned as such.
  --       The ConfigVar uiscale supports dragging information, but the information which item has been clicked gets lost somehow
  --local B, Track, Info, TrackEnvelope, TakeEnvelope, X, Y
  
  B=reaper.SNM_GetDoubleConfigVar("uiscale", -999)
  if tostring(B)=="-1.#QNAN" then
    ultraschall.EnvelopeClickState_OldTrack=nil
    ultraschall.EnvelopeClickState_OldInfo=nil
    ultraschall.EnvelopeClickState_OldTrackEnvelope=nil
    ultraschall.EnvelopeClickState_OldTakeEnvelope=nil
    return 1
  else
    Track=ultraschall.EnvelopeClickState_OldTrack
    Info=ultraschall.EnvelopeClickState_OldInfo
    TrackEnvelope=ultraschall.EnvelopeClickState_OldTrackEnvelope
    TakeEnvelope=ultraschall.EnvelopeClickState_OldTakeEnvelope
  end
  
  if Track==nil then
    X,Y=reaper.GetMousePosition()
    Track, Info = reaper.GetTrackFromPoint(X,Y)
    ultraschall.EnvelopeClickState_OldTrack=Track
    ultraschall.EnvelopeClickState_OldInfo=Info
  end
  
  -- BUggy, til the end
  -- Ich will hier mir den alten Take auch noch merken, und danach herausfinden, welcher EnvPoint im Envelope existiert, der
  --   a) an der Zeit existiert und
  --   b) selektiert ist
  -- damit könnte ich eventuell es schaffen, die Info zurückzugeben, welcher Envelopepoint gerade beklickt wird.
  if TrackEnvelope==nil then
    reaper.BR_GetMouseCursorContext()
    TrackEnvelope = reaper.BR_GetMouseCursorContext_Envelope()
    ultraschall.EnvelopeClickState_OldTrackEnvelope=TrackEnvelope
  end
  
  if TakeEnvelope==nil then
    reaper.BR_GetMouseCursorContext()
    TakeEnvelope = reaper.BR_GetMouseCursorContext_Envelope()
    ultraschall.EnvelopeClickState_OldTakeEnvelope=TakeEnvelope
  end
  --[[
  
  
  
  reaper.BR_GetMouseCursorContext()
  local TrackEnvelope, TakeEnvelope = reaper.BR_GetMouseCursorContext_Envelope()
  
  if Track==nil then Track=ultraschall.EnvelopeClickState_OldTrack end
  if Track~=nil then ultraschall.EnvelopeClickState_OldTrack=Track end
  if TrackEnvelope~=nil then ultraschall.EnvelopeClickState_OldTrackEnvelope=TrackEnvelope end
  if TrackEnvelope==nil then TrackEnvelope=ultraschall.EnvelopeClickState_OldTrackEnvelope end
  if TakeEnvelope~=nil then ultraschall.EnvelopeClickState_OldTakeEnvelope=TakeEnvelope end
  if TakeEnvelope==nil then TakeEnvelope=ultraschall.EnvelopeClickState_OldTakeEnvelope end
  
  --]]
  --[[
  if TakeEnvelope==true or TrackEnvelope==nil then return false end
  local TimePosition=ultraschall.GetTimeByMouseXPosition(reaper.GetMousePosition())
  local EnvelopePoint=
  return true, TimePosition, Track, TrackEnvelope, EnvelopePoint
  --]]
  if TrackEnvelope==nil then TrackEnvelope=TakeEnvelope end
  return true, ultraschall.GetTimeByMouseXPosition(reaper.GetMousePosition()), Track, TrackEnvelope--, reaper.GetEnvelopePointByTime(TrackEnvelope, TimePosition)
end


function ultraschall.SetLiceCapExe(PathToLiceCapExecutable)
-- works on Mac too?
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetLiceCapExe</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.975
    SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetLiceCapExe(string PathToLiceCapExecutable)</functioncall>
  <description>
    Sets the path and filename of the LiceCap-executable

    Note: Doesn't work on Linux, as there isn't a Linux-port of LiceCap yet.
    
    Returns false in case of error.
  </description>
  <parameters>
    string SetLiceCapExe - the LiceCap-executable with path
  </parameters>
  <retvals>
    boolean retval - false in case of error; true in case of success
  </retvals>
  <chapter_context>
    API-Helper functions
    LiceCap
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, set, licecap, executable</tags>
</US_DocBloc>
]]  
  if type(PathToLiceCapExecutable)~="string" then ultraschall.AddErrorMessage("SetLiceCapExe", "PathToLiceCapExecutable", "Must be a string", -1) return false end
  if reaper.file_exists(PathToLiceCapExecutable)==false then ultraschall.AddErrorMessage("SetLiceCapExe", "PathToLiceCapExecutable", "file not found", -2) return false end
  local A,B=reaper.BR_Win32_WritePrivateProfileString("REAPER", "licecap_path", PathToLiceCapExecutable, reaper.get_ini_file())
  return A
end

--O=ultraschall.SetLiceCapExe("c:\\Program Files (x86)\\LICEcap\\LiceCap.exe")

function ultraschall.SetupLiceCap(output_filename, title, titlems, x, y, right, bottom, fps, gifloopcount, stopafter, prefs)
-- works on Mac too?
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetupLiceCap</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.975
    SWS=2.9.7
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetupLiceCap(string output_filename, string title, integer titlems, integer x, integer y, integer right, integer bottom, integer fps, integer gifloopcount, integer stopafter, integer prefs)</functioncall>
  <description>
    Sets up an installed LiceCap-instance.
    
    To choose the right LiceCap-version, run the action 41298 - Run LICEcap (animated screen capture utility)
    
    Note: Doesn't work on Linux, as there isn't a Linux-port of LiceCap yet.
    
    Returns false in case of error.
  </description>
  <parameters>
    string output_filename - the output-file; you can choose whether it shall be a gif or an lcf by giving it the accompanying extension "mylice.gif" or "milice.lcf"; nil, keep the current outputfile
    string title - the title, which shall be shown at the beginning of the licecap; newlines will be exchanged by spaces, as LiceCap doesn't really support newlines; nil, keep the current title
    integer titlems - how long shall the title be shown, in milliseconds; nil, keep the current setting
    integer x - the x-position of the LiceCap-window in pixels; nil, keep the current setting
    integer y - the y-position of the LiceCap-window in pixels; nil, keep the current setting
    integer right - the right side-position of the LiceCap-window in pixels; nil, keep the current setting
    integer bottom - the bottom-position of the LiceCap-window in pixels; nil, keep the current setting
    integer fps - the maximum frames per seconds, the LiceCap shall have; nil, keep the current setting
    integer gifloopcount - how often shall the gif be looped?; 0, infinite looping; nil, keep the current setting
    integer stopafter - stop recording after xxx milliseconds; nil, keep the current setting
    integer prefs - the preferences-settings of LiceCap, which is a bitfield; nil, keep the current settings
                  - &1 - display in animation: title frame - checkbox
                  - &2 - Big font - checkbox
                  - &4 - display in animation: mouse button press - checkbox
                  - &8 - display in animation: elapsed time - checkbox
                  - &16 - Ctrl+Alt+P pauses recording - checkbox
                  - &32 - Use .GIF transparency for smaller files - checkbox
                  - &64 - Automatically stop after xx seconds - checkbox           
  </parameters>
  <retvals>
    boolean retval - false in case of error; true in case of success
  </retvals>
  <chapter_context>
    API-Helper functions
    LiceCap
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>helper functions, licecap, setup</tags>
</US_DocBloc>
]]  
  if output_filename~=nil and type(output_filename)~="string" then ultraschall.AddErrorMessage("SetupLiceCap", "output_filename", "Must be a string", -2) return false end
  if title~=nil and type(title)~="string" then ultraschall.AddErrorMessage("SetupLiceCap", "title", "Must be a string", -3) return false end
  if titlems~=nil and math.type(titlems)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "titlems", "Must be an integer", -4) return false end
  if x~=nil and math.type(x)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "x", "Must be an integer", -5) return false end
  if y~=nil and math.type(y)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "y", "Must be an integer", -6) return false end
  if right~=nil and math.type(right)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "right", "Must be an integer", -7) return false end
  if bottom~=nil and math.type(bottom)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "bottom", "Must be an integer", -8) return false end
  if fps~=nil and math.type(fps)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "fps", "Must be an integer", -9) return false end
  if gifloopcount~=nil and math.type(gifloopcount)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "gifloopcount", "Must be an integer", -10) return false end
  if stopafter~=nil and math.type(stopafter)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "stopafter", "Must be an integer", -11) return false end
  if prefs~=nil and math.type(prefs)~="integer" then ultraschall.AddErrorMessage("SetupLiceCap", "prefs", "Must be an integer", -12) return false end
  
  local CC
  local A,B=reaper.BR_Win32_GetPrivateProfileString("REAPER", "licecap_path", -1, reaper.get_ini_file())
  if B=="-1" or reaper.file_exists(B)==false then ultraschall.AddErrorMessage("SetupLiceCap", "", "LiceCap not installed, please run action \"Run LICEcap (animated screen capture utility)\" to set up LiceCap", -1) return false end
  local Path, File=ultraschall.GetPath(B)
  if reaper.file_exists(Path.."/".."licecap.ini")==false then ultraschall.AddErrorMessage("SetupLiceCap", "", "Couldn't find licecap.ini in LiceCap-path. Is LiceCap really installed?", -13) return false end
  if output_filename~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "lastfn", output_filename, Path.."/".."licecap.ini") end
  if title~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "title", string.gsub(title,"\n"," "), Path.."/".."licecap.ini") end
  if titlems~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "titlems", titlems, Path.."/".."licecap.ini") end
  
  local retval, oldwnd_r=reaper.BR_Win32_GetPrivateProfileString("licecap", "wnd_r", -1, Path.."/".."licecap.ini")  
  if x==nil then x=oldwnd_r:match("(.-) ") end
  if y==nil then y=oldwnd_r:match(".- (.-) ") end
  if right==nil then right=oldwnd_r:match(".- .- (.-) ") end
  if bottom==nil then bottom=oldwnd_r:match(".- .- .- (.*)") end
  
  CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "wnd_r", x.." "..y.." "..right.." "..bottom, Path.."/".."licecap.ini")
  if fps~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "maxfps", fps, Path.."/".."licecap.ini") end
  if gifloopcount~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "gifloopcnt", gifloopcount, Path.."/".."licecap.ini") end
  if stopafter~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "stopafter", stopafter, Path.."/".."licecap.ini") end
  if prefs~=nil then CC=reaper.BR_Win32_WritePrivateProfileString("licecap", "prefs", prefs, Path.."/".."licecap.ini") end
  
  return true
end


function ultraschall.StartLiceCap(autorun)
-- doesn't work, as I can't click the run and save-buttons
-- maybe I need to add that to the LiceCap-codebase myself...somehow
  reaper.Main_OnCommand(41298, 0)  
  O=0
  while reaper.JS_Window_Find("LICEcap v", false)==nil do
    O=O+1
    if O==1000000 then break end
  end
  local HWND=reaper.JS_Window_Find("LICEcap v", false)
  reaper.JS_WindowMessage_Post(reaper.JS_Window_FindChildByID(HWND, 1001), "WM_LBUTTONDOWN", 1,0,0,0)
  reaper.JS_WindowMessage_Post(reaper.JS_Window_FindChildByID(HWND, 1001), "WM_LBUTTONUP", 1,0,0,0)

  HWNDA0=reaper.JS_Window_Find("Choose file for recording", false)

--[[    
  O=0
  while reaper.JS_Window_Find("Choose file for recording", false)==nil do
    O=O+1
    if O==100 then break end
  end

  HWNDA=reaper.JS_Window_Find("Choose file for recording", false)
  TIT=reaper.JS_Window_GetTitle(HWNDA)
  
  for i=-1000, 10000 do
    if reaper.JS_Window_FindChildByID(HWNDA, i)~=nil then
      print_alt(i, reaper.JS_Window_GetTitle(reaper.JS_Window_FindChildByID(HWNDA, i)))
    end
  end

  print(reaper.JS_Window_GetTitle(reaper.JS_Window_FindChildByID(HWNDA, 1)))

  for i=0, 100000 do
    AA=reaper.JS_WindowMessage_Post(reaper.JS_Window_FindChildByID(HWNDA, 1), "WM_LBUTTONDOWN", 1,0,0,0)
    BB=reaper.JS_WindowMessage_Post(reaper.JS_Window_FindChildByID(HWNDA, 1), "WM_LBUTTONUP", 1,0,0,0)
  end
  
  return HWND
  --]]
  
  ultraschall.WriteValueToFile(ultraschall.API_TempPath.."/LiceCapSave.lua", [[
    dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
    P=0
    
    function main3()
      LiceCapWinPreRoll=reaper.JS_Window_Find(" [stopped]", false)
      LiceCapWinPreRoll2=reaper.JS_Window_Find("LICEcap", false)
      
      if LiceCapWinPreRoll~=nil and LiceCapWinPreRoll2~=nil and LiceCapWinPreRoll2==LiceCapWinPreRoll then
        reaper.JS_Window_Destroy(LiceCapWinPreRoll)
        print("HuiTja", reaper.JS_Window_GetTitle(LiceCapWinPreRoll))
      else
        reaper.defer(main3)
      end
    end
    
    function main2()
      print("HUI:", P)
      A=reaper.JS_Window_Find("Choose file for recording", false)
      if A~=nil and P<20 then  
        P=P+1
        print_alt(reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(A, 1), "WM_LBUTTONDOWN", 1,1,1,1))
        print_alt(reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(A, 1), "WM_LBUTTONUP", 1,1,1,1))
        reaper.defer(main2)
      elseif P~=0 and A==nil then
        reaper.defer(main3)
      else
        reaper.defer(main2)
      end
    end
    
    
    main2()
    ]])
    local retval, script_identifier = ultraschall.Main_OnCommandByFilename(ultraschall.API_TempPath.."/LiceCapSave.lua")
end

--ultraschall.StartLiceCap(autorun)

--ultraschall.SetupLiceCap("Hula", "Hachgotterl\nahh", 20, 1, 2, 3, 4, 123, 1, 987, 64)
--ultraschall.SetupLiceCap("Hurtz.lcf")



function ultraschall.SaveProjectAs(filename_with_path, fileformat, overwrite, create_subdirectory, copy_all_media, copy_rather_than_move)
  -- TODO:  - if a file exists already, fileformats like edl and txt may lead to showing of a overwrite-prompt of the savedialog
  --                this is mostly due Reaper adding the accompanying extension to the filename
  --                must be treated somehow or the other formats must be removed
  --        - convert mediafiles into another format(possible at all?)
  --        - check on Linux and Mac
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SaveProjectAs</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.965
    SWS=2.10.0.1
    JS=0.963
    Lua=5.3
  </requires>
  <functioncall>boolean retval, string newfilename_with_path = ultraschall.SaveProjectAs(string filename_with_path, integer fileformat, boolean overwrite, boolean create_subdirectory, integer copy_all_media, boolean copy_rather_than_move)</functioncall>
  <description>
    Saves the current project under a new filename.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, saving was successful; false, saving wasn't successful
    string newfilename_with_path - the new projectfilename with path, helpful if you only gave the filename
  </retvals>
  <parameters>
    string filename_with_path - the new projectfile; omitting the path saves the project in the last used folder
    integer fileformat - the fileformat, in which you want to save the project
                       - 0, REAPER Project files (*.RPP)
                       - 1, EDL TXT (Vegas) files (*.TXT)
                       - 2, EDL (Samplitude) files (*.EDL)
    boolean overwrite - true, overwrites the projectfile, if it exists; false, keep an already existing projectfile
    boolean create_subdirectory - true, create a subdirectory for the project; false, save it into the given folder
    integer copy_all_media - shall the project's mediafiles be copied or moved or left as they are?
                           - 0, don't copy/move media
                           - 1, copy the project's mediafiles into projectdirectory
                           - 2, move the project's mediafiles into projectdirectory
    boolean copy_rather_than_move - true, copy rather than move source media if not in old project media path; false, leave the files as they are
  </parameters>
  <chapter_context>
    Project-Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>project management, save, project as, edl, rpp, vegas, samplitude</tags>
</US_DocBloc>
--]]
  -- check parameters
  local A=ultraschall.GetSaveProjectAsHWND()
  if A~=nil then ultraschall.AddErrorMessage("SaveProjectAs", "", "SaveAs-dialog already open", -1) return false end
  if type(filename_with_path)~="string" then ultraschall.AddErrorMessage("SaveProjectAs", "filename_with_path", "must be a string", -2) return false end
  local A,B=reaper.BR_Win32_GetPrivateProfileString("REAPER", "lastprojuiref", "", reaper.get_ini_file())
  local C,D=ultraschall.GetPath(B)
  local E,F=ultraschall.GetPath(filename_with_path)
  
  if E=="" then filename_with_path=C..filename_with_path end
  if E~="" and ultraschall.DirectoryExists2(E)==false then 
    reaper.RecursiveCreateDirectory(E,1)
    if ultraschall.DirectoryExists2(E)==false then 
      ultraschall.AddErrorMessage("SaveProjectAs", "filename_with_path", "invalid path", -3)
      return false
    end
  end
  if type(overwrite)~="boolean" then ultraschall.AddErrorMessage("SaveProjectAs", "overwrite", "must be a boolean", -4) return false end
  if type(create_subdirectory)~="boolean" then ultraschall.AddErrorMessage("SaveProjectAs", "create_subdirectory", "must be a boolean", -5) return false end
  if math.type(copy_all_media)~="integer" then ultraschall.AddErrorMessage("SaveProjectAs", "copy_all_media", "must be an integer", -6) return false end
  if type(copy_rather_than_move)~="boolean" then ultraschall.AddErrorMessage("SaveProjectAs", "copy_rather_than_move", "must be a boolean", -7) return false end
  if math.type(fileformat)~="integer" then ultraschall.AddErrorMessage("SaveProjectAs", "fileformat", "must be an integer", -8) return false end
  if fileformat<0 or fileformat>2 then ultraschall.AddErrorMessage("SaveProjectAs", "fileformat", "must be between 0 and 2", -9) return false end
  if copy_all_media<0 or copy_all_media>2 then ultraschall.AddErrorMessage("SaveProjectAs", "copy_all_media", "must be between 0 and 2", -10) return false end
  
  -- management of, if file already exists
  if overwrite==false and reaper.file_exists(filename_with_path)==true then ultraschall.AddErrorMessage("SaveProjectAs", "filename_with_path", "file already exists", -11) return false end
  if overwrite==true and reaper.file_exists(filename_with_path)==true then os.remove(filename_with_path) end

  
  -- create the background-script, which will manage the saveas-dialog and run it
      ultraschall.WriteValueToFile(ultraschall.API_TempPath.."/saveprojectas.lua", [[
      dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
      num_params, params, caller_script_identifier = ultraschall.GetScriptParameters()

      filename_with_path=params[1]
      fileformat=tonumber(params[2])
      create_subdirectory=toboolean(params[3])
      copy_all_media=params[4]
      copy_rather_than_move=toboolean(params[5])
      
      function main2()
        --if A~=nil then print2("Hooray") end
        translation=reaper.JS_Localize("Create subdirectory for project", "DLG_185")
        PP=reaper.JS_Window_Find("Create subdirectory", false)
        A2=reaper.JS_Window_GetParent(PP)
        ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1042), create_subdirectory)
        if copy_all_media==1 then 
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1043), true)
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1044), false)
        elseif copy_all_media==2 then 
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1043), false)
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1044), true)
        else
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1043), false)
          ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1044), false)
        end
        ultraschall.SetCheckboxState(reaper.JS_Window_FindChildByID(A2, 1045), copy_rather_than_move)
        A3=reaper.JS_Window_FindChildByID(A, 0)
        A3=reaper.JS_Window_FindChildByID(A3, 0)
        A3=reaper.JS_Window_FindChildByID(A3, 0)
        A3=reaper.JS_Window_FindChildByID(A3, 0)
        reaper.JS_Window_SetTitle(A3, filename_with_path)
        reaper.JS_WindowMessage_Send(A3, "WM_LBUTTONDOWN", 1,1,1,1)
        reaper.JS_WindowMessage_Send(A3, "WM_LBUTTONUP", 1,1,1,1)
        
        XX=reaper.JS_Window_FindChild(A, "REAPER Project files (*.RPP)", true)

        reaper.JS_WindowMessage_Send(XX, "WM_LBUTTONDOWN", 1,1,1,1)
        reaper.JS_WindowMessage_Send(XX, "WM_LBUTTONUP", 1,1,1,1)
        reaper.JS_WindowMessage_Send(XX, "CB_SETCURSEL", fileformat,0,0,0)
        reaper.JS_WindowMessage_Send(XX, "WM_LBUTTONDOWN", 1,1,1,1)
        reaper.JS_WindowMessage_Send(XX, "WM_LBUTTONUP", 1,1,1,1)
        
        reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(A, 1), "WM_LBUTTONDOWN", 1,1,1,1)
        reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(A, 1), "WM_LBUTTONUP", 1,1,1,1)
      end

      function main1()
        A=ultraschall.GetSaveProjectAsHWND()
        if A==nil then reaper.defer(main1) else main2() end
      end
      
      --print("alive")
      
      main1()
      ]])
      local retval, script_identifier = ultraschall.Main_OnCommandByFilename(ultraschall.API_TempPath.."/saveprojectas.lua", filename_with_path, fileformat, create_subdirectory, copy_all_media, copy_rather_than_move)
    
  -- open SaveAs-dialog
  reaper.Main_SaveProject(0, true)
  -- remove background-script
  os.remove(ultraschall.API_TempPath.."/saveprojectas.lua")
  return true, filename_with_path
end

--reaper.Main_SaveProject(0, true)
--ultraschall.SaveProjectAs("Fix it all of that HUUUIII", true, 0, true)


function ultraschall.TransientDetection_Set(Sensitivity, Threshold, ZeroCrossings)
  -- needs to take care of faulty parametervalues AND of correct value-entering into an already opened
  -- 41208 - Transient detection sensitivity/threshold: Adjust... - dialog
  reaper.SNM_SetDoubleConfigVar("transientsensitivity", Sensitivity) -- 0.0 to 1.0
  reaper.SNM_SetDoubleConfigVar("transientthreshold", Threshold) -- -60 to 0
  local val=reaper.SNM_GetIntConfigVar("tabtotransflag", -999)
  if val&2==2 and ZeroCrossings==false then
    reaper.SNM_SetIntConfigVar("tabtotransflag", val-2)
  elseif val&2==0 and ZeroCrossings==true then
    reaper.SNM_SetIntConfigVar("tabtotransflag", val+2)
  end
end

--ultraschall.TransientDetection_Set(0.1, -9, false)



function ultraschall.ReadSubtitles_VTT(filename_with_path)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ReadSubtitles_VTT</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.965
    Lua=5.3
  </requires>
  <functioncall>string Kind, string Language, integer Captions_Counter, table Captions = ultraschall.ReadSubtitles_VTT(string filename_with_path)</functioncall>
  <description>
    parses a webvtt-subtitle-file and returns its contents as table
    
    returns nil in case of an error
  </description>
  <retvals>
    string Kind - the type of the webvtt-file, like: captions
    string Language - the language of the webvtt-file
    integer Captions_Counter - the number of captions in the file
    table Captions - the Captions as a table of the format:
                   -    Captions[index]["start"]= the starttime of this caption in seconds
                   -    Captions[index]["end"]= the endtime of this caption in seconds
                   -    Captions[index]["caption"]= the caption itself
  </retvals>
  <parameters>
    string filename_with_path - the filename with path of the webvtt-file
  </parameters>
  <chapter_context>
    File Management
    Read Files
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>ultraschall_functions_engine.lua</source_document>
  <tags>filemanagement, read, file, webvtt, subtitle, import</tags>
</US_DocBloc>
--]]
  if type(filename_with_path)~="string" then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "must be a string", -1) return end
  if reaper.file_exists(filename_with_path)=="false" then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "must be a string", -2) return end
  local A, Type, Offset, Kind, Language, Subs, Subs_Counter, i
  Subs={}
  Subs_Counter=0
  A=ultraschall.ReadFullFile(filename_with_path)
  Type, Offset=A:match("(.-)\n()")
  if Type~="WEBVTT" then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "not a webvtt-file", -3) return end
  A=A:sub(Offset,-1)
  Kind, Offset=A:match(".-: (.-)\n()")
  A=A:sub(Offset,-1)
  Language, Offset=A:match(".-: (.-)\n()")
  A=A:sub(Offset,-1)
  
  i=0
  for k in string.gmatch(A, "(.-)\n") do
    i=i+1
    if i==2 then 
      Subs_Counter=Subs_Counter+1
      Subs[Subs_Counter]={} 
      Subs[Subs_Counter]["start"], Subs[Subs_Counter]["end"] = k:match("(.-) --> (.*)")
      if Subs[Subs_Counter]["start"]==nil or Subs[Subs_Counter]["end"]==nil then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "can't parse the file; probably invalid", -3) return end
      Subs[Subs_Counter]["start"]=reaper.parse_timestr(Subs[Subs_Counter]["start"])
      Subs[Subs_Counter]["end"]=reaper.parse_timestr(Subs[Subs_Counter]["end"])
    elseif i==3 then 
      Subs[Subs_Counter]["caption"]=k
      if Subs[Subs_Counter]["caption"]==nil then ultraschall.AddErrorMessage("ReadSubtitles_VTT", "filename_with_path", "can't parse the file; probably invalid", -4) return end
    end
    if i==3 then i=0 end
  end
  
  
  return Kind, Language, Subs_Counter, Subs
end


--A,B,C,D,E=ultraschall.ReadSubtitles_VTT("c:\\test.vtt")

function ultraschall.BatchConvertFiles(filelist, RenderTable, BWFStart, PadStart, PadEnd, FXChain)
-- Todo:
-- Check on Mac and Linux
--    Linux saves outfile into wrong directory -> lastcwd not OUTPATH for some reason
-- Check all parameters for correct typings
-- Test FXChain-capability
  local BatchConvertData=""
  --local ExeFile, filename, path
  if FXChain==nil then FXChain="" end
  if BWFStart==true then BWFStart="    USERCSTART 1\n" else BWFStart="" end
  if PadStart~=nil  then PadStart="    PAD_START "..PadStart.."\n" else PadStart="" end
  if PadEnd~=nil  then PadEnd="    PAD_END "..PadEnd.."\n" else PadEnd="" end
  local i=1
  while filelist[i]~=nil do
    path, filename = ultraschall.GetPath(filelist[i])
    filename2=filename:match("(.-)%.")
    if filename2==nil then filename2=filename end
    BatchConvertData=BatchConvertData..filelist[i].."\t"..filelist[i]:match("(.*)%.").."\n"
    i=i+1
  end
  BatchConvertData=BatchConvertData..[[
<CONFIG
]]..FXChain..[[
  <OUTFMT 
    ]]      ..RenderTable["RenderString"]..[[
    
    SRATE ]]..RenderTable["SampleRate"]..[[
    
    NCH ]]..RenderTable["Channels"]..[[
    
    RSMODE ]]..RenderTable["RenderResample"]..[[
    
    DITHER ]]..RenderTable["Dither"]..[[
    
]]..BWFStart..[[
]]..PadStart..[[
]]..PadEnd..[[
    OUTPATH ]]..RenderTable["RenderFile"]..[[
    
    OUTPATTERN ']]..[['
  >
>
]]

  ultraschall.WriteValueToFile(ultraschall.API_TempPath.."/filelist.txt", BatchConvertData)
print3(BatchConvertData)
  if ultraschall.IsOS_Windows()==true then
    ExeFile=reaper.GetExePath().."\\reaper.exe"
    AAAA, AAAAAA=reaper.ExecProcess(ExeFile.." -batchconvert "..string.gsub(ultraschall.API_TempPath, "/", "\\").."\\filelist.txt", -1)
    print3(ExeFile.." -batchconvert "..string.gsub(ultraschall.API_TempPath, "/", "\\").."\\filelist.txt")

  elseif ultraschall.IsOS_Mac()==true then
    print2("Must be checked on Mac!!!!")
    ExeFile=reaper.GetExePath().."\\reaper"
    AAAA, AAAAAA=reaper.ExecProcess(ExeFile.." -batchconvert "..string.gsub(ultraschall.API_TempPath, "\\\\", "/").."/filelist.txt", -1)
  else
    print2("Must be checked on Linux!!!!")
    ExeFile=reaper.GetExePath().."/reaper"
--print3(ExeFile.." -batchconvert "..string.gsub(ultraschall.API_TempPath, "\\\\", "/").."/filelist.txt")
    AAAA, AAAAAA=reaper.ExecProcess(ExeFile.." -batchconvert "..string.gsub(ultraschall.API_TempPath, "\\\\", "/").."/filelist.txt", -1)
  end
end


-- These seem to work working:

function ultraschall.ResizeJPG(filename_with_path, outputfilename_with_path, aspectratio, width, height, quality)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ResizeJPG</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    JS=1.215
    Lua=5.3
  </requires>
  <functioncall>integer count = ultraschall.ResizeJPG(string filename_with_path, string outputfilename_with_path, boolean aspectratio, integer width, integer height, integer quality)</functioncall>
  <description>
    resizes a jpg-file. It will stretch/shrink the picture by that. That means you can't crop or enhance jpgs with this function.
    
    If you set aspectratio=true, then the image will be resized with correct aspect-ratio. However, it will use the value from parameter width as maximum size for each side of the picture.
    So if the height of the jpgis bigger than the width, the height will get the size and width will be shrinked accordingly.
    
    When making jpg bigger, pixelation will occur. No pixel-filtering within this function!
    
    returns false in case of an error 
  </description>
  <parameters>
    string filename_with_path - the jpg-file, that you want to resize
    string outputfilename_with_path - the output-file, where to store the resized jpg
    boolean aspectratio - true, keep aspect-ratio(use size of param width as base); false, don't keep aspect-ratio
    integer width - the width of the newly created png in pixels
    integer height - the height of the newly created png in pixels
    integer quality - the quality of the jpg in percent; 1 to 100
  </parameters>
  <retvals>
    boolean retval - true, resizing was successful; false, resizing was unsuccessful
  </retvals>
  <chapter_context>
    Image File Handling
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Imagefile_Module.lua</source_document>
  <tags>image file handling, resize, jpg, image, graphics</tags>
</US_DocBloc>
]]
  if type(filename_with_path)~="string" then ultraschall.AddErrorMessage("ResizeJPG", "filename_with_path", "must be a string", -1) return false end
  if type(outputfilename_with_path)~="string" then ultraschall.AddErrorMessage("ResizeJPG", "outputfilename_with_path", "must be a string", -2) return false end
  if reaper.file_exists(filename_with_path)==false then ultraschall.AddErrorMessage("ResizeJPG", "filename_with_path", "file can not be opened", -3) return false end
  if type(aspectratio)~="boolean" then ultraschall.AddErrorMessage("ResizeJPG", "aspectratio", "must be a boolean", -4) return false end
  if math.type(width)~="integer" then ultraschall.AddErrorMessage("ResizeJPG", "width", "must be an integer", -5) return false end
  if aspectratio==false and math.type(height)~="integer" then ultraschall.AddErrorMessage("ResizeJPG", "height", "must be an integer, when aspectratio==false", -6) return false end
  if math.type(quality)~="integer" then ultraschall.AddErrorMessage("ResizeJPG", "quality", "must be an integer", -7) return false end
  if quality<1 or quality>100 then ultraschall.AddErrorMessage("ResizeJPG", "quality", "must be between 1 and 100", -8) return false end
  
  local Identifier, Identifier2, squaresize, NewWidth, NewHeight, Height, Width, Retval
  Identifier=reaper.JS_LICE_LoadJPG(filename_with_path)
  Width=reaper.JS_LICE_GetWidth(Identifier)
  Height=reaper.JS_LICE_GetHeight(Identifier)
  if aspectratio==true then
    squaresize=width
    if Width>Height then 
      NewWidth=squaresize
      NewHeight=((100/Width)*Height)
      NewHeight=NewHeight/100
      NewHeight=math.floor(squaresize*NewHeight)
    else
      NewHeight=squaresize
      NewWidth=((100/Height)*Width)
      NewWidth=NewWidth/100
      NewWidth=math.floor(squaresize*NewWidth)
    end
  else
    NewHeight=height
    NewWidth=width
  end
  
  Identifier2=reaper.JS_LICE_CreateBitmap(true, NewWidth, NewHeight)
  reaper.JS_LICE_ScaledBlit(Identifier2, 0, 0, NewWidth, NewHeight, Identifier, 0, 0, Width, Height, 1, "COPY")
  Retval=reaper.JS_LICE_WriteJPG(outputfilename_with_path, Identifier2, quality)
  reaper.JS_LICE_DestroyBitmap(Identifier)
  reaper.JS_LICE_DestroyBitmap(Identifier2)
  if Retval==false then ultraschall.AddErrorMessage("ResizeJPG", "outputfilename_with_path", "Can't write outputfile", -9) return false end
end

function ultraschall.ProjectSettings_GetVideoFramerate()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ProjectSettings_GetVideoFramerate</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>integer framerate, string addnotes = ultraschall.ProjectSettings_GetVideoFramerate()</functioncall>
  <description>
    returns the video-framerate of the current project
  </description>
  <retvals>
    integer framerate - the framerate in fps from 1 to 999999999
    string addnotes - either "DF", "ND" or ""
  </retvals>
  <chapter_context>
    Project Settings
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_video_engine.lua</source_document>
  <tags>project settings, get, framerate</tags>
</US_DocBloc>
]]
  local framerate=reaper.SNM_GetIntConfigVar("projfrbase", -999)
  local subframerate=reaper.SNM_GetIntConfigVar("projfrdrop", -999)
  if     subframerate==1 then return 29.97, "DF"
  elseif subframerate==2 then return 23.976, ""
  elseif subframerate==2 then return 29.97, "ND"
  else return framerate, ""
  end
end

function ultraschall.ProjectSettings_SetVideoFramerate(framerate, persist)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ProjectSettings_SetVideoFramerate</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    SWS=2.10.0.1
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ProjectSettings_SetVideoFramerate(integer framerate, boolean persist)</functioncall>
  <description>
    sets the video-framerate of the current project and optionally the default video-framerate for new projects
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <parameters>
    integer framerate - the framerate in fps from 1 to 999999999;
                      - 0, 29.97 fps DF
                      - -1, 23.976 fp
                      - -2, 29.97 fps ND
    boolean persist - true, set these values as default for new projects; false, don't set these values as defaults for 
  </parameters>
  <chapter_context>
    Project Settings
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_video_engine.lua</source_document>
  <tags>project settings, set, framerate, default projects</tags>
</US_DocBloc>
]]
  if math.type(framerate)~="integer" then ultraschall.AddErrorMessage("ProjectSettings_SetVideoFramerate", "framerate", "must be an integer", -1) return false end
  if framerate<-2 or framerate>999999999 then ultraschall.AddErrorMessage("ProjectSettings_SetVideoFramerate", "framerate", "must be between -2 and 999999999", -2) return false end
  if type(persist)~="boolean" then ultraschall.AddErrorMessage("ProjectSettings_SetVideoFramerate", "persist", "must be a boolean", -3) return false end
  if     framerate==0  then framerate=30 subframerate=1 -- 29.97 fps DF
  elseif framerate==-1 then framerate=24 subframerate=2 -- 23.976 fps 
  elseif framerate==-2 then framerate=30 subframerate=2 -- 29.97 fps ND
  else subframerate=0
  end
  reaper.SNM_SetIntConfigVar("projfrbase", framerate)
  reaper.SNM_SetIntConfigVar("projfrdrop", subframerate)  
  if persist==true then
    reaper.BR_Win32_WritePrivateProfileString("REAPER", "projfrbase", framerate, reaper.get_ini_file())
    reaper.BR_Win32_WritePrivateProfileString("REAPER", "projfrdrop", subframerate, reaper.get_ini_file())
  end
  return true
end

--A=ultraschall.ProjectSettings_SetVideoFramerate(11, true)

function ultraschall.ApplyAllThemeLayoutParameters(ThemeLayoutParameters, persist, refresh)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ApplyAllThemeLayoutParameters</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ApplyAllThemeLayoutParameters(table ThemeLayoutParameters, boolean persist, boolean refresh)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    allows applying all theme-layout-parameter-values from a ThemeLayoutParameters-table, as gettable by [GetAllThemeLayoutParameters](#GetAllThemeLayoutParameters)
    
    the table ThemeLayoutParameters is of the following format:

    ThemeLayoutParameters[parameter_index]["name"] - the name of the parameter
    ThemeLayoutParameters[parameter_index]["description"] - the description of the parameter
    ThemeLayoutParameters[parameter_index]["value"] - the value of the parameter
    ThemeLayoutParameters[parameter_index]["value default"] - the defult value of the parameter
    ThemeLayoutParameters[parameter_index]["value min"] - the minimum value of the parameter
    ThemeLayoutParameters[parameter_index]["value max"] - the maximum value of the parameter
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <parameters>
    table ThemeLayoutParameters - a table, which holds all theme-layout-parameter-values to apply; set values to nil to use default-value
    boolean persist - true, the new values shall be persisting; false, values will not be persisting and lost after theme-change/Reaper restart
    boolean refresh - true, refresh the theme to show the applied changes; false, don't refresh
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, apply, all, parameters</tags>
</US_DocBloc>
]]
  if type(ThemeLayoutParameters)~="table" then ultraschall.AddErrorMessage("ApplyAllThemeLayoutParameters", "ThemeLayoutParameters", "must be a ThemeLayoutParameters-table, as created by GetAllThemeLayoutParameters", -1) return false end
  if type(persist)~="boolean" then ultraschall.AddErrorMessage("ApplyAllThemeLayoutParameters", "persist", "must be a boolean", -2) return false end
  if type(refresh)~="boolean" then ultraschall.AddErrorMessage("ApplyAllThemeLayoutParameters", "refresh", "must be a boolean", -3) return false end
  for i=1, #ThemeLayoutParameters do
    if ThemeLayoutParameters[i]["value"]~=nil then
      if ThemeLayoutParameters[i]["value"]>ThemeLayoutParameters[i]["value max"] or ThemeLayoutParameters[i]["value"]<ThemeLayoutParameters[i]["value min"] then
        ultraschall.AddErrorMessage("ApplyAllThemeLayoutParameters", "ThemeLayoutParameters", "entry: "..i.." \""..ThemeLayoutParameters[i]["name"].."\" - isnt within the allowed valuerange of this parameter("..ThemeLayoutParameters[i]["value min"].." - "..ThemeLayoutParameters[i]["value max"]..")", -7)
        return false
      end
    end
  end
  for i=1, #ThemeLayoutParameters do
    local val=ThemeLayoutParameters[i]["value"]
    if val==nil then val=ThemeLayoutParameters[i]["value default"] end
    reaper.ThemeLayout_SetParameter(i, val, persist)
  end  
  if refresh==true then
    reaper.ThemeLayout_RefreshAll()
  end
  return true
end

function ultraschall.ActivateEnvelope(Envelope, visible, bypass)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>ActivateEnvelope</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.981
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.ActivateEnvelope(TrackEnvelope env, optional boolean visible, optional boolean bypass)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Activates an envelope, so it can be displayed in the arrange-view.
    
    Will add an envelope-point at position 0 in the envelope, if no point is in the envelope yet
    
    returns false in case of an error
  </description>
  <retvals>
   boolean retval - true, activating was successful; false, activating was unsuccessful
  </retvals>
  <parameters>
   TrackEnvelope Envelope - the envelope, which you want to activate
   optional boolean visible - true or nil, show envelope; false, don't show envelope
   optional boolean bypass  - true or nil, don't bypass envelope; false, bypass envelope
  </parameters>
  <chapter_context>
    Envelope Management
    Helper functions
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
  <tags>envelope management, activate, envelope</tags>
</US_DocBloc>
--]]
  -- Meo-Ada Mespotine
  -- activates an envelope
  -- thanks to Sexan for giving the hint to make this work
  --
  -- parameters:
  --    TrackEnvelope Envelope - the envelope, which you want to activate
  --    optional boolean visible - true or nil, show envelope; false, don't show envelope
  --    optional boolean bypass  - true or nil, don't bypass envelope; false, bypass envelope
  if ultraschall.type(Envelope)~="TrackEnvelope" then ultraschall.AddErrorMessage("ActivateEnvelope", "Envelope", "must be a trackenvelope-object", -1) return false end
  if visible~=nil and ultraschall.type(visible)~="boolean" then ultraschall.AddErrorMessage("ActivateEnvelope", "visible", "must be either nil or a boolean", -2) return false end
  if bypass~=nil and ultraschall.type(bypass)~="boolean" then ultraschall.AddErrorMessage("ActivateEnvelope", "bypass", "must be either nil or a boolean", -3) return false end
  local _, EnvelopeStateChunk = reaper.GetEnvelopeStateChunk(send_env_vol, "", false)
  if EnvelopeStateChunk:match("PT ")==nil then
   EnvelopeStateChunk = EnvelopeStateChunk:match("(.*)>").."PT 0 1 0\n>"
  end
  if bypass~=false then
    EnvelopeStateChunk = string.gsub(EnvelopeStateChunk, "ACT . ", "ACT 1 ")
  end
  if visible~=false then
    EnvelopeStateChunk = string.gsub(EnvelopeStateChunk, "VIS . ", "VIS 1 ")
  end
  return reaper.SetEnvelopeStateChunk(Envelope, EnvelopeStateChunk, false)
end

function ultraschall.ActivateTrackVolumeEnv(track)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>ActivateTrackVolumeEnv</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.ActivateTrackVolumeEnv(integer track)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      activates a volume-envelope of a track
        
      returns false in case of error
    </description>
    <retvals>
      boolean retval - true, activating was successful; false, activating was unsuccessful
    </retvals>
    <parameters>
      integer track - the track, whose volume-envelope you want to activate; 1, for the first track
    </parameters>
    <chapter_context>
      Envelope Management
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
    <tags>envelope management, volume, activate</tags>
  </US_DocBloc>
  --]]
  if math.type(track)~="integer" then ultraschall.AddErrorMessage("ActivateTrackVolumeEnv", "track", "must be an integer", -1) return false end
  if track<1 or track>reaper.CountTracks(0) then ultraschall.AddErrorMessage("ActivateTrackVolumeEnv", "track", "no such track", -2) return false end
  local env=reaper.GetTrackEnvelopeByName(reaper.GetTrack(0,track-1), "Volume")
  local retval
  ultraschall.PreventUIRefresh()
  if env==nil then
    retval = ultraschall.ApplyActionToTrack(tostring(track), 40406)
  else 
    retval=false ultraschall.AddErrorMessage("ActivateTrackVolumeEnv", "", "already activated", -3)
  end
  ultraschall.RestoreUIRefresh()
  return retval
end

--ultraschall.ActivateTrackVolumeEnv(1)

function ultraschall.ActivateTrackVolumeEnv_TrackObject(track)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>ActivateTrackVolumeEnv_TrackObject</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.ActivateTrackVolumeEnv_TrackObject(MediaTrack track)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      activates a volume-envelope of a MediaTrack-object
        
      returns false in case of error
    </description>
    <retvals>
      boolean retval - true, activating was successful; false, activating was unsuccessful
    </retvals>
    <parameters>
      MediaTrack track - the track, whose volume-envelope you want to activate
    </parameters>
    <chapter_context>
      Envelope Management
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
    <tags>envelope management, volume, activate</tags>
  </US_DocBloc>
  --]]
  if ultraschall.type(track)~="MediaTrack" then ultraschall.AddErrorMessage("ActivateTrackVolumeEnv_TrackObject", "track", "must be a MediaTrack", -1) return false end
  local env=reaper.GetTrackEnvelopeByName(track, "Volume")
  local retval
  if env==nil then
    ultraschall.PreventUIRefresh()
    local tracknumber=reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    retval = ultraschall.ApplyActionToTrack(tostring(tracknumber), 40406)
    ultraschall.RestoreUIRefresh()
  else 
    retval=false ultraschall.AddErrorMessage("ActivateTrackVolumeEnv_TrackObject", "", "already activated", -3)
  end
  return retval
end

function ultraschall.ActivateTrackPanEnv(track)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>ActivateTrackPanEnv</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.ActivateTrackPanEnv(integer track)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      activates a pan-envelope of a track
        
      returns false in case of error
    </description>
    <retvals>
      boolean retval - true, activating was successful; false, activating was unsuccessful
    </retvals>
    <parameters>
      integer track - the track, whose pan-envelope you want to activate; 1, for the first track
    </parameters>
    <chapter_context>
      Envelope Management
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
    <tags>envelope management, pan, activate</tags>
  </US_DocBloc>
  --]]
  if math.type(track)~="integer" then ultraschall.AddErrorMessage("ActivateTrackPanEnv", "track", "must be an integer", -1) return false end
  if track<1 or track>reaper.CountTracks(0) then ultraschall.AddErrorMessage("ActivateTrackPanEnv", "track", "no such track", -2) return false end
  local env=reaper.GetTrackEnvelopeByName(reaper.GetTrack(0,track-1), "Pan")
  local retval
  ultraschall.PreventUIRefresh()
  if env==nil then
    retval = ultraschall.ApplyActionToTrack(tostring(track), 40407)
  else 
    retval=false ultraschall.AddErrorMessage("ActivateTrackPanEnv", "", "already activated", -3)
  end
  ultraschall.RestoreUIRefresh()
  return retval
end

--ultraschall.ActivateTrackPanEnv(1)

function ultraschall.ActivateTrackPanEnv_TrackObject(track)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>ActivateTrackPanEnv_TrackObject</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.ActivateTrackPanEnv_TrackObject(MediaTrack track)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      activates a pan-envelope of a MediaTrack-object
        
      returns false in case of error
    </description>
    <retvals>
      boolean retval - true, activating was successful; false, activating was unsuccessful
    </retvals>
    <parameters>
      MediaTrack track - the track, whose pan-envelope you want to activate
    </parameters>
    <chapter_context>
      Envelope Management
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
    <tags>envelope management, pan, activate</tags>
  </US_DocBloc>
  --]]
  if ultraschall.type(track)~="MediaTrack" then ultraschall.AddErrorMessage("ActivateTrackPanEnv_TrackObject", "track", "must be a MediaTrack", -1) return false end
  local env=reaper.GetTrackEnvelopeByName(track, "Pan")
  local retval
  if env==nil then
    ultraschall.PreventUIRefresh()
    local tracknumber=reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    retval = ultraschall.ApplyActionToTrack(tostring(tracknumber), 40407)
    ultraschall.RestoreUIRefresh()
  else 
    retval=false ultraschall.AddErrorMessage("ActivateTrackPanEnv_TrackObject", "", "already activated", -3)
  end
  return retval
end

function ultraschall.ActivateTrackPreFXPanEnv(track)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>ActivateTrackPreFXPanEnv</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.ActivateTrackPreFXPanEnv(integer track)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      activates a preFX-pan-envelope of a track
        
      returns false in case of error
    </description>
    <retvals>
      boolean retval - true, activating was successful; false, activating was unsuccessful
    </retvals>
    <parameters>
      integer track - the track, whose preFX-pan-envelope you want to activate; 1, for the first track
    </parameters>
    <chapter_context>
      Envelope Management
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
    <tags>envelope management, prefx-pan, activate</tags>
  </US_DocBloc>
  --]]
  if math.type(track)~="integer" then ultraschall.AddErrorMessage("ActivateTrackPreFXPanEnv", "track", "must be an integer", -1) return false end
  if track<1 or track>reaper.CountTracks(0) then ultraschall.AddErrorMessage("ActivateTrackPreFXPanEnv", "track", "no such track", -2) return false end
  local env=reaper.GetTrackEnvelopeByName(reaper.GetTrack(0,track-1), "Pan (Pre-FX)")
  local retval
  ultraschall.PreventUIRefresh()
  if env==nil then
    retval = ultraschall.ApplyActionToTrack(tostring(track), 40409)
  else 
    retval=false ultraschall.AddErrorMessage("ActivateTrackPreFXPanEnv", "", "already activated", -3)
  end
  ultraschall.RestoreUIRefresh()
  return retval
end

--ultraschall.ActivateTrackPreFXPanEnv(1)

function ultraschall.ActivateTrackPreFXPanEnv_TrackObject(track)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>ActivateTrackPreFXPanEnv_TrackObject</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.ActivateTrackPreFXPanEnv_TrackObject(MediaTrack track)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      activates a preFX-pan-envelope of a MediaTrack-object
        
      returns false in case of error
    </description>
    <retvals>
      boolean retval - true, activating was successful; false, activating was unsuccessful
    </retvals>
    <parameters>
      MediaTrack track - the track, whose prefx-pan-envelope you want to activate
    </parameters>
    <chapter_context>
      Envelope Management
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
    <tags>envelope management, prefx-pan, activate</tags>
  </US_DocBloc>
  --]]
  if ultraschall.type(track)~="MediaTrack" then ultraschall.AddErrorMessage("ActivateTrackPreFXPanEnv_TrackObject", "track", "must be a MediaTrack", -1) return false end
  local env=reaper.GetTrackEnvelopeByName(track, "Pan (Pre-FX)")
  local retval
  if env==nil then
    ultraschall.PreventUIRefresh()
    local tracknumber=reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    retval = ultraschall.ApplyActionToTrack(tostring(tracknumber), 40409)
    ultraschall.RestoreUIRefresh()
  else 
    retval=false ultraschall.AddErrorMessage("ActivateTrackPreFXPanEnv_TrackObject", "", "already activated", -3)
  end
  return retval
end

function ultraschall.ActivateTrackPreFXVolumeEnv(track)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>ActivateTrackPreFXVolumeEnv</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.ActivateTrackPreFXVolumeEnv(integer track)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      activates a preFX-volume-envelope of a track
        
      returns false in case of error
    </description>
    <retvals>
      boolean retval - true, activating was successful; false, activating was unsuccessful
    </retvals>
    <parameters>
      integer track - the track, whose preFX-volume-envelope you want to activate; 1, for the first track
    </parameters>
    <chapter_context>
      Envelope Management
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
    <tags>envelope management, prefx-volume, activate</tags>
  </US_DocBloc>
  --]]
  if math.type(track)~="integer" then ultraschall.AddErrorMessage("ActivateTrackPreFXVolumeEnv", "track", "must be an integer", -1) return false end
  if track<1 or track>reaper.CountTracks(0) then ultraschall.AddErrorMessage("ActivateTrackPreFXVolumeEnv", "track", "no such track", -2) return false end
  local env=reaper.GetTrackEnvelopeByName(reaper.GetTrack(0,track-1), "Volume (Pre-FX)")
  local retval
  ultraschall.PreventUIRefresh()
  if env==nil then
    retval = ultraschall.ApplyActionToTrack(tostring(track), 40408)
  else 
    retval=false ultraschall.AddErrorMessage("ActivateTrackPreFXVolumeEnv", "", "already activated", -3)
  end
  ultraschall.RestoreUIRefresh()
  return retval
end

--ultraschall.ActivateTrackPreFXVolumeEnv(1)

function ultraschall.ActivateTrackPreFXVolumeEnv_TrackObject(track)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>ActivateTrackPreFXVolumeEnv_TrackObject</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.ActivateTrackPreFXVolumeEnv_TrackObject(MediaTrack track)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      activates a preFX-volume-envelope of a MediaTrack-object
        
      returns false in case of error
    </description>
    <retvals>
      boolean retval - true, activating was successful; false, activating was unsuccessful
    </retvals>
    <parameters>
      MediaTrack track - the track, whose prefx-volume-envelope you want to activate
    </parameters>
    <chapter_context>
      Envelope Management
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
    <tags>envelope management, prefx-volume, activate</tags>
  </US_DocBloc>
  --]]
  if ultraschall.type(track)~="MediaTrack" then ultraschall.AddErrorMessage("ActivateTrackPreFXVolumeEnv_TrackObject", "track", "must be a MediaTrack", -1) return false end
  local env=reaper.GetTrackEnvelopeByName(track, "Volume (Pre-FX)")
  local retval
  if env==nil then
    ultraschall.PreventUIRefresh()
    local tracknumber=reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    retval = ultraschall.ApplyActionToTrack(tostring(tracknumber), 40408)
    ultraschall.RestoreUIRefresh()
  else 
    retval=false ultraschall.AddErrorMessage("ActivateTrackPreFXVolumeEnv_TrackObject", "", "already activated", -3)
  end
  return retval
end

function ultraschall.ActivateTrackTrimVolumeEnv(track)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>ActivateTrackTrimVolumeEnv</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.ActivateTrackTrimVolumeEnv(integer track)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      activates a trim-volume-envelope of a track
        
      returns false in case of error
    </description>
    <retvals>
      boolean retval - true, activating was successful; false, activating was unsuccessful
    </retvals>
    <parameters>
      integer track - the track, whose trim-volume-envelope you want to activate; 1, for the first track
    </parameters>
    <chapter_context>
      Envelope Management
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
    <tags>envelope management, trim-volume, activate</tags>
  </US_DocBloc>
  --]]
  if math.type(track)~="integer" then ultraschall.AddErrorMessage("ActivateTrackTrimVolumeEnv", "track", "must be an integer", -1) return false end
  if track<1 or track>reaper.CountTracks(0) then ultraschall.AddErrorMessage("ActivateTrackTrimVolumeEnv", "track", "no such track", -2) return false end
  local env=reaper.GetTrackEnvelopeByName(reaper.GetTrack(0,track-1), "Trim Volume")
  local retval
  ultraschall.PreventUIRefresh()
  if env==nil then
    retval = ultraschall.ApplyActionToTrack(tostring(track), 42020)
  else 
    retval=false ultraschall.AddErrorMessage("ActivateTrackTrimVolumeEnv", "", "already activated", -3)
  end
  ultraschall.RestoreUIRefresh()
  return retval
end

--ultraschall.ActivateTrackTrimVolumeEnv(3)

function ultraschall.ActivateTrackTrimVolumeEnv_TrackObject(track)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>ActivateTrackTrimVolumeEnv_TrackObject</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>boolean retval = ultraschall.ActivateTrackTrimVolumeEnv_TrackObject(MediaTrack track)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      activates a trim-volume-envelope of a MediaTrack-object
        
      returns false in case of error
    </description>
    <retvals>
      boolean retval - true, activating was successful; false, activating was unsuccessful
    </retvals>
    <parameters>
      MediaTrack track - the track, whose trim-volume-envelope you want to activate
    </parameters>
    <chapter_context>
      Envelope Management
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
    <tags>envelope management, trim-volume, activate</tags>
  </US_DocBloc>
  --]]
  if ultraschall.type(track)~="MediaTrack" then ultraschall.AddErrorMessage("ActivateTrackTrimVolumeEnv_TrackObject", "track", "must be a MediaTrack", -1) return false end
  local env=reaper.GetTrackEnvelopeByName(track, "Trim Volume")
  local retval
  if env==nil then
    ultraschall.PreventUIRefresh()
    local tracknumber=reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    retval = ultraschall.ApplyActionToTrack(tostring(tracknumber), 42020)
    ultraschall.RestoreUIRefresh()
  else 
    retval=false ultraschall.AddErrorMessage("ActivateTrackTrimVolumeEnv_TrackObject", "", "already activated", -3)
  end
  return retval
end

function ultraschall.GetAllVisibleTracks_Arrange(master_track, completely_visible)
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>GetAllVisibleTracks_Arrange</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>string trackstring = ultraschall.GetAllVisibleTracks_Arrange(optional boolean master_track, optional boolean completely_visible)</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      returns a trackstring with all tracks currently visible in the arrange-view.
        
      returns nil in case of error
    </description>
    <retvals>
      string trackstring - a string with holds all tracknumbers from all found tracks, separated by a comma; beginning with 1 for the first track
    </retvals>
    <parameters>
      optional boolean master_track - nil or true, check for visibility of the master-track; false, don't include the master-track
      optional boolean completely_visible - nil or false, all tracks including partially visible ones; true, only fully visible tracks
    </parameters>
    <chapter_context>
      Track Management
      Assistance functions
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_TrackManagement_Module.lua</source_document>
    <tags>track management, get, all visible, tracks, arrangeview</tags>
  </US_DocBloc>
  --]]
  if completely_visible~=nil and ultraschall.type(completely_visible)~="boolean" then ultraschall.AddErrorMessage("GetAllVisibleTracks_Arrange", "completely_visible", "must be either nil(for false) or a boolean",-1) return end
  if master_track~=nil and ultraschall.type(master_track)~="boolean" then ultraschall.AddErrorMessage("GetAllVisibleTracks_Arrange", "master_track", "must be either nil(for true) or a boolean",-1) return end
  local arrange_view = ultraschall.GetHWND_ArrangeViewAndTimeLine()
  local retval, left, top, right, bottom = reaper.JS_Window_GetClientRect(arrange_view)

  -- find all tracks currently visible
  local trackstring=""
  if master_track~=false then
    if reaper.SNM_GetIntConfigVar("showmaintrack",-99)&1==1 then
      local track=reaper.GetMasterTrack(0)
      if completely_visible~=true and reaper.GetMediaTrackInfo_Value(track, "I_TCPY")+reaper.GetMediaTrackInfo_Value(track, "I_WNDH")>0 then 
        trackstring="0,"
      end
    end
  end
   
  for i=1, reaper.CountTracks(0) do
    local track=reaper.GetTrack(0, i-1)
    if completely_visible==true then 
      if reaper.GetMediaTrackInfo_Value(track, "I_TCPY")>=0 and reaper.GetMediaTrackInfo_Value(track, "I_TCPY")+reaper.GetMediaTrackInfo_Value(track, "I_WNDH")<=bottom-top then
        trackstring=trackstring..i.."," 
      end
    else
      if reaper.GetMediaTrackInfo_Value(track, "I_TCPY")<=bottom-top and reaper.GetMediaTrackInfo_Value(track, "I_TCPY")+reaper.GetMediaTrackInfo_Value(track, "I_WNDH")>=0 then
        trackstring=trackstring..i..","
      end
    end
  end
  return trackstring:sub(1,-2)
end

function ultraschall.GetTakeEnvelopeUnderMouseCursor()
  --[[
  <US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
    <slug>GetTakeEnvelopeUnderMouseCursor</slug>
    <requires>
      Ultraschall=4.1
      Reaper=6.10
      Lua=5.3
    </requires>
    <functioncall>TakeEnvelope env, MediaItem_Take take, number projectposition = ultraschall.GetTakeEnvelopeUnderMouseCursor()</functioncall>
    <description markup_type="markdown" markup_version="1.0.1" indent="default">
      returns the take-envelope underneath the mouse
    </description>
    <retvals>
      TakeEnvelope env - the take-envelope found unterneath the mouse; nil, if none has been found
      MediaItem_Take take - the take from which the take-envelope is
      number projectposition - the project-position
    </retvals>
    <chapter_context>
      Envelope Management
      Envelopes
    </chapter_context>
    <target_document>US_Api_Functions</target_document>
    <source_document>Modules/ultraschall_functions_Envelope_Module.lua</source_document>
    <tags>envelope management, get, take, envelope, mouse position</tags>
  </US_DocBloc>
  --]]
  -- todo: retval for position within the take
  
  local Awindow, Asegment, Adetails = reaper.BR_GetMouseCursorContext()
  local retval, takeEnvelope = reaper.BR_GetMouseCursorContext_Envelope()
  if takeEnvelope==true then 
    return retval, reaper.BR_GetMouseCursorContext_Position(), reaper.BR_GetMouseCursorContext_Item()
  else
    return nil, reaper.BR_GetMouseCursorContext_Position()
  end
end

function ultraschall.GetThemeParameterIndexByName(parametername)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetThemeParameterIndexByName</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer parameterindex, string retval, optional string desc, optional number value, optional number defValue, optional number minValue, optional number maxValue = ultraschall.GetThemeParameterIndexByName(string parametername)</functioncall>
  <description>
    allows getting a theme-parameter's values by its name
    
    returns nil in case of an error
  </description>
  <retvals>
    integer parameterindex - the index of the theme-parameter
    string retval - the name of the theme-parameter
    optional string desc - the description of the theme-parameter
    optional number value - the current value of the theme-parameter
    optional number defValue - the default value of the theme-parameter
    optional number minValue - the minimum-value of the theme-parameter
    optional number maxValue - the maximum-value of the theme-parameter
  </retvals>
  <parameters>
    string parametername - the name of the theme-parameter, whose attributes you want to get(default v6-Theme has usually paramX, where X is a number between 0 and 80, other themes may differ from that)
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, get, parameters, by name</tags>
</US_DocBloc>
]]
  if ultraschall.type(parametername)~="string" then ultraschall.AddErrorMessage("GetThemeParameterIndexByName", "parametername", "must be a string", -1) return end
  local retval=1
  local index=-1
  local desc, value, defValue, minValue, maxValue 
  while retval~=nil do
    index=index+1
    retval, desc, value, defValue, minValue, maxValue = reaper.ThemeLayout_GetParameter(index)
    if retval==parametername then return index, retval, desc, value, defValue, minValue, maxValue end
  end
  ultraschall.AddErrorMessage("GetThemeParameterIndexByName", "parametername", "no such parameter found", -2) 
end

--A={ultraschall.GetThemeParameterIndexByName("param1")}

function ultraschall.SetThemeParameterIndexByName(parametername, value, persist, strict)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetThemeParameterIndexByName</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetThemeParameterIndexByName(string parametername, integer value, boolean persist, optional boolean strict)</functioncall>
  <description>
    allows setting the theme-parameter value by its name
    
    returns nil in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <parameters>
    string parametername - the name of the theme-parameter, whose attributes you want to set(default v6-Theme has usually paramX, where X is a number between 0 and 80, other themes may differ from that)
    integer value - the new value to set
    boolean persist - true, the new value shall persist; false, the new value shall only be used until Reaper is closed
    optional boolean strict - true or nil, only allow values within the minimum and maximum values of the parameter; false, allows setting values out of the range
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, set, parameter, value, by name</tags>
</US_DocBloc>
]]
  if ultraschall.type(parametername)~="string" then ultraschall.AddErrorMessage("SetThemeParameterIndexByName", "parametername", "must be a string", -1) return false end
  if ultraschall.type(value)~="number: integer" then ultraschall.AddErrorMessage("SetThemeParameterIndexByName", "value", "must be an integer", -2) return false end
  if ultraschall.type(persist)~="boolean" then ultraschall.AddErrorMessage("SetThemeParameterIndexByName", "persist", "must be a boolean", -3) return false end
  if strict~=nil and ultraschall.type(strict)~="boolean" then ultraschall.AddErrorMessage("SetThemeParameterIndexByName", "strict", "must be nil(for true) or a boolean", -4) return false end
  ultraschall.SuppressErrorMessages(true)
  local index, retval, desc, pvalue, defValue, minValue, maxValue = ultraschall.GetThemeParameterIndexByName(parametername)
  ultraschall.SuppressErrorMessages(false)
  if index==nil then ultraschall.AddErrorMessage("SetThemeParameterIndexByName", "parametername", "no such parameter found", -5) return false end
  if strict~=false then
    if maxValue~=nil and minValue~=nil and (value>maxValue or value<minValue) then
      ultraschall.AddErrorMessage("SetThemeParameterIndexByName", "value", "value "..value.." out of valid bounds between "..minValue.." and "..maxValue, -6) 
      return false
    end
  end
  return reaper.ThemeLayout_SetParameter(index, value, persist)
end

function ultraschall.GetThemeParameterIndexByDescription(description)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetThemeParameterIndexByDescription</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>integer parameterindex, string retval, optional string desc, optional number value, optional number defValue, optional number minValue, optional number maxValue = ultraschall.GetThemeParameterIndexByDescription(string description)</functioncall>
  <description>
    allows getting a theme-parameter's values by its description
    
    returns nil in case of an error
  </description>
  <retvals>
    integer parameterindex - the index of the theme-parameter
    string retval - the name of the theme-parameter
    optional string desc - the description of the theme-parameter
    optional number value - the current value of the theme-parameter
    optional number defValue - the default value of the theme-parameter
    optional number minValue - the minimum-value of the theme-parameter
    optional number maxValue - the maximum-value of the theme-parameter
  </retvals>
  <parameters>
    string description - the description of the theme-parameter, whose attributes you want to get
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, get, parameters, by description</tags>
</US_DocBloc>
]]
  if ultraschall.type(description)~="string" then ultraschall.AddErrorMessage("GetThemeParameterIndexByDescription", "description", "must be a string", -1) return end
  local retval=1
  local index=-1
  local desc, value, defValue, minValue, maxValue 
  while retval~=nil do
    index=index+1
    retval, desc, value, defValue, minValue, maxValue = reaper.ThemeLayout_GetParameter(index)
    if desc==description then return index, retval, desc, value, defValue, minValue, maxValue end
  end
  ultraschall.AddErrorMessage("GetThemeParameterIndexByDescription", "description", "no such parameter found", -2) 
end

--A={ultraschall.GetThemeParameterIndexByDescription("A_tcp_LabelMeasure")}

function ultraschall.SetThemeParameterIndexByDescription(description, value, persist, strict)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetThemeParameterIndexByDescription</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetThemeParameterIndexByDescription(string description, integer value, boolean persist, optional boolean strict)</functioncall>
  <description>
    allows setting the theme-parameter value by its description
    
    returns nil in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <parameters>
    string description - the description of the theme-parameter, whose attributes you want to set
    integer value - the new value to set
    boolean persist - true, the new value shall persist; false, the new value shall only be used until Reaper is closed
    optional boolean strict - true or nil, only allow values within the minimum and maximum values of the parameter; false, allows setting values out of the range
  </parameters>
  <chapter_context>
    Themeing
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Themeing_Module.lua</source_document>
  <tags>theme management, set, parameter, value, by description</tags>
</US_DocBloc>
]]
  if ultraschall.type(description)~="string" then ultraschall.AddErrorMessage("SetThemeParameterIndexByDescription", "description", "must be a string", -1) return false end
  if ultraschall.type(value)~="number: integer" then ultraschall.AddErrorMessage("SetThemeParameterIndexByDescription", "value", "must be an integer", -2) return false end
  if ultraschall.type(persist)~="boolean" then ultraschall.AddErrorMessage("SetThemeParameterIndexByDescription", "persist", "must be a boolean", -3) return false end
  if strict~=nil and ultraschall.type(strict)~="boolean" then ultraschall.AddErrorMessage("SetThemeParameterIndexByDescription", "strict", "must be nil(for true) or a boolean", -4) return false end
  ultraschall.SuppressErrorMessages(true)
  local index, retval, desc, pvalue, defValue, minValue, maxValue = ultraschall.GetThemeParameterIndexByDescription(description)
  ultraschall.SuppressErrorMessages(false)
  if index==nil then ultraschall.AddErrorMessage("SetThemeParameterIndexByDescription", "description", "no such parameter found", -5) return false end
  if strict~=false then
    if maxValue~=nil and minValue~=nil and (value>maxValue or value<minValue) then
      ultraschall.AddErrorMessage("SetThemeParameterIndexByDescription", "value", "value "..value.." out of valid bounds between "..minValue.." and "..maxValue, -6) 
      return false
    end
  end
  return reaper.ThemeLayout_SetParameter(index, value, persist)
end

--AAA=ultraschall.SetThemeParameterIndexByDescription("A_tcp_Record_Arm", 2, false, true)

function ultraschall.TCP_SetWidth(width)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetThemeParameterIndexByDescription</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetThemeParameterIndexByDescription(integer width)</functioncall>
  <description>
    allows setting the width of the tcp.
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, setting was unsuccessful
  </retvals>
  <parameters>
    integer width - the new width of the tcp in pixels; 0 and higher
  </parameters>
  <chapter_context>
    User Interface
    Track Control Panel(TCP)
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_ReaperUserInterface_Module.lua</source_document>
  <tags>userinterface, set, width, tcp, track control panel</tags>
</US_DocBloc>
]]
  -- initial code by amagalma
  if ultraschall.type(width)~="number: integer" then ultraschall.AddErrorMessage("TCP_SetWidth", "width", "must be an integer", -1) return false end
  if width<0 then ultraschall.AddErrorMessage("TCP_SetWidth", "width", "must be bigger or equal 0", -2) return false end

  local main = reaper.GetMainHwnd()
  local _, _, tcp_hwnd, tracklist = ultraschall.GetHWND_ArrangeViewAndTimeLine()
  local x,y = 0,0 
  local _, _, _, av_r = reaper.JS_Window_GetRect(tracklist) 
  
  local _, main_x = reaper.JS_Window_GetRect(main) 
  local _, tcp_x, tcp_y, tcp_r = reaper.JS_Window_GetRect(tcp_hwnd) 

  if tcp_r < av_r then
    x,y = reaper.JS_Window_ScreenToClient(main, tcp_x+(tcp_r-tcp_x)+2, tcp_y)
    reaper.JS_WindowMessage_Send(main, "WM_LBUTTONDOWN", 1, 0, x, y) -- mouse down message at splitter location
    reaper.JS_WindowMessage_Send(main, "WM_LBUTTONUP", 0, 0, (tcp_x+width)-main_x-2, y) -- set width, mouse up message
  else -- ' TCP is on right side
    x,y = reaper.JS_Window_ScreenToClient(main, tcp_x-5, tcp_y)
    reaper.JS_WindowMessage_Send(main, "WM_LBUTTONDOWN", 1, 0, x, y)
    reaper.JS_WindowMessage_Send(main, "WM_LBUTTONUP", 0, 0, (tcp_r-width)-main_x-8, y)
  end 
  return true
end

--ultraschall.TCP_SetWidth(300)

function ultraschall.GetTrackManagerHWND()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetTrackManagerHWND</slug>
  <requires>
    Ultraschall=4.1
    Reaper=5.965
    JS=0.963
    Lua=5.3
  </requires>
  <functioncall>HWND hwnd = ultraschall.GetTrackManagerHWND()</functioncall>
  <description>
    returns the HWND of the Track Manager-dialog, if the window is opened.
    
    returns nil if Track Manager-dialog is closed
  </description>
  <retvals>
    HWND hwnd - the window-handler of the Track Manager-dialog
  </retvals>
  <chapter_context>
    User Interface
    Reaper-Windowhandler
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_ReaperUserInterface_Module.lua</source_document>
  <tags>user interface, window, track manager, hwnd, get</tags>
</US_DocBloc>
--]]
  local translation=reaper.JS_Localize("Track Manager", "common")
 
  local selection=reaper.JS_Localize("Set selection from:", "DLG_469")
  local show_all=reaper.JS_Localize("Show all", "DLG_469")
  local mcp=reaper.JS_Localize("MCP", "trackmgr")
  
  local count_hwnds, hwnd_array, hwnd_adresses = ultraschall.Windows_Find(translation, true)
  if count_hwnds==0 then return nil
  else
    for i=count_hwnds, 1, -1 do
      if ultraschall.HasHWNDChildWindowNames(hwnd_array[i], 
                                           selection,
                                           show_all,
                                           mcp)==true then return hwnd_array[i] end
    end
  end
  return nil
end



function ultraschall.TrackManager_ClearFilter()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>TrackManager_ClearFilter</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    JS=0.963
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.TrackManager_ClearFilter()</functioncall>
  <description>
    clears the filter of the trackmanager, if the window is opened.
    
    returns false if Track Manager is closed
  </description>
  <retvals>
    boolean retval - true, clearing was successful; false, clearing was unsuccessful
  </retvals>
  <chapter_context>
    TrackManager
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_TrackManager_Module.lua</source_document>
  <tags>trackmanager, clear, filter</tags>
</US_DocBloc>
--]]
  local tm_hwnd=ultraschall.GetTrackManagerHWND()
  if tm_hwnd==nil then ultraschall.AddErrorMessage("TrackManager_ClearFilter", "", "Track Manager not opened", -1) return false end
  local button=reaper.JS_Window_FindChildByID(tm_hwnd, 1056)
  reaper.JS_WindowMessage_Send(button, "WM_LBUTTONDOWN", 1,1,1,1)
  reaper.JS_WindowMessage_Send(button, "WM_LBUTTONUP", 1,1,1,1)
  return true
end

function ultraschall.TrackManager_ShowAll()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>TrackManager_ShowAll</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    JS=0.963
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.TrackManager_ShowAll()</functioncall>
  <description>
    shows all tracks, if the window is opened.
    
    returns false if Track Manager is closed
  </description>
  <retvals>
    boolean retval - true, showall was successful; false, showall was unsuccessful
  </retvals>
  <chapter_context>
    TrackManager
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_TrackManager_Module.lua</source_document>
  <tags>trackmanager, show, all</tags>
</US_DocBloc>
--]]
  local tm_hwnd=ultraschall.GetTrackManagerHWND()
  if tm_hwnd==nil then ultraschall.AddErrorMessage("TrackManager_ShowAll", "", "Track Manager not opened", -1) return false end
  local button=reaper.JS_Window_FindChildByID(tm_hwnd, 1058)
  reaper.JS_WindowMessage_Send(button, "WM_LBUTTONDOWN", 1,1,1,1)
  reaper.JS_WindowMessage_Send(button, "WM_LBUTTONUP", 1,1,1,1)
  return true
end

function ultraschall.TrackManager_SelectionFromProject()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>TrackManager_SelectionFromProject</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    JS=0.963
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.TrackManager_SelectionFromProject()</functioncall>
  <description>
    sets trackselection in trackmanager to the trackselection from the project, if the trackmanager-window is opened.
    
    returns false if Track Manager is closed
  </description>
  <retvals>
    boolean retval - true, setting selection was successful; false, setting selection was unsuccessful
  </retvals>
  <chapter_context>
    TrackManager
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_TrackManager_Module.lua</source_document>
  <tags>trackmanager, set, selection, from project</tags>
</US_DocBloc>
--]]
  local tm_hwnd=ultraschall.GetTrackManagerHWND()
  if tm_hwnd==nil then ultraschall.AddErrorMessage("TrackManager_SelectionFromProject", "", "Track Manager not opened", -1) return false end
  local button=reaper.JS_Window_FindChildByID(tm_hwnd, 1057)
  reaper.JS_WindowMessage_Send(button, "WM_LBUTTONDOWN", 1,1,1,1)
  reaper.JS_WindowMessage_Send(button, "WM_LBUTTONUP", 1,1,1,1)
  return true
end

function ultraschall.TrackManager_SelectionFromList()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>TrackManager_SelectionFromProject</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    JS=0.963
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.TrackManager_SelectionFromProject()</functioncall>
  <description>
    sets trackselection from trackmanager into the trackselection of the project, if the trackmanager-window is opened.
    
    returns false if Track Manager is closed
  </description>
  <retvals>
    boolean retval - true, setting selection was successful; false, setting selection was unsuccessful
  </retvals>
  <chapter_context>
    TrackManager
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_TrackManager_Module.lua</source_document>
  <tags>trackmanager, set, selection, to project</tags>
</US_DocBloc>
--]]
  local tm_hwnd=ultraschall.GetTrackManagerHWND()
  if tm_hwnd==nil then ultraschall.AddErrorMessage("TrackManager_SelectionFromList", "", "Track Manager not opened", -1) return false end
  local button=reaper.JS_Window_FindChildByID(tm_hwnd, 1062)
  reaper.JS_WindowMessage_Send(button, "WM_LBUTTONDOWN", 1,1,1,1)
  reaper.JS_WindowMessage_Send(button, "WM_LBUTTONUP", 1,1,1,1)
  return true
end

function ultraschall.TrackManager_SetFilter(filter)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>TrackManager_SetFilter</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    JS=0.963
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.TrackManager_SetFilter(string filter)</functioncall>
  <description>
    sets filter of the trackmanager, if the trackmanager-window is opened.
    
    returns false if Track Manager is closed
  </description>
  <retvals>
    boolean retval - true, setting filter was successful; false, setting filter was unsuccessful
  </retvals>
  <parameters>
    string filter - the new filter-phrase to be set 
  </parameters>
  <chapter_context>
    TrackManager
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_TrackManager_Module.lua</source_document>
  <tags>trackmanager, set, filter</tags>
</US_DocBloc>
--]]
  if ultraschall.type(filter)~="string" then ultraschall.AddErrorMessage("TrackManager_SetFilter", "filter", "must be a string", -1) return false end
  local tm_hwnd=ultraschall.GetTrackManagerHWND()
  if tm_hwnd==nil then ultraschall.AddErrorMessage("TrackManager_SelectionFromList", "", "Track Manager not opened", -2) return false end
  local button=reaper.JS_Window_FindChildByID(tm_hwnd, 1007)
  reaper.JS_Window_SetTitle(button, filter)
  return true
end

function ultraschall.TrackManager_OpenClose(toggle)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>TrackManager_OpenClose</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    JS=0.963
    Lua=5.3
  </requires>
  <functioncall>boolean retval, optional boolean new_toggle_state = ultraschall.TrackManager_OpenClose(optional boolean toggle)</functioncall>
  <description>
    opens/closes the trackmanager
    
    returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, opening/closing was successful; false, there was an error
    optional boolean new_toggle_state - true, track manager is opened; false, track manager is closed
  </retvals>
  <parameters>
    optional boolean toggle - true, open the track manager; false, close the track manager; nil, just toggle open/close of the trackmanager
  </parameters>
  <chapter_context>
    TrackManager
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_TrackManager_Module.lua</source_document>
  <tags>trackmanager, open, close</tags>
</US_DocBloc>
--]]
  if toggle~=nil and ultraschall.type(toggle)~="boolean" then ultraschall.AddErrorMessage("TrackManager_OpenClose", "toggle", "must be a boolean", -1) return false end
  local state=reaper.GetToggleCommandState(40906)
  if (state==0 and toggle==true) or
     (state==1 and toggle==false) then
    reaper.Main_OnCommand(40906,0)
  elseif toggle==nil then
    reaper.Main_OnCommand(40906,0)
    if state==0 then return true, true else return true, false end
  end
  return true, toggle
end

--A,B=ultraschall.TrackManager_OpenClose()

function ultraschall.Lokasenna_LoadGuiLib_v2()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Lokasenna_LoadGuiLib_v2</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.02
    Lua=5.3
  </requires>
  <functioncall>ultraschall.Lokasenna_LoadGuiLib_v2()</functioncall>
  <description>
    loads Lokasenna's Gui Lib v2 into the current script, so you can make your own guis.
    
    This prevents the need to use dofile, require, loadfile to load Lokasenna's Gui Lib, so you can code the actual Gui right after calling this function.
    
    It gives you access to all classes immediately.
    
    It uses a version of Lokasenna's Gui Lib v2 included with Ultraschall-API, so it doesn't get into conflict with other installed versions on your system.
    
    You can find the documentation for it <a href="../3rd_party_modules/Lokasenna_GUI%20v2/Developer%20Tools/Documentation.html">at this location.</a>
  </description>
  <chapter_context>
    User Interface
    Lokasenna Gui Lib v2
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_TrackManager_Module.lua</source_document>
  <tags>user interface, load, lokasenna, guilib, v2, classes</tags>
</US_DocBloc>
--]]
  loadfile(ultraschall.Api_Path.."/3rd_party_modules/Lokasenna_GUI v2/Library/Core.lua")()

  local filename=""
  local i=0
  while filename~=nil do
    filename=reaper.EnumerateFiles(ultraschall.Api_Path.."/3rd_party_modules/Lokasenna_GUI v2/Library/Classes/", i)
    if filename==nil then break end
    i=i+1
    loadfile(ultraschall.Api_Path.."/3rd_party_modules/Lokasenna_GUI v2/Library/Classes/"..filename)()
  end
end

--ultraschall.Lokasenna_LoadGuiLib_v2()

function ultraschall.GetRender_EmbedMetaData()
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>GetRender_EmbedMetaData</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.11
    SWS=2.10.0.1
    JS=0.972
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.GetRender_EmbedMetaData()</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets the current state of the "Embed metadata"-checkbox from the Render to File-dialog.
  </description>
  <retvals>
    boolean state - true, check the checkbox; false, uncheck the checkbox
  </retvals>
  <chapter_context>
    Configuration Settings
    Render to File
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
  <tags>render, get, checkbox, render, embed metadata</tags>
</US_DocBloc>
]]
  local SaveCopyOfProject, hwnd, retval, length, state
  hwnd = ultraschall.GetRenderToFileHWND()
  if hwnd==nil then
    state=reaper.SNM_GetIntConfigVar("projrenderstems", 0)&512
  else
    state = reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(hwnd,1178), "BM_GETCHECK", 0,0,0,0)
  end
  if state==0 then state=false else state=true end
  return state
end

--A=ultraschall.GetRender_EmbedMetaData()

function ultraschall.SetRender_EmbedMetaData(state)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>SetRender_EmbedMetaData</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.11
    SWS=2.10.0.1
    JS=0.972
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.SetRender_EmbedMetaData(boolean state)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Sets the new state of the "Embed metadata"-checkbox from the Render to File-dialog.
    
    Returns false in case of an error
  </description>
  <retvals>
    boolean retval - true, setting was successful; false, it was unsuccessful
  </retvals>
  <parameters>
    boolean state - true, check the checkbox; false, uncheck the checkbox
  </parameters>
  <chapter_context>
    Configuration Settings
    Render to File
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_Render_Module.lua</source_document>
  <tags>render, set, checkbox, render, embed metadata, transient guides</tags>
</US_DocBloc>
]]
  if type(state)~="boolean" then ultraschall.AddErrorMessage("SetRender_EmbedStretchMarkers", "state", "must be a boolean", -1) return false end
  local SaveCopyOfProject, hwnd, retval, Oldstate, Oldstate2, state2
  if state==false then state=0 else state=1 end
  hwnd = ultraschall.GetRenderToFileHWND()
  Oldstate=reaper.SNM_GetIntConfigVar("projrenderstems", -99)
  Oldstate2=Oldstate&512  
  if Oldstate2==512 and state==0 then state2=Oldstate-512
  elseif Oldstate2==0 and state==1 then state2=Oldstate+512
  else state2=Oldstate
  end
  
  
  if hwnd==nil then
    reaper.SNM_SetIntConfigVar("projrenderstems", state2)
  else
    reaper.JS_WindowMessage_Send(reaper.JS_Window_FindChildByID(hwnd, 1178), "BM_SETCHECK", state,0,0,0)
    reaper.SNM_SetIntConfigVar("projrenderstems", state2)
  end
  return true
end

--A=ultraschall.SetRender_EmbedMetaData(true)

function ultraschall.Metadata_ID3_GetSet(Tag, Value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Metadata_ID3_GetSet</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.11
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Metadata_ID3_GetSet(string Tag, optional string Value)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets/Sets a stored ID3-metadata-tag into the current project.
    
    To get a value, set parameter Value to nil; to set a value, set the parameter Value to the desired value
    Note: APIC\_TYPE allows only specific values, as listed below!
    
    Supported tags are:
      TIT2 - Title
      TPE1 - Artist
      TPE2 - Album Artist
      TALB - Album
      TRCK - Track
      TCON - Genre
      TYER - Year, must be of the format yyyy, like 2020
      TDRC - Recording Time, must be of the format YYYY-MM-DD or YYYY-MM-DDThh:mm like 2020-06-27 or 2020-06-27T23:30
      TKEY - Key
      TBPM - Tempo
      TCOM - Composer
      TEXT - Lyricist/Text Writer
      TIPL - Involved People
      TMCL - Musician Credits
      TIT1 - Content Group
      TIT3 - Subtitle/Description
      TRCK - Track number
      TCOP - Copyright Message
      TSRC - International Standard Recording Code
      TXXX - User defined(description=value)
      COMM - Comment
      COMM\_LANG - Comment language, 3-character code like "eng"
      APIC\_TYPE - the type of the cover-image
        "", unset
        0, Other
        1, 32x32 pixel file icon (PNG only)
        2, Other file icon
        3, Cover (front)
        4, Cover (back)
        5, Leaflet page
        6, Media
        7, Lead artist/Lead Performer/Solo
        8, Artist/Performer
        9, Conductor
        10, Band/Orchestra
        11, Composer
        12, Lyricist/Text writer
        13, Recording location
        14, During recording
        15, During performance
        16, Movie/video screen capture
        17, A bright colored fish
        18, Illustration
        19, Band/Artist logotype
        20, Publisher/Studiotype
    APIC\_DESC - the description of the cover-image
    APIC\_FILE - the filename+absolute path of the cover-image; must be either png or jpg
    
    Returns nil in case of an error
  </description>
  <retvals>
    string value - the value of the specific tag
  </retvals>
  <parameters>
    string Tag - the tag, whose value you want to get/set; see description for a list of supported ID3-Tags
    optional string Value - nil, only get the current value; any other value, set the value
  </parameters>
  <chapter_context>
    Metadata Management
    Tags
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_MetaData_Module.lua</source_document>
  <tags>metadata management, get, set, id3, metadata, tags, tag</tags>
</US_DocBloc>
]]
  if ultraschall.type(Tag)~="string" then ultraschall.AddErrorMessage("Metadata_ID3_GetSet", "Tag", "must be a string", -1) return end
  if Value~=nil and ultraschall.type(Value)~="string" then ultraschall.AddErrorMessage("Metadata_ID3_GetSet", "Value", "must be a string", -2) return end
  if Value==nil then Value="" set=false else Value="|"..Value set=true end
  Tag=Tag:upper()
  if Value~=nil then
    if Tag=="TYER" and Value:match("^|%d%d%d%d$")==nil then ultraschall.AddErrorMessage("Metadata_ID3_GetSet", "Value", "TYER: must be of the following format yyyy like 2020", -3) return end
    if Tag=="TDRC" and (Value:match("^|%d%d%d%d%-%d%d%-%d%d$")==nil and Value:match("^|%d%d%d%d%-%d%d%-%d%dT%d%d:%d%d$")==nil) then ultraschall.AddErrorMessage("Metadata_ID3_GetSet", "Value", "TDRC: must be of the following format yyyy-mm-dd or yyyy-mm-ddThh-mm like 2020-06-27 or 2020-06-27T23:30", -4) return end
    if Tag=="COMM_LANG" and Value:len()~=4 then ultraschall.AddErrorMessage("Metadata_ID3_GetSet", "Value", "COMM_LANG: must be a 3-character code like \"eng\"", -5) return end
    if Tag=="APIC_FILE" then
      local fileformat = ultraschall.CheckForValidFileFormats(Value)
      if fileformat~="PNG" and fileformat~="JPG" then ultraschall.AddErrorMessage("Metadata_ID3_GetSet", "Value", "APIC_FILE: must be either a jpg or a png-file", -6) return end
    end
  end
  
  local a,b=reaper.GetSetProjectInfo_String(0, "RENDER_METADATA", "ID3:"..Tag:upper()..Value, set)
  return b
end

--A=ultraschall.Metadata_ID3_GetSet("APIC_TYPE", "1")

function ultraschall.Metadata_BWF_GetSet(Tag, Value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Metadata_BWF_GetSet</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.11
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Metadata_BWF_GetSet(string Tag, optional string Value)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets/Sets a stored BWF-metadata-tag into the current project.
    
    To get a value, set parameter Value to nil; to set a value, set the parameter Value to the desired value
    
    Supported tags are:
      Description
      Originator
      OriginatorReference
      AXML_ISRC - International Standard Recording Code
      
      Note: OriginationDate, OriginationTime and TimeReference are set by Reaper itself
      
    Returns nil in case of an error
  </description>
  <retvals>
    string value - the value of the specific tag
  </retvals>
  <parameters>
    string Tag - the tag, whose value you want to get/set; see description for a list of supported BWF-Tags
    optional string Value - nil, only get the current value; any other value, set the value
  </parameters>
  <chapter_context>
    Metadata Management
    Tags
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_MetaData_Module.lua</source_document>
  <tags>metadata management, get, set, bwf, metadata, tags, tag</tags>
</US_DocBloc>
]]
  if ultraschall.type(Tag)~="string" then ultraschall.AddErrorMessage("Metadata_BWF_GetSet", "Tag", "must be a string", -1) return end
  if Value~=nil and ultraschall.type(Value)~="string" then ultraschall.AddErrorMessage("Metadata_BWF_GetSet", "Value", "must be a string", -2) return end
  if Value==nil then Value="" set=false else Value="|"..Value set=true end
  local a,b=reaper.GetSetProjectInfo_String(0, "RENDER_METADATA", "BWF:"..Tag..Value, set)
  return b
end

function ultraschall.Metadata_IXML_GetSet(Tag, Value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Metadata_IXML_GetSet</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.11
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Metadata_IXML_GetSet(string Tag, optional string Value)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets/Sets a stored IXML-metadata-tag into the current project.
    
    To get a value, set parameter Value to nil; to set a value, set the parameter Value to the desired value
    
    Supported tags are:
      PROJECT
      SCENE
      TAPE
      TAKE
      CIRCLED - either TRUE or FALSE
      FILE_UID - unique identifier for the file
      NOTE
      
    Returns nil in case of an error
  </description>
  <retvals>
    string value - the value of the specific tag
  </retvals>
  <parameters>
    string Tag - the tag, whose value you want to get/set; see description for a list of supported IXML-Tags
    optional string Value - nil, only get the current value; any other value, set the value
  </parameters>
  <chapter_context>
    Metadata Management
    Tags
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_MetaData_Module.lua</source_document>
  <tags>metadata management, get, set, ixml, metadata, tags, tag</tags>
</US_DocBloc>
]]
  if ultraschall.type(Tag)~="string" then ultraschall.AddErrorMessage("Metadata_IXML_GetSet", "Tag", "must be a string", -1) return end
  if Value~=nil and ultraschall.type(Value)~="string" then ultraschall.AddErrorMessage("Metadata_IXML_GetSet", "Value", "must be a string", -2) return end
  if Value==nil then Value="" set=false else Value="|"..Value set=true end
  if Tag:upper()=="CIRCLED" and Value:upper()~="|TRUE" and Value:upper()~="|FALSE" then 
    ultraschall.AddErrorMessage("Metadata_IXML_GetSet", "Value", "CIRCLED: must be either TRUE or FALSE", -3) return 
  elseif Tag:upper()=="CIRCLED" and (Value:upper()=="|TRUE" or Value:upper()=="|FALSE") then
    Value=Value:upper()
  end

  local a,b=reaper.GetSetProjectInfo_String(0, "RENDER_METADATA", "IXML:"..Tag:upper()..Value, set)
  return b
end

function ultraschall.Metadata_INFO_GetSet(Tag, Value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Metadata_INFO_GetSet</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.11
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Metadata_INFO_GetSet(string Tag, optional string Value)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets/Sets a stored INFO-metadata-tag into the current project.
    
    To get a value, set parameter Value to nil; to set a value, set the parameter Value to the desired value
    
    Supported tags are:
      INAM - Name/Description
      IART - Artist
      IPRD - Product(Album)
      IGNR - Genre
      ICRD - Creation Date, must be of the format yyyy-mm-dd like 2020-06-27
      ISRC - Source
      IKEY - Keywords
      ICMT - Comment
      
    Returns nil in case of an error
  </description>
  <retvals>
    string value - the value of the specific tag
  </retvals>
  <parameters>
    string Tag - the tag, whose value you want to get/set; see description for a list of supported INFO-Tags
    optional string Value - nil, only get the current value; any other value, set the value
  </parameters>
  <chapter_context>
    Metadata Management
    Tags
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_MetaData_Module.lua</source_document>
  <tags>metadata management, get, set, info, metadata, tags, tag</tags>
</US_DocBloc>
]]
  if ultraschall.type(Tag)~="string" then ultraschall.AddErrorMessage("Metadata_INFO_GetSet", "Tag", "must be a string", -1) return end
  if Value~=nil and ultraschall.type(Value)~="string" then ultraschall.AddErrorMessage("Metadata_INFO_GetSet", "Value", "must be a string", -2) return end
  if Value==nil then Value="" set=false else Value="|"..Value set=true end

  if Tag=="ICRD" and Value~=nil then
    if Value:match("%d%d%d%d%-%d%d%-%d%d")==nil then
      ultraschall.AddErrorMessage("Metadata_INFO_GetSet", "Value", "ICRD: must be of the format \"yyyy-mm-dd\" like \"2020-06-27\"", -3) return 
    end
  end

  local a,b=reaper.GetSetProjectInfo_String(0, "RENDER_METADATA", "INFO:"..Tag:upper()..Value, set)
  return b
end

--A=ultraschall.Metadata_INFO_GetSet("ICRD", "2020-06-27")

function ultraschall.Metadata_CART_GetSet(Tag, Value)
--[[
<US_DocBloc version="1.0" spok_lang="en" prog_lang="*">
  <slug>Metadata_CART_GetSet</slug>
  <requires>
    Ultraschall=4.1
    Reaper=6.11
    Lua=5.3
  </requires>
  <functioncall>boolean retval = ultraschall.Metadata_CART_GetSet(string Tag, optional string Value)</functioncall>
  <description markup_type="markdown" markup_version="1.0.1" indent="default">
    Gets/Sets a stored CART-metadata-tag into the current project.
    
    To get a value, set parameter Value to nil; to set a value, set the parameter Value to the desired value
    
    Supported tags are:
      Title
      Artist
      CutID - Cut
      ClientID - Client
      Category
      StartDate - the start-date, must be of the following format, yyyy-mm-dd, like 2020-06-27
      EndDate - the end-date, must be of the following format, yyyy-mm-dd, like 2020-06-27
      URL
      TagText - Text
      
    Note: INT1 is set by the INT1 marker; SEG1 is set by the SEG1-marker
      
    Returns nil in case of an error
  </description>
  <retvals>
    string value - the value of the specific tag
  </retvals>
  <parameters>
    string Tag - the tag, whose value you want to get/set; see description for a list of supported CART-Tags
    optional string Value - nil, only get the current value; any other value, set the value
  </parameters>
  <chapter_context>
    Metadata Management
    Tags
  </chapter_context>
  <target_document>US_Api_Functions</target_document>
  <source_document>Modules/ultraschall_functions_MetaData_Module.lua</source_document>
  <tags>metadata management, get, set, cart, metadata, tags, tag</tags>
</US_DocBloc>
]]
  if ultraschall.type(Tag)~="string" then ultraschall.AddErrorMessage("Metadata_CART_GetSet", "Tag", "must be a string", -1) return end
  if Value~=nil and ultraschall.type(Value)~="string" then ultraschall.AddErrorMessage("Metadata_CART_GetSet", "Value", "must be a string", -2) return end
  if Value==nil then Value="" set=false else Value="|"..Value set=true end

  if Tag=="StartDate" and Value~=nil then
    if Value:match("%d%d%d%d%-%d%d%-%d%d")==nil then
      ultraschall.AddErrorMessage("Metadata_CART_GetSet", "Value", "StartDate: must be of the format \"yyyy-mm-dd\" like \"2020-06-27\"", -3) return 
    end
  end
  if Tag=="EndDate" and Value~=nil then
    if Value:match("%d%d%d%d%-%d%d%-%d%d")==nil then
      ultraschall.AddErrorMessage("Metadata_CART_GetSet", "Value", "EndDate: must be of the format \"yyyy-mm-dd\" like \"2020-06-27\"", -4) return 
    end
  end
  
  local a,b=reaper.GetSetProjectInfo_String(0, "RENDER_METADATA", "CART:"..Tag..Value, set)
  return b
end

--A=ultraschall.Metadata_CART_GetSet("EndDate", "2020-06-27")

ultraschall.ShowLastErrorMessage()
