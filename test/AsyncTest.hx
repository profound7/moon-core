package;

import AsyncSugaredExamples;

/**
 * ...
 * @author Munir Hussin
 */
class AsyncTest
{
    public static function main()
    {
        test();
    }
    
    public static function test(greet:String, msg:String):Iterator<String>
    {
        var __started:Bool = false;
        var __state:Int = 0;
        var __current:String = null;
        var __generator:Iterator<String> = null;
        var __var_alice_20196:AsyncSugaredExamples.Worker = null;
        var __var_dave_20199:AsyncSugaredExamples.Worker = null;
        var __var_bob_20197:AsyncSugaredExamples.Worker = null;
        var __var_carol_20198:AsyncSugaredExamples.Worker = null;
        var __var___yield___20192:String -> StdTypes.Void = null;
        var __var_name_20211:String = null;
        var __var_workers_20210:Array<AsyncSugaredExamples.Worker> = null;
        var __tmp_20201:StdTypes.Int = 0;
        var __tmp_20202:Array<AsyncSugaredExamples.Worker> = null;
        var __var_p_20200:AsyncSugaredExamples.Worker = null;
        var __set_cond_1 = null;
        var __set_ret_2 = null;
        function __run():Void while (true) {
            switch (__state) {
                case -1:{
                    throw moon.core.Async.AsyncException.FunctionEnded;
                };
                case 0:{
                    __var_alice_20196 = Worker.Employee("aliceaaa");
                    __var_bob_20197 = Worker.Employee("bob");
                    __var_carol_20198 = Worker.Employee("carol");
                    __var_dave_20199 = Worker.Manager("dave", [__var_alice_20196, __var_bob_20197, __var_carol_20198]);
                    __tmp_20201 = 0;
                    __tmp_20201 = [__var_alice_20196, __var_bob_20197, __var_carol_20198, __var_dave_20199];
                };
                case 1:{
                    __set_cond_1 = __tmp_20201 < __tmp_20202.length;
                    if (!__set_cond_1) {
                        __state = 11;
                        continue;
                    };
                    __var_p_20200 = __tmp_20202[__tmp_20201];
                    ++__tmp_20201;
                    switch @:exhaustive __var_p_20200.getIndex() {
                        case 0:{
                            __state = 2;
                            continue;
                        };
                        case 1:{
                            __state = 8;
                            continue;
                        };
                    };
                    {
                        __state = 10;
                        continue;
                    };
                };
                case 2:{
                    switch __var_p_20200.getParameters()[0] {
                        case "alice", "bob":{
                            __state = 3;
                            continue;
                        };
                        default:{
                            __state = 5;
                            continue;
                        };
                    };
                    {
                        __state = 7;
                        continue;
                    };
                };
                case 3:{
                    __current = (greet + " " + "! " + msg);
                    __state = 4;
                    return;
                };
                case 4:{
                    __set_ret_2 = @void if (false) null;
                    {
                        __state = 7;
                        continue;
                    };
                };
                case 5:{
                    __current = "hello";
                    __state = 6;
                    return;
                };
                case 6:{ };
                case 7:{
                    __set_ret_2;
                    {
                        __state = 10;
                        continue;
                    };
                };
                case 8:{
                    __var_workers_20210 = __var_p_20200.getParameters()[1];
                    __var_name_20211 = __var_p_20200.getParameters()[0];
                    __current = (greet + " " + __var_name_20211 + "! How are " + __var_workers_20210.join(",") + " doing?");
                    __state = 9;
                    return;
                };
                case 9:{
                    {
                        __state = 10;
                        continue;
                    };
                };
                case 10:{
                    {
                        __state = 1;
                        continue;
                    };
                };
                case 11:{ };
                case 12:{
                    __state = -1;
                    return;
                };
                default:{
                    throw moon.core.Async.AsyncException.InvalidState(__state);
                };
            };
            ++__state;
        };
        function __hasNext() {
            return __state >= 0;
        };
        function __next() {
            if (__started) {
                var tmp = __current;
                __run();
                return tmp;
            } else {
                __started = true;
                __run();
                return __next();
            };
        };
        __generator = { hasNext : __hasNext, next : __next };
        return __generator;
    }
    
}