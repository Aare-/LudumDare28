package com.subfty.ld28.screens.game.sceneutils;

import flash.display.Bitmap;
import flash.events.Event;
import openfl.Assets;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.display.Sprite;

class TiledBackground extends Sprite {

    var bitmapData : BitmapData;
    var fill       : Rectangle;
    var target     : Sprite;

    public function new(fill : Rectangle) {
        super();

        setFill(fill);

        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

  //BINDING
    public function setTile(?path : String = null){
        if(path != null)
            bitmapData = Assets.getBitmapData(path);
        if(bitmapData == null)
            return;

        this.graphics.clear();

        this.graphics.beginBitmapFill(bitmapData, null, true);
        this.graphics.drawRect(-bitmapData.width * 2,
                               -bitmapData.height * 2,
                                fill.width + bitmapData.width * 3,
                                fill.height + bitmapData.height * 3);

    }

    public function setTarget(target : Sprite){
        this.target = target;
    }

    public function setFill(fill : Rectangle){
        this.fill = fill;
        setTile();
    }

  //EVENTS
    function onEnterFrame(e){
        if(target == null) return;

        updateOnTargetPosition();
    }

    function updateOnTargetPosition(){
        this.x = target.x % bitmapData.width;
        this.y = target.y % bitmapData.height;
    }
}
