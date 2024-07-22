import 'package:flame/components.dart';
import 'package:flame/events.dart';

class CaterpillarJoystick extends JoystickComponent {
  Vector2 currentDelta = Vector2.zero();

  CaterpillarJoystick({
    super.knob,
    super.background,
    super.margin,
    super.position,
    double? size,
    double? knobRadius,
    Anchor super.anchor = Anchor.center,
    super.children,
    super.priority,
    super.key,
  });

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    currentDelta = Vector2(-delta.x, -delta.y);
    return false;
  }

  @override
  bool onDragEnd(_) {
    super.onDragEnd(_);
    delta.scaleTo(knobRadius);

    return false;
  }

  @override
  bool onDragCancel(_) {
    super.onDragCancel(_);
    return false;
  }
}
