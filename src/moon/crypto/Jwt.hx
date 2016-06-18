package moon.crypto;

import haxe.Json;
import moon.core.Struct;

/**
 * Json Web Tokens
 * http://jwt.io/
 * https://developer.atlassian.com/static/connect/docs/latest/concepts/understanding-jwt.html
 * 
 * I've implemented checks to ensure an attacker cannot bypass validation
 * by changing algo to `none` as described in the following article:
 * https://auth0.com/blog/2015/03/31/critical-vulnerabilities-in-json-web-token-libraries/
 * 
 * No asymmetric-based algo (RSA, elliptic curve) is currently supported
 * as haxe does not have any standard cross-platform solutions yet.
 * 
 * IMPORTANT:
 * JWT does NOT encrypt the payload.
 * The client can read the data in the payload.
 * JWT just signs the payload, so it can be checked for modifications/tampering.
 * DO NOT put sensitive or non-public information in the payload.
 * 
 * Usage:
 * // server: issuing token
 * var secret:String = "change me";
 * var duration:Int = 1000 * 60 * 5; // 5 mins
 * var expiry:Date = DateTools.delta(Date.now(), duration);
 * var data:Dynamic = { uid: 123, foo: "bar" };
 * var token:String = Jwt.encode("hs256", secret, expiry, null, data);
 * // send `token` to the client
 * 
 * // client: keeps the token and uses it for subsequent requests
 * 
 * // server: when receive request from the client, validate token first
 * var data:Struct = Jwt.decode(token, secret);
 * // if there's a problem with the token, an error is thrown
 * 
 * @author Munir Hussin
 */
class Jwt
{
    /**
     * Signs a message using the specified algorithm.
     */
    public static function sign(msg:String, algo:String, secret:String):String
    {
        return Base64.urlEncode(switch (algo.toLowerCase())
        {
            case "hs256": Hmac.of("sha256").make(secret, msg);
            case "none": "";
            case _: throw "Unsupported JWT algorithm";
        });
    }
    
    /**
     * Utility method to get time in seconds from a given date.
     */
    public static inline function getTime(date:Date):Int
    {
        return Std.int(date.getTime() / 1000.0);
    }
    
    /**
     * Create a web token based on the payload and arguments given.
     * 
     * @param algo          hs256 or none
     * @param secret        a secret key known only to the issuer
     * @param expiry        token is valid only before this date
     * @param notBefore     token is valid only after this date
     * @param payload       the PUBLIC data you wish to send
     * @return              returns a signed token
     */
    public static function encode(algo:String, secret:String, ?expiry:Date,
        ?notBefore:Date, payload:Struct):String
    {
        var header:JwtHeader = { alg: algo, typ: "JWT" };
        
        payload["iat"] = getTime(Date.now());
        if (expiry != null) payload["exp"] = getTime(expiry);
        if (notBefore != null) payload["nbf"] = getTime(notBefore);
        
        var h:String = Base64.urlEncode(Json.stringify(header));
        var p:String = Base64.urlEncode(Json.stringify(payload));
        
        var hp:String = '$h.$p';
        var s:String = sign(hp, header.alg, secret);
        
        return '$hp.$s';
    }
    
    /**
     * Extract the header, payload and signature from the token.
     * This does not validate the data within the info.
     */
    public static function extract(token:String):JwtInfo
    {
        return new JwtInfo(token);
    }
    
    /**
     * Retrieve the token that was created using encode().
     * 
     * If secret is given, verification checks will be made against
     * the token, and will throw an error when any of the checks failed.
     * 
     * If secret is not given, you can retrieve the payload (since it's
     * public anyway), however you won't know if the token is valid
     * or forged.
     * 
     * @param token
     * @param secret
     * @return
     */
    public static function decode(token:String, ?secret:String):Struct
    {
        var info:JwtInfo = new JwtInfo(token);
        
        // if secret is given, we MUST validate
        if (secret != null)
        {
            info.validate(secret);
        }
        
        // OK!
        return info.payload;
    }
}

typedef JwtHeader =
{
    var alg:String;
    var typ:String;
}

typedef JwtPayload =
{
    @:optional var iss:String;  // issuer of token
    
    @:optional var iat:Int;     // time issued. can be used to determine age of jwt
    @:optional var exp:Int;     // expiration in NumericDate value
    @:optional var nbf:Int;     // defines the time before which the jwt must NOT be accepted
    
    @:optional var sub:String;  // subject of token
    @:optional var aud:String;  // audience of token
    @:optional var jti:String;  // unique identifier, for one time use token
}

class JwtInfo
{
    public var token:String;
    public var parts:Array<String>;
    public var header:Struct;
    public var payload:Struct;
    public var signature:String;
    
    public function new(token:String)
    {
        this.token = token;
        
        if (token == null)
            throw "Invalid token";
            
        parts = token.split(".");
        
        if (parts.length != 3)
            throw "Invalid token";
        
        header = Json.parse(Base64.urlDecode(parts[0]));
        payload = Json.parse(Base64.urlDecode(parts[1]));
        signature = parts[2];
    }
    
    
    public function validate(secret:String):Void
    {
        if (secret == null)
            throw "Secret not provided";
            
        if (!header.exists("alg"))
            throw "No algorithm was specified in the header";
            
        // prevent attack of removing signatures
        if (header["alg"] == "none")
            throw "Algorithm none cannot be used when secret is given.";
        
        // verify signature to see if token has been tampered
        var hp = parts[0] + "." + parts[1];
        var s:String = Jwt.sign(hp, header["alg"], secret);
        var now = Jwt.getTime(Date.now());
        
        if (s != signature)
            throw "Invalid signature";
        
        if (payload.exists("iat"))
        {
            if (payload["iat"] > now)
                throw "Invalid issued at time";
            else if (payload.exists("exp") && payload["exp"] < payload["iat"])
                throw "Invalid issued at time";
        }
            
        if (payload.exists("exp") && payload["exp"] < now)
            throw "Token has expired";
        
        if (payload.exists("nbf") && payload["nbf"] > now)
            throw "Token cannot be used yet";
    }
    
    public function hasExpired():Bool
    {
        return payload.exists("exp") && payload["exp"] < Jwt.getTime(Date.now());
    }
    
    public function hasNotActivated():Bool
    {
        return payload.exists("nbf") && payload["nbf"] > Jwt.getTime(Date.now());
    }
    
    public function isActive():Bool
    {
        return !hasExpired() && !hasNotActivated();
    }
}