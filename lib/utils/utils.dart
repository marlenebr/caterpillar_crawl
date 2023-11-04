import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class FlameGameUtils
{
  ///Gets the angle from a point and the up vector
  static double getAngleFromUp(Vector2 point)
  {
	 	double radiansOfTap = atan2( point.y, point.x );
    double quaterRotationInRadiant = 90 * (pi /180); //atan2 uses positive x axis as vektor to calulate angle
    //double angleOfTap = degrees(-radiansOfTap -quaterRotationInRadiant);
    double worldRadiansOfTap = radiansOfTap -quaterRotationInRadiant;
    double finalAngle;

    if(worldRadiansOfTap <0)
    {
      finalAngle  = 2*pi +worldRadiansOfTap;
    }
    else
    {
      finalAngle =worldRadiansOfTap;
    }
    return finalAngle;
  }
}