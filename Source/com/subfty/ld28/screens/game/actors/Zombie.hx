package com.subfty.ld28.screens.game.actors;

import com.subfty.sub.data.Config;
import flash.display.Bitmap;
import nape.geom.Vec2;
import com.subfty.sub.SMain;
import nape.phys.Material;
import nape.shape.Circle;
import com.subfty.ld28.screens.game.sceneutils.ZombieSpawner;
import de.polygonal.core.math.Mathematics;
import haxe.EnumTools;
import de.polygonal.core.math.random.Random;
import flash.display.Sprite;

using haxe.EnumTools;
using com.subfty.sub.utils.ArrayTools;

enum ZombieState {
    inactive;
    dead;
    pursuit;
    inrange;
    stroll;
    outofrange;
    think;
}

enum ZombieTypes {
    typeA;
    typeB;
    typeC;
    typeD;
}

class Zombie extends Character {

  //VALUES
    var playerRef : Player;
    public var state (default, set) : ZombieState;
    var type               : ZombieTypes;
    var inVisibleRange     : Bool;
    var wobblePower        : Float;
    var newDirect          : Vec2;
    static var tmpVec      : Vec2;
    var readyToBeDestroyed : Bool;
    var lives              : Int;

  //SETTERS AND GETTERS
    function set_state(newState : ZombieState) {
        if(this.state == newState)
            return this.state;

        this.state = newState;

        switch(state){
        case inactive, stroll, outofrange :
            this.visible = false;
            if(state == outofrange || state == inactive){
                hibernateBody();
            }else
                dehibernateBody();

        default:
            dehibernateBody();
            this.visible = true;

            if(state == pursuit)
                ZombieSpawner.detect.getRandomElement().play();
        }

        return this.state;
    }

    override function get_movementSpeed() : Float {
        switch(state){
        case pursuit:
            return ZombieSpawner.PURSUIT_SPEED;
        case stroll, inrange:
            return ZombieSpawner.STROLL_SPEED;
        case thing:
            return 0.0;
        }
        return 0.0;
    }

  //CONSTUCTOR
    public function new(player : Player){
        super();
        this.playerRef = player;
        newDirect = new Vec2(0, 0);

        if(tmpVec == null)
            tmpVec = new Vec2();

        destroy();
    }

  //STATUS
    public function init(x : Float, y : Float, ?type : ZombieTypes = null, ?state : ZombieState = null){
        if(type == null)
            type = ZombieTypes.createAll().getRandomElement();
        if(state == null)
            state = stroll;

        this.type = type;
        this.state = state;
        this.inVisibleRange = true;
        this.wobbleTime = Math.PI * 2 * Random.frand();
        this.wobblePower = Random.frand();
        this.lives = Std.parseInt(Config.f.node.zombies.att.lives);
        this.readyToBeDestroyed = false;

        chooseNewDirection();
        direction.setxy(newDirect.x, newDirect.y);

        loadBitmaps("zambies/"+this.type.getName());

        for(b in bitmaps){
            b.x = -b.bitmapData.width / 2;
            b.y = -b.bitmapData.height;
            body.x = b.bitmapData.width / 2;
            body.y = b.bitmapData.height;
        }

        faceDirection(up);
        faceDirection(down);

        if(nape_body == null)
            initBody(Game.ZOMBIE, this);
        nape_body.userData.zombie = this;

        this.nape_body.position.setxy(x, y);
        this.x = x;
        this.y = y;
    }

    public function destroy(){

        if(this.state == inactive) return;

        this.state = inactive;
        this.visible = true;

        if(body != null){
            while(body.numChildren > 0)
                body.removeChildAt(0);

            if(bitmaps != null && bitmaps.length > 4 && bitmaps[4] != null){
                body.addChild(bitmaps[4]);
            }
        }
    }

    public function isDestroyed() : Bool{
        return state == inactive;
    }

    public function hittedByBullet(){
        Main.game.bloodLayer.addBloodSplash(this.x, this.y,
                                            30 + Random.randRange(0, 15),
                                            20 + Random.randRange(0, 15));
        ZombieSpawner.hit.getRandomElement().play();

        this.lives--;
        if(this.lives <= 0){
            Main.game.zombieSpawner.zombieKilled++;
            decease();
        }
    }

    function decease(){
        /*if(body.numChildren > 0){
            if(bitmaps.length >= 4 && bitmaps[4] != null)
                Main.game.bloodLayer.addBitmap(this.x + 10, this.y, bitmaps[4]);
        }                       */
        readyToBeDestroyed = true;
    }

  //MOVEMENT
    function chooseNewDirection(){
        newDirect.setxy(1.0, 0.0);
        newDirect.rotate(Math.PI * 2 * Random.frand());
        newDirect.normalise();
    }

    function pow(val : Float){
        return val * val;
    }

  //FRAME ACTIONS
    var testVec : Vec2;
    public override function onEnterFrame(e) {
        super.onEnterFrame(e);

        if(readyToBeDestroyed){
            destroy();
            return;
        }

        if(state == dead || state == inactive){
            if(!Game.isGameOver){
                if(testVec == null)
                    testVec = new Vec2(0,0);

                testVec.setxy(this.x - Main.game.player.x, this.y- Main.game.player.y);
                if(testVec.length > 300){
                    init(this.x, this.y);
                }
            }

            return;
        }

      //CHANGING STATUS

        if(state != pursuit){
            var lenFromPlayer : Float = Mathematics.sqrt(pow(this.x - playerRef.x) + pow(this.y - playerRef.y));
            if(state != pursuit && Mathematics.inRange(lenFromPlayer, 0, ZombieSpawner.STATUS_POSS_PURSUIT))
                state = inrange;
            else if(Mathematics.inRange(lenFromPlayer, ZombieSpawner.STATUS_POSS_PURSUIT, ZombieSpawner.STATUS_STROLL))
                state = stroll;
            else
                if(state != pursuit)
                    state = outofrange;
        }

        #if debug
        this.graphics.clear();
        #end

        direction.angle += (newDirect.angle - direction.angle) * SMain.delta / 33.0 * 0.8;

      //ACTING
        switch(state){
        case stroll:
            if(Random.frand() < 0.05)
                chooseNewDirection();

            #if debug
                this.graphics.beginFill(0x0000ff);
                this.graphics.drawRect(0,0,5,5);
            #end

        case inrange:
            if(Random.frand() < 0.1)
                chooseNewDirection();

            tmpVec.x = playerRef.x - this.x;
            tmpVec.y = playerRef.y - this.y;
            if(tmpVec.length < 15)
                state = pursuit;

            tmpVec.normalise();

            //if(Math.abs(tmpVec.cross(direction)) < 0.2)
            var vecang : Float = Math.acos(tmpVec.dot(direction) / (tmpVec.length * direction.length));
            if(Math.abs(vecang) < Math.PI * 0.4)
                state = pursuit;

            #if debug
                this.graphics.beginFill(0x110000);
                this.graphics.drawRect(0,0,5,5);
            #end

        case pursuit:
            direction.setxy( playerRef.x - this.x, playerRef.y - this.y );
            direction.normalise();

            #if debug
            this.graphics.beginFill(0xff0000);
            this.graphics.drawRect(0,0,5,5);
            #end

        case outofrange:
            #if debug
            this.graphics.beginFill(0x00ff00);
            this.graphics.drawRect(0,0,5,5);
            #end

            return;

        default:
        }

        #if debug
        this.graphics.beginFill(0x00ff00);
        this.graphics.moveTo(0, 0);
        this.graphics.lineStyle(1.5);
        this.graphics.lineTo(direction.x * 15.0, direction.y * 15.0);
        #end

        performMovement();
        wobble();
    }

    var wobbleTime : Float = 0;
    function wobble(){
        wobbleTime += SMain.delta / 1000.0 * 150.0;
        if(body != null)
            body.rotation = Math.sin(Math.PI * 2.0 * wobbleTime) * (7.0 + 4.0 * wobblePower);
    }
}