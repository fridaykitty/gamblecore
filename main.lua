--- STEAMODDED HEADER
--- MOD_NAME: Gamblecore
--- MOD_ID: gamblecore
--- PREFIX: gamblecore
--- MOD_AUTHOR: [fridaykitty]
--- MOD_DESCRIPTION: Does some funny stuff to the Wheel of Fortune. Let's go gambling! Works best on Speed 4.
--- VERSION: 1.0.0

--[[
	Feel free to rewrite this mod.
	Please give some credit if you do.
]]--


SMODS.Sound({
	key = 'gamble1',
	path = 'gamble1.ogg'
})

SMODS.Sound({
	key = 'gamble2',
	path = 'gamble2.ogg'
})

SMODS.Sound({
	key = 'gamble3',
	path = 'gamble3.ogg'
})

SMODS.Consumable:take_ownership('wheel_of_fortune',{
    key = 'wheel_of_fortune',
    set = 'Tarot',
    pos = { x = 0, y = 1 },
    config = { extra = { odds = 4 } },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds,
            'gamblecore_wheel_of_fortune')
        return { vars = { numerator, denominator } }
    end,
    use = function(self, card, area, copier)
		play_sound('gamblecore_gamble1')
		delay(1.2*G.SETTINGS.GAMESPEED)
        if SMODS.pseudorandom_probability(card, 'gamblecore_wheel_of_fortune', 1, card.ability.extra.odds) then
            local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)

            local eligible_card = pseudorandom_element(editionless_jokers, 'gamblecore_wheel_of_fortune')
            local edition = poll_edition('gamblecore_wheel_of_fortune', nil, true, true,
                { 'e_polychrome', 'e_holo', 'e_foil' })
            eligible_card:set_edition(edition, true)
            check_for_unlock({ type = 'have_edition' })
			G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4*G.SETTINGS.GAMESPEED,
				func = function()
					play_sound('gamblecore_gamble3')
				end
			}))
        else
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4*G.SETTINGS.GAMESPEED,
                func = function()
					play_sound('gamblecore_gamble2')
                    attention_text({
                        text = localize('k_nope_ex'),
                        scale = 1.3,
                        hold = 1.4,
                        major = card,
                        backdrop_colour = G.C.SECONDARY_SET.Tarot,
                        align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and
                            'tm' or 'cm',
                        offset = { x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and -0.2 or 0 },
                        silent = true
                    })
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.06 * G.SETTINGS.GAMESPEED,
                        blockable = false,
                        blocking = false,
                        func = function()
                            play_sound('tarot2', 0.76, 0.4)
                            return true
                        end
                    }))
                    play_sound('tarot2', 1, 0.4)
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        end
    end,
    can_use = function(self, card)
        return next(SMODS.Edition:get_edition_cards(G.jokers, true))
    end
},
true
)