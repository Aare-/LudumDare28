package com.subfty.ld28.screens.intro;

import flash.display.Sprite;
import motion.easing.Sine;
import motion.Actuate;
import openfl.Assets;
import flash.display.Bitmap;
import com.subfty.sub.display.Screen;
import com.subfty.sub.SMain;
import de.polygonal.core.scene.Scene;

class Intro extends Screen {

    var container : Sprite;
    var introBitmap : Bitmap;

    public function new(parent : SMain) {
        super(parent, "intro", true);

        container = new Sprite();
        introBitmap = new Bitmap(Assets.getBitmapData("img/sf2.png"));
        introBitmap.x = -introBitmap.bitmapData.width / 2;
        introBitmap.y = -introBitmap.bitmapData.height / 2;

        container.addChild(introBitmap);

        container.x = SMain.STAGE_W / 2;
        container.y = SMain.STAGE_H / 2;

        container.scaleX = container.scaleY = 0.25;

        this.addChild(container);
    }

    override public function postLoad() {
        container.alpha = 0.0;

        Actuate.tween(container, 1.0, {alpha : 1.0})
               .delay(1.0)
               .onComplete(function(){
                    Actuate.tween(container, 1.0, {alpha : 0.0})
                           .delay(3.0)
                           .onComplete(function(){
                                SMain.setScreen(Main.menu);
                            })
                           .ease(Sine.easeIn);
                })
               .ease(Sine.easeIn);
    }

}
