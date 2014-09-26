package com.subfty.ld28.screens.credits;

import openfl.Assets;
import motion.easing.Sine;
import motion.Actuate;
import flash.events.MouseEvent;
import com.subfty.sub.SMain;
import flash.display.Bitmap;
import flash.display.Sprite;
import com.subfty.sub.display.Screen;

class Credits extends Screen {
    var container : Sprite;
    var introBitmap : Bitmap;

    public function new(parent : SMain) {
        super(parent, "intro", true);

        container = new Sprite();
        introBitmap = new Bitmap(Assets.getBitmapData("img/credits.png"));
        introBitmap.x = -introBitmap.bitmapData.width / 2;
        introBitmap.y = -introBitmap.bitmapData.height / 2;

        container.addChild(introBitmap);

        container.x = SMain.STAGE_W / 2;
        container.y = SMain.STAGE_H / 2;
        container.scaleX = container.scaleY = 0.8;

        container.addEventListener(MouseEvent.CLICK, function(e){


            SMain.setScreen(Main.menu,
            function (prevS : Screen, nextS : Screen, callback : Dynamic) : Void {
                Actuate.tween(prevS, 1.0, {alpha : 0.0})
                .onComplete(function(){
                    prevS.alpha = 1.0;
                    callback();
                });
            });


        });

        this.addChild(container);
    }

    override public function postLoad() {
        /*container.alpha = 0.0;

        Actuate.tween(container, 1.0, {alpha : 1.0})
        .delay(1.0)
        .ease(Sine.easeIn);*/
    }
}
