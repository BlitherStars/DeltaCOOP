screenOffset = 0
local function border()
	djui_hud_set_resolution(RESOLUTION_N64)
	djui_hud_set_color(0, 0, 0, 255)
    local sW = djui_hud_get_screen_width()
    local sH = djui_hud_get_screen_height()
    screenOffset = sW - 320
    local barW = screenOffset / 2
    djui_hud_render_rect(0,0,barW,sH)
    djui_hud_render_rect(sW-barW,0,barW,sH)
end
hook_event(HOOK_ON_HUD_RENDER, border)