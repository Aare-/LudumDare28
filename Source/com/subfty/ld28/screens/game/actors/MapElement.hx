package com.subfty.ld28.screens.game.actors;

import nape.geom.Vec2;
import nape.shape.Circle;
import com.subfty.sub.SMain;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.phys.Material;
import nape.phys.Body;
import com.subfty.sub.svg.SVGParser;
import openfl.Assets;
import com.subfty.sub.svg.actors.SVGRect.SRect;
import flash.display.Bitmap;
import flash.display.Sprite;

using com.subfty.sub.utils.ArrayTools;

class MapElement extends Sprite {

    var bitmap : Bitmap;

    var m_width : Float;
    var m_height : Float;

    public function new(e : Xml) {
        super();
        bitmap = new Bitmap();
        var loc : String = e.get("xlink:href").substr(e.get("xlink:href").indexOf("img/")+4);
        var r : SRect = {x : 0, y : 0, w : 0, h : 0};
        bitmap.bitmapData = Assets.getBitmapData("img/"+loc);
        SVGParser.applyTransformToRect(e, r);
        bitmap.x = 0;
        bitmap.y = 0;
        bitmap.width = r.w;
        bitmap.height = r.h;
        this.x = r.x;
        this.y = r.y;
        m_width = r.w;
        m_height = r.h;
        name = e.get("id");

        createPhycis(loc.substring(loc.lastIndexOf("/")+1, loc.lastIndexOf(".")));
        addChild(bitmap);
    }

    function createRect(name : String, rx : Float, ry : Float, rw : Float, rh : Float) {
        var body = new Body(BodyType.STATIC);
        new Polygon(Polygon.rect(rx, ry, rw, rh), Material.steel()).body = body;
        try{
            body.space = SMain.space;
        }catch(e : String){
            body = null;
        }
    }

    function createCircle(name : String, rx : Float, ry : Float, rad : Float){
        var body = new Body(BodyType.STATIC);
        new Circle(rad, new Vec2(rx, ry), Material.steel()).body = body;
        try{
            body.space = SMain.space;
            body.userData.data = this;
            body.cbTypes.add(Game.WALL);
        }catch(e : String){
            trace("CIRCLE ERROR: "+e+" in body: "+name);
            for(s in body.shapes)
                s.body = null;
            body.shapes.clear();
            body = null;
        }
    }

    function createPhycis(name : String) {
        var translY : Float = -9;
        var translH : Float = 5;

        switch(name){
        case "01":
            createRect(name, x, y + 11 + translY, m_width, m_height -11 - 13 + translH);
        case "02":
            createRect(name, x, y + 11 + translY, m_width, m_height -11 - 13 + translH);
        case "02b":
            createRect(name, x, y + 11 + translY, m_width, m_height -11 - 15 + translH);
        case "04":
            createRect(name, x, y + 11 + translY, m_width, m_height -11 - 9 + translH);
        case "05":
            createRect(name, x, y + 11 + translY, m_width, m_height -11 - 7 + translH);
        case "06":
            createRect(name, x, y + 11 + translY, m_width, m_height -11 - 7 + translH);
        case "06b":
            createRect(name, x, y + 11 + translY, m_width, m_height -11 - 7 + translH);
        case "07":
            createRect(name, x, y + 11 + translY, m_width, m_height -11 - 8 + translH);
        case "08":
            createRect(name, x, y, 60, 117);
            createRect(name, x, y+37, 175, 72);
        case "09b":
            createRect(name, x, y + 15, 125, 66);
            createRect(name, x, y+66, 61, 51);
        case "diner-1":
            createRect(name, x, y+11 + translY, m_width, m_height - 11 + translH);
        case "latryna":
            createRect(name, x + 12, y + 12 + translY, 21, 27 + 4);
        case "motel-1":
            createRect(name, x, y+11 + translY, m_width, m_height - 11 + translH);
        case "motel-2":
            createRect(name, x, y + 11 + translY, m_width, m_height - 11 + translH);
        case "stacja-1":
            createRect(name, x, y + 11 + translY, m_width, m_height - 11 + translH);
        case "magazyn":
            createRect(name, x, y + 13 + translY, m_width, m_height - 11 + translH - 8);

        case "stacja-2":
            createRect(name, x, y , 14, 22);
            createRect(name, x + 38, y , 12, 22);
            createRect(name, x + 76, y , 14, 22);

        case "tree1":
            createCircle(name, x + 19 + 5, y + 50 - 10, 7);
        case "tree2":
            createCircle(name, x + 24 + 5, y + 66- 10, 8);
        case "tree3":
            createCircle(name, x + 20 + 5, y + 87- 10, 8);
        case "tree4":
            createCircle(name, x + 40 + 5, y + 98- 10, 8);
        case "plot1":
            createRect(name, x, y + 22-10, m_width, 5);
        case "plot2":
            createRect(name, x, y, m_width, m_height);
        case "wall1":
            createRect(name, x, y + 20, m_width, 15);
        case "wall3":
            createRect(name, x, y, m_width, m_height);
        case "wall-corner":
            createRect(name, x, y, m_width, m_height);
        case "wall-end":
            createRect(name, x, y + 30, m_width, 13);
        case "wall-end2":
            createRect(name, x, y + 30, m_width, 13);

        case "barrel":
            createRect(name, x, y + 11, m_width, m_height - 11);

        case "car1", "car2", "car3":
            createRect(name, x, y , m_width, m_height);

        case "crate1":
            createRect(name, x, y + 3 , m_width, m_height-10);

        case "stone1", "stone2", "stone3", "tires1", "tires2", "tires3":
            createRect(name, x, y + 8 , m_width, m_height - 8 - 5);

        default:
        }
    }

  //MEASUREMENT
    public function getWidth() : Float {
        return m_width;
    }

    public function getHeight() : Float{
        return m_height;
    }
}
