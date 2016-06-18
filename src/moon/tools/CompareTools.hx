package moon.tools;

import moon.core.Types.Comparable;

/**
 * Used with moon.core.Compare
 * 
 * When a function argument expects a T->T->Bool but you wanna use
 * one of the comparison functions from moon.core.Compare which
 * is in the form of T->T->Int.
 * 
 * @author Munir Hussin
 */
class CompareTools
{
    
    public static inline function equals<T>(cmp:T->T->Int):T->T->Bool
    {
        return function(a:T, b:T):Bool return cmp(a, b) == 0;
    }
    
    public static inline function notEquals<T>(cmp:T->T->Int):T->T->Bool
    {
        return function(a:T, b:T):Bool return cmp(a, b) != 0;
    }
    
    public static inline function greaterThan<T>(cmp:T->T->Int):T->T->Bool
    {
        return function(a:T, b:T):Bool return cmp(a, b) > 0;
    }
    
    public static inline function lesserThan<T>(cmp:T->T->Int):T->T->Bool
    {
        return function(a:T, b:T):Bool return cmp(a, b) < 0;
    }
    
    public static inline function greaterThanOrEqual<T>(cmp:T->T->Int):T->T->Bool
    {
        return function(a:T, b:T):Bool return cmp(a, b) >= 0;
    }
    
    public static inline function lesserThanOrEqual<T>(cmp:T->T->Int):T->T->Bool
    {
        return function(a:T, b:T):Bool return cmp(a, b) <= 0;
    }
    
}


/**
 * Static extension for classes with a compareTo(other:T) method.
 */
class ComparableTools
{
    public static inline function equals<T:Comparable<T>>(a:T, b:T):Bool
    {
        return a.compareTo(b) == 0;
    }
    
    public static inline function notEquals<T:Comparable<T>>(a:T, b:T):Bool
    {
        return a.compareTo(b) != 0;
    }
    
    public static inline function greaterThan<T:Comparable<T>>(a:T, b:T):Bool
    {
        return a.compareTo(b) > 0;
    }
    
    public static inline function lesserThan<T:Comparable<T>>(a:T, b:T):Bool
    {
        return a.compareTo(b) < 0;
    }
    
    public static inline function greaterThanOrEqual<T:Comparable<T>>(a:T, b:T):Bool
    {
        return a.compareTo(b) >= 0;
    }
    
    public static inline function lesserThanOrEqual<T:Comparable<T>>(a:T, b:T):Bool
    {
        return a.compareTo(b) <= 0;
    }
}
