import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
          ),
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  final List<IconData> items;

  const Dock({
    super.key,
    required this.items,
  });

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<IconData> items;
  int? hoveredIndex;

  @override
  void initState() {
    super.initState();
    items = List.of(widget.items); // Copy to ensure immutability
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          items.length,
          (index) => AnimatedDraggableIcon(
            key: ValueKey(items[index]),
            icon: items[index],
            index: index,
            isHovered: hoveredIndex == index,
            isAdjacentHovered: hoveredIndex != null &&
                (index == hoveredIndex! - 1 || index == hoveredIndex! + 1),
            onHover: (isHovering) {
              setState(() {
                hoveredIndex = isHovering ? index : null;
              });
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = items.removeAt(oldIndex);
                items.insert(newIndex, item);
              });
            },
          ),
        ),
      ),
    );
  }
}

class AnimatedDraggableIcon extends StatefulWidget {
  final IconData icon;
  final int index;
  final bool isHovered;
  final bool isAdjacentHovered;
  final Function(bool) onHover;
  final Function(int oldIndex, int newIndex) onReorder;

  const AnimatedDraggableIcon({
    super.key,
    required this.icon,
    required this.index,
    required this.isHovered,
    required this.isAdjacentHovered,
    required this.onHover,
    required this.onReorder,
  });

  @override
  State<AnimatedDraggableIcon> createState() => _AnimatedDraggableIconState();
}

class _AnimatedDraggableIconState extends State<AnimatedDraggableIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedDraggableIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isHovered) {
      _controller.animateTo(0.5); // Scale to maximum
    } else if (widget.isAdjacentHovered) {
      _controller.animateTo(0.5); // Scale to slightly enlarged
    } else {
      _controller.animateBack(0.0); // Scale back to normal
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor =
        Colors.primaries[widget.icon.hashCode % Colors.primaries.length];

    return MouseRegion(
      onEnter: (_) {
        widget.onHover(true);
      },
      onExit: (_) => widget.onHover(false),
      child: Draggable<int>(
        data: widget.index,
        feedback: Transform.scale(
          scale: _scaleAnimation.value * 1,
          child: _buildIconContainer(iconColor, scale: _scaleAnimation.value),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildIconContainer(iconColor, scale: 0),
        ),
        onDragCompleted: () {},
        child: DragTarget<int>(
          builder: (context, candidateData, rejectedData) {
            return AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return _buildIconContainer(iconColor,
                    scale: _scaleAnimation.value);
              },
            );
          },
          onWillAccept: (data) => data != widget.index,
          onAccept: (data) {
            widget.onReorder(data, widget.index);
          },
        ),
      ),
    );
  }

  Widget _buildIconContainer(Color color, {required double scale}) {
    return Container(
      width: 50 * scale,
      height: 50 * scale,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color,
      ),
      child: Center(
        child: Icon(
          widget.icon,
          color: Colors.white,
          size: 24 * scale,
        ),
      ),
    );
  }
}
