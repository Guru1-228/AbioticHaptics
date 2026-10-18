file_path = "Z:/dev/shm/dualsense_state"
local isInitialized = false

local CurrentWeaponProfile = "trigger both off\n"
local defaultCommand = "trigger both off\n"
local DualSenseProfiles = {
    ["Weapon_Gun_Pistol_C"] = "trigger right bow 1 5 2 5\ntrigger left off\n",
    ["Weapon_Gun_wFlashlight_C"] = "trigger right bow 1 5 2 5\ntrigger left off\n",
    ["Weapon_Gun_Crossbow_C"] = "trigger right bow 1 5 3 7\ntrigger left off\n",
    ["Weapon_Gun_Vacuum_C"] = "trigger right vibration 5 1 30\ntrigger left off\n",
    ["Weapon_Melee_Drill_C"] = "trigger right vibration 5 2 40\ntrigger left off\n",
    ["Abiotic_Weapon_Melee_ParentBP_C"] = "trigger right feedback 1 1\ntrigger left off\n",
    ["Weapon_Melee_TechSpear_C"] = "trigger right feedback 1 1\ntrigger left off\n",
    ["Weapon_Melee_Heavy_C"] = "trigger right feedback 1 1\ntrigger left off\n",
    ["Item_Teleporter_ParentBP_C"] = "trigger right bow 1 2 1 6\ntrigger left off\n",
    ["Item_LightSource_Megalight_C"] = "trigger right bow 1 2 1 6\ntrigger left off\n",
    ["FIRE"] = "trigger right vibration 0 6 45\n",
    ["ATTACK"] = "trigger right vibration 0 2 45\n",
}


function SendCommand(Context)
    local file = io.open(file_path, "w")
    file:write(Context)
    file:close()
end


function SetupItemProfile(Context)
    local Character = Context
    local Item = Character.ItemInHand_BP
    local ItemClass = "NULL"

    if Item:IsValid() then
        ItemClass = Item:GetClass():GetFName():ToString()
    end
    CurrentWeaponProfile = DualSenseProfiles[ItemClass] or defaultCommand
    SendCommand(CurrentWeaponProfile)
    print (ItemClass)
end


function ToggleInventory(Context, InventoryClosed)
    if InventoryClosed then
        print(string.format(" -> InventoryClosed: %s", tostring(InventoryClosed:get())))
        if InventoryClosed:get() then
            SendCommand(CurrentWeaponProfile)
        else
            SendCommand(defaultCommand)
        end
    end
end


--- конвертация уровня радиации в цвет
local function GetRadiationLightbarCommand(radiation)
    local maxRad = 50.0

    -- 1. Нормализуем значение в диапазон от 0.0 до 1.0 (защита от вылета за границы)
    local t = radiation / maxRad
    if t < 0.0 then t = 0.0 end
    if t > 1.0 then t = 1.0 end

    local r, g, b = 0, 0, 0

    -- 2. Считаем цвета в зависимости от половины диапазона
    if t < 0.5 then
        -- Первая половина (0.0 -> 0.5): Зеленый -> Желтый
        -- t * 2 переводит отрезок [0.0, 0.5] в диапазон [0.0, 1.0]
        r = math.floor(255 * (t * 2))
        g = 255
    else
        -- Вторая половина (0.5 -> 1.0): Желтый -> Красный
        -- (t - 0.5) * 2 переводит отрезок [0.5, 1.0] в диапазон [0.0, 1.0]
        r = 255
        g = math.floor(255 * (1.0 - (t - 0.5) * 2))
    end

    -- Формируем готовую команду для dualsensectl
    return string.format("lightbar %d %d %d\n", r, g, b)
end

local function OnRadiationChanged(Context)
    local Character = Context
    if not Character or not Character:IsValid() then return end

    -- Читаем радиацию (если вдруг nil, берем 0.0)
    local rad = Character.CurrentRadiation or 0.0

    -- Превращаем число в команду с цветом
    local lightbarCmd = GetRadiationLightbarCommand(rad)

    -- Отправляем в наш мост (файл в ОЗУ)
    SendCommand(lightbarCmd)
end




local function InitHooks()
    if isInitialized then return end
    isInitialized = true

    --- lightbar init
    SendCommand("lightbar on\nlightbar off\n")

    --- Синхронизация состояния контроллера
    local Character = FindFirstOf("Abiotic_PlayerCharacter_C")
    if Character and Character:IsValid() then
        print("[DualSense] Haptics synched")
        SetupItemProfile(Character)
        OnRadiationChanged(Character)
    end


    --- регистрация смены предмета
    RegisterHook("/Game/Blueprints/Characters/Abiotic_PlayerCharacter.Abiotic_PlayerCharacter_C:OnRep_ItemInHand_BP", function(Context)
        SetupItemProfile(Context:get())
    end)

    --- регистрация выстрела
    RegisterHook("/Game/Blueprints/Characters/Abiotic_PlayerCharacter.Abiotic_PlayerCharacter_C:ConsumeAmmunitionInWeapon", function(Context)
        local Action = "FIRE"
        local command = DualSenseProfiles[Action] or defaultCommand
        SendCommand(command)
        ExecuteWithDelay(40, function()
            ExecuteInGameThread(function()
                SendCommand(CurrentWeaponProfile)
            end)
        end)
    end)

    -- удар ближнего боя
    RegisterHook("/Game/Blueprints/Characters/Abiotic_PlayerCharacter.Abiotic_PlayerCharacter_C:EndMeleeSwingArc", function(Context)
        local Action = "ATTACK"
        local command = DualSenseProfiles[Action] or defaultCommand
        SendCommand(command)
        ExecuteWithDelay(40, function()
            ExecuteInGameThread(function()
                SendCommand(CurrentWeaponProfile)
            end)
        end)
    end)

    --- регистрация радиации
    RegisterHook("/Game/Blueprints/Characters/Abiotic_PlayerCharacter.Abiotic_PlayerCharacter_C:Radiation_Changed_Event", function(Context)
        OnRadiationChanged(Context:get())
    end)

    --- регистрация переключения инвентаря
    RegisterHook("/Game/Blueprints/Characters/Abiotic_PlayerCharacter.Abiotic_PlayerCharacter_C:ToggleInventory", ToggleInventory)

    --- начало перезарядки
    RegisterHook("/Game/Blueprints/Characters/Abiotic_PlayerCharacter.Abiotic_PlayerCharacter_C:PlayReloadAnimation", function(Context)
        SendCommand(defaultCommand)
    end)

    -- завершение перезарядки
    RegisterHook("/Game/Blueprints/Characters/Abiotic_PlayerCharacter.Abiotic_PlayerCharacter_C:FinishWeaponReload", function(Context)
        SendCommand(CurrentWeaponProfile)
    end)

    -- прерывание перезарядки
    RegisterHook("/Game/Blueprints/Characters/Abiotic_PlayerCharacter.Abiotic_PlayerCharacter_C:Local_InterruptReload", function(Context)
        SendCommand(CurrentWeaponProfile)
    end)
end


--- иннициализировать, если уже в игре
local existingPlayer = FindFirstOf("Abiotic_PlayerCharacter_C")
if existingPlayer and existingPlayer:IsValid() then
    InitHooks()
end


RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(Context)
    -- Небольшая задержка, чтобы блюпринт персонажа успел инициализироваться
    ExecuteWithDelay(1000, InitHooks)
end)
