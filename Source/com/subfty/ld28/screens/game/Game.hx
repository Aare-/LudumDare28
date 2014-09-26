package com.subfty.ld28.screens.game;

import flash.text.TextFormatAlign;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.Timer;
import flash.system.System;
import de.polygonal.core.math.Vec2;
import de.polygonal.core.math.random.Random;
import flash.media.SoundChannel;
import flash.events.MouseEvent;
import motion.easing.Sine;
import motion.Actuate;
import flash.media.SoundTransform;
import flash.media.Sound;
import nape.callbacks.CbType;
import com.subfty.ld28.screens.game.sceneutils.BloodLayer;
import nape.geom.Geom;
import nape.phys.Body;
import com.subfty.ld28.screens.game.actors.Bullet;
import com.subfty.ld28.screens.game.actors.MapElement;
import com.subfty.ld28.screens.game.actors.Crosshair;
import flash.ui.Mouse;
import openfl.Assets;
import com.subfty.sub.svg.actors.SVGRect.SRect;
import flash.display.Bitmap;
import com.subfty.sub.svg.SVGParser;
import flash.display.Sprite;
import com.subfty.ld28.screens.game.sceneutils.SortedClippedStage;
import com.subfty.ld28.screens.game.sceneutils.TiledBackground;
import flash.geom.Rectangle;
import com.subfty.ld28.screens.game.sceneutils.ZombieSpawner;
import com.subfty.sub.SMain;
import com.subfty.sub.display.Screen;
import com.subfty.ld28.screens.game.actors.Player;

class Game extends Screen {

    public static var shootInVall : Array<Sound>;

    public static var ZOMBIE : CbType;
    public static var WALL   : CbType;
    public static var PLAYER : CbType;
    public static var BULLET : CbType;

  //ENTITIES
    var floorColours  : Sprite;
    public var mapScrollView : SortedClippedStage;
    var tiledBg       : TiledBackground;
    public var zombieSpawner : ZombieSpawner;
    public var player : Player;
    public var crosshair     : Crosshair;
    var bullet        : Bullet;
    public var bloodLayer    : BloodLayer;

  //SUBSCREENS
    public static var isGameOver : Bool = true;
    var gameOver : Sprite;

    var music : Sound;
    var channel : SoundChannel;

    var delay : Int;
    public var startTime : Float;

    public function new(parent : SMain){
        super(parent , "game");

      //LOADING MUSIC
        music = Assets.getSound("game2");

        shootInVall = [];
        shootInVall.push(Assets.getSound("music/rykoszet1.wav"));
        shootInVall.push(Assets.getSound("music/rykoszet2.wav"));
        shootInVall.push(Assets.getSound("music/rykoszet3.wav"));
        shootInVall.push(Assets.getSound("music/rykoszet4.wav"));

      //LOADING BODY TYPES
        ZOMBIE = new CbType();
        WALL = new CbType();
        PLAYER = new CbType();
        BULLET = new CbType();

      //INIT

        player = new Player();
        mapScrollView = new SortedClippedStage();
        zombieSpawner = new ZombieSpawner(player);
        tiledBg = new TiledBackground(new Rectangle(0, 0, SMain.STAGE_W, SMain.STAGE_H));
        floorColours = new Sprite();
        crosshair = new Crosshair();
        bullet = new Bullet();
        bloodLayer = new BloodLayer();

        tiledBg.setTile("img/ground/grass-tile.png");
        tiledBg.setTarget(mapScrollView.getMainLayer());
        mapScrollView.setClipBox(new Rectangle(0, 0, SMain.STAGE_W, SMain.STAGE_H));
        mapScrollView.setSpriteToFollow(player,
                                        new Rectangle(SMain.STAGE_W * 0.45, SMain.STAGE_H * 0.45,
                                                      SMain.STAGE_W * 0.05, SMain.STAGE_H * 0.05),
                                        0.4);
        zombieSpawner.setRegisterFunc(mapScrollView.addSprite);

      //ADD TO STAGE
        mapScrollView.addSprite(player);
        this.addChild(tiledBg);
        this.addChild(floorColours);
        this.addChild(bloodLayer);

        this.addChild(mapScrollView);

        this.addChild(crosshair);

      //CREATING SUBSCREENS
        initGameOverScreen();
    }

    override public function load() {
        super.load();

        if(!mapScrollView.getMainLayer().contains(bullet)){
            SVGParser.parseHash = getGameParseHash();
            SVGParser.parse("layouts/map.svg", floorColours, true, ["Markers", "MapItems"]);

            SVGParser.parseHash = getGameParseHash();
            SVGParser.parse("layouts/map.svg", mapScrollView.getMainLayer(), true, ["Background"]);

            mapScrollView.addSprite(bullet);//this.addChild(bullet);
        }

        gameOver.visible = false;
        isGameOver = false;

        player.init();
        crosshair.x = 0;//SMain.STAGE_W / 2;
        crosshair.y = 0;//SMain.STAGE_H / 2;

        mapScrollView.jumpToFollowedSpritePosition();

        zombieSpawner.destroyZombies();
        zombieSpawner.init();

        bullet.connectToCrosshair(crosshair);
    }

    var gOver : TextField;
    var lasted : TextField;
    var sent : TextField;
    var click : TextField;

    function initGameOverScreen(){
        gameOver = new Sprite();

        gameOver.x = 0;
        gameOver.y = 0;
        gameOver.graphics.beginFill(0xff0000, 0.4);
        gameOver.graphics.drawRect(0, 0, SMain.STAGE_W, SMain.STAGE_H);

        gameOver.addEventListener(MouseEvent.CLICK, function(e){
            SMain.setScreen(Main.menu,
            function (prevS : Screen, nextS : Screen, callback : Dynamic) : Void {
                Actuate.tween(prevS, 1.0, {alpha : 0.0})
                       .onComplete(function(){
                            prevS.alpha = 1.0;
                            callback();
                       });
            });
        });

        gameOver.alpha = 0.0;
        gameOver.visible = false;

        var initFunc = function(target : TextField, text : String, size : Float,
                                yPos : Float, parent : Sprite){

            var tFormat : TextFormat = new TextFormat(Assets.getFont("fonts/pzim3x5.ttf").fontName, size, 0xffffff, true);

            tFormat.align = TextFormatAlign.CENTER;
            target.width = SMain.STAGE_W;
            target.mouseEnabled = false;
            target.doubleClickEnabled = false;
            target.textColor = 0xffffff;
            target.defaultTextFormat = tFormat;
            target.embedFonts = true;
            target.x = 0;
            target.y = yPos;
            target.text = text;

            parent.addChild(target);
        };

        gOver = new TextField();
        lasted = new TextField();
        sent = new TextField();
        click = new TextField();

        initFunc(gOver, "GAME OVER", 30, 60, gameOver);
        initFunc(lasted, "YOU LASTED ", 20, 80, gameOver);
        initFunc(sent, "AND ", 11, 100, gameOver);
        initFunc(click, "CLICK TO QUIT", 20, 120, gameOver);

        this.addChild(gameOver);
    }

    override public function postLoad() {
        super.postLoad();

        var transf : SoundTransform = new SoundTransform();
        transf.volume = 0.3;
        channel = music.play(0, -1, transf);

        delay = Random.randRange(1000, 3000);
        isGameOver = false;

        startTime = Date.now().getTime();

        Mouse.hide();
    }

    override public function unload() {
        Mouse.show();

        if(channel != null){
            channel.stop();
            channel = null;
        }
    }

    public function starGameOver(){
        isGameOver = true;
        gameOver.visible = true;
        gameOver.alpha = 0.0;

        gameOver.alpha = 0.0;
        Actuate.tween(gameOver, 1.0, {alpha : 1.0});

        Mouse.show();

        gOver.alpha = 0.0;
        lasted.alpha = 0.0;
        sent.alpha = 0.0;
        click.alpha = 0.0;

        Actuate.tween(gOver, 1.0, {alpha : 1.0})
               .delay(0.5);
        Actuate.tween(lasted, 1.0, {alpha : 1.0})
               .delay(0.7);
        Actuate.tween(sent, 1.0, {alpha : 1.0})
               .delay(0.9);
        Actuate.tween(click, 1.0, {alpha : 1.0})
               .delay(1.1);

        sent.text = "AND SENT " + zombieSpawner.zombieKilled + " ZOMBIES TO HELL.";
        var diff : Int = Math.floor(Date.now().getTime() - startTime);
        lasted.text = "YOU LASTED " + Math.floor(diff / 60000  ) +
                      ":" + (Math.round((diff / 1000 ))% 60);

        var delay = Date.now().getTime() - startTime;
    }

    function getGameParseHash() : Map<String, Sprite -> Xml -> Void> {
        return ["image" => parseImage,
                "rect" => parseRectMarkers];
    }

    function parseImage(root : Sprite, e : Xml) {
        root.addChild(new MapElement(e));
    }

    function parseRectMarkers(root : Sprite, e : Xml) {
        if(e.get("id") == "startPoint")
            SVGParser.applyTransformToPoint(e, player.startPoint);
        if(e.get("id").indexOf("swarmPoint") != -1){
            var swarmP : Vec2 = new Vec2(0,0);
            SVGParser.applyTransformToPoint(e, swarmP);
            zombieSpawner.registerSwarmPoint(swarmP);
        }

        if(e.get("id").indexOf("casualSwarm") != -1){
            var swarmP : Vec2 = new Vec2(0,0);
            SVGParser.applyTransformToPoint(e, swarmP);
            zombieSpawner.registerCasualSwamPoint(swarmP);
        }
    }

    public override function enterFrame() {
        bloodLayer.x = floorColours.x = mapScrollView.getMainLayer().x;
        bloodLayer.y = floorColours.y = mapScrollView.getMainLayer().y;

        mapScrollView.clipSprites(floorColours);

        /*delay -= SMain.delta;
        if(delay < 0 && !isGameOver){
            delay = Random.randRange(1000, 3000);
            var zombie = zombieSpawner.addZombie();
            var v : nape.geom.Vec2 = new nape.geom.Vec2(1, 0);
            v.rotate(Random.frandRange(0, Math.PI * 2));

            zombie.init( player.x + v.x * 130,
                         player.y + v.y * 130);
            zombie.state = pursuit;
        }                           */
    }
}
