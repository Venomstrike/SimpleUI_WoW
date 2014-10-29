local SUI = LibStub("AceAddon-3.0"):NewAddon("SUI", "AceTimer-3.0", "AceConsole-3.0")
-- SimpleUI | Designer to create simple Frames with UI Elements


--------------Global Variables----------------
local MainFrame
local timer

local delMode = false
local movMode = true
local selMode = false
local frametbl = {}
local framecount = 1
local acName = ""
local acIndex
local colortbl = {}
local projName = "testproject"
local projtbl = {}
----------------------------------------------


function SUI:OnInitialize()


	--self.db = LibStub("AceDB-3.0"):New("SUIDB")
	--self.db.RegisterCallback(SUI, "OnDatabaseShutdown", "SaveProject")


	local resolutions = {GetScreenResolutions()}
	res = resolutions[GetCurrentResolution()]
	sizetbl = {}

	if res == "800x600" then sizetbl[1] = 185; sizetbl[2] = 135 end
	if res == "1024x768" then sizetbl[1] = 185; sizetbl[2] = 135 end
	if res == "1152x864" then sizetbl[1] = 180; sizetbl[2] = 135 end
	if res == "1280x1024" then sizetbl[1] = 170; sizetbl[2] = 135 end
	if res == "1366x768" then sizetbl[1] = 240; sizetbl[2] = 135 end
	if res == "1920x1080" then sizetbl[1] = 245; sizetbl[2] = 135 end

	MainFrame = self:CreateMainFrame(sizetbl)

	frametbl[1] = MainFrame.designer

	self:RegisterChatCommand("sui", function () MainFrame:Show() end)

	self:ScheduleRepeatingTimer("AutoSave", 5)

	if SUIDB then MainFrame:Hide(); self:ProjectHandling() end

	self:Print("AddOn successfully loaded!")

	--MainFrame:Hide()

end


-----------------Core Part-----------------

function SUI:CreateMainFrame(sizetbl) -- Creates the complete designer frame with all sub-frames (much functions in the OnClick-Events)
	

	backdropS = {
	  -- path to the background texture
	  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",  
	  -- path to the border texture
	  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	  -- true to repeat the background texture to fill the frame, false to scale it
	  tile = true,
	  -- size (width or height) of the square repeating background tiles (in pixels)
	  tileSize = 32,
	  -- thickness of edge segments and square size of edge corners (in pixels)
	  edgeSize = 32,
	  -- distance from the edges of the frame to those of the background texture (in pixels)
	  insets = {
	    left = 11,
	    right = 12,
	    top = 12,
	    bottom = 11
	  }
	}

	-- Main Frame
	frame = CreateFrame("Frame", "MainFrame", UIParent) 
	frame:SetSize(WorldFrame:GetWidth()+sizetbl[1], WorldFrame:GetHeight()+sizetbl[2])
	frame:SetFrameStrata("DIALOG")
	frame:SetPoint("CENTER")
	texture = frame:CreateTexture()
	texture:SetAllPoints() 
	texture:SetTexture(0.23,0.23,0.23,1) 
	frame.background = texture
	frame:EnableMouse(true)
	--frame:SetMovable(true)
	--frame:SetResizable(true)
	--frame:SetMinResize(460, 500)
	--frame:SetBackdrop(backdropS)

	frame.designer = CreateFrame("Frame", "MainFrame_designer", frame) 
	frame.designer:SetSize(frame:GetWidth()-90, frame:GetHeight()-110)
	frame.designer:SetPoint("TOPLEFT", frame, 30, -30)
	texture = frame.designer:CreateTexture()
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,1) 
	frame.designer.background = texture
	frame.designer:EnableMouse(true)
	frame.designer:SetResizable(true)
	frame.designer:SetMinResize(30, 30)
	frame.designer:SetMaxResize(frame:GetWidth()-60, frame:GetHeight()-105)

	frame.designer.resize = CreateFrame("Frame", "MainFrame_designer_resize", frame.designer) 
	frame.designer.resize:SetSize(10, 10) 
	frame.designer.resize:SetPoint("BOTTOMRIGHT", 10, 0) 
	texturers = frame.designer.resize:CreateTexture() 
	texturers:SetAllPoints() 
	texturers:SetTexture(0,0,0,1) 
	frame.designer.resize.background = texturers
	frame.designer.resize:EnableMouse(true)
	frame.designer.resize:SetScript("OnMouseDown", function (self, value) MainFrame.designer:StartSizing() end)
	frame.designer.resize:SetScript("OnMouseUp", function (self, value) MainFrame.designer:StopMovingOrSizing(); MainFrame.designer:SetPoint("TOPLEFT", MainFrame, 30, -30); if MainFrame.designer:GetWidth() + 60 <= 460 then MainFrame:SetMinResize(460, MainFrame.designer:GetHeight() + 90) return end; MainFrame:SetMinResize(MainFrame.designer:GetWidth() + 60, MainFrame.designer:GetHeight() + 90) end)


	frame.sel = CreateFrame("Frame", "MainFrame_sel", frame) 
	frame.sel:SetSize(430, 60)
	frame.sel:SetFrameStrata("DIALOG")
	frame.sel:SetPoint("BOTTOMLEFT", frame, 685, 0)
	texture = frame.sel:CreateTexture()
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,0.3) 
	frame.sel.background = texture
	--frame.sel:SetBackdrop(backdropS)
	--frame.sel:SetBackdropBorderColor(0.2,0.2,0.2,1)

	frame.sel.ext = CreateFrame("Button", "MainFrame_selexb", frame.sel, "UIPanelButtonTemplate")
	frame.sel.ext:SetSize(45, 45)
	frame.sel.ext:SetPoint("BOTTOMRIGHT", frame.sel, -10, 8)
	frame.sel.ext.text = _G["MainFrame_selexb" .. "Text"]
	frame.sel.ext.text:SetText("EXT")
	frame.sel.ext:SetScript("OnClick", function() SUI:StartExt() end )

	frame.sel.n = frame.sel:CreateFontString(nil, "OVERLAY")
	frame.sel.n:SetPoint("TOPLEFT", frame.sel, "TOPLEFT", 5, -5)
	frame.sel.n:SetFont("Fonts\\ARIALN.TTF", 15, "OUTLINE")
	frame.sel.n:SetJustifyH("LEFT")
	frame.sel.n:SetShadowOffset(1, -1)
	frame.sel.n:SetTextColor(1, 1, 1)
	frame.sel.n:SetText("Name:")

	frame.sel.t = frame.sel:CreateFontString(nil, "OVERLAY", frame.sel)
	frame.sel.t:SetPoint("BOTTOMLEFT", frame.sel, "BOTTOMLEFT", 5, 10)
	frame.sel.t:SetFont("Fonts\\ARIALN.TTF", 15, "OUTLINE")
	frame.sel.t:SetJustifyH("LEFT")
	frame.sel.t:SetShadowOffset(1, -1)
	frame.sel.t:SetTextColor(1, 1, 1)
	frame.sel.t:SetText("Text:") 
	frame.sel.te = CreateFrame("EditBox", "MainFrame_sel_textEB", frame.sel, "InputBoxTemplate")
	frame.sel.te:SetSize(100, 20)
	frame.sel.te:SetPoint("BOTTOMLEFT", frame.sel, 55, 5)
	frame.sel.te:SetText("")
	frame.sel.te:SetScript("OnEnterPressed", function() index = acIndex; accframe = frametbl[index]; SUI:ModAttr(accframe, MainFrame.sel.te:GetText())  end )

	frame.sel.s = frame.sel:CreateFontString(nil, "OVERLAY")
	frame.sel.s:SetPoint("CENTER", frame.sel, "CENTER", 0, 15)
	frame.sel.s:SetFont("Fonts\\ARIALN.TTF", 15, "OUTLINE")
	frame.sel.s:SetJustifyH("LEFT")
	frame.sel.s:SetShadowOffset(1, -1)
	frame.sel.s:SetTextColor(1, 1, 1)
	frame.sel.s:SetText("Size:")
	frame.sel.se = CreateFrame("EditBox", "MainFrame_sel_s1EB", frame.sel, "InputBoxTemplate")
	frame.sel.se:SetSize(30, 20)
	frame.sel.se:SetPoint("CENTER", frame.sel, 50, 15)
	frame.sel.se:SetText("")
	frame.sel.se:SetScript("OnEnterPressed", function() SUI:ModVetor(MainFrame.sel.n:GetText(), nil, nil, nil, nil, "se") end )

	frame.sel.seb1 = CreateFrame("Button", "MainFrame_sb1B", frame.sel, "UIPanelButtonTemplate")
	frame.sel.seb1:SetSize(20, 10)
	frame.sel.seb1:SetPoint("CENTER", frame.sel, 70, 20)
	frame.sel.seb1.text = _G["MainFrame_sb1B" .. "Text"]
	frame.sel.seb1.text:SetText("+")
	frame.sel.seb1:SetScript("OnClick", function() SUI:ModVetor(MainFrame.sel.n:GetText(), MainFrame.sel.se:GetText(), nil, nil, nil, "width+") end )
	frame.sel.seb2 = CreateFrame("Button", "MainFrame_sb2B", frame.sel, "UIPanelButtonTemplate")
	frame.sel.seb2:SetSize(20, 10)
	frame.sel.seb2:SetPoint("CENTER", frame.sel, 70, 10)
	frame.sel.seb2.text = _G["MainFrame_sb2B" .. "Text"]
	frame.sel.seb2.text:SetText("-")
	frame.sel.seb2:SetScript("OnClick", function() SUI:ModVetor(MainFrame.sel.n:GetText(), MainFrame.sel.se:GetText(), nil, nil, nil, "width-") end )

	frame.sel.se2 = CreateFrame("EditBox", "MainFrame_sel_s2EB", frame.sel, "InputBoxTemplate")
	frame.sel.se2:SetSize(30, 20)
	frame.sel.se2:SetPoint("CENTER", frame.sel, 110, 15)
	frame.sel.se2:SetText("")
	frame.sel.se2:SetScript("OnEnterPressed", function() SUI:ModVetor(MainFrame.sel.n:GetText(), nil, nil, nil, nil, "se2") end )

	frame.sel.seb3 = CreateFrame("Button", "MainFrame_sb3B", frame.sel, "UIPanelButtonTemplate")
	frame.sel.seb3:SetSize(20, 10)
	frame.sel.seb3:SetPoint("CENTER", frame.sel, 130, 20)
	frame.sel.seb3.text = _G["MainFrame_sb3B" .. "Text"]
	frame.sel.seb3.text:SetText("+")
	frame.sel.seb3:SetScript("OnClick", function() SUI:ModVetor(MainFrame.sel.n:GetText(), nil, MainFrame.sel.se2:GetText(), nil, nil, "high+") end )
	frame.sel.seb4 = CreateFrame("Button", "MainFrame_sb4B", frame.sel, "UIPanelButtonTemplate")
	frame.sel.seb4:SetSize(20, 10)
	frame.sel.seb4:SetPoint("CENTER", frame.sel, 130, 10)
	frame.sel.seb4.text = _G["MainFrame_sb4B" .. "Text"]
	frame.sel.seb4.text:SetText("-")
	frame.sel.seb4:SetScript("OnClick", function() SUI:ModVetor(MainFrame.sel.n:GetText(), nil, MainFrame.sel.se2:GetText(), nil, nil, "high-") end )



	frame.sel.p = frame.sel:CreateFontString(nil, "OVERLAY")
	frame.sel.p:SetPoint("CENTER", frame.sel, "CENTER", 0, -15)
	frame.sel.p:SetFont("Fonts\\ARIALN.TTF", 15, "OUTLINE")
	frame.sel.p:SetJustifyH("LEFT")
	frame.sel.p:SetShadowOffset(1, -1)
	frame.sel.p:SetTextColor(1, 1, 1)
	frame.sel.p:SetText("Position:")

	frame.sel.pe = CreateFrame("EditBox", "MainFrame_sel_p1EB", frame.sel, "InputBoxTemplate")
	frame.sel.pe:SetSize(30, 20)
	frame.sel.pe:SetPoint("CENTER", frame.sel, 50, -15)
	frame.sel.pe:SetText("")
	frame.sel.pe:SetScript("OnEnterPressed", function() SUI:ModVetor(MainFrame.sel.n:GetText(), nil, nil, nil, nil, "pe") end )

	frame.sel.peb1 = CreateFrame("Button", "MainFrame_pb1B", frame.sel, "UIPanelButtonTemplate")
	frame.sel.peb1:SetSize(20, 10)
	frame.sel.peb1:SetPoint("CENTER", frame.sel, 70, -10)
	frame.sel.peb1.text = _G["MainFrame_pb1B" .. "Text"]
	frame.sel.peb1.text:SetText("+")
	frame.sel.peb1:SetScript("OnClick", function() SUI:ModVetor(MainFrame.sel.n:GetText(), nil, nil, MainFrame.sel.pe:GetText(), nil, "posl+") end )
	frame.sel.peb2 = CreateFrame("Button", "MainFrame_pb2B", frame.sel, "UIPanelButtonTemplate")
	frame.sel.peb2:SetSize(20, 10)
	frame.sel.peb2:SetPoint("CENTER", frame.sel, 70, -20)
	frame.sel.peb2.text = _G["MainFrame_pb2B" .. "Text"]
	frame.sel.peb2.text:SetText("-")
	frame.sel.peb2:SetScript("OnClick", function() SUI:ModVetor(MainFrame.sel.n:GetText(), nil, nil, MainFrame.sel.pe:GetText(), nil, "posl-") end )

	frame.sel.pe2 = CreateFrame("EditBox", "MainFrame_sel_p2EB", frame.sel, "InputBoxTemplate")
	frame.sel.pe2:SetSize(30, 20)
	frame.sel.pe2:SetPoint("CENTER", frame.sel, 110, -15)
	frame.sel.pe2:SetText("")
	frame.sel.pe2:SetScript("OnEnterPressed", function() SUI:ModVetor(MainFrame.sel.n:GetText(), nil, nil, nil, nil, "pe2") end )

	frame.sel.peb3 = CreateFrame("Button", "MainFrame_pb3B", frame.sel, "UIPanelButtonTemplate")
	frame.sel.peb3:SetSize(20, 10)
	frame.sel.peb3:SetPoint("CENTER", frame.sel, 130, -10)
	frame.sel.peb3.text = _G["MainFrame_pb3B" .. "Text"]
	frame.sel.peb3.text:SetText("+")
	frame.sel.peb3:SetScript("OnClick", function() SUI:ModVetor(MainFrame.sel.n:GetText(), nil, nil, nil, MainFrame.sel.pe2:GetText(), "posb+") end )
	frame.sel.peb4 = CreateFrame("Button", "MainFrame_pb4B", frame.sel, "UIPanelButtonTemplate")
	frame.sel.peb4:SetSize(20, 10)
	frame.sel.peb4:SetPoint("CENTER", frame.sel, 130, -20)
	frame.sel.peb4.text = _G["MainFrame_pb4B" .. "Text"]
	frame.sel.peb4.text:SetText("-")
	frame.sel.peb4:SetScript("OnClick", function() SUI:ModVetor(MainFrame.sel.n:GetText(), nil, nil, nil, MainFrame.sel.pe2:GetText(), "posb-") end )




	frame.modes = frame:CreateFontString(nil, "OVERLAY")
	frame.modes:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
	frame.modes:SetFont("Fonts\\ARIALN.TTF", 15, "OUTLINE")
	frame.modes:SetJustifyH("LEFT")
	frame.modes:SetShadowOffset(1, -1)
	frame.modes:SetTextColor(1, 1, 1)
	frame.modes:SetText("Move Mode")

	--[[mover frame
	frame.move = CreateFrame("Frame", "MainFrame_move", frame) 
	frame.move:SetSize(10, 10) 
	frame.move:SetPoint("TOPRIGHT", 10, 0) 
	texturers = frame.move:CreateTexture() 
	texturers:SetAllPoints()
	texturers:SetTexture(0,0,0,1) 
	frame.move.background = texturers
	frame.move:EnableMouse(true)
	frame.move:SetScript("OnMouseDown", function (self, value) MainFrame:StartMoving() end) 
	frame.move:SetScript("OnMouseUp", function (self, value) MainFrame:StopMovingOrSizing() end)

	-- resize frame
	frame.resize = CreateFrame("Frame", "MainFrame_resize", frame) 
	frame.resize:SetSize(10, 10) 
	frame.resize:SetPoint("BOTTOMRIGHT", 10, 0) 
	texturers = frame.resize:CreateTexture() 
	texturers:SetAllPoints() 
	texturers:SetTexture(0,0,0,1) 
	frame.resize.background = texturers
	frame.resize:EnableMouse(true)
	frame.resize:SetScript("OnMouseDown", function (self, value) MainFrame:StartSizing() end) 
	frame.resize:SetScript("OnMouseUp", function (self, value) MainFrame:StopMovingOrSizing(); MainFrame.designer:SetMaxResize(MainFrame:GetWidth() - 60, MainFrame:GetHeight() - 90); SUI:Print(MainFrame:GetWidth() .. " " .. MainFrame:GetHeight()) end)]]

	--button close
	frame.c = CreateFrame("Button", "MainFrame_CloseB", frame, "UIPanelButtonTemplate")
	frame.c:SetSize(70, 20)
	frame.c:SetPoint("BOTTOMLEFT", frame, 385, 30)
	frame.c.text = _G["MainFrame_CloseB" .. "Text"]
	frame.c.text:SetText("Close")
	frame.c:SetScript("OnClick", function() MainFrame:Hide() end )

	frame.b = CreateFrame("Button", "MainFrame_AddButtonB", frame, "UIPanelButtonTemplate")
	frame.b:SetSize(80, 20)
	frame.b:SetPoint("BOTTOMLEFT", frame, 5, 5)
	frame.b.text = _G["MainFrame_AddButtonB" .. "Text"]
	frame.b.text:SetText("Add Button")
	frame.b:SetScript("OnClick", function() if MainFrame.n:GetText() == "" or  MainFrame.t:GetText() == "" then return end SUI:AddButton(MainFrame.n:GetText(), MainFrame.t:GetText()); MainFrame.n:SetText(""); MainFrame.t:SetText("") end )

	frame.t = CreateFrame("Button", "MainFrame_AddTextB", frame, "UIPanelButtonTemplate")
	frame.t:SetSize(80, 20)
	frame.t:SetPoint("BOTTOMLEFT", frame, 90, 5)
	frame.t.text = _G["MainFrame_AddTextB" .. "Text"]
	frame.t.text:SetText("Add Text")
	frame.t:SetScript("OnClick", function() if MainFrame.n:GetText() == "" or  MainFrame.t:GetText() == "" then return end SUI:AddText(MainFrame.n:GetText(), MainFrame.t:GetText()); MainFrame.n:SetText(""); MainFrame.t:SetText("") end )

	frame.cb = CreateFrame("Button", "MainFrame_AddButtonCB", frame, "UIPanelButtonTemplate")
	frame.cb:SetSize(110, 20)
	frame.cb:SetPoint("BOTTOMLEFT", frame, 460, 30)
	frame.cb.text = _G["MainFrame_AddButtonCB" .. "Text"]
	frame.cb.text:SetText("Add CheckBox")
	frame.cb:SetScript("OnClick", function() if MainFrame.n:GetText() == "" then return end SUI:AddCheckButton(MainFrame.n:GetText(), MainFrame.t:GetText()); MainFrame.n:SetText(""); MainFrame.t:SetText("") end )

	frame.d = CreateFrame("Button", "MainFrame_AddButtondd", frame, "UIPanelButtonTemplate")
	frame.d:SetSize(110, 20)
	frame.d:SetPoint("BOTTOMLEFT", frame, 460, 5)
	frame.d.text = _G["MainFrame_AddButtondd" .. "Text"]
	frame.d.text:SetText("Add DropDown")
	frame.d:SetScript("OnClick", function() if MainFrame.n:GetText() == "" or  MainFrame.t:GetText() == "" then return end SUI:AddDropDown(MainFrame.n:GetText(), MainFrame.t:GetText()); MainFrame.n:SetText(""); MainFrame.t:SetText("") end )

	frame.i = CreateFrame("Button", "MainFrame_AddButtonib", frame, "UIPanelButtonTemplate")
	frame.i:SetSize(95, 20)
	frame.i:SetPoint("BOTTOMLEFT", frame, 575, 5)
	frame.i.text = _G["MainFrame_AddButtonib" .. "Text"]
	frame.i.text:SetText("Add Icon")
	frame.i:SetScript("OnClick", function() if MainFrame.n:GetText() == "" or  MainFrame.t:GetText() == "" then return end SUI:AddIcon(MainFrame.n:GetText(), MainFrame.t:GetText()); MainFrame.n:SetText(""); MainFrame.t:SetText("") end )

	frame.f = CreateFrame("Button", "MainFrame_AddButtonfb", frame, "UIPanelButtonTemplate")
	frame.f:SetSize(95, 20)
	frame.f:SetPoint("BOTTOMLEFT", frame, 575, 30)
	frame.f.text = _G["MainFrame_AddButtonfb" .. "Text"]
	frame.f.text:SetText("Add Frame")
	frame.f:SetScript("OnClick", function() if MainFrame.n:GetText() == "" or  MainFrame.t:GetText() == "" then return end SUI:AddFrame(MainFrame.n:GetText(), MainFrame.t:GetText()); MainFrame.n:SetText(""); MainFrame.t:SetText("") end )




	frame.pb = CreateFrame("Button", "MainFrame_AddButtonpb", frame, "UIPanelButtonTemplate")
	frame.pb:SetSize(80, 20)
	frame.pb:SetPoint("BOTTOMRIGHT", frame, -5, 30)
	frame.pb.text = _G["MainFrame_AddButtonpb" .. "Text"]
	frame.pb.text:SetText("Project")
	frame.pb:SetScript("OnClick", function() SUI:OpenProject() end )

	frame.ob = CreateFrame("Button", "MainFrame_AddButtonob", frame, "UIPanelButtonTemplate")
	frame.ob:SetSize(80, 20)
	frame.ob:SetPoint("BOTTOMRIGHT", frame, -5, 5)
	frame.ob.text = _G["MainFrame_AddButtonob" .. "Text"]
	frame.ob.text:SetText("Options")
	frame.ob:SetScript("OnClick", function() SUI:OpenOptions() end )




	frame.mm = CreateFrame("Button", "MainFrame_MoveB", frame, "UIPanelButtonTemplate")
	frame.mm:SetSize(80, 20)
	frame.mm:SetPoint("BOTTOMLEFT", frame, 5, 30)
	frame.mm.text = _G["MainFrame_MoveB" .. "Text"]
	frame.mm.text:SetText("Move")
	frame.mm:SetScript("OnClick", function() delMode = false; selMode = false; movMode = true; MainFrame.sel:Hide(); MainFrame.modes:SetText("Move Mode") end )

	frame.dm = CreateFrame("Button", "MainFrame_DeleteB", frame, "UIPanelButtonTemplate")
	frame.dm:SetSize(80, 20)
	frame.dm:SetPoint("BOTTOMLEFT", frame, 90, 30)
	frame.dm.text = _G["MainFrame_DeleteB" .. "Text"]
	frame.dm.text:SetText("Delete")
	frame.dm:SetScript("OnClick", function() delMode = true; selMode = false; movMode = false; MainFrame.sel:Hide(); MainFrame.modes:SetText("Delete Mode") end )

	frame.sm = CreateFrame("Button", "MainFrame_SelectB", frame, "UIPanelButtonTemplate")
	frame.sm:SetSize(80, 20)
	frame.sm:SetPoint("BOTTOMLEFT", frame, 175, 30)
	frame.sm.text = _G["MainFrame_SelectB" .. "Text"]
	frame.sm.text:SetText("Select")
	frame.sm:SetScript("OnClick", function() delMode = false; selMode = true; movMode = false; MainFrame.modes:SetText("Select Mode") end )

	frame.cb = CreateFrame("Button", "MainFrame_CreateB", frame, "UIPanelButtonTemplate")
	frame.cb:SetSize(120, 20)
	frame.cb:SetPoint("BOTTOMLEFT", frame, 260, 30)
	frame.cb.text = _G["MainFrame_CreateB" .. "Text"]
	frame.cb.text:SetText("Create Code")
	frame.cb:SetScript("OnClick", function() SUI:CreateCode() end )



	frame.e = CreateFrame("Button", "MainFrame_AddEditBoxB", frame, "UIPanelButtonTemplate")
	frame.e:SetSize(90, 20)
	frame.e:SetPoint("BOTTOMLEFT", frame, 175, 5)
	frame.e.text = _G["MainFrame_AddEditBoxB" .. "Text"]
	frame.e.text:SetText("Add EditBox")
	frame.e:SetScript("OnClick", function() if MainFrame.n:GetText() == "" or  MainFrame.t:GetText() == "" then return end SUI:AddEditBox(MainFrame.n:GetText(), MainFrame.t:GetText()); MainFrame.n:SetText(""); MainFrame.t:SetText("") end )

	frame.n = CreateFrame("EditBox", "MainFrame_nameEB", frame, "InputBoxTemplate")
	frame.n:SetSize(85, 20)
	frame.n:SetPoint("BOTTOMLEFT", frame, 275, 5)
	frame.n:SetText("Name")

	frame.t = CreateFrame("EditBox", "MainFrame_textEB", frame, "InputBoxTemplate")
	frame.t:SetSize(85, 20)
	frame.t:SetPoint("BOTTOMLEFT", frame, 370, 5)
	frame.t:SetText("Text")


	frame.ext = CreateFrame("Frame", "MainFrame_ext", frame) 
	frame.ext:SetSize(380, 420)
	frame.ext:SetPoint("CENTER", frame, 220, 0)
	texture = frame.ext:CreateTexture()
	texture:SetAllPoints() 
	texture:SetTexture(0,0,0,1) 
	frame.ext.background = texture

	frame.ext.s = CreateFrame("Button", "MainFrame_extsb", frame.ext, "UIPanelButtonTemplate")
	frame.ext.s:SetSize(370, 30)
	frame.ext.s:SetPoint("BOTTOMRIGHT", frame.ext, -5, 5)
	frame.ext.s.text = _G["MainFrame_extsb" .. "Text"]
	frame.ext.s.text:SetText("Save")

	frame.ext:Hide()


	frame.sel:Hide()

	return frame

end


-- frame:SetPoint("BOTTOMLEFT", MainFrame.designer, SUI:GetRPos(frame:GetLeft(), frame:GetBottom(), true, false), SUI:GetRPos(frame:GetLeft(), frame:GetBottom(), false, true)) | to set frames to the designer after moved (unused)

function SUI:AddButton(name, text) -- adds an dynamic created button to the designer frame and adds them to the frametbl

	account = framecount + 1
	framecount = framecount + 1

	local frame = CreateFrame("Button", name .. ";" .. account, MainFrame.designer, "UIPanelButtonTemplate")
	frame:SetSize(80, 25)
	frame:SetPoint("CENTER", MainFrame.designer, 0, 0)
	frame.text = _G[name .. ";" .. account .. "Text"]
	frame.text:SetText(text)
	frame:SetMovable(true)
	frame:SetScript("OnMouseDown", function (self, value) if movMode == true then frame:StartMoving() elseif delMode == true then frame:Hide() end end) 
	frame:SetScript("OnMouseUp", function (self, value) if movMode == true then frame:StopMovingOrSizing(); elseif selMode == true then SUI:FrameSelect(frame); MainFrame.sel:Show() end end)
	frame.i = "Button"

	frametbl[account] = frame;

end

function SUI:AddText(name, text) -- adds an dynamic created FontString to the designer frame and adds them to the frametbl

	account = framecount + 1
	framecount = framecount + 1

	local frame = CreateFrame("Frame", name .. ";" .. account .. ";" .. "_subframe", MainFrame.designer) 
	frame:SetSize(50, 35) 
	frame:SetPoint("CENTER", MainFrame.designer) 
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetScript("OnMouseDown", function (self, value) if movMode == true then frame:StartMoving() elseif delMode == true then frame.s:Hide(); frame:Hide() end end) 
	frame:SetScript("OnMouseUp", function (self, value) if movMode == true then frame:StopMovingOrSizing(); elseif selMode == true then SUI:FrameSelect(frame); MainFrame.sel:Show() end end)
	
	frame.s = MainFrame.designer:CreateFontString(name .. ";" .. account) 
	frame.s:SetPoint("CENTER", frame, "CENTER", 0, 0)
	frame.s:SetFont("Fonts\\ARIALN.TTF", 15, "OUTLINE")
	frame.s:SetJustifyH("LEFT")
	frame.s:SetShadowOffset(1, -1)
	frame.s:SetTextColor(1, 1, 1)
	frame.s:SetText(text)
	frame.s.s = 15
	frame.s.f = "Fonts\\ARIALN.TTF"
	frame.i = "FontString"

	frametbl[account] = frame;

end

function SUI:AddCheckButton(name, text) -- adds an dynamic created CheckBox to the designer frame and adds them to the frametbl
	
	account = framecount + 1
	framecount = framecount + 1

	local frame = CreateFrame("CheckButton", name .. ";" .. account, MainFrame.designer, "UICheckButtonTemplate")
	frame:SetSize(28, 28)
	frame:SetPoint("CENTER", MainFrame.designer, 0, 0)
	frame.text = _G[name .. ";" .. account .. "Text"]
	frame.text:SetText(text)
	frame:SetChecked(true)
	frame:SetMovable(true)
	frame:Disable()
	frame:SetScript("OnMouseDown", function (self, value) if movMode == true then frame:StartMoving() elseif delMode == true then frame:Hide() end end) 
	frame:SetScript("OnMouseUp", function (self, value) if movMode == true then frame:StopMovingOrSizing(); elseif selMode == true then SUI:FrameSelect(frame); MainFrame.sel:Show() end end)
	frame.i = "CheckButton"

	frametbl[account] = frame;

end

function SUI:AddFrame (name, text)
	
	-- add frame

end

function SUI:AddIcon(name, spellid)
	
	-- adds frame witch icon path set to it

end

function SUI:AddDropDown(name, text) -- adds an dynamic created DropDownMenu to the designer frame and adds them to the frametbl
	
	account = framecount + 1
	framecount = framecount + 1


	local frame = CreateFrame("Button", name .. ";" .. account, MainFrame.designer, "UIDropDownMenuTemplate") 
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", MainFrame.designer, 0, 0)
	frame:SetMovable(true)
	 
	local items = {
		text,
	}
	 
	--local function OnClick(self)
	  --UIDropDownMenu_SetSelectedID(frame, self:GetID())
	--end
	 
	local function initialize(self, level)
	   local info = UIDropDownMenu_CreateInfo()
	   for k,v in pairs(items) do
	      info = UIDropDownMenu_CreateInfo()
	      info.text = v
	      info.value = v
	      info.func = OnClick
	      UIDropDownMenu_AddButton(info, level)
	   end
	end
	 
	 
	UIDropDownMenu_Initialize(frame, initialize)
	UIDropDownMenu_SetWidth(frame, 100);
	UIDropDownMenu_SetButtonWidth(frame, 124)
	UIDropDownMenu_SetSelectedID(frame, 1)
	UIDropDownMenu_JustifyText(frame, "LEFT")
	UIDropDownMenu_DisableDropDown(frame) 

	
	frame.s = CreateFrame("Frame", name .. ";" .. account .. ";" .. "_subframe", frame) 
	frame.s:SetSize(95, 10) 
	frame.s:SetPoint("BOTTOMLEFT", frame, 25, 0) 
	frame.s:EnableMouse(true)
	frame.s:SetMovable(true)
	frame.s:SetFrameStrata("DIALOG")
	texture = frame.s:CreateTexture()
	texture:SetAllPoints() 
	texture:SetTexture(0.3,0.3,0.3,1) 
	frame.s.background = texture
	frame.s:SetScript("OnMouseDown", function (self, value) if movMode == true then frame:StartMoving() elseif delMode == true then frame.s:Hide(); frame:Hide() end end) 
	frame.s:SetScript("OnMouseUp", function (self, value) if movMode == true then frame:StopMovingOrSizing(); elseif selMode == true then SUI:FrameSelect(frame); MainFrame.sel:Show() end end)
	frame.items = text
	frame.i = "DropDown"

	frametbl[account] = frame;

end

function SUI:AddEditBox(name, text) -- adds an dynamic created EditBox to the designer frame and adds them to the frametbl
	
	account = framecount + 1
	framecount = framecount + 1

	local frame = CreateFrame("EditBox", name .. ";" .. account, MainFrame.designer, "InputBoxTemplate")
	frame:SetSize(85, 20)
	frame:SetPoint("CENTER", MainFrame.designer, 0, 0)
	frame:SetText(text)
	frame:SetMovable(true)
	frame:Disable()
	frame:SetScript("OnMouseDown", function (self, value) if movMode == true then frame:StartMoving() elseif delMode == true then frame:Hide() end end) 
	frame:SetScript("OnMouseUp", function (self, value) if movMode == true then frame:StopMovingOrSizing(); elseif selMode == true then SUI:FrameSelect(frame); MainFrame.sel:Show() end end)
	frame.i = "EditBox"

	frametbl[account] = frame;

end

function SUI:UpdateObjects(name, x, y, scale, ftype) -- for some debug purpose
	
	dy = MainFrame.designer:GetBottom()
	dx = MainFrame.designer:GetLeft()

	ry = y - dy
	rx = x - dx

	self:Print("From Bottom: " .. math.floor(ry+0.5) .. " | From Left: " .. math.floor(rx+0.5))

end

function SUI:ModVetor(name, width, high, x, y, mod) -- modificates the size or the poition of the selected frame 

	if not width and not high and not x and not y then

		index = acIndex

		accframe = frametbl[index]

		if mod == "se" then
			if accframe:GetObjectType() == "Frame" then accframe.s:SetFont("Fonts\\ARIALN.TTF", tonumber(MainFrame.sel.se:GetText()), "OUTLINE"); accframe.s.s = MainFrame.sel.se:GetText() return end
			accframe:SetWidth(tonumber(MainFrame.sel.se:GetText()))
		elseif mod == "se2" then
			accframe:SetHeight(tonumber(MainFrame.sel.se2:GetText()))
		elseif mod == "pe" then
			accframe:SetPoint("BOTTOMLEFT", MainFrame.designer, tonumber(MainFrame.sel.pe:GetText()), tonumber(MainFrame.sel.pe2:GetText()))
		elseif mod == "pe2" then
			accframe:SetPoint("BOTTOMLEFT", MainFrame.designer, tonumber(MainFrame.sel.pe:GetText()), tonumber(MainFrame.sel.pe2:GetText()))
		else
		-- not triggered
		end

	 return

	end

	widthr = tonumber(width)

	heightr = tonumber(high)

	xr = tonumber(x)

	yr = tonumber(y)

	index = acIndex

	accframe = frametbl[index]

	ftype = accframe:GetObjectType()

	if ftype == "Frame" then ftype = accframe.s:GetObjectType() end


	if ftype == "FontString" then


		if mod == "width+" then
			accframe.s.s = accframe.s.s + 1
			accframe.s:SetFont("Fonts\\ARIALN.TTF", accframe.s.s, "OUTLINE")
			accframe:SetSize(accframe:GetWidth(), accframe:GetHeight() + 1) 
			MainFrame.sel.se:SetText(accframe.s.s) 
		elseif mod == "width-" then
			accframe.s.s = accframe.s.s - 1
			accframe.s:SetFont("Fonts\\ARIALN.TTF", accframe.s.s, "OUTLINE")
			accframe:SetSize(accframe:GetWidth(), accframe:GetHeight() - 1) 
			MainFrame.sel.se:SetText(accframe.s.s)
		elseif mod == "posl+" then
			accframe:SetPoint("BOTTOMLEFT", MainFrame.designer, SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), true, false) + 1, SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), false, true))
			MainFrame.sel.pe:SetText(SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), true, false))
		elseif mod == "posl-" then
			accframe:SetPoint("BOTTOMLEFT", MainFrame.designer, SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), true, false) - 1, SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), false, true))
			MainFrame.sel.pe:SetText(SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), true, false))
		elseif mod == "posb+" then
			accframe:SetPoint("BOTTOMLEFT", MainFrame.designer, SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), true, false), SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), false, true) + 1)
			MainFrame.sel.pe2:SetText(SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), false, true))
		elseif mod == "posb-" then
			accframe:SetPoint("BOTTOMLEFT", MainFrame.designer, SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), true, false), SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), false, true) - 1)
			MainFrame.sel.pe2:SetText(SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), false, true))
		else
			-- not triggered
		end

	else

		if mod == "width+" then
			accframe:SetWidth(widthr + 1)
			widthr = widthr + 1
			MainFrame.sel.se:SetText(widthr)
		elseif mod == "width-" then
			accframe:SetWidth(widthr - 1)
			widthr = widthr - 1
			MainFrame.sel.se:SetText(widthr)
		elseif mod == "high+" then
			accframe:SetHeight(heightr + 1)
			heightr = heightr + 1
			MainFrame.sel.se2:SetText(heightr)
		elseif mod == "high-" then
			accframe:SetHeight(heightr - 1)
			heightr = heightr - 1
			MainFrame.sel.se2:SetText(heightr)
		elseif mod == "posl+" then
			accframe:SetPoint("BOTTOMLEFT", MainFrame.designer, SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), true, false) + 1, SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), false, true))
			MainFrame.sel.pe:SetText(SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), true, false))
		elseif mod == "posl-" then
			accframe:SetPoint("BOTTOMLEFT", MainFrame.designer, SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), true, false) - 1, SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), false, true))
			MainFrame.sel.pe:SetText(SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), true, false))
		elseif mod == "posb+" then
			accframe:SetPoint("BOTTOMLEFT", MainFrame.designer, SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), true, false), SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), false, true) + 1)
			MainFrame.sel.pe2:SetText(SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), false, true))
		elseif mod == "posb-" then
			accframe:SetPoint("BOTTOMLEFT", MainFrame.designer, SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), true, false), SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), false, true) - 1)
			MainFrame.sel.pe2:SetText(SUI:GetRPos(accframe:GetLeft(), accframe:GetBottom(), false, true))
		else
			-- not triggered
		end

	end

end

function SUI:FrameSelect(frame) -- fills the selection tab with the infos

	acName = SUI:StringSplit(frame:GetName(), true, false)
	acIndex = tonumber(self:StringSplit(frame:GetName(), false, true))

   MainFrame.sel.n:SetText("Name:  " .. acName)


   if frame.i == "FontString" then

   	   MainFrame.sel.se:SetText(frame.s.s)
	   MainFrame.sel.te:SetText(frame.s:GetText())
	   MainFrame.sel.pe:SetText(self:GetRPos(frame:GetLeft(), frame:GetBottom(), true, false))
	   MainFrame.sel.pe2:SetText(self:GetRPos(frame:GetLeft(), frame:GetBottom(), false, true))

	   MainFrame.sel.se2:Disable()
	    MainFrame.sel.seb3:Disable()
	     MainFrame.sel.seb4:Disable()

   	return 

   end

   if frame:GetObjectType() == "EditBox" then

   	  MainFrame.sel.se:SetText(frame:GetWidth())
	   MainFrame.sel.te:SetText(frame:GetText())
	   MainFrame.sel.se2:SetText(self:round(tonumber(frame:GetHeight())))
	   MainFrame.sel.pe:SetText(self:GetRPos(frame:GetLeft(), frame:GetBottom(), true, false))
	   MainFrame.sel.pe2:SetText(self:GetRPos(frame:GetLeft(), frame:GetBottom(), false, true))

	   MainFrame.sel.se2:Disable()
	    MainFrame.sel.seb3:Disable()
	     MainFrame.sel.seb4:Disable()

	     return
   end

   if frame.i == "CheckButton" then 

   	  MainFrame.sel.se:SetText(self:round(tonumber(frame:GetWidth())))
	   MainFrame.sel.te:SetText(frame.text:GetText())
	   MainFrame.sel.se2:SetText(self:round(tonumber(frame:GetHeight())))
	   MainFrame.sel.pe:SetText(self:GetRPos(frame:GetLeft(), frame:GetBottom(), true, false))
	   MainFrame.sel.pe2:SetText(self:GetRPos(frame:GetLeft(), frame:GetBottom(), false, true))


   	return
   end

   if frame.i == "DropDown" then

	  MainFrame.sel.se:SetText(self:round(tonumber(frame:GetWidth())))
	   MainFrame.sel.te:SetText(frame.items)
	   MainFrame.sel.se2:SetText(self:round(tonumber(frame:GetHeight())))
	   MainFrame.sel.pe:SetText(self:GetRPos(frame:GetLeft(), frame:GetBottom(), true, false))
	   MainFrame.sel.pe2:SetText(self:GetRPos(frame:GetLeft(), frame:GetBottom(), false, true))
   	

   	return
   end

   if frame.i == "Button" then
	   MainFrame.sel.se:SetText(self:round(tonumber(frame:GetWidth())))
	   MainFrame.sel.se2:SetText(self:round(tonumber(frame:GetHeight())))
	   MainFrame.sel.te:SetText(frame:GetText())
	   MainFrame.sel.pe:SetText(self:GetRPos(frame:GetLeft(), frame:GetBottom(), true, false))
	   MainFrame.sel.pe2:SetText(self:GetRPos(frame:GetLeft(), frame:GetBottom(), false, true))

	   	MainFrame.sel.se2:Enable()
		   MainFrame.sel.seb3:Enable()
		     MainFrame.sel.seb4:Enable()

	 return
	end

end

function SUI:GetRPos(x, y, gx, gy) -- returns the real position of a frame in the designer frame
	
	dy = MainFrame.designer:GetBottom()
	dx = MainFrame.designer:GetLeft()

	ry = y - dy
	rx = x - dx

	if gx == true then return self:round(rx) end
	if gy == true then return self:round(ry) end

end

function SUI:ModAttr(frame, mod) -- modifies an atribute of the given frame 

	ftype = frame:GetObjectType()

	
	if ftype == "Frame" then accframe = frame.s; accframe:SetText(mod) return end

	if ftype == "Button" then frame:SetText(mod) return end

	if ftype == "CheckButton" then frame:SetChecked(mod) return end

	if ftype == "EditBox" then frame:SetText(mod) return end

	if ftype == "DropDown" then frame:SetText(mod) return end

end

function SUI:StartExt() -- start the Extendet menu for the actual frame 

	accframe = frametbl[acIndex]
	
	ftype = accframe.i

	MainFrame.designer:Hide()

	MainFrame.ext:Show()
	


	if ftype == "Frame" then 

		self:ColorPicker(accframe)

		MainFrame.ext.s:SetScript("OnClick", function() MainFrame.ext:Hide(); MainFrame.designer:Show();  end )

		return
	end

	if ftype == "Button" then 

		self:ColorPicker(accframe)

		MainFrame.ext.s:SetScript("OnClick", function() MainFrame.ext:Hide(); MainFrame.designer:Show();  end )

		return 
	end

	if ftype == "CheckButton" then 

		

		return
	end

	if ftype == "EditBox" then

		

		return
	end

	if ftype == "DropDown" then 

		

		return
	end

	if ftype == "FontString" then

		

		return
	end

end


---- Short functions -----------------

function SUI:StringSplit(string, name, index) -- splits an string into 2
	count = 0
	
	for word in string.gmatch(string, '([^;]+)') do
		count = count + 1

	    if name == true and count == 1 then self:Print(word); return word end
	    if index == true and count == 2 then self:Print(word); return tonumber(word) end

	end

end

function SUI:round(n) -- rounds a value 

    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)

end

function SUI:Print(msg) -- the print funktion with the Red SimpleUI before every chat msg

	print("|cffff0020Simple UI|r: " .. msg)

end

function SUI:ColorPicker(frame) -- shows a colorpicker and modifies the color of the given frame

		texture = frame:CreateTexture()
		texture:SetAllPoints()
	
		ColorPickerFrame:SetColorRGB(0,0,0);
		ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = nil, 1;
		ColorPickerFrame.previousValues = {0,0,0,1};
		ColorPickerFrame.func = function () colortbl[1], colortbl[2], colortbl[3] = ColorPickerFrame:GetColorRGB(); texture:SetTexture(colortbl[1],colortbl[2],colortbl[3],colortbl[4])  end
		ColorPickerFrame.opacityFunc = function () colortbl[4] = OpacitySliderFrame:GetValue(); texture:SetTexture(colortbl[1],colortbl[2],colortbl[3],colortbl[4])  end
		ColorPickerFrame.cancelFunc = function ()  end
		ColorPickerFrame:Hide();
		ColorPickerFrame:Show();
 	
		frame.background = texture

end


----- Code Creation ----------

function SUI:CreateCode() -- creates the code witch dynamic names 

	-- userNameFrame "" müssen entfernt werden!!!
	afz = "\""

	stringTable = ""
	count = 0

	stringTable = 	"frame = CreateFrame(\"Frame\", \"userFrameName\", UIParent)" .. "\n" ..
	"frame:SetSize(" .. self:round(MainFrame.designer:GetWidth()) .. ", " .. self:round(MainFrame.designer:GetHeight()) .. ")" .. "\n" ..
	"frame:SetPoint(\"CENTER\", UIParent)" .. "\n" ..
	"texture = frame:CreateTexture()" .. "\n" ..
	"texture:SetAllPoints()" .. "\n" ..
	"texture:SetTexture(0,0,0,1)" .. "\n" ..
	"frame.background = texture" .. "\n"

	
	for index, frame in pairs(frametbl) do 
		count = count + 1
		frameName = self:StringSplit(frame:GetName(), true, false)

		if frame:IsShown() == true then

			ftype = frame:GetObjectType()

			if ftype == "Frame" then -- creating code for an FontString in string format

				if frame.s:GetObjectType() == "FontString" then
					frameName = self:StringSplit(frame.s:GetName(), true, false)

					stringTable = stringTable .. "\n" .. "-- creating " .. frameName .. "\n" .. "frame.b = " .. "frame" .. ":CreateFontString(nil, \"OVERLAY\")" .. "\n" .. 
					"frame.b:SetPoint(\"BOTTOMLEFT\", frame, \"BOTTOMLEFT\", " .. self:GetRPos(frame.s:GetLeft(), frame.s:GetBottom(), true, false) .. ", " .. self:GetRPos(frame.s:GetLeft(), frame.s:GetBottom(), false, true) .. ")" .. "\n" ..
					"frame.b:SetFont(\"Fonts\\\\ARIALN.TTF\", 15, \"OUTLINE\")" .. "\n" ..
					"frame.b:SetJustifyH(\"LEFT\")" .. "\n" ..
					"frame.b:SetShadowOffset(1, -1)" .. "\n" ..
					"frame.b:SetTextColor(1, 1, 1)" .. "\n" ..
					"frame.b:SetText(" .. afz .. frame.s:GetText() .. afz .. ")" .. "\n"

				end

			elseif ftype == "Button" then -- creating code for an Button in string format

				stringTable = stringTable .. "\n" .. "-- creating " .. frameName .. "\n" .. "frame.b = CreateFrame(\"Button\", " .. afz .. frameName .. afz .. ", " .. "frame" .. ", \"UIPanelButtonTemplate\")" .. "\n" ..
				"frame.b:SetSize(" .. self:round(frame:GetWidth()) .. ", " .. self:round(frame:GetHeight()) .. ")" .. "\n" ..
				"frame.b:SetPoint(\"BOTTOMLEFT\", " .. "frame" .. ", " .. self:GetRPos(frame:GetLeft(), frame:GetBottom(), true, false) .. ", " .. self:GetRPos(frame:GetLeft(), frame:GetBottom(), false, true) .. ")" .. "\n" ..
				"frame.b.text = _G[" .. afz .. frameName .. afz .. " .. \"Text\"]" .. "\n" .. 
				"frame.b.text:SetText(" .. afz .. frame:GetText() .. afz .. ")" .. "\n" ..
				"frame.b:SetScript(\"OnMouseDown\", function (self, value)  end)" .. "\n"


			elseif ftype == "EditBox" then -- creating code for an EditBox in string format

				stringTable = stringTable .. "\n" .. "-- creating " .. frameName .. "\n" .. "frame.eb = CreateFrame(\"EditBox\", " .. afz .. frameName .. afz .. ", " .. "frame" .. ", \"InputBoxTemplate\")" .. "\n" ..
				"frame.eb:SetSize(" .. self:round(frame:GetWidth()) .. ", " .. self:round(frame:GetHeight()) .. ")" .. "\n" ..
				"frame.eb:SetPoint(\"BOTTOMLEFT\", " .. "frame" .. ", " .. self:GetRPos(frame:GetLeft(), frame:GetBottom(), true, false) .. ", " .. self:GetRPos(frame:GetLeft(), frame:GetBottom(), false, true) .. ")" .. "\n" ..
				"frame.eb:SetText(".. afz .. afz .. ")" .. "\n" ..
				"frame.eb:SetScript(\"OnMouseDown\", function (self, value)  end)" .. "\n"

			else
				
			end

		end

	end

	MainFrame:Hide()
	--------------

	--parent frame 
	local frame = CreateFrame("Frame", "MyFrame", UIParent) 
	frame:SetSize(560, 610) 
	frame:SetPoint("CENTER") 
	local texture = frame:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(1,1,1,1) 
	frame.background = texture 


	 
	--scrollframe 
	scrollframe = CreateFrame("ScrollFrame", nil, frame) 
	scrollframe:SetPoint("TOPLEFT", 10, -10) 
	scrollframe:SetPoint("BOTTOMRIGHT", -10, 10) 
	local texture = scrollframe:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(.5,.5,.5,1) 
	frame.scrollframe = scrollframe 
	 
	--scrollbar 
	scrollbar = CreateFrame("Slider", nil, scrollframe, "UIPanelScrollBarTemplate") 
	scrollbar:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, -16) 
	scrollbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 4, 16) 
	scrollbar:SetMinMaxValues(1, (60 * count))
	scrollbar:SetValueStep(20) 
	scrollbar.scrollStep = 20
	scrollbar:SetValue(0) 
	scrollbar:SetWidth(16) 
	scrollbar:SetScript("OnValueChanged", 
	function (self, value) 
	self:GetParent():SetVerticalScroll(value) 
	end) 
	local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND") 
	scrollbg:SetAllPoints(scrollbar) 
	scrollbg:SetTexture(0, 0, 0, 0.4) 
	frame.scrollbar = scrollbar 
	 
	--content frame 


	local content = CreateFrame("Frame", nil, scrollframe) 
	content:SetSize(500, 500) 
	local texture = content:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture("Interface\\GLUES\\MainMenu\\Glues-BlizzardLogo") 
	content.texture = texture 
	scrollframe.content = content

	content.e = CreateFrame("EditBox", "endEB", content, "InputBoxTemplate")
	content.e:SetMultiLine(true)
	content.e:SetWidth(500)
	content.e:SetAutoFocus( true )
	content.e:SetPoint("CENTER", scrollframe, 0, 60)
	content.e:SetText("Creating...")
	
	content.e:SetText(stringTable)

	content.e:HighlightText(0, content.e:GetNumLetters())



	frame.s = frame:CreateFontString("stringend") 
	frame.s:SetPoint("TOPLEFT", frame, "TOPLEFT", 90, 30)
	frame.s:SetFont("Fonts\\ARIALN.TTF", 15, "OUTLINE")
	frame.s:SetJustifyH("LEFT")
	frame.s:SetShadowOffset(1, -1)
	frame.s:SetTextColor(1, 1, 1)
	frame.s:SetText("and press CTRL + C !")

	frame.b = CreateFrame("Button", "endBtn", frame, "UIPanelButtonTemplate")
	frame.b:SetSize(80, 25)
	frame.b:SetPoint("TOPLEFT", frame, 5, 30)
	frame.b.text = _G["endBtn" .. "Text"]
	frame.b.text:SetText("Select All")
	frame.b:SetScript("OnMouseDown", function (self, value) content.e:HighlightText(0, content.e:GetNumLetters()) end) 

	scrollframe:SetScrollChild(content.e)

end


-- Project -----------------

function SUI:ProjectHandling()
	
	-- Project Create/Open


	MainFrame:Show()

end

function SUI:SaveProject()
	
	self.db.global.projects[projName].frametbl = frametbl
	self.db.global.projects[projName].framecount = framecount
	self.db.global.SavedProject = true

end

function SUI:AutoSave()

	projtbl[1] = projName
	projtbl[2] = frametbl
	projtbl[3] = framecount
	
	-- save frametable and designer frame
	SUIDB = projtbl

end

function SUI:RebuildProject()
	
	-- get the frametable and the designer frame out of the db
	-- rebuild the project out of the frametable

end

----------------------------

