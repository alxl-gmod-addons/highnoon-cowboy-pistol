if SERVER then
    resource.AddFile("materials/vgui/ttt/icon_cowboypistol.vmt")
    resource.AddFile("materials/vgui/ttt/icon_cowboypistol.vtf")

    resource.AddFile("materials/killicons/cowboypistol.vtf")
    resource.AddFile("materials/killicons/cowboypistol.vmt")

    resource.AddFile("materials/entities/weapon_highnoon_cowboy_pistol.png")
end

if CLIENT then
    killicon.Add("weapon_highnoon_cowboy_pistol", "vgui/hud/killicon_cowboypistol", Color(255, 80, 0, 255))
end

CreateConVar("highnoon_cowboy_pistol_shop_detective", 0, FCVAR_ARCHIVE + FCVAR_NOTIFY,
    "Allows the Detectives to buy the Cowboy Pistol in TTT")
CreateConVar("highnoon_cowboy_pistol_shop_traitor", 1, FCVAR_ARCHIVE + FCVAR_NOTIFY,
    "Allows the Traitors to buy the Cowboy Pistol in TTT")
