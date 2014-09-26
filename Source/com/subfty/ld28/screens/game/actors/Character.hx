package com.subfty.ld28.screens.game.actors;

import nape.callbacks.CbType;
import nape.shape.Circle;
import nape.phys.Material;
import com.subfty.sub.SMain;
import nape.shape.Shape;
import nape.phys.BodyType;
import nape.phys.Body;
import de.polygonal.core.math.Mathematics;
import flash.display.Bitmap;
import flash.events.Event;
import nape.geom.Vec2;
import openfl.Assets;
import flash.display.Bitmap;
import flash.display.Sprite;

using haxe.EnumTools;

enum CharacterFrames {
    up;
    right;
    down;
    left;

    dead;
}

enum Directions {
    up;
    right;
    down;
    left;
    rightup;
    rightdown;
    leftdown;
    leftup;
}

class Character extends Sprite {

    var bitmaps   : Array<Bitmap>;
    var shadow    : Bitmap;
    var body      : Sprite;
    var direction : Vec2;
    var movementSpeed (get, null) : Float;

    //psychic
    var nape_body : Body = null;

    function get_movementSpeed() : Float {
        return 0;
    }

    public function new() {
        super();

        bitmaps = [for(i in 0 ... CharacterFrames.getConstructors().length) null];

        body = new Sprite();
        direction = new Vec2(0.0, 0.0);

        this.addChild(body);
        this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

  //PSYCHIC
    function initBody(?cType : CbType = null, ?data : Dynamic = null){
        var material : Material = Material.ice();

        var n_shape : Circle = new Circle(getWidth() * 0.2, nape.geom.Vec2.weak(0,0), material, null);

        nape_body = new Body(BodyType.DYNAMIC);

        n_shape.body = nape_body;
        dehibernateBody();

        if(data != null){
            n_shape.userData.data = data;
            nape_body.userData.data = data;
        }
        if(cType != null)
            nape_body.cbTypes.add(cType);
    }

    function hibernateBody(){
        if(nape_body != null)
            nape_body.space = null;
    }

    function dehibernateBody(){
        if(nape_body != null && nape_body.space == null){
            nape_body.space = SMain.space;
        }
    }

  //ASSETS
    function loadBitmaps(prefix : String, ?bitmapsPaths : Map<CharacterFrames, String> = null){
        if(bitmapsPaths == null){
            bitmapsPaths = new Map<CharacterFrames, String>();
            for(e in CharacterFrames.createAll())
                bitmapsPaths.set(e, e.getName());
        }

        for(key in bitmapsPaths.keys()){
            bitmaps[key.getIndex()] = new Bitmap(Assets.getBitmapData("img/"+prefix+"/"+bitmapsPaths.get(key)+".png"));
            bitmaps[key.getIndex()].x = 0;//-bitmaps[key.getIndex()].bitmapData.width / 2;
            bitmaps[key.getIndex()].y = 0;//-bitmaps[key.getIndex()].bitmapData.height;
        }
    }

  //VISUALS
    var prevDirection : Directions = null;
    public function faceDirection( direction : Directions ){
        if(prevDirection == direction) return;
        prevDirection = direction;

        while(body.numChildren > 0)
            body.removeChildAt(0);

        switch(direction){
        case up:
            body.addChild(bitmaps[direction.getIndex()]);
        case down:
            body.addChild(bitmaps[direction.getIndex()]);
        case left:
            body.addChild(bitmaps[direction.getIndex()]);
        //case right:
        default:
            body.addChild(bitmaps[down.getIndex()]);
        }
    }

    static var tmpVec21 : nape.geom.Vec2;
    static var tmpVec22 : nape.geom.Vec2;
    public function getFaceDirectionFromAngle(ang : Float){
        while(ang < 0)
            ang += Math.PI * 2;
        ang %= Math.PI * 2;
        var step : Float = Math.PI / 4;

        if(Mathematics.inRange(ang, step * 0, step * 1))
            return down;
        if(Mathematics.inRange(ang, step * 1, step * 2))
            return down;
        if(Mathematics.inRange(ang, step * 2, step * 3))
            return left;
        if(Mathematics.inRange(ang, step * 3, step * 4))
            return left;
        if(Mathematics.inRange(ang, step * 4, step * 5))
            return up;
        if(Mathematics.inRange(ang, step * 5, step * 6))
            return up;
        if(Mathematics.inRange(ang, step * 6, step * 7))
            return right;

        return right;


        /*if(Mathematics.inRange(ang, -Math.PI * 0.25, Math.PI * 0.25) ||
           Mathematics.inRange(ang, Math.PI * 1.75 , Math.PI * 2.25))
            return right;
        if(Mathematics.inRange(ang, Math.PI * 0.25, Math.PI * 0.75))
            return down;
        if(Mathematics.inRange(ang, Math.PI * 0.75, Math.PI * 1.25))
            return left;
        return up;                          */
    }

  //MEASUREMENT
    public function getWidth() : Float{
        if(body.numChildren <= 0) return 0;
        var child : Bitmap = cast(body.getChildAt(0), Bitmap);
        return child.bitmapData.width;
    }

    public function getHeight() : Float{
        if(body.numChildren <= 0) return 0;
        var child : Bitmap = cast(body.getChildAt(0), Bitmap);
        return child.bitmapData.height;
    }

  //EVENTS
    function onEnterFrame(e){

    }

    function performMovement(?steerable : Bool = false){
        if(steerable){
            direction.setxy(0,0);
            if(Main.KEYS[Main.KEY_UP])
                direction.setxy(direction.x, direction.y - 1.0);
            if(Main.KEYS[Main.KEY_DOWN])
                direction.setxy(direction.x, direction.y + 1.0);
            if(Main.KEYS[Main.KEY_LEFT])
                direction.setxy(direction.x - 1.0, direction.y);
            if(Main.KEYS[Main.KEY_RIGHT])
                direction.setxy(direction.x + 1.0, direction.y);
        }

        if(nape_body != null){

            nape_body.velocity.setxy(direction.x * movementSpeed,
                                     direction.y * movementSpeed);

            this.x = (1.0 - SMain.movAlpha) * this.x + nape_body.position.x * SMain.movAlpha - getWidth() / 2;
            this.y = (1.0 - SMain.movAlpha) * this.y + nape_body.position.y * SMain.movAlpha;
        }else{
            this.x += direction.x * movementSpeed;
            this.y += direction.y * movementSpeed;
        }

        nape_body.position.x = Math.min(1200, Math.max(0,nape_body.position.x));
        nape_body.position.y = Math.min(1200, Math.max(0,nape_body.position.y));

        if(movementSpeed <= 0.01 || direction.length < 0.01)
            faceDirection(down);
        else
            faceDirection(getFaceDirectionFromAngle(direction.angle));
    }

    public function onDeath(){}
}
