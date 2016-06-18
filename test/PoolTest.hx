package;

import moon.core.Struct;
import moon.data.pool.Pool;

/**
 * ...
 * @author Munir Hussin
 */
class PoolTest
{

    public static function main() 
    {
        trace("aaaaa");
        
        // [KillInactive, IncreaseSize(3)],
        
        var ctor = function() return new Particle(0, 0, 0);
        var dtor = function(p:Particle) p.kill();
        
        var pool:Pool<Particle> = new Pool<Particle>(3, IncreaseSize(3), ctor, dtor);
        
        
        var p1:Particle = pool.create().init(1, 2, 3); trace(pool);
        
        var p2:Particle = pool.create().init(5, 5, 5); trace(pool);
        
        var p3:Particle = pool.create().init(9, 8, 7); trace(pool);
        
        var p4:Particle = pool.create().init(2, 4, 6); trace(pool);
        
        //pool.destroy(p2); trace(pool);
        
        for (p in pool)
        {
            trace(p);
        }
    }
    
}

class Particle
{
    public var x:Float;
    public var y:Float;
    public var z:Float;
    
    public function new(x:Float, y:Float, z:Float)
    {
        init(x, y, z);
    }
    
    public function init(x:Float, y:Float, z:Float):Particle
    {
        this.x = x;
        this.y = y;
        this.z = z;
        return this;
    }
    
    public function kill():Void
    {
        // do whatever cleanup
        trace("particle killed");
    }
    
    public function toString():String
    {
        return '($x,$y,$z)';
    }
}