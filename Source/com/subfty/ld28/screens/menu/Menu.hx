package com.subfty.ld28.screens.menu;

import flash.system.System;
import flash.media.SoundChannel;
import flash.media.Sound;
import flash.display.Sprite;
import flash.events.MouseEvent;
import motion.Actuate;
import openfl.Assets;
import flash.display.Bitmap;
import com.subfty.sub.SMain;
import com.subfty.sub.display.Screen;

class Menu extends Screen {

    var logo : Bitmap;
    var spr1 : Sprite;
    var spr2 : Sprite;
    var spr3 : Sprite;

    var startButton : Bitmap;
    var creditsButton : Bitmap;
    var quitButton : Bitmap;


    var music : Sound;

    var channel : SoundChannel;

    public function new(parent : SMain){
        super(parent, "menu", true);

        logo = new Bitmap(Assets.getBitmapData("img/menu.png"));
        logo.x = (SMain.STAGE_W - logo.bitmapData.width) / 2;
        logo.y = 10;

        spr1 = new Sprite();
        startButton = new Bitmap(Assets.getBitmapData("img/b_Startgame.png"));
        startButton.x = (SMain.STAGE_W - startButton.bitmapData.width) / 2;
        startButton.y = logo.y + logo.bitmapData.height + 20;
        startButton.alpha = 0.6;
        spr1.addChild(startButton);
        spr1.addEventListener(MouseEvent.MOUSE_OVER, function(e){
            startButton.alpha = 1.0;
        });
        spr1.addEventListener(MouseEvent.MOUSE_OUT, function(e){
            startButton.alpha = 0.6;
        });
        spr1.addEventListener(MouseEvent.CLICK, function(e){
            var click : Sound = Assets.getSound("music/menu-click.wav");
            click.play();

            Main.game.alpha = 0.0;

            Actuate.tween(Main.menu, 1.0, {alpha : 0.0})
                    .onComplete(function(){
                        SMain.setScreen(Main.game,
                        function (prevS : Screen, nextS : Screen, callback : Dynamic) : Void {
                            Actuate.tween(nextS, 1.0, {alpha : 1.0})
                                   .onComplete(function(){
                                        callback();
                                    });
                        });
                    });
        });

        spr2 = new Sprite();
        creditsButton = new Bitmap(Assets.getBitmapData("img/b_credits.png"));
        creditsButton.x = (SMain.STAGE_W - creditsButton.bitmapData.width) / 2;
        creditsButton.y = startButton.y + 15;
        spr2.addEventListener(MouseEvent.CLICK, function(e){
            var click : Sound = Assets.getSound("music/menu-click.wav");
            click.play();

            Main.credits.alpha = 0.0;

            Actuate.tween(Main.menu, 1.0, {alpha : 0.0})
                    .onComplete(function(){
                        SMain.setScreen(Main.credits,
                        function (prevS : Screen, nextS : Screen, callback : Dynamic) : Void {
                            Actuate.tween(nextS, 1.0, {alpha : 1.0})
                            .onComplete(function(){
                                callback();
                            });
                        });
                    });

        });
        creditsButton.alpha = 0.6;
        spr2.addChild(creditsButton);
        spr2.addEventListener(MouseEvent.MOUSE_OVER, function(e){
            creditsButton.alpha = 1.0;
        });
        spr2.addEventListener(MouseEvent.MOUSE_OUT, function(e){
            creditsButton.alpha = 0.6;
        });

        spr3 = new Sprite();
        quitButton = new Bitmap(Assets.getBitmapData("img/b_quit.png"));
        quitButton.x = (SMain.STAGE_W - quitButton.bitmapData.width) / 2;
        quitButton.y = creditsButton.y + 15;
        spr3.addEventListener(MouseEvent.CLICK, function(e){
            var click : Sound = Assets.getSound("music/menu-click.wav");
            click.play();
            System.exit(0);
        });
        quitButton.alpha = 0.6;
        spr3.addChild(quitButton);
        spr3.addEventListener(MouseEvent.MOUSE_OVER, function(e){
            quitButton.alpha = 1.0;
        });
        spr3.addEventListener(MouseEvent.MOUSE_OUT, function(e){
            quitButton.alpha = 0.6;
        });

        this.addChild(logo);
        this.addChild(spr1);
        this.addChild(spr2);
        this.addChild(spr3);
    }

    override public function postLoad() {
        this.alpha = 1.0;

        logo.alpha = 0.0;
        spr1.alpha = 0.0;
        spr2.alpha = 0.0;
        spr3.alpha = 0.0;

        Actuate.stop(logo);
        Actuate.stop(spr1);
        Actuate.stop(spr2);
        Actuate.stop(spr3);

        Actuate.tween(logo, 1.0, {alpha : 1.0})
               .delay(0.5);

        Actuate.tween(spr1,  1.0, {alpha : 1.0})
               .delay(1.1);
        Actuate.tween(spr2,  1.0, {alpha : 1.0})
               .delay(1.3);
        Actuate.tween(spr3, 1.0, {alpha : 1.0})
               .delay(1.5);


        music = Assets.getSound("menu");
        channel = music.play();

    }

    override public function unload() {
        if(channel != null){
            channel.stop();
            channel =null;
        }
        logo.alpha = 0.0;
        spr1.alpha = 0.0;
        spr2.alpha = 0.0;
        spr3.alpha = 0.0;
    }
}