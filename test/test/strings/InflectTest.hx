package test.strings;

import moon.strings.Inflect;
import moon.test.TestCase;
import moon.test.TestRunner;

/**
 * ...
 * @author Munir Hussin
 */
class InflectTest extends TestCase
{
    public static function main() 
    {
        var r = new TestRunner();
        r.add(new InflectTest());
        r.run();
    }
    
    public function testOps()
    {
        assert.isEqual(Inflect.upper("HeLlO wOrLd"), "HELLO WORLD");
        assert.isEqual(Inflect.lower("HeLlO wOrLd"), "hello world");
        assert.isEqual(Inflect.ucfirst("heLlO wOrLd"), "HeLlO wOrLd");
        assert.isEqual(Inflect.lcfirst("HeLlO wOrLd"), "heLlO wOrLd");
        assert.isEqual(Inflect.proper("HeLlO wOrLd"), "Hello world");
    }
    
    public function testWords()
    {
        assert.isEqual(Inflect.ucwords("HeLlO wOrLd"), "HeLlO WOrLd");
        assert.isEqual(Inflect.lcwords("HeLlO wOrLd"), "heLlO wOrLd");
        assert.isEqual(Inflect.title("HeLlO wOrLd"), "Hello World");
    }
    
    public function testDecamel()
    {
        var a =
        [
            "TodayILiveInTheUSAWithSimon",
            "USAToday",
            "IAmSOOOBored",
        ];
        
        var r = a.map(Inflect.decamel);
        
        assert.isDeepEqual(r,
        [
            ["Today", "I", "Live", "In", "The", "USA", "With", "Simon"],
            ["USA", "Today"],
            ["I", "Am", "SOOO", "Bored"],
        ]);
    }
    
    public function inflect(c1:InflectCase, c2:InflectCase)
    {
        return function (s:String):String
        {
            return Inflect.inflect(s, c1, c2);
        }
    }
    
    /*public function testInflect()
    {
        var base =
        [
            "TodayILiveInTheUSAWithSimon",
            "USAToday",
            "IAmSOOOBored",
        ];
        
        var pascal =
        [
            "TodayILiveInTheUsaWithSimon",
            "UsaToday",
            "IAmSoooBored",
        ];
        
        var camel =
        [
            "todayILiveInTheUsaWithSimon",
            "usaToday",
            "iAmSoooBored",
        ];
        
        var kebab =
        [
            "today-i-live-in-the-usa-with-simon",
            "usa-today",
            "i-am-sooo-bored",
        ];
        
        var skebab =
        [
            "TODAY-I-LIVE-IN-THE-USA-WITH-SIMON",
            "USA-TODAY",
            "I-AM-SOOO-BORED",
        ];
        
        var train =
        [
            "Today-I-Live-In-The-Usa-With-Simon",
            "Usa-Today",
            "I-Am-Sooo-Bored",
        ];
        
        var r_camel = base.map(inflect(PascalCase, CamelCase));
        var r_kebab = base.map(inflect(PascalCase, KebabCase));
        var r_skebab = base.map(inflect(PascalCase, ScreamingKebabCase));
        var r_train = base.map(inflect(PascalCase, TrainCase));
        
        assert.isDeepEqual(camel, r_camel);
        assert.isDeepEqual(kebab, r_kebab);
    }*/
}

