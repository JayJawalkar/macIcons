import 'package:flutter/material.dart';

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
      duration: const Duration(milliseconds: 250),
      animationBehavior: AnimationBehavior.preserve,
    );

    scaleAnimation =
        Tween<double>(begin: 1, end: widget.isAdjacentToActive ? 1.15 : 1.24)
            .animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutCubic,
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

    scaleAnimation =
        Tween<double>(begin: 1, end: widget.isAdjacentToActive ? 1.15 : 1.24)
            .animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutCubic,
      ),
    );
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
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: Draggable<int>(
          data: widget.index,
          feedback: Material(
            color: Colors.transparent,
            child: Transform.scale(
              scale: 1.2,
              child: _buildIcon(iconColor, widget, scale: 1.05),
            ),
          ),
          onDragStarted: () {
            widget.onDragStart(widget.index);
            animationController.animateTo(0.0, curve: Curves.easeOutCubic);
          },
          onDragEnd: widget.onDragEnd,
          onDragUpdate: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localPosition = box.globalToLocal(details.globalPosition);

            final isOutside = !Rect.fromLTWH(
              -box.size.width,
              -box.size.height,
              box.size.width * 2.5,
              box.size.height * 2.5,
            ).contains(localPosition);

            widget.onDragUpdate(widget.index, isOutside, localPosition);
          },
          childWhenDragging: const SizedBox(width: 100, height: 100),
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
                  return Center(
                    child: _buildIcon(
                      iconColor,
                      widget,
                      scale: scaleAnimation.value,
                    ),
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
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  builder: (context, offset, child) {
                    return Transform.translate(
                      offset: offset,
                      child: child,
                    );
                  },
                  child: child,
                );
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(centerOffset, 0, 0),
                child: child,
              );
            },
            onWillAcceptWithDetails: (data) {
              if (widget.index == widget.totalItems - 1) {
                return widget.isDropTarget || widget.isDragging;
              }
              return data.data != widget.index;
            },
            onAccept: (data) => widget.onReorder(data, widget.index),
          ),
        ),
      ),
    );
  }
}

Widget _buildIcon(Color color, dynamic widget, {required double scale}) {
  return Container(
    width: 60 * scale,
    height: 60 * scale,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: widget.isDropTarget ? color.withOpacity(0.8) : color,
      boxShadow: widget.isDropTarget || widget.isHovered
          ? [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              )
            ]
          : null,
    ),
    child: Center(
      child: Icon(
        widget.icon,
        color: Colors.white,
        size: 32 * scale,
      ),
    ),
  );
}
