package test.core;

import moon.core.Compare;
import moon.core.Sugar;
import moon.test.TestCase;
import moon.test.TestRunner;

/**
 * ...
 * @author Munir Hussin
 */
@:build(moon.core.Sugar.build())
class CompareTest extends TestCase
{
    public static function main() 
    {
        var r = new TestRunner();
        r.add(new CompareTest());
        r.run();
    }
    
    
    public function testInt()
    {
        var arr1:Array<Int> = [5, 2, 8, 1, 4, 7, 9, 3, 0, 6];
        var arr2:Array<Int> = [5, 2, 8, 1, 4, 7, 9, 3, 0, 6];
        arr1.sort(Compare.asc);
        arr2.sort(Compare.desc);
        
        assert.isDeepEqual([arr1, arr2],
        [
            [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
            [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
        ]);
    }
    
    public function testString()
    {
        var arr1:Array<String> = ["f", "c", "i", "b", "e", "h", "j", "d", "a", "g"];
        var arr2:Array<String> = ["f", "c", "i", "b", "e", "h", "j", "d", "a", "g"];
        arr1.sort(Compare.asc);
        arr2.sort(Compare.desc);
        
        assert.isDeepEqual([arr1, arr2],
        [
            ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"],
            ["j", "i", "h", "g", "f", "e", "d", "c", "b", "a"],
        ]);
    }
    
    public function testNatural()
    {
        var arr1:Array<String> = ["z1.doc", "z10.doc", "z17.doc", "z2.doc", "z23.doc", "z3.doc"];
        var arr2:Array<String> = ["c11", "c1", "c", "b", "c10", "e", "f", "c2", "a", "d"];
        var arr3:Array<String> = ["c11f", "c1", "c", "c11e1", "b", "c10", "c10a", "c11e", "c2", "a", "d"];
        var arr4:Array<String> = ["B", "c", "a", "1", "D"];
        
        arr1.sort(Compare.string(Asc, CaseSensitive, true));
        arr2.sort(Compare.string(Asc, CaseSensitive, true));
        arr3.sort(Compare.string(Asc, CaseSensitive, true));
        arr4.sort(Compare.string(Asc, CaseInsensitive, true));
        
        assert.isDeepEqual([arr1, arr2, arr3, arr4],
        [
            ["z1.doc", "z2.doc", "z3.doc", "z10.doc", "z17.doc", "z23.doc"],
            ["a", "b", "c", "c1", "c2", "c10", "c11", "d", "e", "f"],
            ["a", "b", "c", "c1", "c2", "c10", "c10a", "c11e", "c11e1", "c11f", "d"],
            ["1", "a", "B", "c", "D"],
        ]);
    }
    
    public function testObject()
    {
        var arr1:Array<Dynamic> =
        [
            {street: '350 5th Ave', room: 'A-21046-b'},
            {street: '2100 5th Ave', room: 'A-21046-a'},
            {street: '350 5th Ave', room: 'A-21046' },
            {street: '350 5th Ave', room: 'A-1021'},
        ];
        var arr2:Array<Dynamic> = arr1.copy();
        var arr3:Array<Dynamic> = arr1.copy();
        
        arr1.sort(Compare.map(o => o.room, Compare.string(Asc, CaseSensitive, true)));
        
        arr2.sort([a, b] => @notzero [
            CompareString.naturalAsc(a.street, b.street),
            CompareString.naturalAsc(a.room, b.room)
        ]);
        
        // same as above, but using sugar
        /*arr2.sort(function(a, b)
        {
            // sort by street then by room
            // nonzero is a macro that expands to if-else statements
            // that will return the first nonzero term.
            // in javascript, it's like a || b || c
            return Sugar.notzero
            (
                CompareString.naturalAsc(a.street, b.street),
                CompareString.naturalAsc(a.room, b.room)
            );
        });*/
        
        assert.isDeepEqual([arr1, arr2],
        [
            [
                {street: '350 5th Ave', room: 'A-1021'},
                {street: '350 5th Ave', room: 'A-21046'},
                {street: '2100 5th Ave', room: 'A-21046-a'},
                {street: '350 5th Ave', room: 'A-21046-b'},
            ],
            [
                {street: '350 5th Ave', room: 'A-1021'},
                {street: '350 5th Ave', room: 'A-21046'},
                {street: '350 5th Ave', room: 'A-21046-b' },
                {street: '2100 5th Ave', room: 'A-21046-a'},
            ],
        ]);
    }
}
