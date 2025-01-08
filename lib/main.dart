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
  late List<IconData> dockItems;
  int? hoverIdx;
  int? dragIdx;
  int? dropTargetIdx;
  bool isDraggedOutside = false;
  List<Offset> dragPositions = [];
  bool isReturning = false;

  @override
  void initState() {
    super.initState();
    dockItems = List.of(widget.items);
  }

  double getCenterOffset(int totalItems, int currentIndex, int? draggedIndex) {
    if (draggedIndex == null) return 0;

    const baseIconWidth = 65.0;
    const baseIconMargin = 16.0;
    const itemWidth = baseIconWidth + baseIconMargin;
    const slideOffset = itemWidth * 0.8; // Reduced from 1.3

    if (hoverIdx != null && dragIdx != null) {
      if (dragIdx! < hoverIdx!) {
        if (currentIndex > dragIdx! && currentIndex <= hoverIdx!) {
          return -slideOffset;
        }
      } else if (dragIdx! > hoverIdx!) {
        if (currentIndex < dragIdx! && currentIndex >= hoverIdx!) {
          return slideOffset;
        }
      }
    }

    if (isDraggedOutside) {
      const spreadDistance = itemWidth * 0.4; // Reduced from 0.6
      if (currentIndex < draggedIndex) {
        return spreadDistance;
      } else if (currentIndex > draggedIndex) {
        return -spreadDistance;
      }
    }

    return 0;
  }

  void _animateReturn() async {
    if (!mounted) return;

    setState(() {
      isReturning = true;
    });

    await Future.delayed(const Duration(milliseconds: 200)); // Reduced from 300

    if (mounted) {
      setState(() {
        dragIdx = null;
        hoverIdx = null;
        dropTargetIdx = null;
        isDraggedOutside = false;
        isReturning = false;
        dragPositions.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          dockItems.length,
          (idx) => AnimatedDraggableIcon(
            key: ValueKey(dockItems[idx]),
            icon: dockItems[idx],
            index: idx,
            totalItems: dockItems.length,
            isHovered: hoverIdx == idx,
            isAdjacentToActive: hoverIdx != null &&
                (idx == hoverIdx! - 1 || idx == hoverIdx! + 1),
            isDragging: dragIdx == idx,
            isDropTarget: dropTargetIdx == idx,
            isDraggedOutside: isDraggedOutside && dragIdx != idx,
            draggedIndex: dragIdx,
            isReturning: isReturning && dragIdx == idx,
            dragPositions: dragPositions,
            getCenterOffset: getCenterOffset,
            onHover: (hovering) {
              setState(() {
                hoverIdx = hovering ? idx : null;
                if (dragIdx != null && hovering) {
                  dropTargetIdx = idx;
                }
              });
            },
            onReorder: (oldIdx, newIdx) {
              setState(() {
                if (newIdx > oldIdx) newIdx--;
                final item = dockItems.removeAt(oldIdx);
                dockItems.insert(newIdx, item);
                dropTargetIdx = null;
                dragPositions.clear();
              });
            },
            onDragStart: (idx) {
              setState(() {
                dragIdx = idx;
                isDraggedOutside = false;
                isReturning = false;
                dragPositions.clear();
              });
            },
            onDragEnd: (details) {
              if (dragIdx != null && dropTargetIdx == null) {
                _animateReturn();
              } else {
                setState(() {
                  dragIdx = null;
                  hoverIdx = null;
                  dropTargetIdx = null;
                  isDraggedOutside = false;
                  dragPositions.clear();
                });
              }
            },
            onDragUpdate: (draggedIdx, isOutside, position) {
              setState(() {
                isDraggedOutside = isOutside;
                if (!isOutside) {
                  dropTargetIdx = draggedIdx;
                } else {
                  dropTargetIdx = null;
                }
                dragPositions.add(position);
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
  final int totalItems;
  final bool isHovered;
  final bool isAdjacentToActive;
  final bool isDragging;
  final bool isDropTarget;
  final bool isDraggedOutside;
  final int? draggedIndex;
  final bool isReturning;
  final List<Offset> dragPositions;
  final Function(int totalItems, int currentIndex, int? draggedIndex)
      getCenterOffset;
  final Function(bool) onHover;
  final Function(int oldIdx, int newIdx) onReorder;
  final Function(int idx) onDragStart;
  final Function(DraggableDetails details) onDragEnd;
  final Function(int idx, bool isOutside, Offset position) onDragUpdate;

  const AnimatedDraggableIcon({
    super.key,
    required this.icon,
    required this.index,
    required this.totalItems,
    required this.isHovered,
    required this.isAdjacentToActive,
    required this.isDragging,
    required this.isDropTarget,
    required this.isDraggedOutside,
    required this.draggedIndex,
    required this.isReturning,
    required this.dragPositions,
    required this.getCenterOffset,
    required this.onHover,
    required this.onReorder,
    required this.onDragStart,
    required this.onDragEnd,
    required this.onDragUpdate,
  });

  @override
  State<AnimatedDraggableIcon> createState() => _AnimatedDraggableIconState();
}

class _AnimatedDraggableIconState extends State<AnimatedDraggableIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Reduced from 400
      animationBehavior: AnimationBehavior.preserve,
    );

    scaleAnimation = Tween<double>(begin: 1, end: 1.24).animate(
      // Reduced from 1.5
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutQuart, // Changed from easeInOut for smoother feel
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedDraggableIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isHovered || widget.isDropTarget || widget.isAdjacentToActive) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  @override
  void dispose() {
    animationController.dispose();
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
          scale: 1.1, // Reduced from 1.2
          child: _buildIcon(iconColor, scale: 1.09), // Reduced from 1.1
        ),
        onDragStarted: () {
          widget.onDragStart(widget.index);
          animationController.animateTo(0.0, curve: Curves.easeOutQuart);
        },
        onDragEnd: widget.onDragEnd,
        onDragUpdate: (details) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final localPosition = box.globalToLocal(details.globalPosition);

          final isOutside = !Rect.fromLTWH(
            -box.size.width,
            -box.size.height,
            box.size.width * 3,
            box.size.height * 3,
          ).contains(localPosition);

          widget.onDragUpdate(widget.index, isOutside, localPosition);
        },
        childWhenDragging: const SizedBox(width: 50, height: 50),
        child: DragTarget<int>(
          builder: (context, candidateData, rejectedData) {
            final centerOffset = widget.getCenterOffset(
              widget.totalItems,
              widget.index,
              widget.draggedIndex,
            );

            Widget child = AnimatedBuilder(
              animation: scaleAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(9),
                  child: _buildIcon(iconColor, scale: scaleAnimation.value),
                );
              },
            );

            if (widget.isReturning && widget.dragPositions.isNotEmpty) {
              final position =
                  widget.dragPositions[widget.dragPositions.length - 1];
              child = TweenAnimationBuilder<Offset>(
                tween: Tween<Offset>(
                  begin: position,
                  end: Offset.zero,
                ),
                duration: const Duration(milliseconds: 300), // Reduced from 300
                curve: Curves.easeOutQuart, // Changed from easeOutCubic
                builder: (context, offset, child) {
                  return Transform.translate(
                    offset: offset,
                    child: child,
                  );
                },
                child: child,
              );
            }

            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: centerOffset),
              duration: const Duration(milliseconds: 400), // Reduced from 400
              curve: Curves.easeOutQuart, // Changed from easeInOut
              builder: (context, offset, _) {
                return Transform.translate(
                  offset: Offset(offset / 2.1, 1.1),
                  child: child,
                );
              },
            );
          },
          onWillAccept: (data) => data != widget.index,
          onAccept: (data) => widget.onReorder(data, widget.index),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color, {required double scale}) {
    return Container(
      width: 50 * scale,
      height: 50 * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: widget.isDropTarget ? color.withOpacity(0.3) : color,
        boxShadow: widget.isDropTarget || widget.isHovered
            ? [
                BoxShadow(
                  color: color.withOpacity(0.2), // Reduced from 0.3
                  blurRadius: 6, // Reduced from 8
                  spreadRadius: 2, // Reduced from 4
                )
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          widget.icon,
          color: Colors.white,
          size: 28 * scale,
        ),
      ),
    );
  }
}
