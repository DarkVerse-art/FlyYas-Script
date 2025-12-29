-- FlyYas v1.0 - Universal Fly Script for All Games
-- Compatible with Delta Executor
-- Created by DARK-GPT

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Cek karakter
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Fly variables
local FlyYasEnabled = false
local FlySpeed = 50
local BodyVelocity, BodyGyro
local KeysPressed = {}

-- Notifikasi
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "FlyYas v1.0",
    Text = "Fly script loaded!\nPress X to toggle fly",
    Duration = 5
})

print("\n" .. string.rep("=", 50))
print("🔥 FlyYas v1.0 - Universal Fly Script")
print(string.rep("=", 50))
print("Controls:")
print("  X - Toggle Fly ON/OFF")
print("  W - Forward")
print("  A - Left")
print("  S - Backward")
print("  D - Right")
print("  Space - Up")
print("  Shift - Down")
print("  Q - Increase Speed")
print("  E - Decrease Speed")
print(string.rep("=", 50))

-- Function untuk enable fly
local function EnableFly()
    if FlyYasEnabled or not HumanoidRootPart then return end
    
    FlyYasEnabled = true
    
    -- Create velocity instances
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Name = "FlyYasVelocity"
    BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.Parent = HumanoidRootPart
    
    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.Name = "FlyYasGyro"
    BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    BodyGyro.P = 9e4
    BodyGyro.D = 1000
    BodyGyro.CFrame = HumanoidRootPart.CFrame
    BodyGyro.Parent = HumanoidRootPart
    
    -- Set humanoid state
    Humanoid.PlatformStand = true
    
    -- Visual feedback
    if Character:FindFirstChild("Humanoid") then
        Humanoid:ChangeState(Enum.HumanoidStateType.Flying)
    end
    
    print("[FlyYas] ✈️ Fly mode ENABLED")
    print("[FlyYas] Speed: " .. FlySpeed)
end

-- Function untuk disable fly
local function DisableFly()
    if not FlyYasEnabled then return end
    
    FlyYasEnabled = false
    
    -- Remove velocity instances
    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
    
    if BodyGyro then
        BodyGyro:Destroy()
        BodyGyro = nil
    end
    
    -- Reset humanoid state
    Humanoid.PlatformStand = false
    
    -- Reset keys
    KeysPressed = {}
    
    print("[FlyYas] 🚫 Fly mode DISABLED")
end

-- Function untuk update velocity berdasarkan keys
local function UpdateVelocity()
    if not FlyYasEnabled or not BodyVelocity or not HumanoidRootPart then return end
    
    local camera = Workspace.CurrentCamera
    local forward = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local up = Vector3.new(0, 1, 0)
    
    local direction = Vector3.new(0, 0, 0)
    
    -- Movement based on keys
    if KeysPressed["W"] then
        direction = direction + forward
    end
    if KeysPressed["S"] then
        direction = direction - forward
    end
    if KeysPressed["A"] then
        direction = direction - right
    end
    if KeysPressed["D"] then
        direction = direction + right
    end
    if KeysPressed["Space"] then
        direction = direction + up
    end
    if KeysPressed["Shift"] then
        direction = direction - up
    end
    
    -- Normalize and apply speed
    if direction.Magnitude > 0 then
        direction = direction.Unit * FlySpeed
    end
    
    -- Apply velocity
    BodyVelocity.Velocity = direction
    
    -- Update gyro to face camera direction
    if BodyGyro then
        BodyGyro.CFrame = camera.CFrame
    end
end

-- Keyboard input handling
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    local key = input.KeyCode.Name
    
    -- Toggle fly with X
    if key == "X" then
        if FlyYasEnabled then
            DisableFly()
        else
            EnableFly()
        end
        return
    end
    
    -- Speed controls
    if key == "Q" then
        FlySpeed = math.min(FlySpeed + 10, 200)
        print("[FlyYas] Speed increased to: " .. FlySpeed)
        return
    end
    
    if key == "E" then
        FlySpeed = math.max(FlySpeed - 10, 10)
        print("[FlyYas] Speed decreased to: " .. FlySpeed)
        return
    end
    
    -- Movement keys
    local movementKeys = {"W", "A", "S", "D", "Space", "Shift"}
    for _, movementKey in ipairs(movementKeys) do
        if key == movementKey then
            KeysPressed[movementKey] = true
            break
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if processed then return end
    
    local key = input.KeyCode.Name
    local movementKeys = {"W", "A", "S", "D", "Space", "Shift"}
    
    for _, movementKey in ipairs(movementKeys) do
        if key == movementKey then
            KeysPressed[movementKey] = false
            break
        end
    end
end)

-- Auto-respawn handling
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    
    -- If fly was enabled before respawn, re-enable it
    if FlyYasEnabled then
        task.wait(1) -- Wait for character to fully load
        EnableFly()
    end
end)

-- Main fly loop
RunService.Heartbeat:Connect(function(deltaTime)
    if FlyYasEnabled then
        UpdateVelocity()
        
        -- Anti-fall safety
        if HumanoidRootPart and HumanoidRootPart.Position.Y < -500 then
            HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
            print("[FlyYas] Anti-fall triggered: Teleported to safe position")
        end
    end
end)

-- Simple GUI untuk status
local function CreateFlyGUI()
    local CoreGui = game:GetService("CoreGui")
    
    -- Hapus GUI lama
    pcall(function()
        CoreGui:FindFirstChild("FlyYasGUI"):Destroy()
    end)
    
    -- Buat GUI sederhana
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "FlyYasGUI"
    gui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 250, 0, 100)
    frame.Position = UDim2.new(0.02, 0, 0.02, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    frame.BorderSizePixel = 2
    
    local title = Instance.new("TextLabel", frame)
    title.Text = "✈️ FlyYas v1.0"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.Code
    
    local status = Instance.new("TextLabel", frame)
    status.Name = "StatusText"
    status.Text = "Status: DISABLED\nPress X to toggle\nSpeed: " .. FlySpeed
    status.Size = UDim2.new(1, -10, 1, -35)
    status.Position = UDim2.new(0, 5, 0, 35)
    status.TextColor3 = Color3.fromRGB(0, 255, 0)
    status.Font = Enum.Font.Code
    status.TextSize = 12
    
    -- Update loop untuk GUI
    task.spawn(function()
        while task.wait(0.1) do
            if status and status.Parent then
                status.Text = "Status: " .. (FlyYasEnabled and "ENABLED 🟢" or "DISABLED 🔴") .. 
                             "\nSpeed: " .. FlySpeed .. 
                             "\nControls: WASD + Space/Shift" ..
                             "\nToggle: X | Speed: Q/E"
            end
        end
    end)
    
    return gui
end

-- Create GUI
CreateFlyGUI()

-- Help command in chat
LocalPlayer.Chatted:Connect(function(message)
    if message:lower() == ";flyhelp" then
        print("\n" .. string.rep("=", 50))
        print("FlyYas Commands:")
        print("  X - Toggle Fly ON/OFF")
        print("  Q - Increase Speed (+10)")
        print("  E - Decrease Speed (-10)")
        print("  ;flyhelp - Show this help")
        print(string.rep("=", 50))
    end
end)

-- Final message
print("\n✅ FlyYas v1.0 successfully loaded!")
print("🎮 Ready to fly in any game!")
print("🔧 Created by DARK-GPT")
print("💡 Tip: Use ;flyhelp in chat for controls")
