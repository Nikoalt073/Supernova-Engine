package funkin.menus;

import away3d.core.managers.Mouse3DManager;
#if discord_rpc
import funkin.system.dependency.Discord.DiscordClient;
#end
import flixel.util.FlxTimer;
import flixel.FlxState;
import funkin.menus.MainItem;
import funkin.ui.MenuTypedList;
import funkin.ui.AtlasMenuItem;
import funkin.config.OptionsState;
import funkin.config.Options;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import funkin.system.*;
import funkin.menus.*;
import funkin.system.Paths;
import flixel.group.FlxSpriteGroup;
import lime.utils.Assets;
import funkin.system.FNFSprite;

class MainMenu extends MusicBeatState {
	var bg:FlxSprite;
	var menuGroup:FlxSpriteGroup;
	var items:Array<String> = 
	[
		'story mode', 
		'freeplay', 
		'donate', 
		'options'
	];
	var curItem = 0;

	override function create() {
		super.create();
		bg = new FNFSprite(0, 0).loadGraphic(Paths.image("menuObjects/main_menu/menuBG"));
		add(bg);
		menuGroup = new FlxSpriteGroup();
		for (item in 0...items.length) {
			var newItem = new FlxSprite(0, 0);
			newItem.frames = Paths.getSparrowAtlas('menuObjects/main_menu/${items[item]}');
			newItem.animation.addByPrefix('idle', '${items[item]} basic');
			newItem.animation.addByPrefix('selected', '${items[item]} white');
			newItem.animation.play('idle', true);
			newItem.ID = item;
			newItem.updateHitbox();
			newItem.y = 160 * item;
			newItem.screenCenter(X);
			menuGroup.add(newItem);
		}
		menuGroup.y += 80;
		add(menuGroup);
		changeOption();
		if (!FlxG.sound.music.playing) {
			FlxG.sound.music.kill();
			FlxG.sound.playMusic(Paths.music('menus/freakyMenu'));
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		if (FlxG.keys.justPressed.DOWN || FlxG.gamepads.lastActive.justPressed.DOWN)
			changeOption(1);
		if (FlxG.keys.justPressed.UP || FlxG.gamepads.lastActive.justPressed.UP)
			changeOption(-1);
		if (FlxG.keys.justPressed.ENTER || FlxG.gamepads.lastActive.justPressed.A)
			selectItem();
	}

	public function changeOption(saidItem:Int = 0) {
		curItem = FlxMath.wrap(curItem + saidItem, 0, items.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		menuGroup.forEach(function(item) {
			item.animation.play('idle');
			item.updateHitbox();
			item.screenCenter(X);
		});

		menuGroup.members[curItem].animation.play('selected');
		menuGroup.members[curItem].updateHitbox();
		menuGroup.members[curItem].screenCenter(X);
	}
	
	function selectDonate() {
		#if linux
		Sys.command('/usr/bin/xdg-open', [
			'https://ninja-muffin24.itch.io/funkin',
			'&'
		]);
		#else
		FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
		#end
	}

	public function selectItem() {
		FlxG.sound.play(Paths.sound("confirmMenu"));
		menuGroup.forEach(function(item) {
			if (item.ID != curItem)
				FlxTween.tween(item, {alpha: 0}, 1);
			else
				FlxFlicker.flicker(item, 1.4, 0.06, true, true, function(w) {
					switch (items[curItem]) 
					{
						case "story mode":
							FlxG.switchState(new StoryMenu());
						case 'freeplay':
							FlxG.switchState(new FreeplayMenu());
						case 'donate':
							selectDonate();
						case 'options':
							FlxG.switchState(new OptionsState());
					}
				});
		});
	}
}