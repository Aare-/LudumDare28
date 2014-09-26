package com.subfty.ld28.screens.game.sceneutils;

import flash.geom.Rectangle;
import com.subfty.sub.SMain;
import flash.display.DisplayObject;
import flash.geom.Rectangle;
import flash.events.Event;
import flash.display.Sprite;

class SortedClippedStage extends Sprite {

    var clipWidth  : Int;
    var clipHeight : Int;

    var spriteToFollow : Sprite;
    public var followBox : Rectangle;
    public var clipBox : Rectangle;
    var testRectangle : Rectangle;
    public var followSpeed : Float;

    var mainLayer      : Sprite;

    public function new(){
        super();

        mainLayer = new Sprite();
        testRectangle = new Rectangle();

        this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        this.addChild(mainLayer);
    }

    public function setClipBox(clipBox : Rectangle){
        this.clipBox = clipBox;
    }

    public function setSpriteToFollow(target : Sprite,
                                      followBox : Rectangle, followSpeed : Float){
        this.spriteToFollow = target;
        this.followBox = followBox;
        this.followSpeed = followSpeed;
    }

    public function jumpToFollowedSpritePosition(){
        if(spriteToFollow != null){
            mainLayer.x = -spriteToFollow.x - clipBox.width / 2;
            mainLayer.y = -spriteToFollow.y - clipBox.height / 2;
        }
    }

  //SPRITES ORDER
    function sortTest(a : Dynamic, b : Dynamic) : Float {
        return (b.y + b.getHeight()) - (a.y + a.getHeight());
    }

    function correctPos(pos : Int){
        while(pos >= 1 && sortTest(mainLayer.getChildAt(pos - 1), mainLayer.getChildAt(pos)) < 0){
            mainLayer.swapChildrenAt(pos, pos - 1);
            pos--;
        }
    }

    public function addSprite(sprite : Sprite){
        mainLayer.addChild(sprite);
    }

    public function removeSprite(sprite : Sprite){
        mainLayer.removeChild(sprite);
    }

    public function getMainLayer() : Sprite {
        return mainLayer;
    }

    function checkEntitiesPos(){
        for(i in 1 ... mainLayer.numChildren)
            //if(mainLayer.getChildAt(i).visible)
                correctPos(i);
    }

    public function clipSprites(container : Sprite){
        for(i in 0 ... container.numChildren){
            var child : Dynamic = container.getChildAt(i);
            testRectangle.x = child.x + container.x;
            testRectangle.y = child.y + container.y;
            testRectangle.width = child.getWidth();
            testRectangle.height = child.getHeight();

            if(clipBox.intersects(testRectangle))
                container.getChildAt(i).visible = true;
            else
                container.getChildAt(i).visible = false;
        }
    }

  //ENTER FRAME
    function onEnterFrame(e){
        clipSprites(mainLayer);
        checkEntitiesPos();

      //FOLLOWING SPRITE
        if(spriteToFollow != null){
            var followX : Float = (spriteToFollow.x + (Main.game.crosshair.x - mainLayer.x)) / 2;
            var followY : Float = (spriteToFollow.y + (Main.game.crosshair.y - mainLayer.y)) / 2;

            if(followX + mainLayer.x < followBox.x)
                mainLayer.x += (followBox.x - followX - mainLayer.x) * followSpeed;
            if(followX + mainLayer.x > followBox.x + followBox.width)
                mainLayer.x -= (followX + mainLayer.x - followBox.x - followBox.width) * followSpeed;

            if(followY + mainLayer.y < followBox.y)
                mainLayer.y += (followBox.y - followY - mainLayer.y) * followSpeed;
            if(followY + mainLayer.y > followBox.y + followBox.height)
                mainLayer.y -= (followY + mainLayer.y - followBox.y - followBox.height) * followSpeed;
        }
    }
}