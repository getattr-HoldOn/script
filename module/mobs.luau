local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Mobs = {
    Rendered = ReplicatedStorage:WaitForChild('MobRenderBin'),
}

function Mobs:IsAlive(Mob)
    local Dead = Mob:FindFirstChild('Dead')
    return Dead and Dead.Value == false
end

function Mobs:IsDead(Mob)
    return not self:IsAlive(Mob)
end

function Mobs:IsValid(Mob)
    return Mob and Mob.Parent and self:IsAlive(Mob)
end

function Mobs:Get()
    return self.Rendered:GetChildren()
end

function Mobs:GetOne()
    local List = self:Get()
    
    for _, Mob in ipairs(List) do
        local RootReference = Mob:FindFirstChild('RootReference')
        if RootReference and RootReference.Value and self:IsValid(RootReference.Value) then
            return RootReference.Value
        end
    end

    return nil
end

function Mobs:GetFirst()
    local List = self:Get()
    return List[1] and List[1].RootReference and List[1].RootReference.Value
end

function Mobs:GetLast()
    local List = self:Get()
    local Last = #List
    return Last > 0 and List[Last].RootReference and List[Last].RootReference.Value
end

return Mobs
