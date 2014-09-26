package com.subfty.ld28.screens.game.actors;

import com.subfty.sub.SMain;
import com.subfty.sub.SMain;
import flash.events.MouseEvent;
import openfl.Assets;
import flash.display.Bitmap;
import flash.display.Sprite;

class Crosshair extends Sprite {

    var bitmap : Bitmap;
    var move : Bool;

    public function new() {
        super();

        bitmap = new Bitmap(Assets.getBitmapData("img/interface/celownik.png"));
        bitmap.x = -bitmap.bitmapData.width / 2;
        bitmap.y = -bitmap.bitmapData.height / 2;

        this.addChild(bitmap);

        move =false;

        Main.stg.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        Main.stg.addEventListener(MouseEvent.MOUSE_OUT, onMouseLeave);
        Main.stg.addEventListener(MouseEvent.MOUSE_OVER, onMouseEnter);
    }

    function onMouseLeave(e){
        move = false;
    }

    function onMouseEnter(e){
        move =true;
    }

    function onMouseMove(e : MouseEvent){
        if(move){
            this.x = e.stageX / 640 * SMain.STAGE_W;
            this.y = e.stageY / 640 * SMain.STAGE_H;
        }
    }
}
