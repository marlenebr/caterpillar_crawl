import 'dart:math';

import 'package:flame/game.dart';

class FlameGameUtils
{
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
    //print('caterpillar Rotation: -> ${degrees(_caterPillar.transform.angle)}');
    //print('math tap: -> ${angleOfTap}');
  }
}