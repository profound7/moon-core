package moon.numbers.units;

import moon.numbers.units.base.*;
import moon.numbers.units.derived.*;
import moon.numbers.units.electric.*;

/**
 * ...
 * @author Munir Hussin
 */

@:dimension(Length          = Length)
@:dimension(Mass            = Mass)
@:dimension(Temperature     = Temperature)
@:dimension(Time            = Time)

@:dimension(Hertz           = 1 / Time)

@:dimension(Area            = Length^2)
@:dimension(Volume          = Length^3)


@:formula(AreaDensity       = Mass / Length^2)
@:formula(Density           = Mass / Length^3)

@:formula(Velocity          = Length / Time^1)
@:formula(Acceleration      = Length / Time^2)
@:formula(Jolt              = Length / Time^3)
@:formula(Snap              = Length / Time^4)

@:formula(Viscocity         = Length^2 / Time^1)
@:formula(VolumetricFlow    = Length^3 / Time^1)

@:formula(Force             = Mass * Length / Time^2)
@:formula(Energy            = Mass * Length^2 / Time^2)
@:formula(Power             = Mass * Length^2 / Time^3)
@:formula(Pressure          = Mass / Length^1 * Time^2)


class Units
{
    
    public function new() 
    {
        
    }
    
}