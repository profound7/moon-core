package moon.web;

/**
 * List of HTTP Status codes
 * @author Munir Hussin
 */
@:enum abstract HttpStatus(Int) to Int from Int
{
    // informational
    var InfoContinue                            = 100;
    var InfoSwitchingProtocols                  = 101;
    
    // success
    var SuccessOk                               = 200;
    var SuccessCreated                          = 201;
    var SuccessAccepted                         = 202;
    var SuccessNonAuthoritativeInfo             = 203;
    var SuccessNoContent                        = 204;
    var SuccessResetContent                     = 205;
    var SuccessPartialContent                   = 206;
    
    // redirection
    var RedirectMultipleChoices                 = 300;
    var RedirectMovedPermanently                = 301;
    var RedirectFound                           = 302;
    var RedirectSeeOther                        = 303;
    var RedirectNotModified                     = 304;
    var RedirectUseProxy                        = 305;
    var RedirectTemporary                       = 307;
    var RedirectPermanent                       = 308;
    
    // client errors
    var ClientErrorBadRequest                   = 400;
    var ClientErrorUnauthorized                 = 401;
    var ClientErrorPaymentRequired              = 402;
    var ClientErrorForbidden                    = 403;
    var ClientErrorNotFound                     = 404;
    var ClientErrorMethodNotAllowed             = 405;
    var ClientErrorNotAcceptable                = 406;
    var ClientErrorProxyAuthRequired            = 407;
    var ClientErrorRequestTimeout               = 408;
    var ClientErrorConflict                     = 409;
    var ClientErrorGone                         = 410;
    var ClientErrorLengthRequired               = 411;
    var ClientErrorPreconditionFailed           = 412;
    var ClientErrorRequestEntityTooLarge        = 413;
    var ClientErrorRequestUriTooLong            = 414;
    var ClientErrorUnsupportedMediaType         = 415;
    var ClientErrorRequestRangeUnsatisfiable    = 416;
    var ClientErrorExpectationFailed            = 417;
    var ClientErrorTooManyRequests              = 429;
    
    // server errors
    var ServerErrorInternal                     = 500;
    var ServerErrorNotImplemented               = 501;
    var ServerErrorBadGateway                   = 502;
    var ServerErrorServiceUnavailable           = 503;
    var ServerErrorGatewayTimeout               = 504;
    var ServerErrorHttpVersionUnsupported       = 505;
    var ServerErrorBandwidthLimitExceeded       = 509;
}
