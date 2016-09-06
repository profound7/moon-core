package moon.data.pack;

/**
 * @author Munir Hussin
 */
@:enum abstract PackType(Int) to Int from Int
{
    var PNull           = 0x00;
    var PTrue           = 0x01;
    var PFalse          = 0x02;
    
    // 00000000 00000000 00000000 000000 00
    // 00000000 00000000 00000000 000000 01
    // 00000000 00000000 00000000 000000 10
    // 00000000 00000000 00000000 000000 11
    
    // Pointer
    var PRef8           = 0x10;
    var PRef16          = 0x11;
    var PRef32          = 0x12;
    
    // Int
    var PInt8           = 0x20;     var PIntVal4        = 0x28;
    var PInt16          = 0x21;     var PIntVal5        = 0x29;
    var PInt32          = 0x22;     var PIntVal6        = 0x2A;
    var PInt64          = 0x23;     var PIntVal7        = 0x2B;
    var PIntVal0        = 0x24;     var PIntVal8        = 0x2C;
    var PIntVal1        = 0x25;     var PIntVal9        = 0x2D;
    var PIntVal2        = 0x26;     var PIntVal10       = 0x2E;
    var PIntVal3        = 0x27;     var PIntValNeg1     = 0x2F;
    
    // Float
    var PFloat32        = 0x30;
    var PFloat64        = 0x31;
    var PFloatNaN       = 0x32;
    var PFloatPosInf    = 0x33;
    var PFloatNegInf    = 0x34;
    var PFloatVal0      = 0x35;
    var PFloatVal1      = 0x36;
    var PFloatVal2      = 0x37;
    
    // String
    var PString8        = 0x40;     var PStringLen4     = 0x48;
    var PString16       = 0x41;     var PStringLen5     = 0x49;
    var PString32       = 0x42;     var PStringLen6     = 0x4A;
    var PStringLen0     = 0x43;     var PStringLen7     = 0x4B;
    var PStringLen1     = 0x44;     var PStringLen8     = 0x4C;
    var PStringLen2     = 0x45;     var PStringLen9     = 0x4D;
    var PStringLen3     = 0x46;     var PStringLen10    = 0x4E;
    var PStringLen4     = 0x47;     var PStringLen11    = 0x4F;
    
    // Tag Length Data
    var PArray8         = 0x50;     var PArrayLen5      = 0x58;
    var PArray16        = 0x51;     var PArrayLen6      = 0x59;
    var PArray32        = 0x52;     var PArrayLen7      = 0x5A;
    var PArrayLen0      = 0x53;     var PArrayLen8      = 0x5B;
    var PArrayLen1      = 0x54;     var PArrayLen9      = 0x5C;
    var PArrayLen2      = 0x55;     var PArrayLen10     = 0x5D;
    var PArrayLen3      = 0x56;     var PArrayLen11     = 0x5E;
    var PArrayLen4      = 0x57;     var PArrayLen12     = 0x5F;
    
    var PArray8Int8     = 0x60;     var PArray8IntValN1 = 0x68;
    var PArray8Int16    = 0x61;     var PArray8FltVal0  = 0x69;
    var PArray8Int32    = 0x62;     var PArray8FltVal1  = 0x6A;
    var PArray16Int8    = 0x63;     var PArray8FltValN1 = 0x6B;
    var PArray16Int16   = 0x64;     var PArray8Flt32    = 0x6C;
    var PArray16Int32   = 0x65;     var PArray8Flt64    = 0x6D;
    var PArray8IntVal0  = 0x66;     var PArray16Flt32   = 0x6E;
    var PArray8IntVal1  = 0x67;     var PArray16Flt64   = 0x6F;
    
    var PArray8Str8     = 0x60;
    var PArray8Str16    = 0x61;
    var PArray16Str8    = 0x61;
    var PArray16Str16   = 0x61;
    
    
    // Tag Length Fields Data
    var PObject0        = 0x60;
    var PObject1        = 0x61;
    var PObject8        = 0x62;
    var PObject16       = 0x63;
    var PObject32       = 0x64;
    
    // Tag ObjectRef(Tag Length Fields) Data
    var PObjectRef      = 0x68;
    var PObjectRef1     = 0x69;
    var PObjectRef8     = 0x6A;
    var PObjectRef16    = 0x6B;
    var PObjectRef32    = 0x6C;
    
    // TAG CLASSNAME FIELDS DATA
    // TAG CLASSNAME FIELDSREF DATA
    var PClass0         = 0x70;
    var PClass1         = 0x71;
    var PClass8         = 0x72;
    var PClass16        = 0x73;
    var PClass32        = 0x74;
    var PInstance       = 0x75;
    
    var PStringMapL0    = 0x80;     var PIntMapL0       = 0x88;
    var PStringMapB8    = 0x81;     var PIntMapB8       = 0x89;
    var PStringMapB16   = 0x82;     var PIntMapB16      = 0x8A;
    var PStringMapB32   = 0x83;     var PIntMapB32      = 0x8B;
    
    
    var PObjectMap0     = 0xA0;
    var PObjectMap8     = 0xA1;
    var PObjectMap16    = 0xA2;
    var PObjectMap32    = 0xA3;
    
    var PEnumIndex      = 0xA3;
    var PEnumName       = 0xA3;
    
    var PDate           = 0xB0;
}