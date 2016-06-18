package moon.data.list;

//typedef STList<T> = Tuple<T, STList<T>>;
//typedef DTList<T> = Tuple<T, DTList<T>, DTList<T>>;

/**
 * SingleLinkedList
 * 
 * Static methods for direct manipulation of nodes.
 * 
 * Non static methods for accessing data, hiding away the
 * need to manually handle nodes.
 * 
 * The `head` node is a "dummy" node. The first real node
 * starts at `head.next`. The `tail` node isn't a "dummy".
 * 
 * @author Munir Hussin
 */
class SingleLinkedList<T>
{
    public var head:SingleLinkedNode<T>;
    public var tail:SingleLinkedNode<T>;
    
    public var length(default, null):Int;
    public var first(get, set):T;
    public var last(get, set):T;
    public var isEmpty(get, never):Bool;
    
    public function new()
    {
        length = 0;
        
        // sentinel node
        head = new SingleLinkedNode<T>(null);
        tail = null;
    }
    
    /*==================================================
        Static methods
    ==================================================*/
    
    public static inline function firstNode<T>(list:SingleLinkedList<T>):SingleLinkedNode<T>
    {
        return list.head.next;
    }
    
    public static inline function lastNode<T>(list:SingleLinkedList<T>):SingleLinkedNode<T>
    {
        return list.tail;
    }
    
    public static function insertAfter<T>(list:SingleLinkedList<T>, curr:SingleLinkedNode<T>, node:SingleLinkedNode<T>):Void
    {
        if (list.length == 0)
        {
            list.tail = node;
            list.head.next = node;
        }
        else
        {
            // set node's references
            node.next = curr.next;
            
            // update adjacent references
            curr.next = node;
            
            // if we're inserting after the tail, update the tail
            if (curr == list.tail) list.tail = node;
        }
        
        // update length
        ++list.length;
    }
    
    public static inline function insertFirst<T>(list:SingleLinkedList<T>, node:SingleLinkedNode<T>):Void
    {
        insertAfter(list, list.head, node);
    }
    
    public static inline function insertLast<T>(list:SingleLinkedList<T>, node:SingleLinkedNode<T>):Void
    {
        insertAfter(list, list.tail, node);
    }
    
    public static function removeAfter<T>(list:SingleLinkedList<T>, node:SingleLinkedNode<T>):SingleLinkedNode<T>
    {
        var removed = node.next;
        
        if (removed != null)
        {
            node.next = node.next.next;
            
            // if we're removing the tail, update the tail
            if (removed == list.tail) list.tail = node;
            
            --list.length;
        }
        
        return removed;
    }
    
    public static inline function removeFirst<T>(list:SingleLinkedList<T>):SingleLinkedNode<T>
    {
        return removeAfter(list, list.head);
    }
    
    /**
     * O(n)
     */
    public static inline function removeLast<T>(list:SingleLinkedList<T>):SingleLinkedNode<T>
    {
        return list.length <= 1 ?
            removeFirst(list):
            removeAfter(list , nodeAt(list, list.length - 2));
    }
    
    /**
     * Get actual index based on index that allows negative values
     */
    private static inline function absoluteIndex<T>(list:SingleLinkedList<T>, i:Int):Int
    {
        return i < 0 ? list.length + i : i;
    }
    
    /**
     * O(n) Retrieve the node at a particular position
     */
    public static function nodeAt<T>(list:SingleLinkedList<T>, i:Int):SingleLinkedNode<T>
    {
        i = absoluteIndex(list, i);
        
        if (i >= list.length || i < 0)
        {
            return null;
        }
        else
        {
            var curr = firstNode(list);
            while (i-->0)
                curr = curr.next;
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
        return head.next == null ? null : head.next.data;
    }
    
    private inline function set_first(v:T):T
    {
        return head.next == null ? throw "List is empty" : head.next.data = v;
    }
    
    private inline function get_last():T
    {
        return tail == null ? null : tail.data;
    }
    
    private inline function set_last(v:T):T
    {
        return tail == null ? throw "List is empty" : tail.data = v;
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
        insertFirst(this, new SingleLinkedNode<T>(x));
    }
    
    /**
     * O(1) Removes the first element of `this` list and returns it.
     * This operation modifies `this` list in place.
     * If `this` is an empty list, null is returned.
     */
    public function shift():Null<T>
    {
        var node = removeFirst(this);
        return node == null ? null : node.data;
    }
    
    /**
     * O(1) Adds the element `x` at the end of `this` list and returns the new
     * length of `this` list.
     * This operation modifies `this` list in place.
     */
    public function push(x:T):Int
    {
        insertLast(this, new SingleLinkedNode<T>(x));
        return length;
    }
    
    /**
     * O(n) Removes last element of `this` list and returns it.
     * This operation modifies `this` list in place.
     * If `this` is an empty list, null is returned.
     */
    public function pop():Null<T>
    {
        var node = removeLast(this);
        return node == null ? null : node.data;
    }
    
    /**
     * O(1) Concatenates by modifying `this` list, leaving `list` unaffected.
     */
    public function concat(list:SingleLinkedList<T>):Void
    {
        if (length == 0)
        {
            head = list.head;
            tail = list.tail;
        }
        else
        {
            tail.next = list.head.next;
            tail = list.tail;
            length += list.length;
        }
    }
    
    /**
     * O(n) Creates a copy of this list.
     */
    public function clone():SingleLinkedList<T>
    {
        var list = new SingleLinkedList<T>();
        for (v in this)
            list.push(v);
        return list;
    }
    
    /*==================================================
        List access methods
    ==================================================*/
    
    public function iterator():Iterator<T>
    {
        return new SingleLinkedIterator<T>(firstNode(this));
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
    public function map<S>(f:T->S):SingleLinkedList<S>
    {
        var list = new SingleLinkedList<S>();
        for (x in this)
            list.push(f(x));
        return list;
    }
    
    /**
     * Returns a list containing those elements of `this` for which `f`
     * returned true.
     */
    public function filter(f:T->Bool):SingleLinkedList<T>
    {
        var list = new SingleLinkedList<T>();
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
        return "(" + join(" --> ") + ")";
    }
}

class SingleLinkedIterator<T>
{
    public var node:SingleLinkedNode<T>;
    
    public inline function new(first:SingleLinkedNode<T>)
    {
        this.node = first;
    }
    
    public inline function hasNext():Bool
    {
        return node != null;
    }
    
    /**
     * Move pointer to next node and return its value
     */
    public inline function next():T
    {
        var v = node.data;
        node = node.next;
        return v;
    }
    
    /**
     * Returns the value of the next node, without moving the pointer.
     */
    public inline function peek():T
    {
        return node.data;
    }
}

class SingleLinkedNode<T>
{
    public var data:T;
    public var next:SingleLinkedNode<T>;
    
    public function new(data:T)
    {
        this.data = data;
    }
    
    public function toString():String
    {
        var it = new SingleLinkedIterator<T>(this);
        var sbuf = new StringBuf();
        
        sbuf.add("(");
        
        if (it.hasNext())
            sbuf.add(Std.string(it.next()));
        
        for (v in it)
        {
            sbuf.add(" ");
            sbuf.add(Std.string(v));
        }
        
        sbuf.add(")");
        
        return sbuf.toString();
    }
}