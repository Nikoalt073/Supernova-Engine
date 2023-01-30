package funkin.menus;

import funkin.config.Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.system.MusicBeatSubstate;
import funkin.system.Highscore;
import funkin.menus.StoryMenu;
import funkin.menus.FreeplayMenu;
import funkin.editors.ChartingState;
import funkin.game.PlayState;
import funkin.game.Song;

class PauseMenu extends MusicBeatSubstate {
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var pauseOG:Array<String> = [
		'Resume',
		'Restart Song',
		//'Change Difficulty',
		'Practice Mode',
		'Chart Editor',
		'Exit to menu'
	];
	/*var curDifficulty:Int = 1;
	var curDifficultyArray:Array<String> = ['EASY', 'NORMAL', 'HARD', 'BACK'];*/

	var menuItems:Array<String> = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var practiceText:FlxText;

	public function new(x:Float, y:Float) {
		super();

		menuItems = pauseOG;

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, '', 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font('vcr.ttf'), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, '', 32);
		levelDifficulty.text += Highscore.difficultyString;
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var deathCounter:FlxText = new FlxText(20, 15 + 64, 0, '', 32);
		deathCounter.text = 'Blueballed: ' + PlayState.deathCounter;
		deathCounter.scrollFactor.set();
		deathCounter.setFormat(Paths.font('vcr.ttf'), 32);
		deathCounter.updateHitbox();
		add(deathCounter);

		practiceText = new FlxText(20, 15 + 96, 0, 'PRACTICE MODE', 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.updateHitbox();
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.visible = PlayState.practiceMode;
		add(practiceText);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		deathCounter.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		deathCounter.x = FlxG.width - (deathCounter.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(deathCounter, {alpha: 1, y: deathCounter.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
	}

	private function regenMenu() {
		while (grpMenuShit.members.length > 0) {
			grpMenuShit.remove(grpMenuShit.members[0], true);
		}

		for (i in 0...menuItems.length) {
			var menuItem:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			menuItem.isMenuItem = true;
			menuItem.targetY = i;
			grpMenuShit.add(menuItem);
		}

		curSelected = 0;

		changeSelection();
	}

	override function update(elapsed:Float) {
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP) {
			changeSelection(-1);
		}
		if (downP) {
			changeSelection(1);
		}

		if (accepted) {
			var daSelected:String = menuItems[curSelected];

			switch (daSelected) {
				case 'Resume':
					close();
				case 'Restart Song':
					FlxG.resetState();
				/*case 'Change Difficulty':
					menuItems = curDifficultyArray;
					regenMenu();*/
				case 'Practice Mode':
					PlayState.practiceMode = !PlayState.practiceMode;
					practiceText.visible = PlayState.practiceMode;
				case 'Chart Editor':
					FlxG.switchState(new ChartingState());
				case 'Exit to menu':
					PlayState.seenCutscene = false;
					PlayState.deathCounter = 0;
					if (PlayState.isStoryMode)
						FlxG.switchState(new StoryMenu());
					else
						FlxG.switchState(new FreeplayMenu());

				/*case 'EASY' | 'NORMAL' | 'HARD':
					PlayState.SONG = Song.loadFromJson(curDifficultyArray[curDifficulty].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
					PlayState.storyDifficulty2 = curDifficultyArray[curDifficulty].toLowerCase();
					FlxG.resetState();*/
				case 'BACK':
					menuItems = pauseOG;
					regenMenu();
			}
		}

		if (FlxG.keys.justPressed.J) {
		}
	}

	override function destroy() {
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void {
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}
	}
}
