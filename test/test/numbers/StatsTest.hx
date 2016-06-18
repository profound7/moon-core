package test.numbers;

import moon.core.Compare;
import moon.numbers.stats.Stats;
import moon.test.TestCase;
import moon.test.TestRunner;

/**
 * TODO: Add more tests
 * @author Munir Hussin
 */
class StatsTest extends TestCase
{
    public var users:Array<User>;
    
    public static function main() 
    {
        var r = new TestRunner();
        r.add(new StatsTest());
        r.run();
    }
    
    public function setup()
    {
        users = [
            new User("Bob",   20, 1.1),
            new User("Alice", 31, 2.2),
            new User("Dave",  22, 3.3),
            new User("Harry", 20, 3.3),
            new User("Ellen", 34, 2.2),
            new User("Carol", 22, 1.23),
            new User("Gina",  22, 1.23),
            new User("Frank", 29, 7.54),
        ];
    }
    
    public function testStats()
    {
        var stats:Stats<User> = new Stats(users, function(x) return x.age);
        
        var totalAge = stats.sum();
        var maxAge = stats.max();
        var minAge = stats.min();
        
        var meanAge = stats.mean();
        var medianAge = stats.median();
        var modeAge = stats.mode();
        var midAge = stats.mid();
        
        var minUsers = stats.filterMin();
        
        
        assert.isDeepEqual(totalAge, 200);
        assert.isDeepEqual(maxAge, 34);
        assert.isDeepEqual(minAge, 20);
        
        assert.isDeepEqual(meanAge, 25);
        assert.isDeepEqual(medianAge, 22);
        assert.isDeepEqual(modeAge, [22]);
        assert.isDeepEqual(midAge, 27);
        
        assert.isDeepEqual(minUsers, [users[0], users[3]]);
        
        /*
        var zScores = stats.zScores(function(x) return x.age);
        zScores.sort(Compare.obj(function(x) return x.val, Compare.asc));
        
        
        var lp = stats.linearPartition(4, function(x) return x.age);
        var lpi = stats.items.linearPartition(4, function(x) return x.age);
        
        trace("\n");
        trace(lp);
        for (i in 0...lpi.length)
            trace('$i : ${lpi[i]}');
        */
    }
    
}

class User
{
    public var name:String;
    public var age:Int;
    public var score:Float;
    
    public function new(name:String, age:Int, score:Float)
    {
        this.name = name;
        this.age = age;
        this.score = score;
    }
    
    public function toString():String
    {
        return '$name: ($age, $score)';
    }
}