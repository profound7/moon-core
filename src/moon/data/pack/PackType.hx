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
    var PInt8           = 0x20;
    var PInt16          = 0x21;
    var PInt32          = 0x22;
    var PInt64          = 0x23;
    
    // Float
    var PFloat32        = 0x30;
    var PFloat64        = 0x31;
    
    // String
    var PString0        = 0x40;
    var PString1        = 0x41;
    var PString8        = 0x42;
    var PString16       = 0x43;
    var PString32       = 0x44;
    
    // Array<T>
    var PArray0         = 0x50;
    var PArray1         = 0x51;
    var PArray8         = 0x52;
    var PArray16        = 0x53;
    var PArray32        = 0x54;
    
    // {}
    var PObject0        = 0x60;
    var PObject1        = 0x61;
    var PObject8        = 0x62;
    var PObject16       = 0x63;
    var PObject32       = 0x64;
    
    // Class<T>
    var PClass0         = 0x70;
    var PClass1         = 0x71;
    var PClass8         = 0x72;
    var PClass16        = 0x73;
    var PClass32        = 0x74;
    var PInstance       = 0x75;
    
    var PStringMap0     = 0x80;
    var PStringMap8     = 0x81;
    var PStringMap16    = 0x82;
    var PStringMap32    = 0x83;
    
    var PIntMap0        = 0x90;
    var PIntMap8        = 0x91;
    var PIntMap16       = 0x92;
    var PIntMap32       = 0x93;
    
    var PObjectMap0     = 0xA0;
    var PObjectMap8     = 0xA1;
    var PObjectMap16    = 0xA2;
    var PObjectMap32    = 0xA3;
}