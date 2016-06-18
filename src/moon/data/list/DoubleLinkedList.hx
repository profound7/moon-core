package moon.data.list;

/**
 * DoubleLinkedList
 * 
 * Static methods for direct manipulation of nodes, so other classes
 * can make use of DoubleLinkedList in other ways like LRU cache.
 * 
 * Non static methods for accessing data, hiding away the
 * need to manually handle nodes.
 * 
 * The `head` and `tail` nodes are both "dummy" nodes. The real first
 * node is `head.next` and the real last node is `tail.prev`.
 * 
 * @author Munir Hussin
 */
class DoubleLinkedList<T>
{
    public var head:DoubleLinkedNode<T>;
    public var tail:DoubleLinkedNode<T>;
    
    public var length(default, null):Int;
    public var first(get, set):T;
    public var last(get, set):T;
    public var isEmpty(get, never):Bool;
    
    
    public function new()
    {
        length = 0;
        
        // sentinel nodes
        head = new DoubleLinkedNode<T>(null);
        tail = new DoubleLinkedNode<T>(null);
        
        // set initial references
        head.next = tail;
        tail.prev = head;
    }
    
    /*==================================================
        Static methods
    ==================================================*/
    
    public static inline function firstNode<T>(list:DoubleLinkedList<T>):DoubleLinkedNode<T>
    {
        return list.head.next;
    }
    
    public static inline function lastNode<T>(list:DoubleLinkedList<T>):DoubleLinkedNode<T>
    {
        return list.tail.prev;
    }
    
    public static function insertAfter<T>(list:DoubleLinkedList<T>, curr:DoubleLinkedNode<T>, node:DoubleLinkedNode<T>):Void
    {
        // set node's references
        node.prev = curr;
        node.next = curr.next;
        
        // update adjacent references
        curr.next.prev = node;
        curr.next = node;
        
        // update length
        ++list.length;
    }
    
    public static function insertBefore<T>(list:DoubleLinkedList<T>, curr:DoubleLinkedNode<T>, node:DoubleLinkedNode<T>):Void
    {
        // set node's references
        node.next = curr;
        node.prev = curr.prev;
        
        // update adjacent references
        curr.prev.next = node;
        curr.prev = node;
        
        // update length
        ++list.length;
    }
    
    public static inline function insertFirst<T>(list:DoubleLinkedList<T>, node:DoubleLinkedNode<T>):Void
    {
        insertAfter(list, list.head, node);
    }
    
    public static inline function insertLast<T>(list:DoubleLinkedList<T>, node:DoubleLinkedNode<T>):Void
    {
        insertBefore(list, list.tail, node);
    }
    
    public static function removeNode<T>(list:DoubleLinkedList<T>, node:DoubleLinkedNode<T>):Void
    {
        if (list.isEmpty) return;
        
        // link up prev and next nodes together
        node.prev.next = node.next;
        node.next.prev = node.prev;
        
        // update length
        --list.length;
    }
    
    public static inline function removeFirst<T>(list:DoubleLinkedList<T>):DoubleLinkedNode<T>
    {
        var node = list.head.next;
        removeNode(list, node);
        return node;
    }
    
    public static inline function removeLast<T>(list:DoubleLinkedList<T>):DoubleLinkedNode<T>
    {
        var node = list.tail.prev;
        removeNode(list, node);
        return node;
    }
    
    
    /**
     * Get actual index based on index that allows negative values
     */
    private static inline function absoluteIndex<T>(list:DoubleLinkedList<T>, i:Int):Int
    {
        return i < 0 ? list.length + i : i;
    }
    
    private static inline function isIndexInLowerHalf<T>(list:DoubleLinkedList<T>, i:Int):Bool
    {
        return i < (list.length >> 1);
    }
    
    /**
     * O(n) Retrieve the node at a particular position
     */
    public static function nodeAt<T>(list:DoubleLinkedList<T>, i:Int):DoubleLinkedNode<T>
    {
        i = absoluteIndex(list, i);
        
        if (i >= list.length || i < 0)
        {
            return null;
        }
        else
        {
            // optimization: iterate from the nearer direction
            var isLow = isIndexInLowerHalf(list, i);
            var curr:DoubleLinkedNode<T> = isLow ? list.head.next : list.tail.prev;
            
            if (isLow)
            {
                for (idx in 0...i)
                    curr = curr.next;
            }
            else
            {
                for (idx in 0...list.length - i - 1)
                    curr = curr.prev;
            }
            
            return curr;
        }
    }
    
    /*==================================================
        Properties
    ==================================================*/
    
    private inline function get_isEmpty():Bool
    {
        return length == 0;
    }
    
    private inline function get_first():T
    {
        return head.next.data;
    }
    
    private inline function set_first(v:T):T
    {
        return head.next.data = v;
    }
    
    private inline function get_last():T
    {
        return tail.prev.data;
    }
    
    private inline function set_last(v:T):T
    {
        return tail.prev.data = v;
    }
    
    /*==================================================
        List manipulation methods
    ==================================================*/
    
    /**
     * O(1) Adds the element `x` at the start of `this` list.
     * This operation modifies `this` list in place.
     */
    public function unshift(x:T):Void
    {
        insertFirst(this, new DoubleLinkedNode<T>(x));
    }
    
    /**
     * O(1) Removes the first element of `this` list and returns it.
     * This operation modifies `this` list in place.
     * If `this` is an empty list, null is returned.
     */
    public function shift():Null<T>
    {
        return removeFirst(this).data;
    }
    
    /**
     * O(1) Adds the element `x` at the end of `this` list and returns the new
     * length of `this` list.
     * This operation modifies `this` list in place.
     */
    public function push(x:T):Int
    {
        insertLast(this, new DoubleLinkedNode<T>(x));
        return length;
    }
    
    /**
     * O(1) Removes last element of `this` list and returns it.
     * This operation modifies `this` list in place.
     * If `this` is an empty list, null is returned.
     */
    public function pop():Null<T>
    {
        return removeLast(this).data;
    }
    
    /**
     * O(1) Concatenates which modifies both `this` and `list`
     */
    public function concat(list:DoubleLinkedList<T>):Void
    {
        var len = this.length + list.length;
        var aTail = this.tail.prev;
        var bHead = list.head.next;
        
        aTail.next = bHead;
        bHead.prev = aTail;
        
        this.tail = list.tail;
        list.head = this.head;
        
        this.length = len;
        list.length = len;
    }
    
    /**
     * O(n) Creates a copy of this list.
     */
    public function clone():DoubleLinkedList<T>
    {
        var list = new DoubleLinkedList<T>();
        for (v in this)
            list.push(v);
        return list;
    }
    
    /*==================================================
        List access methods
    ==================================================*/
    
    public function iterator():Iterator<T>
    {
        return new DoubleLinkedIterator<T>(this);
    }
    
    public function get(i:Int):Null<T>
    {
        var node = nodeAt(this, i);
        return node == null ? null : node.data;
    }
    
    public function set(i:Int, v:T):T
    {
        var node = nodeAt(this, i);
        return node == null ? throw "Invalid index" : node.data = v;
    }
    
    /*==================================================
        Filters and transformations
    ==================================================*/
    
    /**
     * Creates a new list by applying function `f` to all elements of `this`.
     */
    public function map<S>(f:T->S):DoubleLinkedList<S>
    {
        var list = new DoubleLinkedList<S>();
        for (x in this)
            list.push(f(x));
        return list;
    }
    
    /**
     * Returns a list containing those elements of `this` for which `f`
     * returned true.
     */
    public function filter(f:T->Bool):DoubleLinkedList<T>
    {
        var list = new DoubleLinkedList<T>();
        for (x in this)
            if (f(x))
                list.push(x);
        return list;
    }
    
    /*==================================================
        String methods
    ==================================================*/
    
    /**
     * O(n) Returns a string representation of `this` list with `sep` seperating
     * each element.
     */
    public function join(sep:String):String
    {
        var buf = new StringBuf();
        var it = iterator();
        
        if (it.hasNext()) buf.add(Std.string(it.next()));
        
        for (v in it)
        {
            buf.add(sep);
            buf.add(Std.string(v));
        }
        
        return buf.toString();
    }
    
    /**
     * O(n) Returns a string representation of `this` list.
     */
    public function toString():String
    {
        //return "[" + join(", ") + "]";
        //return "[" + join(", ") + "]" + " " + length + " " + Std.string(first) + ":" + Std.string(last);
        return "(" + join(" <-> ") + ")";
    }
}

class DoubleLinkedIterator<T>
{
    public var list:DoubleLinkedList<T>;
    public var node:DoubleLinkedNode<T>;
    
    public inline function new(list:DoubleLinkedList<T>)
    {
        this.list = list;
        this.node = list.head;
    }
    
    public inline function hasNext():Bool
    {
        return node.next != list.tail;
    }
    
    public inline function hasPrev():Bool
    {
        return node.prev != list.head;
    }
    
    /**
     * Value of current node
     */
    public inline function curr():T
    {
        return node.data;
    }
    
    /**
     * Move pointer to next node and return its value
     */
    public inline function next():T
    {
        node = node.next;
        return node.data;
    }
    
    /**
     * Move pointer to prev node and return its value
     */
    public inline function prev():T
    {
        node = node.prev;
        return node.data;
    }
    
    /**
     * Remove current node.
     */
    public inline function remove(goNext:Bool=true):T
    {
        var data = curr();
        var tmp = goNext ? node.next : node.prev;
        DoubleLinkedList.removeNode(list, node);
        node = tmp;
        return data;
    }
}


class DoubleLinkedNode<T>
{
    public var prev:DoubleLinkedNode<T>;
    public var next:DoubleLinkedNode<T>;
    public var data:T;
    
    public function new(data:T)
    {
        this.data = data;
    }
    
    public inline function unlink():Void
    {
        prev = null;
        next = null;
    }
}