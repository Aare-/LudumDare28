package com.subfty.ld28.screens.game.actors;

import nape.callbacks.InteractionType;
import com.subfty.sub.SMain;
import flash.media.Sound;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import com.subfty.sub.data.Config;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Shape;
import de.polygonal.core.math.Vec2;
import flash.ui.Keyboard;
import openfl.Assets;
import flash.display.Bitmap;
import flash.display.Sprite;

class Player extends Character {

    public var startPoint : Vec2;
    var catchSound : Sound;
    var speed : Float;

    var lives : Int;

    public function new(){
        super();

        startPoint = new Vec2(0.0, 0.0);
        catchSound = Assets.getSound("music/zlapany.wav");

        speed = Std.parseFloat(Config.f.node.player.att.speed);

        loadBitmaps("hero");
        faceDirection(down);

        initBody(Game.PLAYER);

      //REGISTERING CALLBACKS
        SMain.space.listeners.add(new PreListener(
            InteractionType.COLLISION,
            Game.PLAYER,
            Game.ZOMBIE,
            catchedByZombie
        ));
        SMain.space.listeners.add(new PreListener(
            InteractionType.COLLISION,
            Game.PLAYER,
            Game.BULLET,
            hittedByBullet
        ));
    }

    public function init(){
        faceDirection(down);

        dehibernateBody();
        nape_body.position.setxy(startPoint.x, startPoint.y);
        this.lives = 1;
        this.x = startPoint.x;
        this.y = startPoint.y;
    }

    override function get_movementSpeed() : Float {
        return speed;
    }

    var ve : nape.geom.Vec2;
    public override function onEnterFrame(e) {
        if(lives <= 0)
            return;

        performMovement(true);

        if(ve == null)
            ve = new nape.geom.Vec2(0,0);
        ve.setxy((Main.game.crosshair.x - Main.game.mapScrollView.getMainLayer().x) - this.x,
                 (Main.game.crosshair.y - Main.game.mapScrollView.getMainLayer().y) - this.y);
        ve.normalise();


        faceDirection(getFaceDirectionFromAngle(ve.angle));
    }

    function damage(){
        if(Game.isGameOver) return;
        lives--;

        if(lives <= 0){
            catchSound.play();
            Main.game.starGameOver();
        }
    }

  //INTERACTIONS
    function catchedByZombie(cb : PreCallback) : PreFlag {
        damage();

        return PreFlag.IGNORE;
    }
    function hittedByBullet(cb : PreCallback) : PreFlag {
        damage();
        return PreFlag.IGNORE;
    }
}