package com.subfty.ld28.screens.game.sceneutils;

import openfl.Assets;
import flash.media.Sound;
import com.subfty.ld28.screens.game.actors.Player;
import com.subfty.sub.data.Config;
import de.polygonal.core.math.Vec2;
import de.polygonal.core.math.random.Random;
import com.subfty.sub.SMain;
import flash.display.Sprite;
import com.subfty.ld28.screens.game.actors.Zombie;

class ZombieSpawner {

  //CONFIG
    public static var STATUS_STROLL       : Float;
    public static var STATUS_POSS_PURSUIT : Float;

    public static var STROLL_SPEED : Float;
    public static var PURSUIT_SPEED : Float;

    public static var hit    : Array<Sound>;
    public static var detect : Array<Sound>;
    public static var zombie : Array<Sound>;
    public var zombieKilled : Int;

    var zombies : Array<Zombie>;
    var swarmPoints : Array<Vec2>;
    var casualSwarmPoints : Array<Vec2>;
    var registerFunc : Sprite -> Void;
    var playerRef : Player;

    public function new(playerRef : Player) {
        this.playerRef = playerRef;
        zombies = [];
        swarmPoints = [];
        casualSwarmPoints = [];

        hit = [];
        hit.push(Assets.getSound("music/hit1.wav"));
        hit.push(Assets.getSound("music/hit2.wav"));
        hit.push(Assets.getSound("music/hit3.wav"));
        hit.push(Assets.getSound("music/hit4.wav"));
        hit.push(Assets.getSound("music/hit5.wav"));

        detect = [];
        detect.push(Assets.getSound("music/wykrycie1.wav"));
        detect.push(Assets.getSound("music/wykrycie2.wav"));
        detect.push(Assets.getSound("music/wykrycie3.wav"));

        zombie = [];
        zombie.push(Assets.getSound("music/zambie1.wav"));
        zombie.push(Assets.getSound("music/zambie2.wav"));
        zombie.push(Assets.getSound("music/zambie3.wav"));
        zombie.push(Assets.getSound("music/zambie4.wav"));
        zombie.push(Assets.getSound("music/zambie5.wav"));

        STATUS_STROLL = Std.parseFloat(Config.f.node.zombies.node.status_ranges.att.stroll);
        STATUS_POSS_PURSUIT = Std.parseFloat(Config.f.node.zombies.node.status_ranges.att.possPursuit);

        STROLL_SPEED = Std.parseFloat(Config.f.node.zombies.node.speed.att.stroll);
        PURSUIT_SPEED = Std.parseFloat(Config.f.node.zombies.node.speed.att.pursuit);
    }

    public function setRegisterFunc(registerFunc : Sprite -> Void){
        this.registerFunc = registerFunc;
    }

    public function init(){
        var minInSwarm : Int = Std.parseInt(Config.f.node.zombies.att.swarmMinSize);
        var maxInSwarm : Int = Std.parseInt(Config.f.node.zombies.att.swarmMaxSize);
        var swarmGenRadius : Float = Std.parseFloat(Config.f.node.zombies.att.swarmGenRadius);

        var casualMinInSwarm : Int = Std.parseInt(Config.f.node.zombies.att.casualSwarmMinSize);
        var casualMaxInSwarm : Int = Std.parseInt(Config.f.node.zombies.att.casualSwarmMaxSize);
        var casualSwarmGenRadius : Float = Std.parseFloat(Config.f.node.zombies.att.casualSwarmGenRadius);

        zombieKilled = 0;

        for(swarmPoint in swarmPoints){
            var randSize = Random.randRange(minInSwarm, maxInSwarm);
            for(i in 0 ... randSize)
                addZombie()
                    .init( swarmPoint.x + swarmGenRadius * Random.frandRange(-1.0, 1.0),
                           swarmPoint.y + swarmGenRadius * Random.frandRange(-1.0, 1.0));
        }

        for(swarmPoint in casualSwarmPoints){
            var randSize = Random.randRange(casualMinInSwarm, casualMaxInSwarm);
            for(i in 0 ... randSize)
                addZombie()
                    .init( swarmPoint.x + casualSwarmGenRadius * Random.frandRange(-1.0, 1.0),
                           swarmPoint.y + casualSwarmGenRadius * Random.frandRange(-1.0, 1.0));
        }
    }

    public function addZombie() : Zombie {
        var candidate : Zombie = null;
        for(z in zombies)
            if(z.isDestroyed()){
                candidate = z;
                break;
            }

        if(candidate == null){
            candidate = new Zombie(playerRef);
            zombies.push(candidate);
            registerFunc(candidate);
        }

        return candidate;
    }

    public function registerSwarmPoint(vec : Vec2){
        swarmPoints.push(vec);
    }

    public function registerCasualSwamPoint(vec : Vec2){
        casualSwarmPoints.push(vec);
    }

    public function destroyZombies(){
        for(z in zombies)
            z.destroy();
    }
}
