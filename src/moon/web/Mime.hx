package moon.web;

import moon.core.Struct;

/**
 * List of common mime types
 * @author Munir Hussin
 */
@:enum abstract Mime(String) to String from String
{
    // apps
    var AppAtom             = 'application/atom+xml';
    var AppEcmascript       = 'application/ecmascript';
    var AppJson             = 'application/json';
    var AppJavaScript       = 'application/javascript';
    var AppBinary           = 'application/octet-stream';
    var AppOgg              = 'application/ogg';
    var AppPdf              = 'application/pdf';
    var AppPostscript       = 'application/postscript';
    var AppRdf              = 'application/rdf+xml';
    var AppRss              = 'application/rss+xml';
    var AppRtf              = 'application/rtf';
    var AppSoap             = 'application/soap+xml';
    var AppWoff             = 'application/font-woff';
    var AppXhtml            = 'application/xhtml+xml';
    var AppXml              = 'application/xml';
    var AppDtd              = 'application/xml-dtd';
    var AppXop              = 'application/xop+xml';
    var AppZip              = 'application/zip';
    var AppGzip             = 'application/gzip';
    var AppDownload         = 'application/force-download';
    
    var Appx7z              = 'application/x-7z-compressed';
    var AppxTtf             = 'application/x-font-ttf';
    var AppxJavaScript      = 'application/x-javascript';
    var AppxLatex           = 'application/x-latex';
    var AppxMsDownload      = 'application/x-msdownload';
    var AppxRar             = 'application/x-rar-compressed';
    var AppxFlash           = 'application/x-shockwave-flash';
    var AppxStuffit         = 'application/x-stuffit';
    var AppxTar             = 'application/x-tar';
    var AppxForm            = 'application/x-www-form-urlencoded';
    
    
    // audio
    var AudioMulaw          = 'audio/basic';
    var AudioPcm            = 'audio/L24';
    var AudioMp4            = 'audio/mp4';
    var AudioMpeg           = 'audio/mpeg';
    var AudioOgg            = 'audio/ogg';
    var AudioVorbis         = 'audio/vorbis';
    var AudioRealAudio      = 'audio/vnd.rn-realaudio';
    var AudioWav            = 'audio/vnd.wave';
    var AudioWebm           = 'audio/webm';
    
    var AudioxAac           = 'audio/x-aac';
    var AudioxCaf           = 'audio/x-caf';
    
    
    // images
    var ImageBmp            = 'image/bmp';
    var ImageGif            = 'image/gif';
    var ImageJpeg           = 'image/jpeg';
    var ImagePjpeg          = 'image/pjpeg';
    var ImagePng            = 'image/png';
    var ImageSvg            = 'image/svg+xml';
    var ImageTiff           = 'image/tiff';
    var ImageIco            = 'image/vnd.microsoft.icon';
    
    var ImagexPng           = 'image/x-png';
    var ImagexGimp          = 'image/x-xcf';
    
    
    // message
    var MsgHttp             = 'message/http';
    var MsgImdn             = 'message/imdn+xml';
    var MsgPartial          = 'message/partial';
    var MsgEml              = 'message/rfc822';
    var MsgMhtml            = 'message/rfc822';
    
    
    // 3d models
    var ModelExample        = 'model/example';
    var ModelIges           = 'model/iges';
    var ModelMesh           = 'model/mesh';
    var ModelVrml           = 'model/vrml';
    var ModelX3db           = 'model/x3d+binary';
    var ModelX3dv           = 'model/x3d+vrml';
    var ModelX3d            = 'model/x3d+xml';
    
    
    // multipart
    var MultipartMixed      = 'multipart/mixed';
    var MultipartAlt        = 'multipart/alternative';
    var MultipartRelated    = 'multipart/related';
    var MultipartForm       = 'multipart/form-data';
    var MultipartSigned     = 'multipart/signed';
    var MultipartEncrypted  = 'multipart/encrypted';
    
    
    // text
    var TextCommand         = 'text/cmd';
    var TextCss             = 'text/css';
    var TextCsv             = 'text/csv';
    var TextHtml            = 'text/html';
    var TextJavaScript      = 'text/javascript';    // obsolete
    var TextLess            = 'text/less';
    var TextOrbit           = 'text/orbit';
    var TextPlain           = 'text/plain';
    var TextVcard           = 'text/vcard';
    var TextXml             = 'text/xml';
    
    var TextxJqueryTmpl     = 'text/x-jquery-tmpl';
    
    
    // video
    var VideoAvi            = 'video/avi';
    var VideoMpeg           = 'video/mpeg';
    var VideoMp4            = 'video/mp4';
    var VideoOgg            = 'video/ogg';
    var VideoQuicktime      = 'video/quicktime';
    var VideoWebm           = 'video/webm';
    var VideoxFlv           = 'video/x-flv';
    var VideoxMatroska      = 'video/x-matroska';
    var VideoxWmv           = 'video/x-ms-wmv';
    
    
    // adobe
    var AdobePhotoshop      = 'image/vnd.adobe.photoshop';
    
    // microsoft
    var MicrosoftCabinet        = 'application/vnd.ms-cab-compressed';
    var MicrosoftWord           = 'application/msword';
    var MicrosoftExcel          = 'application/vnd.ms-excel';
    var MicrosoftPowerpoint     = 'application/vnd.ms-powerpoint';
    var MicrosoftExcelXml       = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    var MicrosoftPowerpointXml  = 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    var MicrosoftWordXml        = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    
    // open office
    var OasisText           = 'application/vnd.oasis.opendocument.text';
    var OasisDrawing        = 'application/vnd.oasis.opendocument.graphics';
    var OasisPresentation   = 'application/vnd.oasis.opendocument.presentation';
    var OasisSpreadsheet    = 'application/vnd.oasis.opendocument.spreadsheet';
    var OasisChart          = 'application/vnd.oasis.opendocument.chart';
    var OasisFormula        = 'application/vnd.oasis.opendocument.formula';
    var OasisDatabase       = 'application/vnd.oasis.opendocument.database';
    var OasisImage          = 'application/vnd.oasis.opendocument.image';
    
    
    public static var extensions:Struct;
    
    
    public static function __init__()
    {
        extensions =
        {
            // common
            html:   TextHtml,
            htm:    TextHtml,
            txt:    TextPlain,
            php:    TextHtml,
            css:    TextCss,
            js:     AppJavaScript,
            json:   AppJson,
            xml:    AppXml,
            swf:    AppxFlash,
            orb:    TextOrbit,
            
            // images
            bmp:    ImageBmp,
            gif:    ImageGif,
            jpeg:   ImageJpeg,
            jpg:    ImageJpeg,
            jpe:    ImageJpeg,
            png:    ImagePng,
            svg:    ImageSvg,
            svgz:   ImageSvg,
            tiff:   ImageTiff,
            tif:    ImageTiff,
            ico:    ImageIco,
            
            // archives
            zip:    AppZip,
            rar:    AppxRar,
            exe:    AppxMsDownload,
            msi:    AppxMsDownload,
            cab:    MicrosoftCabinet,
            "7z":   Appx7z,
            
            // audio
            mp3:    AudioMpeg,
            wav:    AudioWav,
            
            // video
            avi:    VideoAvi,
            mp4:    VideoMp4,
            mpeg:   VideoMpeg,
            mov:    VideoQuicktime,
            qt:     VideoQuicktime,
            webm:   VideoWebm,
            flv:    VideoxFlv,
            wmv:    VideoxWmv,
            
            // adobe
            pdf:    AppPdf,
            psd:    AdobePhotoshop,
            ai:     AppPostscript,
            eps:    AppPostscript,
            ps:     AppPostscript,
            
            // ms office
            rtf:    AppRtf,
            doc:    MicrosoftWord,
            xls:    MicrosoftExcel,
            ppt:    MicrosoftPowerpoint,
            docx:   MicrosoftWordXml,
            xlsx:   MicrosoftExcelXml,
            pptx:   MicrosoftPowerpointXml,
            
            // open office
            odt:    OasisText,
            odg:    OasisDrawing,
            odp:    OasisPresentation,
            ods:    OasisSpreadsheet,
            odc:    OasisChart,
            odf:    OasisFormula,
            odb:    OasisDatabase,
            odi:    OasisImage,
        };
    }
    
    // get the mime type of a given filename
    public static function lookup(filename:String):Mime
    {
        var ext:String = filename.split(".").pop();
        var mime:Mime = extensions[ext];
        return mime == null ? AppBinary : mime;
    }
    
    // get all file extensions with the given mime type
    public static function find(mime:Mime):Array<String>
    {
        var exts:Array<String> = [];
        
        for (key in extensions.keys())
            if (extensions[key] == mime)
                exts.push(key);
                
        return exts;
    }
    
}

