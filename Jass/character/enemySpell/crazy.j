globals

	trigger Boss_Spell_Trigger_Crazy 	= CreateTrigger()

	trigger Boss_Spell_Trigger_Crazy_Bombs = CreateTrigger()

endglobals

library characterEnemySpellCrazy requires characterEnemySpellNormal

	//炸弹 - 回调
	private function action_Bombs takes nothing returns nothing
		local unit bomb = GetTriggerUnit()
		local unit killer = GetKillingUnit()
	    local location loc = null
	    local group g = null
	    local real hunt = 0
	    local unit u = null
	    if( killer == null ) then
		    set loc = GetUnitLoc( bomb )
			call funcs_effectPoint( Effect_NewMassiveEX , loc )
		    call funcs_effectPoint( Effect_ImpaleTargetDust , loc )
		    set g = funcs_getGroupByPoint( loc , 145.00 , function filterTrigger_enemy_live_disbuild )
		    call RemoveLocation( loc )
		    loop
	            exitwhen(IsUnitGroupEmptyBJ(g) == true)
	                set u = FirstOfGroup(g)
	                call GroupRemoveUnit( g , u )
	                set loc = GetUnitLoc(u)
	                set hunt = GetUnitState( u , UNIT_STATE_MAX_LIFE) * 0.35
					call funcs_huntBySelf( hunt , bomb ,u)
	                call funcs_effectPoint(Effect_Incinerate,loc)
	                call RemoveLocation(loc)
	        endloop
		    call GroupClear(g)
		    call DestroyGroup(g)
		endif
	    call RemoveUnit(bomb)
	endfunction

	//受伤判定
	private function action takes nothing returns nothing
		local unit boss = GetTriggerUnit()
	    local unit damageSource = GetEventDamageSource()
	    local real damage = GetEventDamage()
	    local integer i = 0
	    local location loc = null
	    local location targetLoc = null
	    local integer damageSourceIndex = GetConvertedPlayerId(GetOwningPlayer(damageSource))
	    local real bossLifeRate = GetUnitState(boss, UNIT_STATE_LIFE) / GetUnitState(boss, UNIT_STATE_MAX_LIFE) + Attr_Toughness[damageSourceIndex] * 0.8
	    local real bossDamegeBase = GetUnitState(damageSource, UNIT_STATE_MAX_LIFE)
	    local real punishMax = GetUnitState(boss, UNIT_STATE_MAX_LIFE) * 0.42
	    local integer avoidInt = R2I(1/bossLifeRate)

		//->技能不触发<-
		//#伤害不足30时
		//#是镜像时
		//#被硬直
		//#已死亡
	    if( damage < 30 or IsUnitIllusionBJ(boss) == true or IsUnitPaused(boss) == true or IsUnitAliveBJ(boss) == false ) then
		    return
		endif
		//#伤害来源是建筑
		if( IsUnitType(damageSource, UNIT_TYPE_STRUCTURE) == true ) then
			return
		endif
		//#伤害来源非玩家单位能触发
		if((GetPlayerController(GetOwningPlayer(damageSource)) != MAP_CONTROL_USER) or (GetPlayerSlotState(GetOwningPlayer(damageSource)) != PLAYER_SLOT_STATE_PLAYING)) then
			return
		endif

		//硬直
		call characterEnemySpellAbstract_punish( boss , damage , punishMax )

		//共享技能
		if( GetUnitTypeId(boss) == Enemy_Config_Last_Final_boss ) then
			//TODO最终boss时
			//@绝对无视召唤物
		    if(IsUnitType(damageSource, UNIT_TYPE_SUMMONED) == true) then
		        call KillUnit( damageSource )
		    endif
			//@90%几率触发无敌，冷却50，持续7.0
		    if( GetRandomInt(1,100) <= 90 ) then
				call characterEnemySpellAbstract_invincible( 50 , boss , 7.00 )
		    endif
			//@<90%>几率回避，冷却0.1秒
			if( GetUnitTypeId(damageSource) == Unit_Token_Hunt_Not_Avoid ) then
	            //如果伤害的单位是无视回避类，则不计算
	        elseif( bossLifeRate > 0.8 ) then
	           //如果BOSS血量在80%以上则不计算回避
	        elseif( damage > GetUnitState(boss, UNIT_STATE_MAX_LIFE)*0.15 ) then
	            //如果伤害大于生命15%，回避将被无视
	            call funcs_floatMsg( "|cffff0000嗷！好痛！|r" ,  boss  )
	        else
	        	call characterEnemySpellAbstract_avoid ( 0.1 , boss , 90 )
        	endif
			//@30%几率晕破吼，冷却6.5秒，范围1000，伤害750
			if( GetRandomInt(1,100) <= 30 and IsUnitType(damageSource, UNIT_TYPE_HERO) == true ) then
				call characterEnemySpellAbstract_breakHowl ( 6.5 , boss , 1000 , 750 )
			endif
			//@召唤小弟，25秒，内部分发
			call characterEnemySpellAbstract_callBrother ( 25 , boss )
		else
			//TODO 其他单位
			//@对召唤物造成10%生命伤害
		    if(IsUnitType(damageSource, UNIT_TYPE_SUMMONED) == true) then
		        call SetUnitLifeBJ( damageSource , GetUnitState(damageSource, UNIT_STATE_LIFE) - (I2R(DIFF)*0.1*GetUnitState(damageSource, UNIT_STATE_MAX_LIFE)))
		    endif
			//@75%几率触发无敌，冷却45，持续2.5
		    if( GetRandomInt(1,100) <= 75 ) then
				call characterEnemySpellAbstract_invincible( 45 , boss , 2.50 )
		    endif
		    //@75%几率回避，冷却0.2秒
		    if( GetUnitTypeId(damageSource) == Unit_Token_Hunt_Not_Avoid ) then
	            //如果伤害的单位是无视回避类，则不计算
	        elseif( bossLifeRate > 0.8 ) then
	            //如果BOSS血量在80%以上则不计算回避
	        elseif( damage > GetUnitState(boss, UNIT_STATE_MAX_LIFE)*0.15 ) then
	            //如果伤害大于生命15%，回避将被无视
	            call funcs_floatMsg( "|cffff0000嗷！好痛！|r" ,  boss  )
	        else
	        	call characterEnemySpellAbstract_avoid ( 0.2 , boss , 75 )
        	endif
		    //@15%几率晕破吼，冷却9.0秒，范围600，伤害350
		    if( GetRandomInt(1,100) <= 15 and IsUnitType(damageSource, UNIT_TYPE_HERO) == true ) then
				call characterEnemySpellAbstract_breakHowl ( 9 , boss , 600 , 350 )
			endif
			//@召唤小弟，40秒，内部分发
			call characterEnemySpellAbstract_callBrother ( 40 , boss )
		endif

		/* 特殊技能 - 只有英雄会触发 */
		if( IsUnitType(damageSource, UNIT_TYPE_HERO) == true ) then
			//LAST
			if( GetUnitTypeId(boss) == 'n02R' ) then		//锯裂机车
				//@20%几率触发锯裂机车JUMP，冷却13
			    if( GetRandomInt(1,100) <= 20 ) then
					call characterEnemySpellAbstract_jump( 13 , boss , damageSource , 20 , Effect_ImpaleTargetDust , bossDamegeBase*0.25 , Effect_red_shatter )
			    endif
			    //@9%几率触发尸鬼冲击，冷却20
			    if( GetRandomInt(1,100) <= 9 ) then
					call characterEnemySpellAbstract_leap(20 , boss , damageSource , 350 , 40 , null , bossDamegeBase*0.35 , Effect_red_shatter , false)
			    endif
			elseif( GetUnitTypeId(boss) == 'n02U' ) then	//守卫强暴者
				//@10%几率触发炸弹，冷却12 ， 数量7
			    if( GetRandomInt(1,100) <= 15 ) then
					call characterEnemySpellAbstract_summon( 12 , boss , 'n02V' , 7 , 125 , 5.00 , Boss_Spell_Trigger_Crazy_Bombs )
			    endif
			elseif( GetUnitTypeId(boss) == 'n02Q' ) then	//死神
				//@9%几率触发穿梭，冷却65 , 35次
			    if( GetRandomInt(1,100) <= 9 ) then
					call characterEnemySpellAbstract_shuttle( 65 , boss , 1000 , 45 , 35 , null , bossDamegeBase*0.07 , Effect_ReplenishManaCaster )
			    endif
			    //@12%几率触发丧命魂魄，12道，冷却50，距离800，速度3，重叠伤害
			    if( GetRandomInt(1,100) <= 12 ) then
					call characterEnemySpellAbstract_multiLeap(50 , 'o00U' , boss , damageSource , 800 , 3 , null , 12 , 30 , bossDamegeBase*0.05 , Effect_Explosion , true)
			    endif
			elseif( GetUnitTypeId(boss) == 'n02T' ) then	//无冕帝王
			elseif( GetUnitTypeId(boss) == 'n02S' ) then	//DarkEle
				//@5%几率触发DarkEle踏，冷却65，35个影子
			    if( GetRandomInt(1,100) <= 5 ) then
					call characterEnemySpellAbstract_canyingta( 65 , boss , 35 , 'o00S' , bossDamegeBase*0.11)
			    endif
			    //@9%几率触发鬼巨人撞击，冷却45
			    if( GetRandomInt(1,100) <= 9 ) then
					call characterEnemySpellAbstract_charge(45 , boss , damageSource , SKILL_CHARGE_FLY , 600 , 25 , Effect_ImpaleTargetDust , bossDamegeBase*0.35 , null , false )
			    endif
			endif
			//BOSS
			if( GetUnitTypeId(boss) == 'n004' ) then		//巨石人
				//@9%几率触发巨石残影踏，冷却45，20个影子
			    if( GetRandomInt(1,100) <= 9 ) then
					call characterEnemySpellAbstract_canyingta( 45 , boss ,20 , 'o00N' , bossDamegeBase*0.07)
			    endif
			elseif( GetUnitTypeId(boss) == 'n00M' ) then	//怖残像狼
				//@9%几率触发狼咬，冷却15
			    if( GetRandomInt(1,100) <= 9 ) then
					call characterEnemySpellAbstract_leap(15 , boss , damageSource , 350 , 30 , null , bossDamegeBase*0.35 , Effect_Boold_Cut , false)
			    endif
			elseif( GetUnitTypeId(boss) == 'n03K' ) then	//提灯白牛
				//@7%几率触发白牛JUMP，冷却25
			    if( GetRandomInt(1,100) <= 7 ) then
					call characterEnemySpellAbstract_jump( 25 , boss , damageSource , 13 , Effect_CrushingWhiteRing , bossDamegeBase*0.35 , Effect_DarkLightningNova )
			    endif
			elseif( GetUnitTypeId(boss) == 'n01O' ) then	//军统领
				//@7%几率触发光明炮，12道，冷却55，距离1600，速度13，不重叠伤害
			    if( GetRandomInt(1,100) <= 7 ) then
					call characterEnemySpellAbstract_multiLeap(55, 'o00O' , boss , damageSource , 1600 , 13 , null , 12 , 30.00 , bossDamegeBase*0.40 , Effect_LightStrikeArray , false )
			    endif
			elseif( GetUnitTypeId(boss) == 'n01K' ) then	//食人大佬
				//@7%几率触发鬼巨人撞击，冷却60
			    if( GetRandomInt(1,100) <= 7 ) then
					call characterEnemySpellAbstract_charge(60 , boss , damageSource , SKILL_CHARGE_CRASH , 600 , 25 , Effect_ImpaleTargetDust , bossDamegeBase*0.75 , null , false )
			    endif
			elseif( GetUnitTypeId(boss) == 'n005' ) then	//群暴食尸鬼
				//@9%几率触发尸鬼冲击，冷却22
			    if( GetRandomInt(1,100) <= 9 ) then
					call characterEnemySpellAbstract_leap(22 , boss , damageSource , 350 , 45 , null , bossDamegeBase*0.45 , Effect_Boold_Cut , false)
			    endif
			elseif( GetUnitTypeId(boss) == 'n020' ) then	//鬼巨人
				//@9%几率触发鬼巨人撞击，冷却55
			    if( GetRandomInt(1,100) <= 9 ) then
					call characterEnemySpellAbstract_charge(55 , boss , damageSource , SKILL_CHARGE_FLY , 500 , 20 , Effect_ImpaleTargetDust , bossDamegeBase*0.60 , null , false )
			    endif
			elseif( GetUnitTypeId(boss) == 'n03Z' ) then	//疯狂大炮
				//@5%几率触发大炮冲击，冷却80
			    if( GetRandomInt(1,100) <= 5 ) then
					call characterEnemySpellAbstract_chargeToken(80 , boss , 'o00R' , damageSource , SKILL_CHARGE_DRAG , 2000 , 28 , null , bossDamegeBase*0.8 , Effect_ExplosionBIG , false )
			    endif
			elseif( GetUnitTypeId(boss) == 'n00K' ) then	//炸弹魔
				//@10%几率触发炸弹，冷却12 ， 数量7
			    if( GetRandomInt(1,100) <= 10 ) then
					call characterEnemySpellAbstract_summon( 12 , boss , 'n02V' , 7 , 100 , 5.00 , Boss_Spell_Trigger_Crazy_Bombs )
			    endif
			elseif( GetUnitTypeId(boss) == 'n01Y' ) then	//奇美拉
				//@10%几率触发炸弹，冷却50 ， 数量12
			    if( GetRandomInt(1,100) <= 10 ) then
					call characterEnemySpellAbstract_summon( 50 , boss , 'u00Z' , 12 , 125 , 12.00 , null )
			    endif
			elseif( GetUnitTypeId(boss) == 'n00N' ) then	//鬼狼蛛
				//@15%几率触发狼蛛JUMP，冷却8
			    if( GetRandomInt(1,100) <= 15 ) then
					call characterEnemySpellAbstract_jump( 8 , boss , damageSource , 20 , Effect_HydraCorrosiveGroundEffect , bossDamegeBase*0.15 , Effect_GreatElderHydraAcidSpew )
			    endif
			elseif( GetUnitTypeId(boss) == 'n03G' ) then	//狮鹫
				//@10%几率触发炸弹，冷却55 ， 数量30
			    if( GetRandomInt(1,100) <= 10 ) then
					call characterEnemySpellAbstract_summon( 55 , boss , 'u00Y' , 30 , 45 , 10.00 , null )
			    endif
			elseif( GetUnitTypeId(boss) == 'n040' ) then	//外道魔导师
				//@9%几率触发龙卷风，冷却10
			    if( GetRandomInt(1,100) <= 9 ) then
					call characterEnemySpellAbstract_chargeToken(10 , boss , 'o00T' , damageSource , SKILL_CHARGE_DRAG , 800 , 35 , null , bossDamegeBase*0.14 , null , false )
			    endif
			elseif( GetUnitTypeId(boss) == 'n02C' ) then	//狂斩刺客
				//@9%几率触发穿梭，冷却50 ， 18次
			    if( GetRandomInt(1,100) <= 9 ) then
					call characterEnemySpellAbstract_shuttle( 50 , boss , 1000 , 25 , 18 , null , bossDamegeBase*0.10 , Effect_ShadowAssault )
			    endif
			elseif( GetUnitTypeId(boss) == 'n02B' ) then	//飞蛇
				//@9%几率触发穿梭，冷却50 ，10次
			    if( GetRandomInt(1,100) <= 9 ) then
					call characterEnemySpellAbstract_shuttle( 50 , boss , 1000 , 20 , 10 , null , bossDamegeBase*0.18 , Effect_CrushingWaveBrust )
			    endif
			elseif( GetUnitTypeId(boss) == 'n03F' ) then	//深海海民
				//@9%几率触发海民冲击，冷却40
			    if( GetRandomInt(1,100) <= 9 ) then
					call characterEnemySpellAbstract_charge(40 , boss , damageSource , SKILL_CHARGE_DRAG , 850 , 8 , Effect_CrushingWaveDamage , bossDamegeBase*0.6 , null , false )
			    endif
			elseif( GetUnitTypeId(boss) == 'n02D' ) then	//破坏猛犸王
				//@9%几率触发猛犸王冲击，冷却35
			    if( GetRandomInt(1,100) <= 9 ) then
					call characterEnemySpellAbstract_charge(35 , boss , damageSource , SKILL_CHARGE_DRAG , 1200 , 13 , Effect_ImpaleTargetDust , bossDamegeBase*0.5 , null , false )
			    endif
			elseif( GetUnitTypeId(boss) == 'n02N' ) then	//尖毛猪
				//@7%几率触发尖毛猪残影踏，冷却10，7个影子
			    if( GetRandomInt(1,100) <= 7 ) then
					call characterEnemySpellAbstract_canyingta(10 , boss ,7 , 'o00P' , bossDamegeBase*0.10)
			    endif
			elseif( GetUnitTypeId(boss) == 'n03Y' ) then	//腐蚀邪鬼
				//@9%几率触发腐蚀冲击，冷却25
			    if( GetRandomInt(1,100) <= 9 ) then
					call characterEnemySpellAbstract_charge(25 , boss , damageSource , SKILL_CHARGE_DRAG , 400 , 15 , Effect_UndeadDissipate , bossDamegeBase*0.30 , null , false )
			    endif
			elseif( GetUnitTypeId(boss) == 'n02P' ) then	//灰沙蝎王
				//@9%几率触发蝎王冲击，冷却55
			    if( GetRandomInt(1,100) <= 9 ) then
					call characterEnemySpellAbstract_charge(55 , boss , damageSource , SKILL_CHARGE_DRAG , 1750 , 16 , Effect_ImpaleTargetDust , bossDamegeBase*0.80 , null , false )
			    endif
			elseif( GetUnitTypeId(boss) == 'n02O' ) then	//骷髅杀手
				//@12%几率触发丧命魂魄，12道，冷却60，距离600，速度2，重叠伤害
			    if( GetRandomInt(1,100) <= 12 ) then
					call characterEnemySpellAbstract_multiLeap(60 , 'o00U' , boss , damageSource , 600 , 2 , null , 12 , 30 , bossDamegeBase*0.03 , Effect_Explosion , true)
			    endif
			endif
			//DRAGON
			if( GetUnitTypeId(boss) == 'n013' ) then		//红龙
				//@12%几率触发火焰旋风，10道，冷却55，距离700，速度2，重叠伤害
			    if( GetRandomInt(1,100) <= 20 ) then
					call characterEnemySpellAbstract_multiLeap(55, 'o00M' , boss , damageSource , 700 , 2 , null , 10 , 36 , bossDamegeBase*0.04 , Effect_Explosion , true)
			    endif
			elseif( GetUnitTypeId(boss) == 'n014' ) then	//黑龙
				//@12%几率触发殛寒领域，冷却60，范围750，持续5秒
			    if( GetRandomInt(1,100) <= 12 ) then
					call characterEnemySpellAbstract_multiPunish(60, boss, Effect_IceStomp , 750 , 5.00 , SKILL_PUNISH_TYPE_blue , bossDamegeBase*0.3 , Effect_FrostNovaTarget )
			    endif
			endif
		endif

	endfunction

	//初始化
	public function init takes nothing returns nothing
    	call TriggerAddAction( Boss_Spell_Trigger_Crazy , function action )
    	call TriggerAddAction( Boss_Spell_Trigger_Crazy_Bombs , function action_Bombs )
	endfunction

endlibrary
