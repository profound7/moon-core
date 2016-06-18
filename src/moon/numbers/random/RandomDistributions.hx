package moon.numbers.random;

import moon.numbers.random.Random;

/**
 * Ported from python's numpy
 * https://github.com/numpy/numpy/blob/master/numpy/random/mtrand/distributions.c
 * https://github.com/numpy/numpy/blob/master/numpy/random/mtrand/randomkit.c
 * https://github.com/numpy/numpy/blob/master/LICENSE.txt
 * 
 * http://svn.python.org/projects/python/branches/py3k/Lib/random.py
 * 
 * @author Munir Hussin
 */
abstract RandomDistributions(Random) to Random from Random
{
    private static inline var FLOAT_FACTOR:Float = 0.00000000046566128742;
    private static inline var MAX_INT:Int = 0x7fffffff;
    
    private static var LOGGAM_A:Array<Float> =
    [
        8.333333333333333e-02, -2.777777777777778e-03,
        7.936507936507937e-04, -5.952380952380952e-04,
        8.417508417508418e-04, -1.917526917526918e-03,
        6.410256410256410e-03, -2.955065359477124e-02,
        1.796443723688307e-01, -1.39243221690590e+00
    ];
    
    /*==================================================
        Service Methods
    ==================================================*/
    
    /**
     * Log-gamma function to support some of these distributions. The
     * algorithm comes from SPECFUN by Shanjie Zhang and Jianming Jin and their
     * book "Computation of Special Functions", 1996, John Wiley & Sons, Inc.
     */
    public static function loggam(x:Float):Float
    {
        // doubles
        var x0:Float;
        var x2:Float;
        var xp:Float;
        var gl:Float;
        var gl0:Float;
        
        // longs
        var k:Int;
        var n:Int;
        
        x0 = x;
        n = 0;
        
        if ((x == 1.0) || (x == 2.0))
        {
            return 0.0;
        }
        else if (x <= 7.0)
        {
            n = Std.int(7 - x);
            x0 = x + n;
        }
        
        x2 = 1.0 / (x0 * x0);
        xp = 2 * Math.PI;
        
        gl0 = LOGGAM_A[9];
        
        // 8, 7, 6, 5, 4, 3, 2, 1, 0
        //for (k=8; k>=0; k--)
        k = 9;
        while (k-->0)
        {
            gl0 *= x2;
            gl0 += LOGGAM_A[k];
        }
        
        gl = gl0 / x0 + 0.5 * Math.log(xp) + (x0 - 0.5) * Math.log(x0) - x0;
        
        if (x <= 7.0)
        {
            // 1, 2, 3, 4, ... n
            //for (k=1; k<=n; k++)
            for (k in 1...n+1)
            {
                gl -= Math.log(x0 - 1.0);
                x0 -= 1.0;
            }
        }
        
        return gl;
    }
    
    /*==================================================
        Methods
    ==================================================*/
        
    /**
     * Triangular distribution
     * @param lo        the lowest possible value
     * @param hi        the highest possible value
     * @param mode      the most common value
     * @return
     */
    public function triangular(lo:Float=0.0, hi:Float=1.0, ?mode:Float=0.5):Float
    {
        // when mode is not given, use the middle
        if (mode == null)
        {
            mode = (hi - lo) * 0.5 + lo;
        }
        
        var x:Float = this.nextFloat();
        var base:Float = hi - lo;
        var leftBase:Float = mode - lo;
        var ratio:Float = leftBase / base;
        
        if (x <= ratio)
        {
            return lo + Math.sqrt(x * leftBase * base);
        }
        else
        {
            return hi - Math.sqrt((1.0 - x) * (hi - mode) * base);
        }
    }
    
    /**
     * Gaussian distribution, centered at 0 with sigma of 1.
     * To specify mu and sigma parameters, use normal(mu, sigma).
     * @return
     */
    public function gaussian():Float
    {
        if (this._hasGauss)
        {
            var tmp:Float = this._gauss;
            this._gauss = 0;
            this._hasGauss = false;
            return tmp;
        }
        else
        {
            var f:Float;
            var x1:Float;
            var x2:Float;
            var r2:Float;
            
            do
            {
                x1 = 2.0 * this.nextFloat() - 1.0;
                x2 = 2.0 * this.nextFloat() - 1.0;
                r2 = x1 * x1 + x2 * x2;
            }
            while (r2 >= 1.0 || r2 == 0.0);
            
            // box-muller transform
            f = Math.sqrt(-2.0 * Math.log(r2) / r2);
            
            // keep for next call
            this._gauss = f * x1;
            this._hasGauss = true;
            return f * x2;
        }
    }
    
    /**
     * Normal distribution
     * @param mu        the mean
     * @param sigma     standard deviation
     * @return
     */
    public inline function normal(mu:Float=0.0, sigma:Float=1.0):Float
    {
        return mu + sigma * gaussian();
    }
    
    /**
     * Standard exponential distribution
     * @return
     */
    private inline function standardExponential():Float
    {
        return -Math.log(1.0 - this.nextFloat());
    }
    
    /**
     * Exponential distribution
     * @param scale
     * @return
     */
    public inline function exponential(scale:Float=1.0):Float
    {
        return scale * standardExponential();
    }
    
    /**
     * Generates a random Float in range [lo...hi), excluding `hi`
     * @return returns a random Float between two floats
     */
    public inline function uniform(lo:Float = 0.0, hi:Float = 1.0):Float
    {
        return lo + this.nextFloat() * (hi - lo);
    }
    
    /**
     * Standard gamma distribution
     * @param shape
     * @return
     */
    private function standardGamma(shape:Float):Float
    {
        var b:Float;
        var c:Float;
        
        var U:Float;
        var V:Float;
        var X:Float;
        var Y:Float;
        
        if (shape == 1.0)
        {
            return standardExponential();
        }
        else if (shape < 1.0)
        {
            while (true)
            {
                U = this.nextFloat();
                V = standardExponential();
                
                if (U <= 1.0 - shape)
                {
                    X = Math.pow(U, 1.0 / shape);
                    if (X <= V) return X;
                }
                else
                {
                    Y = -Math.log((1 - U) / shape);
                    X = Math.pow(1.0 - shape + shape * Y, 1.0 / shape);
                    if (X <= (V + Y)) return X;
                }
            }
        }
        else
        {
            b = shape - 1.0 / 3.0;
            c = 1.0 / Math.sqrt(9 * b);
            
            while (true)
            {
                do
                {
                    X = gaussian();
                    V = 1.0 + c * X;
                }
                while (V <= 0.0);
                
                V = V * V * V;
                U = this.nextFloat();
                if (U < 1.0 - 0.0331 * (X * X) * (X * X)) return (b * V);
                if (Math.log(U) < 0.5 * X * X + b * (1.0 - V + Math.log(V))) return (b * V);
            }
        }
    }
    
    /**
     * Gamma distribution
     * @param shape         shape parameter k
     * @param scale         scale parameter theta
     * @return
     */
    public inline function gamma(shape:Float, scale:Float=1.0):Float
    {
        return scale * standardGamma(shape);
    }
    
    /**
     * Beta distribution
     * @param a             alpha shape
     * @param b             beta shape
     * @return
     */
    public function beta(a:Float, b:Float):Float
    {
        if ((a <= 1.0) && (b <= 1.0))
        {
            var U:Float;
            var V:Float;
            var X:Float;
            var Y:Float;
            
            // Use Jonk's algorithm
            while (true)
            {
                U = this.nextFloat();
                V = this.nextFloat();
                X = Math.pow(U, 1.0 / a);
                Y = Math.pow(V, 1.0 / b);
                
                if ((X + Y) <= 1.0)
                {
                    if (X + Y > 0)
                    {
                        return X / (X + Y);
                    }
                    else
                    {
                        var logX:Float = Math.log(U) / a;
                        var logY:Float = Math.log(V) / b;
                        var logM:Float = logX > logY ? logX : logY;
                        logX -= logM;
                        logY -= logM;
                        
                        return Math.exp(logX - Math.log(Math.exp(logX) + Math.exp(logY)));
                    }
                }
            }
        }
        else
        {
            var Ga:Float = standardGamma(a);
            var Gb:Float = standardGamma(b);
            return Ga / (Ga + Gb);
        }
    }
    
    /**
     * Chi-squared distribution
     * @param df        k degrees of freedom
     * @return
     */
    public inline function chiSquare(df:Float):Float
    {
        return 2.0 * standardGamma(df / 2.0);
    }
    
    /**
     * Non-central chi-squared distribution
     * @param df
     * @param nonc
     * @return
     */
    public function nonCentralChiSquare(df:Float, nonc:Float):Float
    {
        if (1 < df)
        {
            var chi2 = chiSquare(df - 1.0);
            var n = gaussian() + Math.sqrt(nonc);
            return chi2 + n * n;
        }
        else
        {
            var i:Float = poisson(nonc / 2.0);
            return chiSquare(df + 2.0 * i);
        }
    }
    
    /**
     * F distribution
     * @param dfnum
     * @param dfden
     * @return
     */
    public inline function f(dfnum:Float, dfden:Float):Float
    {
        return (chiSquare(dfnum) * dfden) / (chiSquare(dfden) * dfnum);
    }
    
    /**
     * Non-central F distribution
     * @param dfnum
     * @param dfden
     * @return
     */
    public inline function nonCentralF(dfnum:Float, dfden:Float, nonc:Float):Float
    {
        //var t:Float = nonCentralChiSquare(dfnum, nonc) * dfden;
        //return t / (chiSquare(dfden) * dfnum);
        return (nonCentralChiSquare(dfnum, nonc) * dfden) / (chiSquare(dfden) * dfnum);
    }
    
    
    private function poissonMult(lam:Float):Float
    {
        var X:Float; // long
        
        var prod:Float;
        var U:Float;
        var enlam:Float;
        
        enlam = Math.exp(-lam);
        X = 0;
        prod = 1.0;
        
        while (true)
        {
            U = this.nextFloat();
            prod *= U;
            
            if (prod > enlam)
            {
                X += 1;
            }
            else
            {
                return X;
            }
        }
    }
    
    private function poissonPtrs(lam:Float):Float
    {
        var k:Float; // long
        
        var U:Float;
        var V:Float;
        var slam:Float;
        var loglam:Float;
        var a:Float;
        var b:Float;
        var invalpha:Float;
        var vr:Float;
        var us:Float;
        
        slam = Math.sqrt(lam);
        loglam = Math.log(lam);
        b = 0.931 + 2.53 * slam;
        a = -0.059 + 0.02483 * b;
        invalpha = 1.1239 + 1.1328 / (b - 3.4);
        vr = 0.9277 - 3.6224 / (b - 2);
        
        while (true)
        {
            U = this.nextFloat() - 0.5;
            V = this.nextFloat();
            us = 0.5 - Math.abs(U);
            k = Math.ffloor((2 * a / us + b) * U + lam + 0.43);
            
            if ((us >= 0.07) && (V <= vr))
            {
                return k;
            }
            
            if ((k < 0) || ((us < 0.013) && (V > us)))
            {
                continue;
            }
            
            if ((Math.log(V) + Math.log(invalpha) - Math.log(a / (us * us) + b))
                <= (-lam + k * loglam - loggam(k + 1)))
            {
                return k;
            }
        }
    }
    
    /**
     * Poisson distribution
     * @param lam
     * @return
     */
    public inline function poisson(lam:Float):Float
    {
        if (lam >= 10)
            return poissonPtrs(lam);
        else if (lam == 0)
            return 0;
        else
            return poissonMult(lam);
    }
    
    /**
     * Standard cauchy distribution
     * @param lam
     * @return
     */
    public inline function standardCauchy():Float
    {
        return gaussian() / gaussian();
    }
    
    /**
     * Standard T distribution
     * @param df
     * @return
     */
    public inline function standardT(df:Float):Float
    {
        var N:Float = gaussian();
        var G:Float = standardGamma(df * 0.5);
        var X:Float = Math.sqrt(df * 0.5) * N * Math.sqrt(G);
        return X;
    }
    
    /**
     * Pareto distribution
     * @param alpha
     * @return
     */
    public inline function pareto(alpha:Float):Float
    {
        return 1.0 / Math.pow(1.0 - this.nextFloat(), 1.0 / alpha);
        //return Math.exp(standardExponential() / a) - 1;
    }
    
    /**
     * Weibull distribution
     * @param scale         lambda parameter
     * @param shape         k parameter
     * @return
     */
    public inline function weibull(scale:Float, shape:Float):Float
    {
        return scale * Math.pow(-Math.log(1.0 - this.nextFloat()), 1.0 / shape);
        //return Math.pow(standardExponential(), 1.0 / alpha);
    }
}
