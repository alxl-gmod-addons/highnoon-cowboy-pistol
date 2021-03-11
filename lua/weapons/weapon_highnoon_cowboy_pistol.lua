AddCSLuaFile()

SWEP.PrintName = "Cowboy Pistol"
SWEP.Author = "alxl"
SWEP.Purpose = "Pew pew! Bang bang!"
SWEP.Instructions =
    "Firing too rapidly results in drastic accuracy loss.\n\nPrimary fire shoots normally.\nSecondary fire fans the hammer.\n\nReloading puts in one bullet at a time."

if engine.ActiveGamemode() == "terrortown" then
    SWEP.Base = "weapon_tttbase"
    SWEP.Slot = 7
    SWEP.Kind = WEAPON_EQUIP1

    SWEP.CanBuy = {}
    if GetConVar("highnoon_cowboy_pistol_shop_detective"):GetBool() then
        table.insert(SWEP.CanBuy, ROLE_DETECTIVE)
    end
    if GetConVar("highnoon_cowboy_pistol_shop_traitor"):GetBool() then
        table.insert(SWEP.CanBuy, ROLE_TRAITOR)
    end

    SWEP.Icon = "vgui/ttt/icon_cowboypistol"

    SWEP.EquipMenuData = {
        type = "Weapon",
        desc = "Infinitely reloading, fairly high damage.\n" .. SWEP.Instructions
    }
else
    SWEP.Base = "weapon_base"
    SWEP.Slot = 1
    SWEP.WepSelectIcon = "vgui/ttt/icon_cowboypistol"
    SWEP.BounceWeaponIcon = false

end

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Ammo = "none"

SWEP.Primary.ShotSound = Sound("Weapon_357.Single")
SWEP.Primary.EmptySound = Sound("Weapon_Pistol.Empty")
SWEP.Primary.Recoil = 7.5
SWEP.Primary.Damage = 60
SWEP.Primary.Force = 500

SWEP.Primary.Delay = 0.2
SWEP.Primary.Automatic = false

SWEP.Secondary.Delay = 0.13
SWEP.Secondary.Automatic = true

-- Here, "Cowboy" refers to the one-bullet-at-a-time reloading
SWEP.Cowboy = {}
SWEP.Cowboy.LoadDelay = 0.23
SWEP.Cowboy.ShootDelay = 0.4
SWEP.Cowboy.NextLoadTime = 0
SWEP.Cowboy.LoadSound = Sound("Weapon_357.RemoveLoader")
SWEP.Cowboy.DoneSound = Sound("Weapon_357.Spin")

-- Here, "Focus" refers to the custom mechanic of losing accuracy when firing too rapidly
SWEP.Primary.Cone = 0.33
SWEP.Secondary.Cone = 0.2
SWEP.Focus = {}
SWEP.Focus.Start = 0
SWEP.Focus.Time = 0.7

SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.UseHands = true
SWEP.HoldType = "revolver"
SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.ViewModelFOV = 54
SWEP.ViewModelFlip = false
SWEP.CSMuzzleFlashes = false

function SWEP:SetNextCowboyLoadTime(time)
    self.Cowboy.NextLoadTime = time
end

function SWEP:CheckNextCowboyLoadTime()
    return CurTime() >= self.Cowboy.NextLoadTime
end

function SWEP:BeginFocus()
    self.Focus.Start = CurTime()
end

function SWEP:GetFocus()
    return 1.0 - math.min(1.0, (CurTime() - self.Focus.Start) / self.Focus.Time)
end

function SWEP:CustomAmmoDisplay()
    self.AmmoDisplay = self.AmmoDisplay or {}

    self.AmmoDisplay.Draw = self.DrawAmmo
    self.AmmoDisplay.PrimaryClip = self:Clip1()
    self.AmmoDisplay.PrimaryAmmo = self:GetMaxClip1()

    return self.AmmoDisplay
end

function SWEP:Reload()
    if IsFirstTimePredicted() then
        if self:CheckNextCowboyLoadTime() then
            self:SetNextCowboyLoadTime(CurTime() + self.Cowboy.LoadDelay)

            if self:Clip1() >= self:GetMaxClip1() then
                self:EmitSound(self.Cowboy.DoneSound)
            else
                self:SetNextPrimaryFire(CurTime() + self.Cowboy.ShootDelay)
                self:SetNextSecondaryFire(CurTime() + self.Cowboy.ShootDelay)
                self:EmitSound(self.Cowboy.LoadSound)
                self:SetClip1(self:Clip1() + 1)
            end
        end
    end
end

function SWEP:CanPrimaryAttack()
    return self:Clip1() > 0
end

function SWEP:PrimaryAttack()
    self:CowboyFire(true, IsFirstTimePredicted())
end

function SWEP:CanSecondaryAttack()
    return true
end

function SWEP:SecondaryAttack()
    self:CowboyFire(false, IsFirstTimePredicted())
end

function SWEP:CowboyFire(primary_shot, first_predicted)
    local now = CurTime()
    self:SetNextPrimaryFire(now + self.Primary.Delay)
    self:SetNextSecondaryFire(now + self.Secondary.Delay)
    self:SetNextCowboyLoadTime(now + self.Cowboy.LoadDelay)

    if not self:CanPrimaryAttack() then
        self:EmitSound(self.Primary.EmptySound)
        return
    end

    if first_predicted then
        self:SetClip1(self:Clip1() - 1)
    end
    self:SetNextCowboyLoadTime(now + self.Cowboy.ShootDelay)

    local cone = self:GetFocus() * (primary_shot and self.Primary.Cone or self.Secondary.Cone)
    self.Weapon:EmitSound(self.Primary.ShotSound)
    self:ShootBullet(cone)

    self:GetOwner():ViewPunch(Angle(-self.Primary.Recoil, 0, 0))
    self:BeginFocus()
end

-- Need to overwrite this because weapon_tttbase:ShootBullet breaks the Focus mechanic
function SWEP:ShootBullet(focused_cone)
    local bullet = {}
    bullet.Num = 1
    bullet.Src = self.Owner:GetShootPos()
    bullet.Dir = self.Owner:GetAimVector()
    bullet.Spread = Vector(focused_cone, focused_cone, 0)
    bullet.Tracer = 1
    bullet.Force = self.Primary.Force
    bullet.Damage = self.Primary.Damage
    bullet.AmmoType = "none"

    self:GetOwner():FireBullets(bullet)
    self:ShootEffects()
end

-- Don't draw TTT's custom crosshairs
function SWEP:DrawHUD()
end
