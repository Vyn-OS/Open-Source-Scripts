-- Made by Vyn_O.S

local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local Debris  = game:GetService("Debris")
local UIS     = game:GetService("UserInputService")
local LP      = Players.LocalPlayer

local jsonDecode
do
    local ok, fn = pcall(function()
        local hs = game:GetService("HttpService")
        hs:JSONDecode('{"a":1}')
        return function(s) return hs:JSONDecode(s) end
    end)
    if ok then jsonDecode = fn end
end
if not jsonDecode then
    if type(json)=="table" and type(json.decode)=="function" then
        jsonDecode = json.decode
    elseif type(JSONDecode)=="function" then
        jsonDecode = JSONDecode
    end
end
if not jsonDecode then
    local function pj(s,i)
        i=i or 1
        local function sk() while i<=#s and s:sub(i,i):match("%s") do i=i+1 end end
        sk(); local c=s:sub(i,i)
        if c=='"' then
            i=i+1; local b={}
            while i<=#s do
                local ch=s:sub(i,i)
                if ch=="\\" then i=i+1; local m={['"']='"',['\\']='\\',n='\n',r='\r',t='\t'}
                    b[#b+1]=m[s:sub(i,i)] or s:sub(i,i)
                elseif ch=='"' then i=i+1; break
                else b[#b+1]=ch end
                i=i+1
            end
            return table.concat(b),i
        elseif c=='{' then
            i=i+1; sk(); local o={}
            if s:sub(i,i)=='}' then return o,i+1 end
            while true do
                sk(); local k; k,i=pj(s,i); sk(); i=i+1
                local v; v,i=pj(s,i); sk(); o[k]=v
                local sep=s:sub(i,i)
                if sep=='}' then i=i+1; break elseif sep==',' then i=i+1 end
            end
            return o,i
        elseif c=='[' then
            i=i+1; sk(); local a={}
            if s:sub(i,i)==']' then return a,i+1 end
            while true do
                local v; v,i=pj(s,i); sk(); a[#a+1]=v
                local sep=s:sub(i,i)
                if sep==']' then i=i+1; break elseif sep==',' then i=i+1 end
            end
            return a,i
        elseif s:sub(i,i+3)=='true'  then return true, i+4
        elseif s:sub(i,i+4)=='false' then return false,i+5
        elseif s:sub(i,i+3)=='null'  then return nil,  i+4
        else
            local n=s:match("^-?%d+%.?%d*[eE]?[+-]?%d*",i)
            if n then return tonumber(n),i+#n end
            error("JSON err pos "..i)
        end
    end
    jsonDecode=function(s) local ok,r=pcall(pj,s,1); if ok then return r end; error(r) end
end

local LogLines = {}
local LogLabel = nil
local function log(msg, col)
    col = col or Color3.fromRGB(200,200,220)
    table.insert(LogLines,1,msg)
    if #LogLines>7 then table.remove(LogLines) end
    if LogLabel then LogLabel.Text=table.concat(LogLines,"\n") end
    print("[AB] "..msg)
end

local function getRF()
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        local bt = bp:FindFirstChild("BuildingTool")
        if bt then
            local rf = bt:FindFirstChild("RF")
            if rf and rf:IsA("RemoteFunction") then return rf end
        end
    end
    local char = LP.Character
    if char then
        local bt = char:FindFirstChild("BuildingTool")
        if bt then
            local rf = bt:FindFirstChild("RF")
            if rf and rf:IsA("RemoteFunction") then return rf end
        end
    end
    for _, container in ipairs({bp, char}) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("Tool") then
                    local rf = child:FindFirstChild("RF")
                    if rf and rf:IsA("RemoteFunction") then
                        log("RF en: "..child:GetFullName(), Color3.fromRGB(200,255,200))
                        return rf
                    end
                end
            end
        end
    end
    if bp then
        for _, child in ipairs(bp:GetChildren()) do
            if child:IsA("Tool") then
                local kids={}
                for _, c in ipairs(child:GetChildren()) do
                    kids[#kids+1]=c.Name.."["..c.ClassName.."]"
                end
                log(child.Name..": "..table.concat(kids,", "):sub(1,80), Color3.fromRGB(255,200,80))
            end
        end
    end
    log("✗ RF no encontrado", Color3.fromRGB(255,80,80))
    return nil
end

local function getScaleRF()
    local bp = LP:FindFirstChild("Backpack")
    if not bp then return nil end
    local t = bp:FindFirstChild("ScalingTool")
    if not t then return nil end
    local rf = t:FindFirstChild("RF")
    return (rf and rf:IsA("RemoteFunction")) and rf or nil
end

local function equipBuildingTool()
    local char = LP.Character
    if not char then return false end
    local equipped = char:FindFirstChild("BuildingTool")
    if equipped and equipped:IsA("Tool") then return true end

    local bp = LP:FindFirstChild("Backpack")
    if not bp then return false end
    local tool = bp:FindFirstChild("BuildingTool")
    if not tool or not tool:IsA("Tool") then return false end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:EquipTool(tool)
    else
        tool.Parent = char
    end
    return true
end

local function getPaintRF()
    local bp = LP:FindFirstChild("Backpack")
    if not bp then return nil end
    local t = bp:FindFirstChild("PaintingTool")
    if not t then return nil end
    local rf = t:FindFirstChild("RF")
    return (rf and rf:IsA("RemoteFunction")) and rf or nil
end

local SPECIAL = {Rope=true,Spring=true,Bar=true,Switch=true,PilotSeat=true,
                 CameraDome=true,BackWheel=true,Thruster=true,SpikeTrap=true}

local NON_BLOCK_NAMES = {
    Gold=true, Cash=true, Money=true, Coins=true, Coin=true, Gate=true,
    BuildingTool=true, ScalingTool=true, PaintingTool=true,
    Level=true, XP=true, Exp=true,
}
local function isValidBlockName(name)
    if NON_BLOCK_NAMES[name] then return false end
    local bpFolder = RS:FindFirstChild("BuildingParts")
    if bpFolder then
        return bpFolder:FindFirstChild(name) ~= nil
    end
    return true
end
local DEFAULT_SIZE = {
    SpikeTrap=Vector3.new(5,5,5), Thruster=Vector3.new(2,2,2),
    CameraDome=Vector3.new(2,2,2), PilotSeat=Vector3.new(2,2,2),
    Switch=Vector3.new(2,2,2), BackWheel=Vector3.new(4,4,4),
}

local function sv3(s)
    if not s then return Vector3.new(0,0,0) end
    local a,b,c = s:match("([^,]+),%s*([^,]+),%s*([^,]+)")
    return Vector3.new(tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0)
end
local function sc3(s)
    if not s then return nil end
    local r,g,b = s:match("([^,]+),%s*([^,]+),%s*([^,]+)")
    return Color3.new(
        math.clamp(tonumber(r) or 1,0,1),
        math.clamp(tonumber(g) or 1,0,1),
        math.clamp(tonumber(b) or 1,0,1))
end
local function makeCF(pos,rot)
    return CFrame.new(pos)
        * CFrame.Angles(0,math.rad(rot.Y),0)
        * CFrame.Angles(math.rad(rot.X),0,0)
        * CFrame.Angles(0,0,math.rad(rot.Z))
end

local function findPlaced(name, nearPos, timeout)
    timeout = timeout or 2
    local t0 = tick()
    local roots = {
        workspace:FindFirstChild("Placed"),
        workspace:FindFirstChild("Blocks"),
        workspace,
    }
    while tick()-t0 < timeout do
        local best, bestD = nil, 40
        for _, root in ipairs(roots) do
            if root then
                for _, m in ipairs(root:GetChildren()) do
                    if m.Name==name then
                        local pp = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
                        if pp then
                            local d=(pp.Position-nearPos).Magnitude
                            if d<bestD then bestD=d; best=m end
                        end
                    end
                end
            end
        end
        if best then return best end
        task.wait(0.08)
    end
    return nil
end

local activeSigIndex = 1

local SIGNATURES = {
    function(rf, name, count, cf) return rf:InvokeServer(name, count, nil, nil, false, cf, false) end,
    function(rf, name, count, cf) return rf:InvokeServer(name, count, nil, nil, false, cf) end,
    function(rf, name, count, cf) return rf:InvokeServer(name, count, cf) end,
    function(rf, name, count, cf) return rf:InvokeServer(name, cf) end,
    function(rf, name, count, cf) return rf:InvokeServer(name, count, nil, nil, true, cf, false) end,
    function(rf, name, count, cf) return rf:InvokeServer(name, 0, nil, nil, false, cf, false) end,
    function(rf, name, count, cf) return rf:InvokeServer(name, nil, nil, nil, false, cf, false) end,
}

local BP_folder = nil

local function placeBlock(blockName, cf)
    equipBuildingTool()
    local rf = getRF()
    if not rf then return false end

    if not BP_folder or not BP_folder.Parent then
        BP_folder = RS:FindFirstChild("BuildingParts")
    end

    local data   = LP:FindFirstChild("Data")
    local countV = data and data:FindFirstChild(blockName)
    local count  = countV and countV.Value or 0

    if count <= 0 then
        log("✗ Sin inventario: "..blockName, Color3.fromRGB(255,150,80))
        return false
    end

    if activeSigIndex then
        local ok, err = pcall(SIGNATURES[activeSigIndex], rf, blockName, count, cf)
        if not ok then
            log("✗ Sig "..activeSigIndex.." falló: "..tostring(err):sub(1,50), Color3.fromRGB(255,100,100))
            activeSigIndex = nil
            return false
        end
        return true
    end

    log("🔍 Detectando firma RF...", Color3.fromRGB(200,200,80))
    for i, sig in ipairs(SIGNATURES) do
        local ok, err = pcall(sig, rf, blockName, count, cf)
        if ok then
            task.wait(0.15)
            local placed = findPlaced(blockName, cf.Position, 0.8)
            if placed then
                activeSigIndex = i
                log(string.format("✔ Firma %d activa para %s", i, blockName), Color3.fromRGB(100,255,100))
                return true
            end
        else
            log(string.format("  Sig%d err: %s", i, tostring(err):sub(1,40)), Color3.fromRGB(200,150,150))
        end
        task.wait(0.05)
    end

    log("✗ Ninguna firma colocó "..blockName, Color3.fromRGB(255,80,80))
    return false
end

local function scaleBlock(model, newSize, cf)
    local rf = getScaleRF()
    if not rf then return false end
    local ok,err = pcall(function() rf:InvokeServer(model, newSize, cf) end)
    if not ok then log("Scale err: "..tostring(err):sub(1,50)) end
    return ok
end

local function paintBlock(model, color)
    local rf = getPaintRF()
    if not rf then return false end
    local ok,err = pcall(function() rf:InvokeServer({{model, color}}) end)
    if not ok then log("Paint err: "..tostring(err):sub(1,50)) end
    return ok
end

local G={files={},selPath=nil,blocks={},stats={}}

local function testRF()
    local rf = getRF()
    if not rf then log("✗ No RF — equipa el BuildingTool", Color3.fromRGB(255,80,80)); return end
    local char = LP.Character
    if not char then log("✗ Sin personaje", Color3.fromRGB(255,80,80)); return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then log("✗ Sin HumanoidRootPart", Color3.fromRGB(255,80,80)); return end
    local testCF = hrp.CFrame * CFrame.new(0, 0, -8)
    local data = LP:FindFirstChild("Data")
    if not data then log("✗ Sin carpeta Data", Color3.fromRGB(255,80,80)); return end
    local testName, testCount = nil, 0
    local known = {}
    for _, b in ipairs(G.blocks) do known[b.name] = true end
    if next(known) then
        for _, v in ipairs(data:GetChildren()) do
            if (v:IsA("IntValue") or v:IsA("NumberValue")) and v.Value > 0 and known[v.Name] then
                testName = v.Name; testCount = v.Value; break
            end
        end
    end
    if not testName then
        for _, v in ipairs(data:GetChildren()) do
            if (v:IsA("IntValue") or v:IsA("NumberValue")) and v.Value > 0 and isValidBlockName(v.Name) then
                testName = v.Name; testCount = v.Value; break
            end
        end
    end
    if not testName then log("✗ Inventario vacío", Color3.fromRGB(255,80,80)); return end
    log("🧪 Probando: "..testName.." (x"..testCount..")", Color3.fromRGB(200,200,80))
    activeSigIndex = nil
    for i, sig in ipairs(SIGNATURES) do
        local ok, res = pcall(sig, rf, testName, testCount, testCF)
        log(string.format("  Sig%d ok=%s res=%s", i, tostring(ok), tostring(res):sub(1,25)),
            ok and Color3.fromRGB(200,255,200) or Color3.fromRGB(255,180,180))
        if ok then
            task.wait(0.2)
            local placed = findPlaced(testName, testCF.Position, 1.0)
            if placed then
                activeSigIndex = i
                log("✔ FIRMA "..i.." COLOCA BLOQUES!", Color3.fromRGB(100,255,100))
                return
            end
        end
        task.wait(0.05)
    end
    log("✗ Ninguna firma funciona — verifica el tool", Color3.fromRGB(255,80,80))
end

local function parseBuild(content)
    local ok, data = pcall(jsonDecode, content)
    if not ok or type(data)~="table" then
        log("JSON error: "..tostring(data):sub(1,60), Color3.fromRGB(255,80,80))
        return nil
    end
    local dict
    if type(data[1])=="table" and type(data[2])=="table" then
        dict = data[2]
    elseif not data[1] then
        dict = data
    else
        log("Formato .Build no reconocido", Color3.fromRGB(255,80,80))
        return nil
    end
    local blocks = {}
    for name, insts in pairs(dict) do
        if type(insts)=="table" then
            for _, inst in ipairs(insts) do
                if type(inst)=="table" then
                    local pos = sv3(type(inst.Position)=="string" and inst.Position)
                    local rot = sv3(type(inst.Rotation)=="string" and inst.Rotation)
                    local sz  = (type(inst.Size)=="string" and sv3(inst.Size))
                            or DEFAULT_SIZE[name] or Vector3.new(1,1,1)
                    local col = type(inst.Color)=="string" and sc3(inst.Color) or nil
                    blocks[#blocks+1] = {
                        name=name, position=pos, rotation=rot,
                        size=sz, color=col, isSpecial=SPECIAL[name]==true,
                    }
                end
            end
        end
    end
    if #blocks==0 then log("Sin bloques válidos", Color3.fromRGB(255,80,80)); return nil end
    return blocks
end

local function getStats(blocks)
    local counts={}
    for _,b in ipairs(blocks) do counts[b.name]=(counts[b.name] or 0)+1 end
    return counts, #blocks
end

local function scanInv()
    local inv={}
    local d=LP:FindFirstChild("Data")
    if not d then return inv end
    for _,c in ipairs(d:GetChildren()) do
        if c:IsA("IntValue") or c:IsA("NumberValue") then inv[c.Name]=c.Value end
    end
    return inv
end

local AB = {running=false, paused=false, DELAY=0.03}
local V1 = Vector3.new(1,1,1)

function AB.build(blocks, onProgress, onDone)
    if AB.running then return end
    AB.running=true; AB.paused=false
    task.spawn(function()
        log("Verificando RF...", Color3.fromRGB(200,200,80))
        if equipBuildingTool() then
            log("✔ BuildingTool equipado", Color3.fromRGB(100,255,100))
            task.wait(0.1)
        end
        local rf = getRF()
        if not rf then
            log("✗ Equipa el BuildingTool y vuelve a intentar.", Color3.fromRGB(255,80,80))
            AB.running=false
            if onDone then task.defer(onDone) end
            return
        end
        log("✔ RF listo: "..rf:GetFullName(), Color3.fromRGB(100,255,100))
        local total = #blocks
        local ok_count = 0
        for i, block in ipairs(blocks) do
            if not AB.running then break end
            while AB.paused and AB.running do task.wait(0.2) end
            if not AB.running then break end
            local cf = makeCF(block.position, block.rotation)
            local ok = placeBlock(block.name, cf)
            if ok then
                ok_count = ok_count + 1
                if (block.size - V1).Magnitude > 0.05 then
                    task.wait(0.08)
                    local m = findPlaced(block.name, block.position, 1.5)
                    if m then scaleBlock(m, block.size, cf) end
                end
                if block.color then
                    task.wait(0.05)
                    local m = findPlaced(block.name, block.position, 1.5)
                    if m then paintBlock(m, block.color) end
                end
            end
            if onProgress then task.defer(onProgress, i, total, block.name, ok, block.isSpecial) end
            task.wait(AB.DELAY)
        end
        log(string.format("%d/%d colocados", ok_count, total),
            ok_count>0 and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,150,80))
        AB.running=false
        if onDone then task.defer(onDone) end
    end)
end

function AB.pause()  AB.paused=true  end
function AB.resume() AB.paused=false end
function AB.stop()   AB.running=false; AB.paused=false end

local T = {
    bg      = Color3.fromRGB(8,8,8),
    panel   = Color3.fromRGB(16,16,16),
    card    = Color3.fromRGB(22,22,22),
    deep    = Color3.fromRGB(4,4,4),
    accent  = Color3.fromRGB(0,210,255),
    accentD = Color3.fromRGB(0,140,180),
    ok      = Color3.fromRGB(0,210,90),
    okD     = Color3.fromRGB(0,150,60),
    warn    = Color3.fromRGB(255,185,0),
    warnD   = Color3.fromRGB(195,135,0),
    err     = Color3.fromRGB(215,40,40),
    errD    = Color3.fromRGB(155,20,20),
    special = Color3.fromRGB(170,75,255),
    text    = Color3.fromRGB(220,220,220),
    sub     = Color3.fromRGB(100,100,100),
    dim     = Color3.fromRGB(55,55,55),
    border  = Color3.fromRGB(40,40,40),
    bar     = Color3.fromRGB(12,12,12),
    rowSel  = Color3.fromRGB(0,28,38),
    rowHov  = Color3.fromRGB(20,20,20),
}

local function mk(cls,p) local i=Instance.new(cls); for k,v in pairs(p) do i[k]=v end; return i end
local function brd(i,c,t) local s=Instance.new("UIStroke"); s.Color=c or T.border; s.Thickness=t or 1
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=i; return s end
local function pdg(i,px) local p=Instance.new("UIPadding"); local u=UDim.new(0,px)
    p.PaddingTop=u;p.PaddingBottom=u;p.PaddingLeft=u;p.PaddingRight=u;p.Parent=i end
local function vl(i,sp) local l=Instance.new("UIListLayout")
    l.SortOrder=Enum.SortOrder.LayoutOrder;l.Padding=UDim.new(0,sp or 4);l.Parent=i end
local function hl(i,sp) local l=Instance.new("UIListLayout")
    l.FillDirection=Enum.FillDirection.Horizontal;l.SortOrder=Enum.SortOrder.LayoutOrder
    l.Padding=UDim.new(0,sp or 4);l.Parent=i end
local function fr(p,props,wb,bc)
    props=props or {}; props.BackgroundColor3=props.BackgroundColor3 or T.panel
    props.BorderSizePixel=0; props.Parent=p
    local f=mk("Frame",props); if wb then brd(f,bc or T.border) end; return f end
local function lbl(p,text,props)
    props=props or {}
    return mk("TextLabel",{Text=text,Font=props.Font or Enum.Font.Code,
        TextSize=props.TextSize or 11,TextColor3=props.TextColor3 or T.text,
        BackgroundTransparency=1,TextXAlignment=props.TextXAlignment or Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd,
        Size=props.Size or UDim2.new(1,0,0,18),LayoutOrder=props.lo or 0,Parent=p}) end
local function sbtn(p,text,col,colH,cb)
    col=col or T.accent; colH=colH or T.accentD
    local b=mk("TextButton",{Text=text,Font=Enum.Font.Code,TextSize=11,
        TextColor3=T.bg,BackgroundColor3=col,BorderSizePixel=0,AutoButtonColor=false,Parent=p})
    b.MouseEnter:Connect(function() b.BackgroundColor3=colH end)
    b.MouseLeave:Connect(function() b.BackgroundColor3=col  end)
    b.MouseButton1Click:Connect(cb); return b end
local function sbtn2(p,text,tc,bc,cb)
    local b=mk("TextButton",{Text=text,Font=Enum.Font.Code,TextSize=11,
        TextColor3=tc or T.sub,BackgroundColor3=T.card,BorderSizePixel=0,AutoButtonColor=false,Parent=p})
    brd(b,bc or T.border)
    b.MouseEnter:Connect(function() b.BackgroundColor3=T.rowSel end)
    b.MouseLeave:Connect(function() b.BackgroundColor3=T.card  end)
    b.MouseButton1Click:Connect(cb); return b end
local function sframe(p,props)
    props=props or {}; props.BackgroundColor3=props.BackgroundColor3 or T.deep
    props.BorderSizePixel=0; props.ScrollBarThickness=2
    props.ScrollBarImageColor3=T.accent; props.CanvasSize=UDim2.new(0,0,0,0)
    props.AutomaticCanvasSize=Enum.AutomaticSize.Y; props.ScrollingEnabled=true
    props.Parent=p; local s=mk("ScrollingFrame",props); brd(s,T.border); return s end
local function sec(p,title,h,lo)
    local w=fr(p,{Size=UDim2.new(1,-16,0,h),BackgroundColor3=T.panel,LayoutOrder=lo},true,T.border)
    fr(w,{Size=UDim2.new(0,2,1,0),BackgroundColor3=T.accent})
    local hdr=fr(w,{Size=UDim2.new(1,-2,0,16),Position=UDim2.new(0,2,0,0),BackgroundColor3=T.deep})
    lbl(hdr,title,{Size=UDim2.new(1,0,1,0),TextSize=9,TextColor3=T.accent,Font=Enum.Font.Code})
    Instance.new("UIPadding",hdr).PaddingLeft=UDim.new(0,6)
    fr(w,{Size=UDim2.new(1,-2,0,1),Position=UDim2.new(0,2,0,16),BackgroundColor3=T.border})
    local body=fr(w,{Size=UDim2.new(1,-2,1,-17),Position=UDim2.new(0,2,0,17),BackgroundColor3=T.panel})
    return w,body end
local function clrKids(p)
    for _,c in ipairs(p:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end end end

G={files={},selPath=nil,blocks={},stats={}}
local statusL,pBar,pLabel,pauseBtn,prevTitle,fileSF,prevSF,missSF
local function setStatus(t,c) statusL.Text=t; statusL.TextColor3=c or T.sub end

local function scanFiles()
    clrKids(fileSF); G.files={}
    local found,seen={},{}
    local function add(p) if not seen[p] then seen[p]=true; found[#found+1]=p end end
    if type(listfiles)=="function" then
        for _,dir in ipairs({"workspace/",""}) do
            local ok,res=pcall(listfiles,dir)
            if ok and type(res)=="table" then
                for _,p in ipairs(res) do
                    if tostring(p):lower():match("%.build$") then add(tostring(p)) end
                end
            end
        end
    end
    for _,obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("StringValue") and obj.Name:lower():match("%.build$") then
            G.files[obj.Name]=obj.Value; add(obj.Name)
        end
    end
    if #found==0 then
        lbl(fileSF,"  [sin .Build en workspace/]",{Size=UDim2.new(1,0,0,20),TextColor3=T.dim,TextSize=10,lo=1})
        setStatus("[pon .Build en workspace/ del executor]",T.warn); return
    end
    for idx,path in ipairs(found) do
        local name=tostring(path):match("[^\\/]+$") or tostring(path)
        local isSel=(path==G.selPath)
        local rb=mk("TextButton",{Text="  > "..name,Font=Enum.Font.Code,TextSize=11,
            TextColor3=isSel and T.accent or T.text,
            BackgroundColor3=isSel and T.rowSel or T.deep,
            BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Left,
            Size=UDim2.new(1,0,0,20),LayoutOrder=idx,AutoButtonColor=false,Parent=fileSF})
        if isSel then brd(rb,T.accent) end
        rb.MouseEnter:Connect(function() if path~=G.selPath then rb.BackgroundColor3=T.rowHov end end)
        rb.MouseLeave:Connect(function() if path~=G.selPath then rb.BackgroundColor3=T.deep  end end)
        rb.MouseButton1Click:Connect(function()
            G.selPath=path
            local content=nil
            if type(readfile)=="function" then local ok,res=pcall(readfile,path); if ok and res then content=res end end
            if not content then content=G.files[path] end
            if not content then setStatus("[error al leer: "..name.."]",T.err); return end
            local blocks=parseBuild(content)
            if not blocks then setStatus("[JSON inválido: "..name.."]",T.err); return end
            G.blocks=blocks
            local stats,total=getStats(blocks); G.stats=stats
            prevTitle.Text=string.format("[%s — %d bloques]",name,total)
            clrKids(prevSF)
            local i2=1
            for bname,cnt in pairs(stats) do
                local pct=cnt/math.max(total,1)
                local row=fr(prevSF,{Size=UDim2.new(1,-6,0,18),BackgroundColor3=T.deep,LayoutOrder=i2})
                fr(row,{Size=UDim2.new(pct,0,1,0),BackgroundColor3=SPECIAL[bname] and T.special or T.dim})
                lbl(row,string.format("  %s%s %d (%.0f%%)",bname,SPECIAL[bname] and "*" or "",cnt,pct*100),
                    {Size=UDim2.new(1,0,1,0),TextSize=10,TextColor3=SPECIAL[bname] and T.special or T.text})
                i2=i2+1
            end
            local inv=scanInv(); clrKids(missSF)
            local hasMiss=false; local j=1
            for bname,cnt in pairs(stats) do
                local have=inv[bname] or 0
                if have<cnt then hasMiss=true
                    lbl(missSF,string.format("  X %s [tienes %d/necesitas %d]",bname,have,cnt),
                        {Size=UDim2.new(1,0,0,18),TextSize=10,TextColor3=T.err,lo=j}); j=j+1
                end
            end
            if not hasMiss then
                lbl(missSF,"  OK todos los bloques disponibles",
                    {Size=UDim2.new(1,0,0,18),TextSize=10,TextColor3=T.ok,lo=1}) end
            pLabel.Text=string.format("0 / %d",total)
            pBar.Size=UDim2.new(0,0,1,0)
            setStatus(string.format("[%d bloques — %d tipos]",total,i2-1),T.ok)
            scanFiles()
        end)
    end
end

local function buildGUI()
    pcall(function() game:GetService("CoreGui"):FindFirstChild("BABFT_AB_v44"):Destroy() end)
    local sg=mk("ScreenGui",{Name="BABFT_AB_v44",ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=game:GetService("CoreGui")})

    local win=mk("Frame",{Size=UDim2.new(0,420,0,520),
        Position=UDim2.new(0.5,-210,0.5,-260),
        BackgroundColor3=T.bg,BorderSizePixel=0,ClipsDescendants=true,Parent=sg})
    brd(win,T.accent,2)

    local tbar=mk("Frame",{Size=UDim2.new(1,0,0,26),BackgroundColor3=T.deep,
        BorderSizePixel=0,Parent=win})
    fr(tbar,{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.accent})
    lbl(tbar,"[ BABFT AUTOBUILDER v4.4 ]",{Size=UDim2.new(1,-72,1,0),TextSize=11,
        TextColor3=T.accent,Font=Enum.Font.Code}).Position=UDim2.new(0,8,0,0)
    lbl(tbar,"auto-sig",{Size=UDim2.new(0,50,1,0),TextSize=9,TextColor3=T.dim,
        TextXAlignment=Enum.TextXAlignment.Right}).Position=UDim2.new(1,-88,0,0)
    local xb=sbtn(tbar,"[X]",T.err,T.errD,function() AB.stop(); sg:Destroy() end)
    xb.Size=UDim2.new(0,32,0,18); xb.Position=UDim2.new(1,-36,0.5,-9); xb.TextColor3=T.text

    do
        local drag,ds,sp=false,nil,nil
        tbar.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;ds=i.Position;sp=win.Position end end)
        tbar.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
        UIS.InputChanged:Connect(function(i)
            if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
                local d=i.Position-ds
                win.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
    end

    local body=mk("ScrollingFrame",{Size=UDim2.new(1,0,1,-27),Position=UDim2.new(0,0,0,27),
        BackgroundColor3=T.bg,BorderSizePixel=0,ScrollBarThickness=2,
        ScrollBarImageColor3=T.accent,CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingEnabled=true,Parent=win})
    pdg(body,8); vl(body,6)

    local _,s1=sec(body,"// ARCHIVOS .BUILD",130,1)
    pdg(s1,6); vl(s1,4)
    fileSF=sframe(s1,{Size=UDim2.new(1,-12,0,74),LayoutOrder=1})
    pdg(fileSF,3); vl(fileSF,1)
    local esb=sbtn(s1,"[ ESCANEAR ]",T.accent,T.accentD,scanFiles)
    esb.Size=UDim2.new(0,130,0,20); esb.LayoutOrder=2

    local _,s2=sec(body,"// PREVIEW",130,2)
    pdg(s2,6); vl(s2,4)
    prevTitle=lbl(s2,"[selecciona un .Build]",{Size=UDim2.new(1,0,0,12),TextSize=9,TextColor3=T.dim,lo=1})
    prevSF=sframe(s2,{Size=UDim2.new(1,-12,0,88),LayoutOrder=2})
    pdg(prevSF,3); vl(prevSF,1)

    local _,s3=sec(body,"// FALTANTES",78,3)
    pdg(s3,6); vl(s3,4)
    missSF=sframe(s3,{Size=UDim2.new(1,-12,0,46),LayoutOrder=1})
    pdg(missSF,3); vl(missSF,1)

    local _,s4=sec(body,"// LOG",72,4)
    pdg(s4,6)
    LogLabel=mk("TextLabel",{Text="(esperando...)",Font=Enum.Font.Code,TextSize=9,
        TextColor3=Color3.fromRGB(0,195,125),BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
        TextWrapped=true,Size=UDim2.new(1,-12,1,0),Parent=s4})

    local _,s5=sec(body,"// CONTROLES",150,5)
    pdg(s5,6); vl(s5,5)

    local dRow=fr(s5,{Size=UDim2.new(1,-12,0,20),BackgroundTransparency=1,LayoutOrder=1}); hl(dRow,4)
    lbl(dRow,"DELAY:",{Size=UDim2.new(0,44,1,0),TextSize=10,TextColor3=T.dim,lo=1})
    local dBox=mk("TextBox",{Text="0.03",Font=Enum.Font.Code,TextSize=11,TextColor3=T.accent,
        BackgroundColor3=T.deep,BorderSizePixel=0,Size=UDim2.new(0,46,1,0),LayoutOrder=2,Parent=dRow})
    brd(dBox,T.border)
    dBox.FocusLost:Connect(function()
        local v=tonumber(dBox.Text)
        if v and v>=0.01 and v<=10 then AB.DELAY=v else dBox.Text=tostring(AB.DELAY) end end)
    lbl(dRow,"seg [0.03=max]",{Size=UDim2.new(0,120,1,0),TextSize=9,TextColor3=T.dim,lo=3})

    local pBg=fr(s5,{Size=UDim2.new(1,-12,0,16),BackgroundColor3=T.bar,LayoutOrder=2},true,T.border)
    pBar=fr(pBg,{Size=UDim2.new(0,0,1,0),BackgroundColor3=T.accent})
    pLabel=lbl(pBg,"0 / 0",{Size=UDim2.new(1,0,1,0),TextXAlignment=Enum.TextXAlignment.Center,
        TextSize=10,Font=Enum.Font.Code,TextColor3=T.bg})

    local bRow=fr(s5,{Size=UDim2.new(1,-12,0,24),BackgroundTransparency=1,LayoutOrder=3}); hl(bRow,3)
    sbtn(bRow,"[INICIAR]",T.ok,T.okD,function()
        if #G.blocks==0 then setStatus("[selecciona un .Build primero]",T.err); return end
        if AB.running then return end
        local total=#G.blocks
        setStatus("[construyendo...]",T.accent)
        AB.build(G.blocks,
            function(i,t,name,ok,isSp)
                pBar.Size=UDim2.new(i/t,0,1,0)
                pLabel.Text=string.format("%s %d/%d %s%s",ok and "OK" or "XX",i,t,name,isSp and "*" or "")
                pLabel.TextColor3=ok and T.bg or T.err
            end,
            function()
                setStatus("[completado]",T.ok)
                pBar.Size=UDim2.new(1,0,1,0)
                pLabel.Text=string.format("%d/%d OK",total,total)
                pLabel.TextColor3=T.bg
            end)
    end).Size=UDim2.new(0,84,1,0)

    pauseBtn=sbtn(bRow,"[PAUSAR]",T.warn,T.warnD,function()
        if AB.paused then AB.resume(); pauseBtn.Text="[PAUSAR]"; setStatus("[construyendo...]",T.accent)
        else AB.pause(); pauseBtn.Text="[REANUDAR]"; setStatus("[pausado]",T.warn) end
    end)
    pauseBtn.Size=UDim2.new(0,92,1,0); pauseBtn.TextColor3=T.bg

    sbtn(bRow,"[DETENER]",T.err,T.errD,function()
        AB.stop(); setStatus("[detenido]",T.err)
    end).Size=UDim2.new(0,84,1,0)

    local bRow2=fr(s5,{Size=UDim2.new(1,-12,0,22),BackgroundTransparency=1,LayoutOrder=4}); hl(bRow2,3)
    sbtn2(bRow2,"[TEST RF]",T.accent,T.accent,function()
        setStatus("[probando firmas...]",T.warn); task.spawn(testRF)
    end).Size=UDim2.new(0,78,1,0)
    sbtn2(bRow2,"[RESET]",T.dim,T.border,function()
        activeSigIndex=nil; log("firma reseteada",Color3.fromRGB(200,200,80))
        setStatus("[firma reseteada]",T.sub)
    end).Size=UDim2.new(0,64,1,0)
    sbtn2(bRow2,"[DIAG]",T.dim,T.border,function()
        task.spawn(function()
            log("=DIAG=",Color3.fromRGB(200,200,80))
            local rf=getRF()
            log(rf and ("RF: "..rf:GetFullName()) or "RF: no encontrado",
                rf and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,80,80))
            log("sig: "..(activeSigIndex and tostring(activeSigIndex) or "ninguna"),Color3.fromRGB(180,180,180))
            local data=LP:FindFirstChild("Data")
            if data then
                local items={}
                for _,v in ipairs(data:GetChildren()) do
                    if (v:IsA("IntValue") or v:IsA("NumberValue")) and v.Value>0 then
                        items[#items+1]=v.Name.."="..v.Value end end
                log("inv: "..table.concat(items,", "):sub(1,80),Color3.fromRGB(0,200,130))
            else log("Data: no encontrado",Color3.fromRGB(255,150,80)) end
        end)
    end).Size=UDim2.new(0,58,1,0)

    statusL=lbl(s5,"[selecciona un .Build para comenzar]",{Size=UDim2.new(1,-12,0,13),
        TextXAlignment=Enum.TextXAlignment.Left,TextSize=9,Font=Enum.Font.Code,TextColor3=T.dim,lo=5})

    scanFiles()
    task.delay(1.5,function()
        log("verificando RF...",Color3.fromRGB(200,200,80))
        local rf=getRF()
        if rf then log("OK "..rf:GetFullName(),Color3.fromRGB(100,255,100)) end
    end)
end

buildGUI()
print("[BABFT AutoBuilder v4.4] cargado")