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
  int? draggingIndex;

  @override
  void initState() {
    super.initState();
    items = List.of(widget.items);
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
            isDragging: draggingIndex == index,
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
            onDragStart: (index) {
              setState(() {
                draggingIndex = index;
              });
            },
            onDragEnd: () {
              setState(() {
                draggingIndex = null;
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
  final bool isDragging;
  final Function(bool) onHover;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(int index) onDragStart;
  final VoidCallback onDragEnd;

  const AnimatedDraggableIcon({
    super.key,
    required this.icon,
    required this.index,
    required this.isHovered,
    required this.isAdjacentHovered,
    required this.isDragging,
    required this.onHover,
    required this.onReorder,
    required this.onDragStart,
    required this.onDragEnd,
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
      animationBehavior: AnimationBehavior.preserve,
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.ease),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedDraggableIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isHovered) {
      _controller.forward();
    } else if (widget.isAdjacentHovered) {
      _controller.animateTo(0.5, curve: Curves.ease);
    } else {
      _controller.reverse();
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
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      child: Draggable<int>(
        data: widget.index,
        feedback: Transform.scale(
          scale: 1.2,
          child: _buildIconContainer(iconColor, scale: 1.1),
        ),
        onDragStarted: () => widget.onDragStart(widget.index),
        onDragEnd: (_) => widget.onDragEnd(),
        // If the widget is dragging, it takes up less space (20x20).
        childWhenDragging: widget.isDragging
            ? const SizedBox(height: 20, width: 20)
            : AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return _buildIconContainer(
                    iconColor,
                    scale: _scaleAnimation.value,
                  );
                },
              ),
        child: DragTarget<int>(
          builder: (context, candidateData, rejectedData) {
            return AnimatedBuilder(
              animation: _scaleAnimation.drive(
                AlignmentTween(
                  begin: Alignment.center,
                  end: Alignment.center,
                ),
              ),
              builder: (context, child) {
                return _buildIconContainer(iconColor,
                    scale: _scaleAnimation.value);
              },
            );
          },
          onLeave: (data) {
            data == widget.index; // Handle leave event
          },
          onMove: (data) => data == widget.index, // Move event on target
          onWillAccept: (data) => data != widget.index,
          onAccept: (data) {
            widget.onReorder(data, widget.index); // Reorder logic
          },
        ),
      ),
    );
  }

  Widget _buildIconContainer(Color color, {required double scale}) {
    return Container(
      width: 45 * scale,
      height: 45 * scale,
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
