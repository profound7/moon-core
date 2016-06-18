package moon.strings.metric;

import moon.core.Char;
import moon.data.array.HyperArray;

using StringTools;

/**
 * Computes the difference between 2 strings.
 * No difference is 0. The more the difference is, the bigger the number.
 * 
 * https://github.com/KevinStern/software-and-algorithms/blob/master/src/main/java/blogspot/software_and_algorithms/stern_library/string/DamerauLevenshteinAlgorithm.java
 * 
 * @author Kevin L. Stern (java original)
 * @author Munir Hussin (haxe port)
 */
class DamerauLevenshtein
{
    public var deleteCost:Int;
    public var insertCost:Int;
    public var replaceCost:Int;
    public var swapCost:Int;
    
    public function new(deleteCost:Int, insertCost:Int, replaceCost:Int, swapCost:Int)
    {
        if (2 * swapCost < insertCost + deleteCost)
            throw "Unsupported cost assignment";
        
        this.deleteCost = deleteCost;
        this.insertCost = insertCost;
        this.replaceCost = replaceCost;
        this.swapCost = swapCost;
    }
    
    public function execute(source:String, target:String):Int
    {
        var infinity:Int = source.length + target.length;
        
        if (source.length == 0)
            return target.length * insertCost;
        
        if (target.length == 0)
            return source.length * deleteCost;
            
        var table:HyperArray<Int> = new HyperArray<Int>([source.length, target.length], 0);
        var sourceIndexByCharacter:Map<Char, Int> = new Map<Char, Int>();
        
        if (source.fastCodeAt(0) != target.fastCodeAt(0))
        {
            table.set([0, 0], Std.int(Math.min(replaceCost, deleteCost + insertCost)));
        }
        
        sourceIndexByCharacter[source.charAt(0)] = 0;
        
        for (i in 1...source.length)
        {
            var deleteDistance:Int = table.get([i - 1, 0]) + deleteCost;
            var insertDistance:Int = (i + 1) * deleteCost + insertCost;
            var matchDistance:Int = i * deleteCost
                + (source.fastCodeAt(i) == target.fastCodeAt(0) ? 0 : replaceCost);
                
            table.set([i, 0], Std.int(Math.min(Math.min(deleteDistance, insertDistance), matchDistance)));
        }
        
        for (j in 1...target.length)
        {
            var deleteDistance:Int = (j + 1) * insertCost + deleteCost;
            var insertDistance:Int = table.get([0, j - 1]) + insertCost;
            var matchDistance:Int = j * insertCost
                    + (source.fastCodeAt(0) == target.fastCodeAt(j) ? 0 : replaceCost);
            table.set([0, j], Std.int(Math.min(Math.min(deleteDistance, insertDistance), matchDistance)));
        }
        
        for (i in 1...source.length)
        {
            var maxSourceLetterMatchIndex:Int = source.fastCodeAt(i) == target.fastCodeAt(0) ? 0 : -1;
            
            for (j in 1...target.length)
            {
                var candidateSwapIndex:Int = sourceIndexByCharacter[target.charAt(j)];
                var jSwap:Int = maxSourceLetterMatchIndex;
                var deleteDistance:Int = table.get([i - 1, j]) + deleteCost;
                var insertDistance:Int = table.get([i, j - 1]) + insertCost;
                var matchDistance:Int = table.get([i - 1, j - 1]);
                
                if (source.fastCodeAt(i) != target.fastCodeAt(j))
                    matchDistance += replaceCost;
                else
                    maxSourceLetterMatchIndex = j;
                
                var swapDistance:Int;
                
                if (candidateSwapIndex != null && jSwap != -1)
                {
                    var iSwap:Int = candidateSwapIndex;
                    var preSwapCost:Int;
                    
                    if (iSwap == 0 && jSwap == 0)
                        preSwapCost = 0;
                    else
                        preSwapCost = table.get([Std.int(Math.max(0, iSwap - 1)), Std.int(Math.max(0, jSwap - 1))]);
                        
                    swapDistance = preSwapCost + (i - iSwap - 1) * deleteCost
                            + (j - jSwap - 1) * insertCost + swapCost;
                }
                else
                {
                    swapDistance = infinity;
                }
                
                table.set([i, j], Std.int(Math.min(Math.min(Math.min(deleteDistance, insertDistance),
                    matchDistance), swapDistance)));
            }
            
            sourceIndexByCharacter[source.charAt(i)] = i;
        }
        
        return table.get([source.length - 1, target.length - 1]);
    }
    
}