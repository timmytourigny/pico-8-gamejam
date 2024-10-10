highscore = 0

--variables
function _init()
    player={
        sp=1,
        x = 64,
        y = 104,
        w = 8,
        h = 8,
        dir = 0,
        dx = 0,
        dy = 0,
        anim = 0,
        landed = true,
        double = true,
        spd = 4,
        collision = false,
        touching_enemy = false,
        touched_enemy = false,
        streak = 1,
        flip_x = false,
        flip_y = false,
        anim_mod = 16
    }

    m = {
        left = 24,
        right = 112,
        top = 24,
        bottom = 112.
    }

    change_walls(64)

    enemy={
        sp = 5,
        x = 64,
        y = 64,
        w = 16,
        h = 16,
        dx = 0,
        dy = 0,
        steps = 0,
        collision = false,
        spd = 1,
        rebound = 15,
        anim = 0,
        left = true,
        down = true
    }

    score = 0
    start_time = time()
    game_active = false
    freeze = 0
    colors = {8,9,10,11,12,1,7}
    color_ind = 1
    wall_sprite = 65
    streak_anim = 0
    debug_test = false
end

function _update()
    if time() - start_time > 30 then
        game_active = false
    end

    if game_active  and freeze == 0 then 
        handle_enemy_collisions()
        handle_enemy_movement()
        handle_player_collisions()
        handle_button_press()
        handle_player_enemy_collision()
        handle_player_sprite_change()
        handle_player_streak()
    elseif game_active and freeze > 0 then 
        handle_freeze()
    else
        change_highscore()
        check_restart()
    end
    player.collsion = false
end

function handle_player_sprite_change()
    player.sp = 1 + ((color_ind - 1) % #colors)

    if player.landed then 
        player.sp += 16
        if time()-player.anim > .2 then
            player.anim = time()
            if player.anim_mod == 16 then 
                player.anim_mod = 0
            else
                player.anim_mod = 16
            end
        end
        player.sp += player.anim_mod
    end

    sp_add_mod = 7

    if player.dx > 0 then 
        player.sp += sp_add_mod
        player.flip_x = true
        player.flip_y = false
    elseif player.dx < 0 then 
        player.sp += sp_add_mod
        player.flip_x = false
        player.flip_y = false
    elseif player.dy > 0 then 
        player.flip_y = true
        player.flip_x = false
    elseif player.dy < 0 then
        player.flip_y = false
        player.flip_x = false
    elseif player.y == m.bottom - player.h then 
        player.flip_y = false
        player.flip_x = false
    elseif player.y == m.top then 
        player.flip_y = true
        player.flip_x = false
    elseif player.x == m.right - player.w then 
        player.sp += sp_add_mod
        player.flip_x = false
        player.flip_y = false
    elseif player.x == m.left then 
        player.sp += sp_add_mod
        player.flip_x = true
        player.flip_y = false
    end
end

function handle_freeze()
    freeze_sp = 160

    if time()-enemy.anim > .1 then
        enemy.anim = time()
        enemy.sp = freeze_sp
        freeze-=1
        if freeze == 0 then 
            enemy.sp = 128
        end
    end
end

function change_highscore()
    if score > highscore then
        highscore = score
    end
end

function check_restart()

    if btnp(❎) then 
        _init()
        game_active = true
    end
end

-- if not collsion and btn press and (landed and valid_movement or double)

function handle_button_press()
    if not player.collsion and is_movement() and
        (player.landed and valid_movement() or player.double and not player.landed) then
    
        if not player.landed then --stop double move
            player.double = false 
            sfx(02)
        else 
            sfx(01)
        end

        player.landed = false

        player.dx = 0 --reset speeds
        player.dy = 0

        if btnp(⬅️) then --change speed
            player.dx = -player.spd 
        elseif btnp(➡️) then
            player.dx = player.spd
        elseif btnp(⬆️) then 
            player.dy = -player.spd
        elseif btnp(⬇️) then
            player.dy = player.spd
        end  
    end

    player.x += player.dx
    player.y += player.dy
end

function is_movement()
    return btnp(⬅️) or btnp(➡️) or btnp(⬆️) or btnp(⬇️)
end

function valid_movement()
    if player.x == m.left and btnp(⬅️) then
        return false
    end
    
    -- Check if the player is trying to move right but is at the right boundary
    if player.x + player.w == m.right and btnp(➡️) then
        return false
    end
    
    -- Check if the player is trying to move up but is at the top boundary
    if player.y == m.top and btnp(⬆️) then
        return false
    end
    
    -- Check if the player is trying to move down but is at the bottom boundary
    if player.y + player.h == m.bottom and btnp(⬇️) then
        return false
    end
    
    return true
end

function handle_player_collisions()

    --collision flag is 1 for vertical, 0 for horizontal

    if player.dy > 0 then  -- Moving down
        if collide_map(player, "down", 1) then
            player.landed = true
            player.double = true
            player.dy = 0
            player.dx = 0
            player.y = m.bottom - player.h
            player.collsion = true
        end
    end
    if player.dy < 0 then  -- Moving up
        if collide_map(player, "up", 1) then
            player.landed = true
            player.double = true
            player.dy = 0
            player.dx = 0
            player.y = m.top
            player.collsion = true
        end
    end
    if player.dx > 0 then  -- Moving right
        if collide_map(player, "right", 0) then
            player.landed = true
            player.double = true
            player.dx = 0
            player.dy = 0
            player.x = m.right - player.w
            player.collsion = true
        end
    end
    if player.dx < 0 then  -- Moving left
        if collide_map(player, "left", 0) then
            player.landed = true
            player.double = true
            player.dx = 0
            player.dy = 0
            player.x = m.left
            player.collsion = true
        end
    end

    if player.collsion then
        player.landed = true
        player.double = true
        player.dy = 0
        player.dx = 0

        if not player.touched_enemy then 
            player.streak = 1
            color_ind = 1
            wall_sprite = 63
            change_walls()
        end

        player.touched_enemy = false
    end

     
end


function _draw()
    cls()
    color = colors[color_ind]

    if game_active then
        map(0,0)
        spr(player.sp,player.x,player.y,1,1,player.flip_x,player.flip_y)
        spr(enemy.sp,enemy.x,enemy.y,enemy.w/8,enemy.h/8,enemy.flip,false)

        text_to_display = "score: " .. score .. "  time: " .. flr(time() - start_time)
        print(text_to_display,68 - #text_to_display * 2,120,color)
    else
        t0 = "epic planet destroyer man!"
        t1 = "highscore:  " .. highscore
        t2 = "score:  " .. score
        t3 = "press x to play"

        print(t0,68 - #t0 * 2, 24,8)
        if highscore != 0 then 
            print(t1,68 - #t1 * 2, 56)
        end 
        print(t2,68 - #t2 * 2, 68)
        print(t3,68 - #t3 * 2, 80)
    end

end

--collisions
function collide_map(obj,aim,flag)
-- obj = table needs x,y,w,h
    local x = obj.x
    local y = obj.y
    local w = obj.w
    local h = obj.h

    --change for future for other uses
    x += obj.dx
    y += obj.dy

    if aim == "left" then
        x1 = x - 1
        x2 = x
        y1 = y
        y2 = y + h
    elseif aim == "right" then
        x1 = x + w
        x2 = x + w + 1
        y1 = y
        y2 = y + h
    elseif aim == "up" then
        x1 = x
        x2 = x + w
        y1 = y - 1
        y2 = y 
    elseif aim == "down" then
        x1 = x
        x2 = x + w
        y1 = y + h 
        y2 = y + h + 1
    end

    x1/=8
    x2/=8
    y1/=8
    y2/=8

    if fget(mget(x1,y1),flag)
    or fget(mget(x1,y2),flag)
    or fget(mget(x2,y1),flag)
    or fget(mget(x2,y2),flag) 
        then return true else return false
    end

end

function handle_enemy_movement()

    if color_ind < 3 then
        enemy.spd = 1
    elseif color_ind < 5 then
        enemy.spd = 2
    elseif color_ind < 7 then
        enemy.spd = 3
    else
        enemy.spd = 4
    end

    enemy.steps -= 1
    
    if enemy.steps <= 0 then
        -- Choose a new random direction
        local r = flr(rnd(4))
        if r == 0 then
            enemy.dx = -enemy.spd  -- Left
            enemy.dy = 0
            enemy.flip = false
            enemy.sp = 128
        elseif r == 1 then
            enemy.dx = enemy.spd   -- Right
            enemy.dy = 0
            enemy.flip = true
            enemy.sp = 128
        elseif r == 2 then
            enemy.dx = 0
            enemy.dy = -enemy.spd  -- Up
            enemy.sp = 130
            enemy.flip = false
        elseif r == 3 then
            enemy.dx = 0
            enemy.dy = enemy.spd   -- Down
            enemy.sp = 132
            enemy.flip = false
        end
        
        -- Set the number of steps to move in this direction
        enemy.steps = flr(rnd(10)) + 5  -- Between 5 and 15 steps
    end
    
    -- Move the enemy
    enemy.x += enemy.dx
    enemy.y += enemy.dy
end

function handle_enemy_collisions()

    --collision flag is 1 for vertical, 0 for horizontal

    enemy.rebound = 15 / enemy.spd

    if enemy.dy > 0 then  -- Moving down
        if collide_map(enemy, "down", 3) then
            enemy.dy = -enemy.spd
            enemy.steps = enemy.rebound
            enemy.flip = false
            enemy.sp = 130
        end
    end
    if enemy.dy < 0 then  -- Moving up
        if collide_map(enemy, "up", 3) then
            enemy.dy = enemy.spd
            enemy.steps = enemy.rebound
            enemy.flip = false
            enemy.sp = 132
        end
    end
    if enemy.dx > 0 then  -- Moving right
        if collide_map(enemy, "right", 2) then
            enemy.dx = -enemy.spd
            enemy.steps = enemy.rebound
            enemy.flip = false
            enemy.sp = 128
        end
    end
    if enemy.dx < 0 then  -- Moving left
        if collide_map(enemy, "left", 2) then
            enemy.dx = enemy.spd
            enemy.steps = enemy.rebound
            enemy.flip = true
            enemy.sp = 128

        end
    end
end

function player_enemy_collision()
    return player.x < enemy.x + enemy.w and   
           player.x + player.w > enemy.x and  
           player.y < enemy.y + enemy.h and    
           player.y + player.h > enemy.y        
end


function handle_player_enemy_collision()
    now_touching_enemy = player_enemy_collision()

    if now_touching_enemy then
        player.touched_enemy = true
    end

    if not player.touching_enemy and now_touching_enemy then
        player.streak += 1
        score += 10 * player.streak
        player.touching_enemy = true
        freeze = 2
        color_ind = min(1+color_ind,#colors)
        change_walls()
        sfx(00)
    elseif player.touching_enemy and not now_touching_enemy then
        player.touching_enemy = false
    end
end

function change_walls(spr_num)
    if spr_num == nil then
        wall_sprite += 1
    else
        wall_sprite = spr_num
    end

    for y = 2, 14 do
        mset(2, y, wall_sprite) 
        mset(14, y, wall_sprite)
    end

    wall_sprite += 1

    for x = 3, 13 do
        mset(x, 2, wall_sprite) 
        mset(x, 14, wall_sprite)
    end
end

function handle_player_streak()
    if color_ind == #colors then 
        if time()-streak_anim > .1 then
            streak_anim = time()
            if wall_sprite == 77 then 
                spr_num = 78
            else
                spr_num = 76
            end
            change_walls(spr_num)
        end
    end
end

