package moon.web;

/**
 * List of common charsets
 * @author Munir Hussin
 */
@:enum abstract Charset(String) to String from String
{
    var Unicode     = "UTF-8";
    var Chinese     = "gb2312";
    var Czech       = "windows-1250";
    var Dutch       = "iso-8859-1";
    var English     = "iso-8859-1";
    var French      = "windows-1252";
    var Finnish     = "windows-1252";
    var German      = "iso-8859-1";
    var Greek       = "windows-1253";
    var Italian     = "iso-8859-1";
    var Japanese    = "shift-jis";
    var Portuguese  = "iso-8859-1";
    var Russian     = "windows-1251";
    var Spanish     = "iso-8859-1";
}