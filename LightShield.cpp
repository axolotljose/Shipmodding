#include "LightShield.h"
#include <libultraship/bridge.h>
#include "soh/Enhancements/game-interactor/GameInteractor.h"
#include "soh/Enhancements/game-interactor/GameInteractor_Hooks.h"
#include "soh/SaveManager.h"
#include "soh/OTRGlobals.h"
#include "global.h"

extern "C" {
#include "macros.h"
#include "variables.h"
}

#define CVAR_LIGHT_SHIELD "gEnhancements.LightShield"
#define CVAR_LIGHT_SHIELD_START "gEnhancements.LightShield.StartWithShield"

// Light offset relative to player position (shield hand area)
static Vec3f sLightOffset = { 0.0f, 45.0f, 15.0f };

// Static LightInfo for our shield light
static LightInfo sShieldLightInfo;
static s32 sLightNum = -1;
static s16 sLastRoom = -1;

static bool IsNighttime() {
    // OoT day/night cycle:
    // 0x4000 - 0xC000 = daytime
    // 0xC001 - 0x3FFF = nighttime
    return (gSaveContext.dayTime >= 0xC001 || gSaveContext.dayTime < 0x4000);
}

static bool HasShieldEquipped(Player* player) {
    if (player == NULL) {
        return false;
    }
    u8 shieldEquip = (gSaveContext.save.info.equips.equipment >> (EQUIP_TYPE_SHIELD * 4)) & 0xF;
    return shieldEquip != EQUIP_VALUE_SHIELD_NONE;
}

static void RemoveLight(Player* player) {
    if (sLightNum >= 0 && player != NULL && player->actor.world.colCtx != NULL) {
        LightContext_RemoveLight(player->actor.world.colCtx, player->actor.world.room, sLightNum);
        sLightNum = -1;
        sLastRoom = -1;
    }
}

void LightShield_Init() {
    // Hook: Give shield at game start (new save initialization)
    GameInteractor::Instance->RegisterGameHook<GameInteractor::OnSaveInit>([](int32_t fileNum) {
        if (!CVarGetInteger(CVAR_LIGHT_SHIELD, 0)) {
            return;
        }
        if (!CVarGetInteger(CVAR_LIGHT_SHIELD_START, 1)) {
            return;
        }

        // Give the player a Deku Shield (our Light Shield base item)
        u16* equipment = &gSaveContext.save.info.inventory.equipment;
        if (!(*equipment & OWNED_EQUIP_FLAG(EQUIP_TYPE_SHIELD, EQUIP_INV_SHIELD_DEKU))) {
            *equipment |= OWNED_EQUIP_FLAG(EQUIP_TYPE_SHIELD, EQUIP_INV_SHIELD_DEKU);
            
            // Auto-equip the shield if no shield is currently equipped
            u8 currentShield = (gSaveContext.save.info.equips.equipment >> (EQUIP_TYPE_SHIELD * 4)) & 0xF;
            if (currentShield == EQUIP_VALUE_SHIELD_NONE) {
                gSaveContext.save.info.equips.equipment &= ~(0xF << (EQUIP_TYPE_SHIELD * 4));
                gSaveContext.save.info.equips.equipment |= EQUIP_VALUE_SHIELD_DEKU << (EQUIP_TYPE_SHIELD * 4);
            }
        }
    });

    // Hook: Update light effect on player update
    GameInteractor::Instance->RegisterGameHook<GameInteractor::OnPlayerUpdate>([](Player* player) {
        if (!CVarGetInteger(CVAR_LIGHT_SHIELD, 0)) {
            RemoveLight(player);
            return;
        }

        // Safety checks
        if (player == NULL || player->actor.world.colCtx == NULL) {
            RemoveLight(player);
            return;
        }

        // Check if player changed rooms - if so, remove old light and re-create
        if (sLastRoom != player->actor.world.room) {
            if (sLightNum >= 0) {
                // Light was in old room, remove it
                LightContext_RemoveLight(player->actor.world.colCtx, sLastRoom, sLightNum);
                sLightNum = -1;
            }
            sLastRoom = player->actor.world.room;
        }

        // Check if it's nighttime and player has shield equipped
        bool shouldGlow = IsNighttime() && HasShieldEquipped(player);

        if (!shouldGlow) {
            RemoveLight(player);
            return;
        }

        // Initialize light info with warm golden glow
        Lights_PointNoGlowSetInfo(
            &sShieldLightInfo,
            (s16)(player->actor.world.pos.x + sLightOffset.x),
            (s16)(player->actor.world.pos.y + sLightOffset.y),
            (s16)(player->actor.world.pos.z + sLightOffset.z),
            255, 220, 150,  // Warm golden white (R, G, B)
            100             // Light radius
        );

        // Insert or maintain the light
        if (sLightNum < 0) {
            sLightNum = LightContext_InsertLight(player->actor.world.colCtx, player->actor.world.room, &sShieldLightInfo);
        }
    });

    // Hook: Clean up light on scene change
    GameInteractor::Instance->RegisterGameHook<GameInteractor::OnSceneInit>([](int32_t sceneNum) {
        sLightNum = -1;
        sLastRoom = -1;
    });

    // Hook: Clean up on exit
    GameInteractor::Instance->RegisterGameHook<GameInteractor::OnExitGame>([](int32_t exitCode) {
        sLightNum = -1;
        sLastRoom = -1;
    });
}
