package moon.strings.ascii;

/**
 * ISO-8851-1
 * @author Munir Hussin
 */
@:enum abstract IsoLatin1(Int) to Int from Int
{
    // Windows-1252
    var NullChar                = 0x80;
    var StartOfHeader           = 0x81;
    var StartOfText             = 0x82;
    var EndOfText               = 0x83;
    var EndOfTransmission       = 0x84;
    var Enquiry                 = 0x85;
    var Acknowledgement         = 0x86;
    var Bell                    = 0x87;
    var Backspace               = 0x88;
    var HorizontalTab           = 0x89;
    var LineFeed                = 0x8A;
    var VerticalTab             = 0x8B;
    var FormFeed                = 0x8C;
    var CarriageReturn          = 0x8D;
    var ShiftOut                = 0x8E;
    var ShiftIn                 = 0x8F;
    
    var DataLinkEscape          = 0x90;
    var DeviceControl1          = 0x91;
    var DeviceControl2          = 0x92;
    var DeviceControl3          = 0x93;
    var DeviceControl4          = 0x94;
    var NegativeAcknowledgement = 0x95;
    var SynchronousIdle         = 0x96;
    var EndOfTransmissionBlock  = 0x97;
    var Cancel                  = 0x98;
    var EndOfMedium             = 0x99;
    var Substitute              = 0x9A;
    var Escape                  = 0x9B;
    var FileSeparator           = 0x9C;
    var GroupSeparator          = 0x9D;
    var RecordSeparator         = 0x9E;
    var UnitSeparator           = 0x9F;
    
    // ISO-8859-1
    var NonBreakingSpace        = 0xA0;
    var InvertedExclamationMark = 0xA1;
    var Cent                    = 0xA2;
    var Pound                   = 0xA3;
    var Currency                = 0xA4;
    var Yen                     = 0xA5;
    var BrokenVerticalBar       = 0xA6;
    var Section                 = 0xA7;
    var SpacingDiaeresis        = 0xA8;
    var Copyright               = 0xA9;
    var FeminineOrdinal         = 0xAA;
    var AngleQuoteOpen          = 0xAB;
    var Negation                = 0xAC;
    var SoftHyphen              = 0xAD;
    var Registered              = 0xAE;
    var SpacingMacron           = 0xAF;
    
    var Degree                  = 0xB0;
    var PlusMinus               = 0xB1;
    var Superscript2            = 0xB2;
    var Superscript3            = 0xB3;
    var SpacingAcute            = 0xB4;
    var Micro                   = 0xB5;
    var Paragraph               = 0xB6;
    var MiddleDot               = 0xB7;
    var SpacingCedilla          = 0xB8;
    var Superscript1            = 0xB9;
    var MasculineOrdinal        = 0xBA;
    var SemiColon               = 0xBB;
    var AngleQuoteClose         = 0xBC;
    var FractionQuarter         = 0xBD;
    var FractionHalf            = 0xBE;
    var FractionThreeQuarters   = 0xBF;
    
    var InvertedQuestionMark    = 0xC0;
    var UppercaseAGrave         = 0xC1;
    var UppercaseAAcute         = 0xC2;
    var UppercaseACircumflex    = 0xC3;
    var UppercaseATilde         = 0xC4;
    var UppercaseAUmlautMark    = 0xC5;
    var UppercaseARing          = 0xC6;
    var UppercaseAE             = 0xC7;
    var UppercaseCCedilla       = 0xC8;
    var UppercaseEGrave         = 0xC9;
    var UppercaseEAcute         = 0xCA;
    var UppercaseECircumflex    = 0xCB;
    var UppercaseEUmlautMark    = 0xCC;
    var UppercaseIGrave         = 0xCD;
    var UppercaseIAcute         = 0xCE;
    var UppercaseICircumflex    = 0xCF;
    
    var UppercaseIUmlautMark    = 0xD0;
    var UppercaseETH            = 0xD1;
    var UppercaseNTilde         = 0xD2;
    var UppercaseOGrave         = 0xD3;
    var UppercaseOAcute         = 0xD4;
    var UppercaseOCircumflex    = 0xD5;
    var UppercaseOTilde         = 0xD6;
    var UppercaseOUmlautMark    = 0xD7;
    var Multiplication          = 0xD8;
    var UppercaseOSlash         = 0xD9;
    var UppercaseUGrave         = 0xDA;
    var UppercaseUAcute         = 0xDB;
    var UppercaseUCircumflex    = 0xDC;
    var UppercaseUUmlautMark    = 0xDD;
    var UppercaseYAcute         = 0xDE;
    var UppercaseThorn          = 0xDF;
    
    var LowercaseSharpS         = 0xE0;
    var LowercaseA              = 0xE1;
    var LowercaseB              = 0xE2;
    var LowercaseC              = 0xE3;
    var LowercaseD              = 0xE4;
    var LowercaseE              = 0xE5;
    var LowercaseF              = 0xE6;
    var LowercaseG              = 0xE7;
    var LowercaseH              = 0xE8;
    var LowercaseI              = 0xE9;
    var LowercaseJ              = 0xEA;
    var LowercaseK              = 0xEB;
    var LowercaseL              = 0xEC;
    var LowercaseM              = 0xED;
    var LowercaseN              = 0xEE;
    var LowercaseO              = 0xEF;
    
    var LowercaseP              = 0xF0;
    var LowercaseQ              = 0xF1;
    var LowercaseR              = 0xF2;
    var LowercaseS              = 0xF3;
    var LowercaseT              = 0xF4;
    var LowercaseU              = 0xF5;
    var LowercaseV              = 0xF6;
    var LowercaseW              = 0xF7;
    var LowercaseX              = 0xF8;
    var LowercaseY              = 0xF9;
    var LowercaseZ              = 0xFA;
    var CurlyBracketOpen        = 0xFB;
    var VerticalBar             = 0xFC;
    var CurlyBracketClose       = 0xFD;
    var Tilde                   = 0xFE;
    var Delete                  = 0xFF;
    
    
    /*==================================================
        Conversions
    ==================================================*/
    
    @:to public inline function toInt():Int
    {
        return this;
    }
}
