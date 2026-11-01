
-- DELTA AUTO CHAT v1.1
-- Interfaz grafica para Roblox TextChatService

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local player = Players.LocalPlayer
local running = false

-- Crear interfaz
local gui = Instance.new("ScreenGui")
gui.Name = "DeltaAutoChat"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(280, 225)
frame.Position = UDim2.new(0.5, -140, 0.5, -112)
frame.BackgroundColor3 = Color3.fromRGB(25, 27, 38)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius =
    UDim.new(0, 10)

-- Funcion para crear elementos
local function create(class, properties)
    local object = Instance.new(class)

    for k, v in pairs(properties) do
        object[k] = v
    end

    object.Parent = frame
    return object
end

-- Titulo
create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 35),
    BackgroundTransparency = 1,
    Text = "DELTA AUTO CHAT",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 18,
    Font = Enum.Font.GothamBold
})

-- Campo del mensaje
local message = create("TextBox", {
    Position = UDim2.fromOffset(15, 50),
    Size = UDim2.new(1, -30, 0, 35),
    PlaceholderText = "Escribe tu mensaje...",
    Text = "",
    TextSize = 14,
    ClearTextOnFocus = false,
    BackgroundColor3 = Color3.fromRGB(45, 48, 62),
    TextColor3 = Color3.new(1, 1, 1)
})

-- Campo del tiempo
local interval = create("TextBox", {
    Position = UDim2.fromOffset(15, 95),
    Size = UDim2.new(1, -30, 0, 35),
    PlaceholderText = "Intervalo en segundos",
    Text = "30",
    TextSize = 14,
    BackgroundColor3 = Color3.fromRGB(45, 48, 62),
    TextColor3 = Color3.new(1, 1, 1)
})

-- Estado
local status = create("TextLabel", {
    Position = UDim2.fromOffset(10, 180),
    Size = UDim2.new(1, -20, 0, 25),
    BackgroundTransparency = 1,
    Text = "Estado: Detenido",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 13
})

-- Boton START
local start = create("TextButton", {
    Position = UDim2.fromOffset(15, 145),
    Size = UDim2.new(0.5, -20, 0, 30),
    Text = "START",
    BackgroundColor3 = Color3.fromRGB(30, 140, 80),
    TextColor3 = Color3.new(1, 1, 1)
})

-- Boton STOP
local stop = create("TextButton", {
    Position = UDim2.new(0.5, 5, 0, 145),
    Size = UDim2.new(0.5, -20, 0, 30),
    Text = "STOP",
    BackgroundColor3 = Color3.fromRGB(180, 50, 50),
    TextColor3 = Color3.new(1, 1, 1)
})

-- Envio mediante TextChatService
local function sendMessage(msg)
    local channels = TextChatService:FindFirstChild("TextChannels")
    local channel = channels and channels:FindFirstChild("RBXGeneral")

    if not channel then
        return false
    end

    local success = pcall(function()
        channel:SendAsync(msg)
    end)

    return success
end

-- Iniciar bucle
start.MouseButton1Click:Connect(function()

    if running then return end

    local msg = message.Text
    local seconds = tonumber(interval.Text)

    if msg == "" then
        status.Text = "Escribe un mensaje"
        return
    end

    if not seconds or seconds < 10 then
        status.Text = "Minimo 10 segundos"
        return
    end

    running = true
    status.Text = "Estado: Activo"

    task.spawn(function()

        while running do

            local success = sendMessage(msg)

            if not success then
                running = false
                status.Text = "Error de envio"
                break
            end

            task.wait(seconds)

        end

        if not running then
            status.Text = "Estado: Detenido"
        end

    end)

end)

-- Detener bucle
stop.MouseButton1Click:Connect(function()
    running = false
    status.Text = "Estado: Detenido"
end)

print("DELTA AUTO CHAT cargado")
