-- SwapLanes v1.0 (2 May 2022)
-- by kloi34

---------------------------------------------------------------------------------------------------
-- Plugin Info ------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Switch selected notes' lanes around

---------------------------------------------------------------------------------------------------
-- Global Constants -------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

SAMELINE_SPACING = 5               -- value determining spacing between GUI items on the same row
DEFAULT_WIDGET_HEIGHT = 26         -- value determining the height of GUI widgets
DEFAULT_WIDGET_WIDTH = 120         -- value determining the width of GUI widgets
PADDING_WIDTH = 8                  -- value determining window and frame padding
PLUGIN_WINDOW_SIZE = {310, 250}    -- dimensions of the plugin window
LANE_BUTTON_SIZE = {30, 30}        -- dimensions of the lane button

---------------------------------------------------------------------------------------------------
-- Plugin -----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Creates the plugin window
function draw()
    setPluginAppearance()
    imgui.SetNextWindowSize(PLUGIN_WINDOW_SIZE)
    imgui.Begin("SwapLanes", imgui_window_flags.AlwaysAutoResize)
    state.IsWindowHovered = imgui.IsWindowHovered()
    createMenu()
    imgui.End()
end
-- Configures GUI styles (colors and appearance)
function setPluginAppearance()
    -- Plugin Styles
    local rounding = 5 -- determines how rounded corners are
    imgui.PushStyleVar( imgui_style_var.WindowPadding,      { PADDING_WIDTH, 8 } )
    imgui.PushStyleVar( imgui_style_var.FramePadding,       { PADDING_WIDTH, 5 } )
    imgui.PushStyleVar( imgui_style_var.ItemSpacing,        { DEFAULT_WIDGET_HEIGHT / 2 - 1, 4 } )
    imgui.PushStyleVar( imgui_style_var.ItemInnerSpacing,   { SAMELINE_SPACING, 6 } )
    imgui.PushStyleVar( imgui_style_var.WindowBorderSize,   0        )
    imgui.PushStyleVar( imgui_style_var.WindowRounding,     rounding )
    imgui.PushStyleVar( imgui_style_var.ChildRounding,      rounding )
    imgui.PushStyleVar( imgui_style_var.FrameRounding,      rounding )
    imgui.PushStyleVar( imgui_style_var.GrabRounding,       rounding )
    
    -- Plugin Colors
    imgui.PushStyleColor( imgui_col.WindowBg,               { 0.00, 0.00, 0.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBg,                { 0.28, 0.14, 0.24, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         { 0.38, 0.24, 0.34, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          { 0.43, 0.29, 0.39, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBg,                { 0.65, 0.41, 0.48, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          { 0.75, 0.51, 0.58, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       { 0.75, 0.51, 0.58, 0.50 } )
    imgui.PushStyleColor( imgui_col.CheckMark,              { 1.00, 0.81, 0.88, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrab,             { 0.75, 0.56, 0.63, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       { 0.80, 0.61, 0.68, 1.00 } )
    imgui.PushStyleColor( imgui_col.Button,                 { 0.50, 0.31, 0.38, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          { 0.60, 0.41, 0.48, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonActive,           { 0.70, 0.51, 0.58, 1.00 } )
    imgui.PushStyleColor( imgui_col.Header,                 { 1.00, 0.81, 0.88, 0.40 } )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          { 1.00, 0.81, 0.88, 0.50 } )
    imgui.PushStyleColor( imgui_col.HeaderActive,           { 1.00, 0.81, 0.88, 0.54 } )
    imgui.PushStyleColor( imgui_col.Separator,              { 1.00, 0.81, 0.88, 0.30 } )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         { 1.00, 0.81, 0.88, 0.40 } )
end
-- Creates the main menu
function createMenu()
    local vars = {
        newLanes = oneTo(map.GetKeyCount()),
        selectedLanePosition = {}
    }
    retrieveStateVariables(vars)
    imgui.Text("Lane order")
    createHelpMarker("Click on two lane numbers to swap them")
    addPadding()
    drawButtons(vars, true)
    drawButtons(vars, false)
    showSwappingLane(vars)
    addPadding()
    if imgui.Button("Randomize", {3 * LANE_BUTTON_SIZE[1], LANE_BUTTON_SIZE[2]}) then
        local lanes = oneTo(map.GetKeyCount())
        vars.newLanes = {}
        while #lanes > 0 do
            table.insert(vars.newLanes, table.remove(lanes, math.random(1, #lanes)))
        end
    end
    imgui.SameLine(0, SAMELINE_SPACING)
    if imgui.Button("Reset", {2 * LANE_BUTTON_SIZE[1], LANE_BUTTON_SIZE[2]}) then
        vars.newLanes = oneTo(map.GetKeyCount())
    end
    addSeparator()
    if #state.SelectedHitObjects == 0 then
        imgui.Text("Select notes to swap")
        createHelpMarker("ctrl+a to modify the whole map, or drag-select to modify a section of notes)")
    else
        if imgui.Button("Swap Selected Notes' Lanes", {6 * LANE_BUTTON_SIZE[1], 2 * LANE_BUTTON_SIZE[2]}) then
            swapSelectedNotes(vars.newLanes)
        end
    end    
    --[[ fuck setdragdroppayload
    for i = 1, map.GetKeyCount() do
        local currentLane = vars.newLanes[i]
        imgui.Button(currentLane, {30, 30})
        if imgui.BeginDragDropSource() then
            --idk how to use intptr in lua
            --imgui.SetDragDropPayload("Lanes", currentLane, 0)
            --imgui.SetDragDropPayload("Lanes", IntPtr.currentLane, 0) 
            --imgui.SetDragDropPayload("Lanes", currentLane, 100) 
            --imgui.SetDragDropPayload("Lanes", imgui.CreateContext(), 0) 
            vars.selectedLane = currentLane
            imgui.Button(currentLane, {30, 30})
            imgui.EndDragDropSource()
        end
        if imgui.BeginDragDropTarget() then
            imgui.AcceptDragDropPayload("Lanes")
            --if imgui.AcceptDragDropPayload("Lanes") then
            --if imgui.IsMouseReleased(imgui_mouse_button.Left) then
            --if imgui.IsMouseReleased(imgui_mouse_button.Left) then
                vars.newLanes[i] = vars.selectedLane
            --end
            imgui.EndDragDropTarget()
        end
        imgui.SameLine(0, SAMELINE_SPACING)
    end
    --]]
    saveStateVariables(vars)
end

---------------------------------------------------------------------------------------------------
-- Calculation/helper functions
---------------------------------------------------------------------------------------------------

-- Retrieves variables from the state
-- Parameters
--    variables : list of variables and values (Table)
function retrieveStateVariables(variables)
    for key, value in pairs(variables) do
        variables[key] = state.GetValue(key) or value
    end
end
-- Saves variables to the state
-- Parameters
--    variables : list of variables and values (Table)
function saveStateVariables(variables)
    for key, value in pairs(variables) do
        state.SetValue(key, value)
    end
end
-- Adds vertical blank space/padding on the GUI
function addPadding()
    imgui.Dummy({0, 0})
end
-- Draws a horizontal line separator on the GUI
function addSeparator()
    addPadding()
    imgui.Separator()
    addPadding()
end
-- Finds unique offsets of all notes currently selected in the Quaver map editor
-- Returns a list of unique offsets (in increasing order) of selected notes [Table]
function uniqueSelectedNoteOffsets()
    local offsets = {}
    for i, hitObject in pairs(state.SelectedHitObjects) do
        offsets[i] = hitObject.StartTime
    end
    offsets = removeDuplicateValues(offsets)
    offsets = table.sort(offsets, function(a, b) return a < b end)
    return offsets
end
-- Combs through a list and locates unique values
-- Returns a list of only unique values (no duplicates) [Table]
-- Parameters
--    list : list of values [Table]
function removeDuplicateValues(list)
    local hash = {}
    local newList = {}
    for _, value in ipairs(list) do
        -- if the value is not already in the new list
        if (not hash[value]) then
            -- add the value to the new list
            newList[#newList + 1] = value
            hash[value] = true
        end
    end
    return newList
end
-- Creates the lane buttons to swap lanes/see old lanes
-- Parameters
--    vars           : list of menu variables [Table]
--    buttonIsStatic : whether button should be static/non-functioning [Boolean]
function drawButtons(vars, buttonIsStatic)
    local text = buttonIsStatic and "  Old:" or "New:"
    imgui.AlignTextToFramePadding()
    imgui.Text(text)
    for i = 1, map.GetKeyCount() do
        imgui.SameLine(0, SAMELINE_SPACING)
        local currentLane = vars.newLanes[i]
        if buttonIsStatic then
            imgui.Button(" "..i.." ", LANE_BUTTON_SIZE)
        else
            if imgui.Button(currentLane, LANE_BUTTON_SIZE) then
                table.insert(vars.selectedLanePosition, i)
                if #vars.selectedLanePosition == 2 then
                    local lanePosition1 = vars.selectedLanePosition[1]
                    local lanePosition2 = vars.selectedLanePosition[2]
                    local firstLane = vars.newLanes[lanePosition1]
                    local secondLane = vars.newLanes[lanePosition2]
                    vars.newLanes[lanePosition1] = secondLane
                    vars.newLanes[lanePosition2] = firstLane
                    vars.selectedLanePosition = {}
                end
            end
        end
    end
end
-- Shows the lane currently being swapped
-- Parameters
--    vars : list of menu variables [Table]
function showSwappingLane(vars)
    if #vars.selectedLanePosition > 0 then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
        imgui.Button(vars.newLanes[vars.selectedLanePosition[1]], LANE_BUTTON_SIZE)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end
-- Swaps the lanes of selected notes
-- Parameters
--    newLanes : new numerical order of the lanes [Table]
function swapSelectedNotes(newLanes)
    local offsets = uniqueSelectedNoteOffsets()
    local startOffset = offsets[1]
    local endOffset = offsets[#offsets]
    local newHitObjects = {}
    local hitObjectsToRemove = {}
    for i, hitObject in pairs(map.HitObjects) do
        if hitObject.StartTime >= startOffset and hitObject.StartTime <= endOffset then
            table.insert(newHitObjects, utils.CreateHitObject(hitObject.StartTime,
                         newLanes[hitObject.Lane], hitObject.EndTime))
            table.insert(hitObjectsToRemove, hitObject)
        end
    end
    actions.RemoveHitObjectBatch(hitObjectsToRemove)
    actions.PlaceHitObjectBatch(newHitObjects)
    actions.SetHitObjectSelection(newHitObjects)
end
-- Creates a tooltip box when an IMGUI item is hovered over
-- Parameters
--    text : text to appear in the tooltip box [String]
function createToolTip(text)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
        imgui.Text(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end
-- Creates an inline, grayed-out '(?)' symbol that shows a tooltip box when hovered over
-- Parameters
--    text : text to appear in the tooltip box [String]
function createHelpMarker(text)
    imgui.SameLine()
    imgui.TextDisabled("(?)")
    createToolTip(text)
end
-- Creates an ascending list of whole numbers starting from 1
-- Returns the list of numbers [Table]
-- Parameters
--    x : max number in the list (1 to x) [Int]
function oneTo(x)
    local nums = {}
    for i = 1, x do
      table.insert(nums, i)
    end
    return nums
end
