package com.subfty.ld28.screens.game.actors;

import de.polygonal.core.math.random.Random;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionType;
import nape.callbacks.PreListener;
import nape.space.Space;
import com.subfty.sub.data.Config;
import nape.shape.Polygon;
import nape.phys.BodyType;
import com.subfty.sub.SMain;
import flash.events.Event;
import nape.geom.Vec2;
import nape.shape.Circle;
import nape.phys.Material;
import nape.phys.Body;
import openfl.Assets;
import flash.display.Bitmap;
import flash.display.Sprite;

using com.subfty.sub.utils.ArrayTools;

class Bullet extends Sprite {

    var movDirection    : Vec2;
    var toCrosshairDirection : Vec2;

    var prevPos : Array<{x : Float, y : Float}>;
    var prevPosIndic : Int;
    var leaveMark : Int;

  //PSYCHIC
    var nape_body    : Body;

  //LINKS
    var crosshair : Sprite;
    var stge : Sprite;

    var movementSpeed : Float;

    public function new (){
        super();

        prevPos = [];
        for(i in 0 ... 20)
            prevPos.push({x : Math.NaN, y : Math.NaN});
        prevPosIndic = 0;

        movDirection = new Vec2();
        toCrosshairDirection = new Vec2();

      //CREATING BODY
        var material : Material = new Material(Std.parseFloat(Config.f.node.bullet.att.elasticy),
                                               Std.parseFloat(Config.f.node.bullet.att.dynamicFriction),
                                               Std.parseFloat(Config.f.node.bullet.att.staticFriction),
                                               Std.parseFloat(Config.f.node.bullet.att.density),
                                               Std.parseFloat(Config.f.node.bullet.att.rollingFriction));
        MAX_DIST = Std.parseFloat(Config.f.node.bullet.att.maxDist);
        DIR_CHNG_SPEED = Std.parseFloat(Config.f.node.bullet.att.dirChngSpeed);
        bulletVelocity = Std.parseFloat(Config.f.node.bullet.att.velocity);
        forceVelocity = Std.parseFloat(Config.f.node.bullet.att.forcevelocity);

        var n_shape : Circle = new Circle(3, nape.geom.Vec2.weak(0,0), material, null);//Polygon = new Polygon(Polygon.rect(-2, -2, 4, 4), material, null);

        nape_body = new Body(BodyType.DYNAMIC);
        nape_body.isBullet = true;
        n_shape.body = nape_body;
        nape_body.space = SMain.space;

        nape_body.cbTypes.add(Game.BULLET);

      //REGISTERING CALLBACKS
        SMain.space.listeners.add(new PreListener(
            InteractionType.COLLISION,
            Game.BULLET,
            Game.ZOMBIE,
            hittedZombie
        ));
        SMain.space.listeners.add(new PreListener(
            InteractionType.COLLISION,
            Game.BULLET,
            Game.WALL,
            hittedWall
        ));

        movementSpeed = 100;

        prepareGraphics();
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    public function connectToCrosshair(crosshair : Sprite){
        this.crosshair = crosshair;

        var stX : Float = Main.game.mapScrollView.getMainLayer().x;
        var stY : Float = Main.game.mapScrollView.getMainLayer().y;

        nape_body.position.setxy(crosshair.x - stX,
                                 crosshair.y - stY);
        movDirection.setxy(1.0, 0.0);

        leaveMark = 0;
    }

    function prepareGraphics(){
        this.graphics.clear();

        for(i in 1 ... prevPos.length + 1){
            var pos : Int = prevPosIndic - i;
            if(pos < 0)
                pos += prevPos.length;
            if(Math.isNaN(prevPos[pos].x) || Math.isNaN(prevPos[pos].y))
                break;

            graphics.beginFill(0xffffff, 1.0 - 0.01 * i - (i > 1 ? 0.87 : 0));
            graphics.drawRect(prevPos[pos].x - x - 2,
                              prevPos[pos].y - y - 2,
                              4, 4);
        }
    }

    var MAX_DIST : Float;
    var DIR_CHNG_SPEED : Float;
    var bulletVelocity : Float;
    var forceVelocity : Float;

    function onEnterFrame(e){
        if(SMain.screen != Main.game || Game.isGameOver) return;

        var stX : Float = Main.game.mapScrollView.getMainLayer().x;
        var stY : Float = Main.game.mapScrollView.getMainLayer().y;

        var cHairX : Float = crosshair.x - stX;
        var cHairY : Float = crosshair.y - stY;

        toCrosshairDirection.setxy(cHairX - this.x,
                                   cHairY - this.y);

        var dirChangeSpeed : Float = Math.min(1.0, toCrosshairDirection.length / MAX_DIST) * DIR_CHNG_SPEED;// * SMain.delta;

        var angleBmovAndCrossh : Float = Math.acos(toCrosshairDirection.dot(movDirection) /
                                                  (toCrosshairDirection.length * movDirection.length));
        var rot : Float = -angleBmovAndCrossh * dirChangeSpeed;

        if(movDirection.cross(toCrosshairDirection) > 0)
            rot *= -1;

        if(!Math.isNaN(rot) )
            movDirection.rotate(rot);
        movDirection.normalise();

        nape_body.velocity.setxy(movDirection.x * bulletVelocity,
                                 movDirection.y * bulletVelocity);

        /*
            var time : Float = SMain.delta / 1000.0;

        if(time > 0){
            nape_body.force.setxy(0,0);
            nape_body.force.setxy(movDirection.x * forceVelocity * nape_body.mass * time,
                                  movDirection.y * forceVelocity * nape_body.mass * time);
        }

        if(nape_body.velocity.length > bulletVelocity){
            nape_body.velocity.normalise();
            nape_body.velocity = nape_body.velocity.mul(bulletVelocity);
        }
        */

        this.x = (1.0 - SMain.movAlpha) * this.x + nape_body.position.x * SMain.movAlpha;
        this.y = (1.0 - SMain.movAlpha) * this.y + nape_body.position.y * SMain.movAlpha;
        prevPos[prevPosIndic].x = this.x;
        prevPos[prevPosIndic].y = this.y;
        prevPosIndic = (prevPosIndic + 1) % prevPos.length;

        prepareGraphics();

        if(leaveMark > 0){
            leaveMark--;
            Main.game.bloodLayer.addBloodSplash(this.x, this.y,
                                                5 + Random.randRange(0, 4),
                                                5 + Random.randRange(0, 4));
        }

        #if debug
        /*this.graphics.moveTo(0,0);
        this.graphics.lineStyle(0.1, 0xff0000);
        this.graphics.lineTo(movDirection.x * 20,
                             movDirection.y * 20);

        this.graphics.moveTo(0,0);
        this.graphics.lineStyle(0.1, 0x00ff00);
        this.graphics.lineTo(toCrosshairDirection.x * 1,
                             toCrosshairDirection.y * 1);*/
        #end
    }

  //MEASUREMENTS
    public function getWidth() : Float {
        return 5;
    }

    public function getHeight() : Float {
        return 5;
    }

  //INTERACTIONS
    function hittedZombie(cb : PreCallback) : PreFlag {
        if(cb.int1.cbTypes.has(Game.ZOMBIE))
            cast(cb.int1.userData.data, Zombie).hittedByBullet();
        else if(cb.int2.cbTypes.has(Game.ZOMBIE))
            cast(cb.int2.userData.data, Zombie).hittedByBullet();

        leaveMark += 10;

        return PreFlag.IGNORE;
    }

    function hittedWall(cb : PreCallback) : PreFlag {
        //Game.shootInVall.getRandomElement().play();

        return PreFlag.ACCEPT;
    }
}