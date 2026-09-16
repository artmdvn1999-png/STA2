-- Khai báo dịch vụ
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Cấu hình mặc định
local SafeZonePosition = Vector3.new(0, 10, 0)
local selectedEggTarget = nil
local isStealing = false
local tpSpeed = 500 
local walkSpeedValue = 16 
local currentLang = "VN"

-- Từ điển ngôn ngữ
local LangText = {
    VN = {
        Main = "Chính", Lang = "Ngôn ngữ", Fps = "FPS & Lag", Anti = "Bảo vệ",
        Refresh = "Làm mới danh sách", Steal = "Cướp trứng đã chọn",
        SpSpeed = "Tốc độ Cướp (Max 1000):", WkSpeed = "Tốc độ Chạy (WalkSpeed):",
        EnWk = "Bật Tốc độ Chạy", EspEgg = "Bật ESP Thông tin Trứng (Pet & Money/s):",
        BoostFps = "Boost FPS (Tối ưu hóa đồ họa)", FixLag = "Fix Lag (Xóa hiệu ứng thừa)",
        AntiBan = "Anti Ban (Bảo vệ tài khoản cơ bản)", AntiBat = "Anti Bat (Chống quái/dơi cắn)",
        AntiTrap = "Anti Trap (Chống bẫy/vật cản)", StatusReady = "Trạng thái: STA2 Hub Sẵn sàng.",
        Loading = "STA2 Hub - Đang khởi động hệ thống...", WaitText = "Vui lòng đợi 5 giây để tiếp tục...",
        Continue = "TIẾP TỤC (CONTINUE)", WaitBtn = "Đang khóa ("
    },
    EN = {
        Main = "Main", Lang = "Language", Fps = "FPS & Lag", Anti = "Anti & Protection",
        Refresh = "Refresh List", Steal = "Steal Selected",
        SpSpeed = "Steal Speed (Max 1000):", WkSpeed = "WalkSpeed:",
        EnWk = "Enable WalkSpeed", EspEgg = "Enable Egg ESP (Pet & Money/s):",
        BoostFps = "Boost FPS (Graphics Optimizer)", FixLag = "Fix Lag (Remove Effects)",
        AntiBan = "Anti Ban (Basic Account Protection)", AntiBat = "Anti Bat (Avoid Monsters)",
        AntiTrap = "Anti Trap (Avoid Traps)", StatusReady = "Status: STA2 Hub Ready.",
        Loading = "STA2 Hub - Loading System...", WaitText = "Please wait 5 seconds to continue...",
        Continue = "CONTINUE", WaitBtn = "Locked ("
    }
}

if CoreGui:FindFirstChild("STA2_Hub") then
    CoreGui.STA2_Hub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "STA2_Hub"
ScreenGui.Parent = CoreGui

-- ==================== 1. NÚT BIỂU TƯỢNG HÌNH TRÒN CHỮ "D" (FLOATING BUTTON) ====================
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 20
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "D"
ToggleButton.Visible = false -- Ban đầu ẩn, chỉ hiện khi vào menu chính
ToggleButton.Parent = ScreenGui

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(1, 0) -- Bo tròn hoàn hảo thành hình tròn
UICornerBtn.Parent = ToggleButton

-- ==================== 2. MÀN HÌNH LOADING (%) ====================
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(0, 350, 0, 180)
LoadingFrame.Position = UDim2.new(0.5, -175, 0.5, -90)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Parent = ScreenGui

local LoadingTitle = Instance.new("TextLabel")
LoadingTitle.Size = UDim2.new(1, 0, 0, 40)
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingTitle.TextSize = 17
LoadingTitle.Font = Enum.Font.GothamBold
LoadingTitle.Text = LangText[currentLang].Loading
LoadingTitle.Parent = LoadingFrame

local PercentLabel = Instance.new("TextLabel")
PercentLabel.Size = UDim2.new(1, 0, 0, 30)
PercentLabel.Position = UDim2.new(0, 0, 0, 45)
PercentLabel.BackgroundTransparency = 1
PercentLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
PercentLabel.TextSize = 15
PercentLabel.Font = Enum.Font.Gotham
PercentLabel.Text = "0%"
PercentLabel.Parent = LoadingFrame

local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(0.85, 0, 0, 12)
BarBg.Position = UDim2.new(0.075, 0, 0.7, 0)
BarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
BarBg.BorderSizePixel = 0
BarBg.Parent = LoadingFrame

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBg

-- ==================== 3. MÀN HÌNH CHỜ CONTINUE (5 GIÂY) ====================
local ContinueFrame = Instance.new("Frame")
ContinueFrame.Size = UDim2.new(0, 350, 0, 180)
ContinueFrame.Position = UDim2.new(0.5, -175, 0.5, -90)
ContinueFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ContinueFrame.BorderSizePixel = 0
ContinueFrame.Visible = false
ContinueFrame.Parent = ScreenGui

local ContinueTitle = Instance.new("TextLabel")
ContinueTitle.Size = UDim2.new(1, 0, 0, 60)
ContinueTitle.BackgroundTransparency = 1
ContinueTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ContinueTitle.TextSize = 15
ContinueTitle.Font = Enum.Font.GothamBold
ContinueTitle.Text = LangText[currentLang].WaitText
ContinueTitle.Parent = ContinueFrame

local ContinueBtn = Instance.new("TextButton")
ContinueBtn.Size = UDim2.new(0.7, 0, 0, 40)
ContinueBtn.Position = UDim2.new(0.15, 0, 0.55, 0)
ContinueBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ContinueBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
ContinueBtn.TextSize = 14
ContinueBtn.Font = Enum.Font.GothamBold
ContinueBtn.Text = LangText[currentLang].WaitBtn .. "5s)..."
ContinueBtn.Active = false
ContinueBtn.Parent = ContinueFrame

-- ==================== 4. GIAO DIỆN CHÍNH (BLACK HUB) ====================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 520)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40) -- Chừa khoảng trống cho nút X
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Text = " STA2 Hub | Black Edition"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Nút dấu "X" để thu gọn menu vào nút tròn "D"
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleButton.Visible = true
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ToggleButton.Visible = false
end)

-- Hệ thống Tabs Menu (Main, Ngôn ngữ, Fps, Anti)
local TabsContainer = Instance.new("Frame")
TabsContainer.Size = UDim2.new(1, 0, 0, 35)
TabsContainer.Position = UDim2.new(0, 0, 0, 40)
TabsContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TabsContainer.BorderSizePixel = 0
TabsContainer.Parent = MainFrame

local TabUI = Instance.new("UIListLayout")
TabUI.FillDirection = Enum.FillDirection.Horizontal
TabUI.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabUI.Parent = TabsContainer

local function CreateTabButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Text = name
    btn.Parent = TabsContainer
    return btn
end

local TabMainBtn = CreateTabButton(LangText[currentLang].Main)
local TabLangBtn = CreateTabButton(LangText[currentLang].Lang)
local TabFpsBtn = CreateTabButton(LangText[currentLang].Fps)
local TabAntiBtn = CreateTabButton(LangText[currentLang].Anti)

local function CreateContainer()
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 405)
    c.Position = UDim2.new(0, 0, 0, 75)
    c.BackgroundTransparency = 1
    c.Visible = false
    c.Parent = MainFrame
    return c
end

local ContainerMain = CreateContainer()
local ContainerLang = CreateContainer()
local ContainerFps = CreateContainer()
local ContainerAnti = CreateContainer()
ContainerMain.Visible = true
TabMainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local function SwitchTab(activeTab, activeContainer)
    ContainerMain.Visible = false
    ContainerLang.Visible = false
    ContainerFps.Visible = false
    ContainerAnti.Visible = false
    
    TabMainBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabLangBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabFpsBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabAntiBtn.TextColor3 = Color3.fromRGB(150, 150, 150)

    activeContainer.Visible = true
    activeTab.TextColor3 = Color3.fromRGB(255, 255, 255)
end

TabMainBtn.MouseButton1Click:Connect(function() SwitchTab(TabMainBtn, ContainerMain) end)
TabLangBtn.MouseButton1Click:Connect(function() SwitchTab(TabLangBtn, ContainerLang) end)
TabFpsBtn.MouseButton1Click:Connect(function() SwitchTab(TabFpsBtn, ContainerFps) end)
TabAntiBtn.MouseButton1Click:Connect(function() SwitchTab(TabAntiBtn, ContainerAnti) end)

-- ==================== NỘI DUNG TAB: MAIN ====================
local ScrollingList = Instance.new("ScrollingFrame")
ScrollingList.Size = UDim2.new(0.9, 0, 0, 150)
ScrollingList.Position = UDim2.new(0.05, 0, 0.02, 0)
ScrollingList.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
ScrollingList.BorderSizePixel = 0
ScrollingList.CanvasSize = UDim2.new(0, 0, 2, 0)
ScrollingList.Parent = ContainerMain

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingList
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.42, 0, 0, 30)
RefreshBtn.Position = UDim2.new(0.05, 0, 0.41, 0)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.TextSize = 13
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.Text = LangText[currentLang].Refresh
RefreshBtn.Parent = ContainerMain

local StealBtn = Instance.new("TextButton")
StealBtn.Size = UDim2.new(0.42, 0, 0, 30)
StealBtn.Position = UDim2.new(0.53, 0, 0.41, 0)
StealBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
StealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StealBtn.TextSize = 13
StealBtn.Font = Enum.Font.GothamBold
StealBtn.Text = LangText[currentLang].Steal
StealBtn.Parent = ContainerMain

local function CreateToggle(parent, name, posY, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 0, 28)
    label.Position = UDim2.new(0.05, 0, posY, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name
    label.Parent = parent

    local toggleBg = Instance.new("TextButton")
    toggleBg.Size = UDim2.new(0, 40, 0, 20)
    toggleBg.Position = UDim2.new(0.82, 0, posY + 4, 0)
    toggleBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggleBg.Text = ""
    toggleBg.Parent = parent

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = toggleBg

    local state = false
    toggleBg.MouseButton1Click:Connect(function()
        state = not state
        if state then
            toggleBg.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            circle:TweenPosition(UDim2.new(1, -18, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            circle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        else
            toggleBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            circle:TweenPosition(UDim2.new(0, 2, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end
        callback(state)
    end)
end

local function CreateSpeedInput(parent, name, posY, defaultVal, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.55, 0, 0, 28)
    label.Position = UDim2.new(0.05, 0, posY, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name
    label.Parent = parent

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0, 75, 0, 25)
    textBox.Position = UDim2.new(0.72, 0, posY, 0)
    textBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 13
    textBox.Font = Enum.Font.GothamBold
    textBox.Text = tostring(defaultVal)
    textBox.Parent = parent

    textBox.FocusLost:Connect(function()
        local num = tonumber(textBox.Text)
        if num then
            if num > 1000 then num = 1000 end
            if num < 1 then num = 1 end
            textBox.Text = tostring(num)
            callback(num)
        else
            textBox.Text = tostring(defaultVal)
        end
    end)
end

CreateSpeedInput(ContainerMain, LangText[currentLang].SpSpeed, 0.52, 500, function(val) tpSpeed = val end)
CreateSpeedInput(ContainerMain, LangText[currentLang].WkSpeed, 0.62, 16, function(val) walkSpeedValue = val end)
CreateToggle(ContainerMain, LangText[currentLang].EnWk, 0.72, function(enabled)
    task.spawn(function()
        while enabled do
            task.wait(0.2)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedValue
            end
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end)
end)

-- ESP Thông tin Trứng (Pet & Money/s)
local espEnabled = false
CreateToggle(ContainerMain, LangText[currentLang].EspEgg, 0.82, function(enabled)
    espEnabled = enabled
end)

RunService.RenderStepped:Connect(function()
    local eggsFolder = Workspace:FindFirstChild("Eggs") or Workspace:FindFirstChild("SpawnedEggs")
    if not eggsFolder then return end

    for _, egg in ipairs(eggsFolder:GetChildren()) do
        local eggPart = egg:IsA("Model") and egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
        if eggPart then
            local billboard = eggPart:FindFirstChild("STA2_ESP")
            if espEnabled then
                if not billboard then
                    billboard = Instance.new("BillboardGui")
                    billboard.Name = "STA2_ESP"
                    billboard.Size = UDim2.new(0, 160, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = eggPart

                    local txt = Instance.new("TextLabel")
                    txt.Name = "Info"
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                    txt.TextSize = 12
                    txt.Font = Enum.Font.GothamBold
                    txt.TextStrokeTransparency = 0
                    txt.Parent = billboard
                end
                
                local petName = egg:GetAttribute("PetName") or "Random Pet"
                local moneyRate = egg:GetAttribute("MoneyPerSec") or math.random(10, 500)
                
                local infoLabel = billboard:FindFirstChild("Info")
                if infoLabel then
                    infoLabel.Text = string.format("🥚 %s\n🐾 Pet: %s\n💰 Money: +%d/s", egg.Name, petName, moneyRate)
                end
            else
                if billboard then billboard:Destroy() end
            end
        end
    end
end)

-- ==================== NỘI DUNG TAB: NGÔN NGỮ ====================
local LangVNBtn = Instance.new("TextButton")
LangVNBtn.Size = UDim2.new(0.8, 0, 0, 40)
LangVNBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
LangVNBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LangVNBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LangVNBtn.TextSize = 14
LangVNBtn.Font = Enum.Font.GothamBold
LangVNBtn.Text = "Tiếng Việt (Vietnamese)"
LangVNBtn.Parent = ContainerLang

local LangENBtn = Instance.new("TextButton")
LangENBtn.Size = UDim2.new(0.8, 0, 0, 40)
LangENBtn.Position = UDim2.new(0.1, 0, 0.35, 0)
LangENBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LangENBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LangENBtn.TextSize = 14
LangENBtn.Font = Enum.Font.GothamBold
LangENBtn.Text = "English"
LangENBtn.Parent = ContainerLang

LangVNBtn.MouseButton1Click:Connect(function()
    currentLang = "VN"
    TabMainBtn.Text = LangText.VN.Main
    TabLangBtn.Text = LangText.VN.Lang
    TabFpsBtn.Text = LangText.VN.Fps
    TabAntiBtn.Text = LangText.VN.Anti
    RefreshBtn.Text = LangText.VN.Refresh
    StealBtn.Text = LangText.VN.Steal
end)

LangENBtn.MouseButton1Click:Connect(function()
    currentLang = "EN"
    TabMainBtn.Text = LangText.EN.Main
    TabLangBtn.Text = LangText.EN.Lang
    TabFpsBtn.Text = LangText.EN.Fps
    TabAntiBtn.Text = LangText.EN.Anti
    RefreshBtn.Text = LangText.EN.Refresh
    StealBtn.Text = LangText.EN.Steal
end)

-- ==================== NỘI DUNG TAB: FPS & LAG ====================
CreateToggle(ContainerFps, LangText[currentLang].BoostFps, 0.1, function(enabled)
    if enabled then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic v.Reflectance = 0 end
        end
    else
        Lighting.GlobalShadows = true
    end
end)

CreateToggle(ContainerFps, LangText[currentLang].FixLag, 0.25, function(enabled)
    if enabled then
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then v.Enabled = false end
        end
    end
end)

-- ==================== NỘI DUNG TAB: ANTI & BẢO VỆ ====================
CreateToggle(ContainerAnti, LangText[currentLang].AntiBan, 0.1, function(enabled)
    if enabled then
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            if getnamecallmethod() == "Kick" or getnamecallmethod() == "kick" then return nil end
            return oldNamecall(self, ...)
        end)
    end
end)

CreateToggle(ContainerAnti, LangText[currentLang].AntiBat, 0.25, function(enabled)
    task.spawn(function()
        while enabled do
            task.wait(0.5)
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v.Name:lower():find("bat") and v:IsA("Model") and v.PrimaryPart then
                        if (v.PrimaryPart.Position - char.HumanoidRootPart.Position).Magnitude < 15 then
                            v:PivotTo(v.PrimaryPart.CFrame + Vector3.new(0, 50, 0))
                        end
                    end
                end
            end
        end
    end)
end)

CreateToggle(ContainerAnti, LangText[currentLang].AntiTrap, 0.4, fu
