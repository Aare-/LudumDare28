package com.subfty.ld28.screens.game.sceneutils;

import flash.display.BlendMode;
import flash.geom.Matrix;
import openfl.Assets;
import flash.display.BitmapData;
import de.polygonal.core.math.random.Random;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.Sprite;

using com.subfty.sub.utils.ArrayTools;

class BloodLayer extends Sprite {

    var bloodColours : Array<Int>;

    var bitmap : Bitmap;
    var bData : BitmapData;

    public function new() {
        super();

        bloodColours = [0xff4b1a1a, 0xff391313];

        bData = new BitmapData(1200, 1200);
        bitmap = new Bitmap(bData);
        #if !flash
        bitmap.bitmapData.setFormat(BitmapData.FORMAT_8888);
        #end
        bitmap.bitmapData.floodFill(0, 0, 0x00ffffff);

        this.addChild(bitmap);

        clear();
    }

    public function clear(){
        #if !flash
        bitmap.bitmapData.clear(0x00ffffff);
        #end

    }

    public function addBloodSplash(x : Float, y : Float, ?splashWidth : Int = 30, ?splashHeight : Int = 20){

        for(w in 0 ... splashWidth)
            for(h in 0 ... splashHeight){
                var prob : Float =  (Math.sin(Math.PI * (w / splashWidth)) * Math.sin(Math.PI * (h / splashHeight)));
                prob *= prob;
                if(Random.frand() < Math.min(Math.max( 0.05, prob), 0.8)){
                    var targetX : Int = Math.floor(Math.max(0, Math.min(1200, Math.round(x) - splashWidth / 2 + w)));
                    var targetY : Int = Math.floor(Math.max(0, Math.min(1200, Math.round(y) - splashHeight / 2 + h)));

                    bitmap.bitmapData.setPixel32(targetX, targetY, bloodColours.getRandomElement());

                }
            }
    }

    public function addBitmap(x : Float, y : Float, bitmap : Bitmap){
        var mat : Matrix = new Matrix();
        mat.scale(1000.0, 1000.0);
        mat.translate(x, y);

        bitmap.bitmapData.draw(bitmap, mat);
    }
}
