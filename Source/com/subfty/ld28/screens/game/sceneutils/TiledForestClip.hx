package com.subfty.ld28.screens.game.sceneutils;

import com.subfty.sub.SMain;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import flash.display.Sprite;

class TiledForestClip extends Sprite {

    var bitmapDatas : Array<BitmapData>;
    var clip        : Rectangle;
    var screen      : Rectangle;
    var target      : Sprite;

    var maxWidth : Float;
    var maxHeight : Float;

    public function new(clip : Rectangle) {
        super();

        screen = new Rectangle(0, 0, SMain.STAGE_W, SMain.STAGE_H);
        setClip(fill);
        setTile();

        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

  //BINDING
    public function setTile(){
        bitmapDatas = [];

        bitmapDatas.push(Assets.getBitmapData("img/trees/tree1.png"));
        bitmapDatas.push(Assets.getBitmapData("img/trees/tree2.png"));
        bitmapDatas.push(Assets.getBitmapData("img/trees/tree3.png"));
        bitmapDatas.push(Assets.getBitmapData("img/trees/tree4.png"));

        maxHeight = 0.0;
        maxWidth = 0.0;

        for(bData in bitmapDatas){
            maxWidth = Math.max(maxWidth, bData.width);
            maxHeight = Math.max(maxHeight, bData.height);
        }
    }

    public function setTarget(target : Sprite){
        this.target = target;
    }

    public function setClip(clip : Rectangle){
        this.clip = clip;
        setTile();
    }

  //EVENTS
    function onEnterFrame(e){
        if(target == null) return;

        updateOnTargetPosition();

        this.graphics.clear();

        screen.x = -target.x;
        screen.y = -target.y;
        if(!clip.containsRect(screen)){
            //TODO: drawing trees
            /*this.graphics.beginBitmapFill(bitmapData, null, true);

            this.graphics.drawRect(-bitmapData.width * 2,
            -bitmapData.height * 2,
            fill.width + bitmapData.width * 3,
            fill.height + bitmapData.height * 3);*/
        }
    }

    function updateOnTargetPosition(){
        this.x = target.x % maxWidth;
        this.y = target.y % maxHeight;
    }
}
