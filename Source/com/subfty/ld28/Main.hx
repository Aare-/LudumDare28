package com.subfty.ld28;

import com.subfty.ld28.screens.credits.Credits;
import com.subfty.ld28.screens.intro.Intro;
import flash.display.Stage;
import com.subfty.sub.SMain;
import openfl.Assets;
import com.subfty.ld28.Art;
import com.subfty.ld28.screens.menu.Menu;
import com.subfty.ld28.screens.game.Game;
import com.subfty.ld28.screens.death.Death;
import flash.media.Sound;
import flash.ui.Keyboard;
import flash.events.KeyboardEvent;
import flash.ui.GameInput;
import com.subfty.sub.data.GameState;
import com.subfty.sub.svg.actors.SVGRect.SRect;
import flash.display.BitmapData;
import com.subfty.sub.svg.SVGParser;
import flash.display.Bitmap;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import com.subfty.sub.SMain;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;

class Main extends SMain{

  //KEYBOARD
    public static var KEY_UP = 0;
    public static var KEY_DOWN = 1;
    public static var KEY_LEFT = 2;
    public static var KEY_RIGHT = 3;

    public static var KEYS = [for(i in 0 ... 4) false];

    public static var stg : Stage;
    var art : Art;

  //SCREENS
    public static var menu  : Menu;
    public static var death : Death;
    public static var game  : Game;
    public static var intro : Intro;
    public static var credits : Credits;

    public function new () {
        art = new Art();

        super (art);

        stg = Lib.current.stage;

        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyFunctionFactory(true));
        Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, keyFunctionFactory(false));
    }

    override private function init(e : Event){

        SVGParser.parseHash = [
        /*"image" =>
        function(root : Sprite, e : Xml){
            var container : Sprite = new Sprite();
            var bitmap : Bitmap = new Bitmap();
            var loc : String = e.get("xlink:href").substr(e.get("xlink:href").indexOf("raw/")+4);
            var r : SRect = {x : 0, y : 0, w : 0, h : 0};

            bitmap.bitmapData = Assets.getBitmapData(loc);
            SVGParser.applyTransformToRect(e, r);
            bitmap.x = 0;
            bitmap.y = 0;
            bitmap.width = r.w;
            bitmap.height = r.h;

            container.x = r.x;
            container.y = r.y;
            container.width = r.w;
            container.height = r.h;
            container.name = e.get("id");
            container.addChild(bitmap);

            if(e.get("specialCare") == "true")
            bitmap.smoothing = false;

            root.addChild(container);
        },                                */
        "rect" => SVGParser.parseRectTag//,
        //"flowRoot" => SVGParser.parseTextTag
        ];

        super.init(e);

        menu = new Menu(this);
        death = new Death(this);
        game = new Game(this);
        intro = new Intro(this);
        credits = new Credits(this);

        onResize(null);

        #if !flash
        trace("-----------------------");
        trace("------ LD28 2013 ------");
        trace("------- #SubFty -------");
        trace("--------- haXe --------");
        trace("-----------------------");
        trace("");
        #end


        #if debug
        SMain.setScreen(game);
        #else
        SMain.setScreen(intro);
        #end
    }

    public override function onResize(e:Event) {
        super.onResize(e);
    }

    public override function onPause(e:Event) {
        super.onPause(e);
    }

    public override function onResume(e:Event) {
        super.onResume(e);
    }

    function keyFunctionFactory(setVal : Bool) : KeyboardEvent -> Void {
        return function (e : KeyboardEvent){
            if(e.keyCode == Keyboard.W)
                KEYS[KEY_UP] = setVal;
            if(e.keyCode == Keyboard.S)
                KEYS[KEY_DOWN] = setVal;
            if(e.keyCode == Keyboard.A)
                KEYS[KEY_LEFT] = setVal;
            if(e.keyCode == Keyboard.D)
                KEYS[KEY_RIGHT] = setVal;
        }
    }
}