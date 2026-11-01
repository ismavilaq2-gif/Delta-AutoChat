
--[[
    AutoChat v2.1
    Para pruebas autorizadas en experiencias propias.
    No evade filtros ni límites de Roblox.
]]

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
if not player then return end

-- Limpiar versión anterior
local parent
if typeof(gethui) == "function" then
    parent = gethui()
else
    parent = CoreGui
end

pcall(function()
    local old = parent:FindFirstChild("AutoChat")
    if old then old:Destroy() end
end)

-- Configuración
local palettes = {
    Midnight = Color3.fromRGB(25, 28, 43),
    Ocean = Color3.fromRGB(23, 60, 89),
    Purple = Color3.fromRGB(53, 32, 77),
    Forest = Color3.fromRGB(23, 70, 56),
    Sunset = Color3.fromRGB(73, 48, 37),
    Graphite = Color3.fromRGB(41, 45, 53)
}

local accent = Color3.fromRGB(70, 135, 210)
local panelColor = palettes.Midnight
local transparency = 0.30
local sentCount = 0
local running = false
local minimized = false
local loopId = 0

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoChat"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = parent

local scale = Instance.new("UIScale")
scale.Scale = 0.50
scale.Parent = gui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(760, 900)
main.Position = UDim2.new(0.5, -380, 0.5, -450)
main.BackgroundColor3 = panelColor
main.BackgroundTransparency = transparency
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(75, 85, 110)
stroke.Thickness = 1.5
stroke.Parent = main

-- Funciones de interfaz
local function makeLabel(parentObj, text, pos, size, fontSize, color)
    local obj = Instance.new("TextLabel")
    obj.BackgroundTransparency = 1
    obj.Position = pos
    obj.Size = size
    obj.Font = Enum.Font.Gotham
    obj.Text = text
    obj.TextSize = fontSize
    obj.TextColor3 = color or Color3.new(1, 1, 1)
    obj.TextXAlignment = Enum.TextXAlignment.Left
    obj.Parent = parentObj
    return obj
end

local function makeButton(parentObj, text, pos, size, color)
    local obj = Instance.new("TextButton")
    obj.Position = pos
    obj.Size = size
    obj.BackgroundColor3 = color or Color3.fromRGB(43, 48, 65)
    obj.BorderSizePixel = 0
    obj.Font = Enum.Font.GothamBold
    obj.Text = text
    obj.TextSize = 16
    obj.TextColor3 = Color3.new(1, 1, 1)
    obj.AutoButtonColor = true
    obj.Parent = parentObj

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = obj
    return obj
end

local function makeBox(parentObj, placeholder, pos, size, defaultText)
    local obj = Instance.new("TextBox")
    obj.Position = pos
    obj.Size = size
    obj.BackgroundColor3 = Color3.fromRGB(38, 43, 59)
    obj.BorderSizePixel = 0
    obj.Font = Enum.Font.Gotham
    obj.Text = defaultText or ""
    obj.PlaceholderText = placeholder
    obj.PlaceholderColor3 = Color3.fromRGB(155, 160, 175)
    obj.TextColor3 = Color3.new(1, 1, 1)
    obj.TextSize = 17
    obj.ClearTextOnFocus = false
    obj.TextXAlignment = Enum.TextXAlignment.Left
    obj.Parent = parentObj

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = obj

    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, 12)
    p.PaddingRight = UDim.new(0, 8)
    p.Parent = obj
    return obj
end

-- Barra superior
local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 65)
top.BackgroundColor3 = Color3.fromRGB(19, 22, 34)
top.BorderSizePixel = 0
top.Parent = main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 14)
topCorner.Parent = top

makeLabel(top, "◉  AutoChat", UDim2.fromOffset(22, 10),
    UDim2.fromOffset(300, 42), 26)

makeLabel(top, "v2.1", UDim2.new(1, -115, 0, 20),
    UDim2.fromOffset(45, 25), 14,
    Color3.fromRGB(120, 180, 255))

local minimizeBtn = makeButton(top, "—",
    UDim2.new(1, -62, 0, 14),
    UDim2.fromOffset(42, 36),
    Color3.fromRGB(55, 65, 85))

-- Icono flotante minimizado
local miniButton = Instance.new("TextButton")
miniButton.Name = "AutoChatMini"
miniButton.Size = UDim2.fromOffset(58, 58)
miniButton.Position = UDim2.new(1, -85, 1, -110)
miniButton.BackgroundColor3 = panelColor
miniButton.BorderSizePixel = 0
miniButton.Text = "💬"
miniButton.TextSize = 29
miniButton.Font = Enum.Font.GothamBold
miniButton.TextColor3 = Color3.new(1, 1, 1)
miniButton.Visible = false
miniButton.Parent = gui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(1, 0)
miniCorner.Parent = miniButton

local miniStroke = Instance.new("UIStroke")
miniStroke.Color = accent
miniStroke.Thickness = 2
miniStroke.Parent = miniButton

-- Contenido
local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(0, 65)
content.Size = UDim2.new(1, 0, 0, 835)
content.BackgroundTransparency = 1
content.Parent = main

makeLabel(content, "CONFIGURACIÓN DEL MENSAJE",
    UDim2.fromOffset(25, 15), UDim2.fromOffset(400, 25),
    16, Color3.fromRGB(160, 190, 225))

makeLabel(content, "Mensaje",
    UDim2.fromOffset(25, 50), UDim2.fromOffset(200, 25), 16)

local messageBox = makeBox(content, "Escribe tu mensaje...",
    UDim2.fromOffset(25, 80),
    UDim2.new(1, -50, 0, 55), "¡Hola a todos!")

makeLabel(content, "Intervalo (segundos, mínimo 5)",
    UDim2.fromOffset(25, 150),
    UDim2.fromOffset(400, 25), 16)

local intervalBox = makeBox(content, "Segundos",
    UDim2.fromOffset(25, 180),
    UDim2.fromOffset(220, 48), "30")

-- START / STOP
local startBtn = makeButton(content, "▶  START",
    UDim2.fromOffset(25, 245),
    UDim2.new(0.5, -35, 0, 55),
    Color3.fromRGB(28, 125, 78))

local stopBtn = makeButton(content, "■  STOP",
    UDim2.new(0.5, 10, 0, 245),
    UDim2.new(0.5, -35, 0, 55),
    Color3.fromRGB(155, 55, 55))

-- Estadísticas
makeLabel(content, "ESTADÍSTICAS",
    UDim2.fromOffset(25, 320),
    UDim2.fromOffset(300, 25),
    16, Color3.fromRGB(160, 190, 225))

local stats = Instance.new("Frame")
stats.Position = UDim2.fromOffset(25, 355)
stats.Size = UDim2.new(1, -50, 0, 100)
stats.BackgroundColor3 = Color3.fromRGB(34, 39, 55)
stats.BorderSizePixel = 0
stats.Parent = content

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 10)
statsCorner.Parent = stats

makeLabel(stats, "MENSAJES ENVIADOS",
    UDim2.fromOffset(18, 10),
    UDim2.fromOffset(260, 22),
    13, Color3.fromRGB(165, 175, 195))

local countLabel = makeLabel(stats, "0",
    UDim2.fromOffset(18, 34),
    UDim2.fromOffset(260, 48),
    30, Color3.fromRGB(95, 170, 255))

makeLabel(stats, "PRÓXIMO ENVÍO",
    UDim2.new(0.58, 0, 0, 10),
    UDim2.fromOffset(250, 22),
    13, Color3.fromRGB(165, 175, 195))

local timerLabel = makeLabel(stats, "Detenido",
    UDim2.new(0.58, 0, 0, 37),
    UDim2.fromOffset(250, 40),
    25, Color3.new(1, 1, 1))

local statusLabel = makeLabel(content, "● DETENIDO",
    UDim2.fromOffset(25, 465),
    UDim2.fromOffset(400, 25),
    15, Color3.fromRGB(235, 115, 115))

-- Personalización
makeLabel(content, "PERSONALIZACIÓN",
    UDim2.fromOffset(25, 505),
    UDim2.fromOffset(300, 25),
    16, Color3.fromRGB(160, 190, 225))

makeLabel(content, "Transparencia del fondo (0-80%)",
    UDim2.fromOffset(25, 540),
    UDim2.fromOffset(400, 22), 14)

local transparencyBox = makeBox(content, "0 a 80",
    UDim2.fromOffset(25, 565),
    UDim2.fromOffset(150, 40), "30")

local applyTransparency = makeButton(content, "Aplicar",
    UDim2.fromOffset(185, 565),
    UDim2.fromOffset(120, 40), accent)

makeLabel(content, "Tamaño de ventana",
    UDim2.fromOffset(25, 620),
    UDim2.fromOffset(300, 22), 14)

local sizeButtons = {}
local sizes = {25, 50, 75, 100}

for i, value in ipairs(sizes) do
    local btn = makeButton(content, value .. "%",
        UDim2.fromOffset(25 + (i - 1) * 105, 650),
        UDim2.fromOffset(90, 38),
        value == 50 and accent or Color3.fromRGB(43, 48, 65))
    sizeButtons[value] = btn
end

makeLabel(content, "Paleta de colores",
    UDim2.fromOffset(25, 705),
    UDim2.fromOffset(300, 22), 14)

local paletteNames = {
    "Midnight", "Ocean", "Purple",
    "Forest", "Sunset", "Graphite"
}

local paletteButtons = {}

for i, name in ipairs(paletteNames) do
    local col = (i - 1) % 3
    local row = math.floor((i - 1) / 3)

    local btn = makeButton(content, name,
        UDim2.fromOffset(25 + col * 165, 735 + row * 42),
        UDim2.fromOffset(150, 34), palettes[name])

    paletteButtons[name] = btn
end

-- Minimizar y restaurar
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = true
    main.Visible = false
    miniButton.Visible = true
end)

miniButton.MouseButton1Click:Connect(function()
    minimized = false
    main.Visible = true
    miniButton.Visible = false
end)

-- Arrastrar ventana
local dragging = false
local dragStart, startPosition

top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Tamaño de ventana
for value, btn in pairs(sizeButtons) do
    btn.MouseButton1Click:Connect(function()
        scale.Scale = value / 100

        for n, b in pairs(sizeButtons) do
            b.BackgroundColor3 =
                n == value and accent
                or Color3.fromRGB(43, 48, 65)
        end
    end)
end

-- Paletas: ventana e icono siempre sincronizados
for name, btn in pairs(paletteButtons) do
    btn.MouseButton1Click:Connect(function()
        panelColor = palettes[name]

        main.BackgroundColor3 = panelColor
        miniButton.BackgroundColor3 = panelColor

        -- Borde del icono también cambia con la paleta
        miniStroke.Color = panelColor:Lerp(Color3.new(1, 1, 1), 0.35)

        for paletteName, paletteBtn in pairs(paletteButtons) do
            paletteBtn.Text = paletteName
            if paletteName == name then
                paletteBtn.Text = "✓ " .. paletteName
            end
        end
    end)
end

-- Transparencia solo del fondo principal
applyTransparency.MouseButton1Click:Connect(function()
    local value = tonumber(transparencyBox.Text)

    if not value then
        transparencyBox.Text = "30"
        return
    end

    value = math.clamp(value, 0, 80)
    transparency = value / 100
    main.BackgroundTransparency = transparency
    transparencyBox.Text = tostring(value)
end)

-- Canal de chat
local function getChatChannel()
    local channels = TextChatService:FindFirstChild("TextChannels")
    if not channels then return nil end

    return channels:FindFirstChild("RBXGeneral")
end

-- Detener
local function stopAutoChat()
    running = false
    loopId += 1

    timerLabel.Text = "Detenido"
    statusLabel.Text = "● DETENIDO"
    statusLabel.TextColor3 = Color3.fromRGB(235, 115, 115)
end

stopBtn.MouseButton1Click:Connect(stopAutoChat)

-- Iniciar
startBtn.MouseButton1Click:Connect(function()
    if running then return end

    local message = messageBox.Text
    local interval = tonumber(intervalBox.Text)

    if not message or message:gsub("%s", "") == "" then
        statusLabel.Text = "● ESCRIBE UN MENSAJE"
        return
    end

    if not interval then
        statusLabel.Text = "● INTERVALO NO VÁLIDO"
        return
    end

    interval = math.clamp(math.floor(interval), 5, 3600)
    intervalBox.Text = tostring(interval)

    if not getChatChannel() then
        statusLabel.Text = "● CANAL RBXGENERAL NO DISPONIBLE"
        return
    end

    running = true
    loopId += 1

    local thisLoop = loopId

    statusLabel.Text = "● ACTIVO"
    statusLabel.TextColor3 = Color3.fromRGB(90, 220, 145)

    task.spawn(function()
        while running and loopId == thisLoop do
            local remaining = interval

            while remaining > 0
                and running
                and loopId == thisLoop do

                timerLabel.Text = string.format(
                    "00:%02d", remaining
                )

                task.wait(1)
                remaining -= 1
            end

            if not running or loopId ~= thisLoop then
                break
            end

            local channel = getChatChannel()

            if not channel then
                statusLabel.Text = "● CANAL NO DISPONIBLE"
                stopAutoChat()
                break
            end

            local currentMessage = messageBox.Text

            if currentMessage:gsub("%s", "") == "" then
                statusLabel.Text = "● MENSAJE VACÍO"
                stopAutoChat()
                break
            end

            local ok, result = pcall(function()
                return channel:SendAsync(currentMessage)
            end)

            if ok and result ~= nil then
                sentCount += 1
                countLabel.Text = tostring(sentCount)
                statusLabel.Text = "● ACTIVO — API OK"
            else
                statusLabel.Text = "● ERROR AL ENVIAR"
                timerLabel.Text = "Error"
                stopAutoChat()
                break
            end
        end
    end)
end)

-- Limpieza
gui.Destroying:Connect(function()
    running = false
    loopId += 1
end)

print("AutoChat v2.1 cargado correctamente")
