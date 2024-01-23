Icons = {}
Icons[PlayerStates.Poison] = {
    tooltip = tr('You are poisoned'),
    path = '/images/game/states/poisoned',
    id = 'condition_poisoned'
}
Icons[PlayerStates.Burn] = {
    tooltip = tr('You are burning'),
    path = '/images/game/states/burning',
    id = 'condition_burning'
}
Icons[PlayerStates.Energy] = {
    tooltip = tr('You are electrified'),
    path = '/images/game/states/electrified',
    id = 'condition_electrified'
}
Icons[PlayerStates.Drunk] = {
    tooltip = tr('You are drunk'),
    path = '/images/game/states/drunk',
    id = 'condition_drunk'
}
Icons[PlayerStates.ManaShield] = {
    tooltip = tr('You are protected by a magic shield'),
    path = '/images/game/states/magic_shield',
    id = 'condition_magic_shield'
}
Icons[PlayerStates.Paralyze] = {
    tooltip = tr('You are paralysed'),
    path = '/images/game/states/slowed',
    id = 'condition_slowed'
}
Icons[PlayerStates.Haste] = {
    tooltip = tr('You are hasted'),
    path = '/images/game/states/haste',
    id = 'condition_haste'
}
Icons[PlayerStates.Swords] = {
    tooltip = tr('You may not logout during a fight'),
    path = '/images/game/states/logout_block',
    id = 'condition_logout_block'
}
Icons[PlayerStates.Drowning] = {
    tooltip = tr('You are drowning'),
    path = '/images/game/states/drowning',
    id = 'condition_drowning'
}
Icons[PlayerStates.Freezing] = {
    tooltip = tr('You are freezing'),
    path = '/images/game/states/freezing',
    id = 'condition_freezing'
}
Icons[PlayerStates.Dazzled] = {
    tooltip = tr('You are dazzled'),
    path = '/images/game/states/dazzled',
    id = 'condition_dazzled'
}
Icons[PlayerStates.Cursed] = {
    tooltip = tr('You are cursed'),
    path = '/images/game/states/cursed',
    id = 'condition_cursed'
}
Icons[PlayerStates.PartyBuff] = {
    tooltip = tr('You are strengthened'),
    path = '/images/game/states/strengthened',
    id = 'condition_strengthened'
}
Icons[PlayerStates.PzBlock] = {
    tooltip = tr('You may not logout or enter a protection zone'),
    path = '/images/game/states/protection_zone_block',
    id = 'condition_protection_zone_block'
}
Icons[PlayerStates.Pz] = {
    tooltip = tr('You are within a protection zone'),
    path = '/images/game/states/protection_zone',
    id = 'condition_protection_zone'
}
Icons[PlayerStates.Bleeding] = {
    tooltip = tr('You are bleeding'),
    path = '/images/game/states/bleeding',
    id = 'condition_bleeding'
}
Icons[PlayerStates.Hungry] = {
    tooltip = tr('You are hungry'),
    path = '/images/game/states/hungry',
    id = 'condition_hungry'
}

healthInfoWindow = nil
healthBar = nil
manaBar = nil
soulLabel = nil
capLabel = nil
healthTooltip = 'Your character health is %d out of %d.'
manaTooltip = 'Your character mana is %d out of %d.'
experienceTooltip = 'You have %d%% to advance to level %d.'

function init()
    connect(LocalPlayer, {
        onHealthChange = onHealthChange,
        onManaChange = onManaChange,
        onLevelChange = onLevelChange,
        onStatesChange = onStatesChange,
        onSoulChange = onSoulChange,
        onFreeCapacityChange = onFreeCapacityChange
    })

    connect(g_game, {
        onGameStart = online,
        onGameEnd = offline
    })

    healthInfoButton = modules.client_topmenu.addRightGameToggleButton('healthInfoButton', tr('Health Information'),
                                                                       '/images/topbuttons/healthinfo', toggle)
    healthInfoButton:setOn(true)

    healthInfoWindow = g_ui.loadUI('healthinfo')
    healthInfoWindow:disableResize()
    healthBar = healthInfoWindow:recursiveGetChildById('healthBar')
    manaBar = healthInfoWindow:recursiveGetChildById('manaBar')
    manaText = healthInfoWindow:recursiveGetChildById('manaText')
    soulLabel = healthInfoWindow:recursiveGetChildById('soulLabel')
    capLabel = healthInfoWindow:recursiveGetChildById('capLabel')

    -- load condition icons
    for k, v in pairs(Icons) do
        g_textures.preload(v.path)
    end

    if g_game.isOnline() then
        local localPlayer = g_game.getLocalPlayer()
        onHealthChange(localPlayer, localPlayer:getHealth(), localPlayer:getMaxHealth())
        onManaChange(localPlayer, localPlayer:getMana(), localPlayer:getMaxMana())
        onLevelChange(localPlayer, localPlayer:getLevel(), localPlayer:getLevelPercent())
        onStatesChange(localPlayer, localPlayer:getStates(), 0)
        onSoulChange(localPlayer, localPlayer:getSoul())
        onFreeCapacityChange(localPlayer, localPlayer:getFreeCapacity())
    end

    healthInfoWindow:setup()
    if g_game.isOnline() then
        healthInfoWindow:setupOnStart()
    end
end

function terminate()
    disconnect(LocalPlayer, {
        onHealthChange = onHealthChange,
        onManaChange = onManaChange,
        onLevelChange = onLevelChange,
        onStatesChange = onStatesChange,
        onSoulChange = onSoulChange,
        onFreeCapacityChange = onFreeCapacityChange
    })

    disconnect(g_game, {
        onGameStart = online,
        onGameEnd = offline
    })

    healthInfoWindow:destroy()
    healthInfoButton:destroy()

    healthInfoWindow = nil
    healthBar = nil
    manaBar = nil
    soulLabel = nil
    capLabel = nil
end

function toggle()
    if healthInfoButton:isOn() then
        healthInfoWindow:close()
        healthInfoButton:setOn(false)
    else
        healthInfoWindow:open()
        healthInfoButton:setOn(true)
    end
end



function online()
    healthInfoWindow:setupOnStart() -- load character window configuration
end

function offline()
    healthInfoWindow:setParent(nil, true)
end

-- hooked events
function onMiniWindowOpen()
    healthInfoButton:setOn(true)
end

function onMiniWindowClose()
    healthInfoButton:setOn(false)
end

function onHealthChange(localPlayer, health, maxHealth)
    healthInfoWindow.texto:setText(health)
    healthBar:setTooltip(tr(healthTooltip, health, maxHealth))
    healthBar:setValue(health, 0, maxHealth)
end

function onManaChange(localPlayer, mana, maxMana)
    healthInfoWindow.texto2:setText(mana)
    manaBar:setTooltip(tr(manaTooltip, mana, maxMana))
    manaBar:setValue(mana, 0, maxMana)
end



-- personalization functions
function hideLabels()
    local removeHeight = math.max(capLabel:getMarginRect().height, soulLabel:getMarginRect().height)
    capLabel:setOn(false)
    soulLabel:setOn(false)
    healthInfoWindow:setHeight(math.max(healthInfoWindow.minimizedHeight, healthInfoWindow:getHeight() - removeHeight))
end


function setHealthTooltip(tooltip)
    healthTooltip = tooltip

    local localPlayer = g_game.getLocalPlayer()
    if localPlayer then
        healthBar:setTooltip(tr(healthTooltip, localPlayer:getHealth(), localPlayer:getMaxHealth()))
    end
end

function setManaTooltip(tooltip)
    manaTooltip = tooltip

    local localPlayer = g_game.getLocalPlayer()
    if localPlayer then
        manaBar:setTooltip(tr(manaTooltip, localPlayer:getMana(), localPlayer:getMaxMana()))
    end
end


