package moon.strings.ascii;

/**
 * Ascii character codes
 * @author Munir Hussin
 */
@:enum abstract Ascii(Int) to Int from Int
{
    var NullChar                = 0x00;
    var StartOfHeader           = 0x01;
    var StartOfText             = 0x02;
    var EndOfText               = 0x03;
    var EndOfTransmission       = 0x04;
    var Enquiry                 = 0x05;
    var Acknowledgement         = 0x06;
    var Bell                    = 0x07;
    var Backspace               = 0x08;
    var HorizontalTab           = 0x09;
    var LineFeed                = 0x0A;
    var VerticalTab             = 0x0B;
    var FormFeed                = 0x0C;
    var CarriageReturn          = 0x0D;
    var ShiftOut                = 0x0E;
    var ShiftIn                 = 0x0F;
    
    var DataLinkEscape          = 0x10;
    var DeviceControl1          = 0x11;
    var DeviceControl2          = 0x12;
    var DeviceControl3          = 0x13;
    var DeviceControl4          = 0x14;
    var NegativeAcknowledgement = 0x15;
    var SynchronousIdle         = 0x16;
    var EndOfTransmissionBlock  = 0x17;
    var Cancel                  = 0x18;
    var EndOfMedium             = 0x19;
    var Substitute              = 0x1A;
    var Escape                  = 0x1B;
    var FileSeparator           = 0x1C;
    var GroupSeparator          = 0x1D;
    var RecordSeparator         = 0x1E;
    var UnitSeparator           = 0x1F;
    
    var Space                   = 0x20;
    var ExclamationMark         = 0x21;
    var DoubleQuote             = 0x22;
    var Hash                    = 0x23;
    var Dollar                  = 0x24;
    var Percent                 = 0x25;
    var Ampersand               = 0x26;
    var Quote                   = 0x27;
    var BracketOpen             = 0x28;
    var BracketClose            = 0x29;
    var Asterisk                = 0x2A;
    var Plus                    = 0x2B;
    var Comma                   = 0x2C;
    var Minus                   = 0x2D;
    var Period                  = 0x2E;
    var Slash                   = 0x2F;
    
    var Digit0                  = 0x30;
    var Digit1                  = 0x31;
    var Digit2                  = 0x32;
    var Digit3                  = 0x33;
    var Digit4                  = 0x34;
    var Digit5                  = 0x35;
    var Digit6                  = 0x36;
    var Digit7                  = 0x37;
    var Digit8                  = 0x38;
    var Digit9                  = 0x39;
    var Colon                   = 0x3A;
    var SemiColon               = 0x3B;
    var LessThan                = 0x3C;
    var Equals                  = 0x3D;
    var GreaterThan             = 0x3E;
    var QuestionMark            = 0x3F;
    
    var At                      = 0x40;
    var UppercaseA              = 0x41;
    var UppercaseB              = 0x42;
    var UppercaseC              = 0x43;
    var UppercaseD              = 0x44;
    var UppercaseE              = 0x45;
    var UppercaseF              = 0x46;
    var UppercaseG              = 0x47;
    var UppercaseH              = 0x48;
    var UppercaseI              = 0x49;
    var UppercaseJ              = 0x4A;
    var UppercaseK              = 0x4B;
    var UppercaseL              = 0x4C;
    var UppercaseM              = 0x4D;
    var UppercaseN              = 0x4E;
    var UppercaseO              = 0x4F;
    
    var UppercaseP              = 0x50;
    var UppercaseQ              = 0x51;
    var UppercaseR              = 0x52;
    var UppercaseS              = 0x53;
    var UppercaseT              = 0x54;
    var UppercaseU              = 0x55;
    var UppercaseV              = 0x56;
    var UppercaseW              = 0x57;
    var UppercaseX              = 0x58;
    var UppercaseY              = 0x59;
    var UppercaseZ              = 0x5A;
    var SquareBracketOpen       = 0x5B;
    var Backslash               = 0x5C;
    var SquareBracketClose      = 0x5D;
    var Caret                   = 0x5E;
    var Underscore              = 0x5F;
    
    var GraveAccent             = 0x60;
    var LowercaseA              = 0x61;
    var LowercaseB              = 0x62;
    var LowercaseC              = 0x63;
    var LowercaseD              = 0x64;
    var LowercaseE              = 0x65;
    var LowercaseF              = 0x66;
    var LowercaseG              = 0x67;
    var LowercaseH              = 0x68;
    var LowercaseI              = 0x69;
    var LowercaseJ              = 0x6A;
    var LowercaseK              = 0x6B;
    var LowercaseL              = 0x6C;
    var LowercaseM              = 0x6D;
    var LowercaseN              = 0x6E;
    var LowercaseO              = 0x6F;
    
    var LowercaseP              = 0x70;
    var LowercaseQ              = 0x71;
    var LowercaseR              = 0x72;
    var LowercaseS              = 0x73;
    var LowercaseT              = 0x74;
    var LowercaseU              = 0x75;
    var LowercaseV              = 0x76;
    var LowercaseW              = 0x77;
    var LowercaseX              = 0x78;
    var LowercaseY              = 0x79;
    var LowercaseZ              = 0x7A;
    var CurlyBracketOpen        = 0x7B;
    var VerticalBar             = 0x7C;
    var CurlyBracketClose       = 0x7D;
    var Tilde                   = 0x7E;
    var Delete                  = 0x7F;
    
    
    /*==================================================
        Conversions
    ==================================================*/
    
    @:to public inline function toInt():Int
    {
        return this;
    }
}
