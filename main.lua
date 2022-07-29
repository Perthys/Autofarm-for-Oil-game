
--[[
    Name: Autofarm for Oil game
    Authors: Bug#2923, Perth#0001
    Description: Automatically farms and harvests oil and sell oil.
    Game-Link: https://www.roblox.com/games/10381075598/Big-Oil-Tycoon
]]

local Sort = loadstring(game:HttpGet('https://raw.githubusercontent.com/Perthys/SmartSort/main/main.lua'))()
local Dump = loadstring(game:HttpGet('https://raw.githubusercontent.com/strawbberrys/LuaScripts/main/TableDumper.lua'))()

local Players = game:GetService("Players");
local Terrain = workspace.Terrain

local LocalPlayer = Players.LocalPlayer;

local Tycoons = Terrain.Tycoons

local Backpack = LocalPlayer.Backpack
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local function GetTool()
    return Character:FindFirstChildOfClass("Tool") or Backpack:FindFirstChildOfClass("Tool")
end

local function UpdateGrip(Tool, Grip)
    Tool.Parent = Backpack
    Tool.Grip = Grip
    Tool.Parent = Character
end

local function InverseCFrame(Offset)
    return Vector3.new(-Offset.X -3, -Offset.Y, -Offset.Z)
end

local function GetTycoon()
    for Index, Tycoon in pairs(Tycoons:GetChildren()) do
        local Attributes = Tycoon:GetAttributes()
        
        if Attributes["Owner"] == LocalPlayer.Name then
            return Tycoon
        end
    end
end

local OilSort = Sort.new()
    :Add("Oil", 1, "Lower")
    
local function GetBestOil()
    local Tycoon = GetTycoon()
    
    local ReturnedRigs = {}
    
    if Tycoon then
        local Rigs = Tycoon:FindFirstChild("Rigs");
        
        if Rigs then
            for Index, Rig in pairs(Rigs:GetChildren()) do
                local Barrel = Rig:FindFirstChild("Barrel");
                local OilRig = Rig:FindFirstChild("Oil Rig");
                
                if Barrel and OilRig then
                    local Overhead = Barrel:FindFirstChild("Overhead");
                    local TopSection = Barrel:FindFirstChild("TopSection")
                    
                    if Overhead and TopSection then
                        local TextLabel = Overhead:FindFirstChild("TextLabel")
                        local Hole = TopSection:FindFirstChild("Hole")
                        
                        if Hole and TextLabel then
                            table.insert(ReturnedRigs, {
                                Oil = tonumber(TextLabel.Text:split("/")[1]);
                                Instance = Rig;
                                Output = Hole;
                            })
                        end
                    end
                end
            end
        end
    end
    

    
    local Sorted = OilSort:Sort(ReturnedRigs)
    print(Dump(Sorted))   
    return Sorted[1]
end

local function GetGasTank()
    local Tycoon = GetTycoon()
    local Objects = Tycoon:FindFirstChild("Objects")
    
    if Objects then
        local GasTank = Objects:FindFirstChild("Gas Tank")
        
        return GasTank
    end
end

local PositionMap = nil;

PositionMap = {
    ["CFrame"] = function(Arg)
        return Arg.Position
    end;
    ["Vector3"] = function(Arg)
        return Arg
    end;
    ["Instance"] = function(Arg)
        for Index, Value in pairs(PositionMap.__InstanceMap) do
            if Arg:IsA(Index) then
                return Value(Arg);
            end
        end
    end;
    __InstanceMap = {
        ["PVInstance"] = function(Arg)
            return Arg:GetPivot().Position;
        end;
        ["Player"] = function(Arg) 
            local Character = Arg.Character or Arg.CharacterAdded:Wait();
            
            if Character then
                return Character:GetPivot().Position;
            end
        end;
        ["Humanoid"] = function(Arg)
            local Character = Arg.Parent;
            
            if Character then
                return Character:GetPivot().Position;
            end
        end
    };
}

local function ConverToPosition(Arg1)
    return PositionMap[typeof(Arg1)](Arg1);
end


local function GetLookAt(Start, PositionArg) 
    PositionArg = ConverToPosition(PositionArg)
    
    local StartPos = ConverToPosition(Start);
    local NewVector = Vector3.new(PositionArg.X, StartPos.Y, PositionArg.X);
    
    return CFrame.new(StartPos, NewVector)
end


local function Main()
    local Tool = GetTool()
    
    if Tool then
        local Handle = Tool:FindFirstChild("Handle");
        
        if Handle then
            local Overhead = Handle:FindFirstChild("Overhead")
            
            if Overhead then
                local TextLabel = Overhead:FindFirstChild("TextLabel")
                
                if TextLabel then
                    
                    local BestOil = GetBestOil()
                    local Split = TextLabel.Text:split("/")
                    local Min = tonumber(Split[1]);
                    local Max = tonumber(Split[2]);
                    
                    if Min < Max then
                        if BestOil then
                            local RightArm = Character:FindFirstChild("RightLowerArm") or Character:FindFirstChild("Right Arm")

                            local Offset = CFrame.new().Inverse(CFrame.new().toObjectSpace(RightArm.CFrame * CFrame.new(0, -1, 0, 1, 0, 0, 0, 0, 1, 0, -1, 0), BestOil.Output.CFrame))

                            UpdateGrip(Tool, Offset)
                        end
                    elseif Min >= Max then
                        repeat wait()
                            local GasTank = GetGasTank()
    
                            if GasTank then
                                local BottomSection = GasTank:FindFirstChild("BottomSection");
                                
                                if BottomSection then
                                    local Hole = BottomSection:FindFirstChild("Hole");
                                    
                                    if Hole then
                                        local RightArm = Character:FindFirstChild("RightLowerArm") or Character:FindFirstChild("Right Arm")

                                        local Offset = CFrame.new().Inverse(CFrame.new().toObjectSpace(RightArm.CFrame * CFrame.new(0, -1, 0, 1, 0, 0, 0, 0, 1, 0, -1, 0), Hole.CFrame))

                                        UpdateGrip(Tool, Offset)
                                    end
                                end
                            end
                        until tonumber(TextLabel.Text:split("/")[1]) == 0 or not shared.Looped
                    end
                end
            end
        end
    end
end

shared.Looped = true;

while shared.Looped do
    Main()
    wait()
end
