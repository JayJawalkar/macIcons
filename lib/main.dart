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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: instructionText(),
            ),
            Center(
              child: Dock(
                items: const [
                  Icons.chrome_reader_mode,
                  Icons.person,
                  Icons.message,
                  Icons.call,
                  Icons.camera,
                  Icons.photo,
                  Icons.gamepad,
                  Icons.square_foot_sharp,
                ],
              ),
            ),
          ],
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
    if (draggedIndex == null || hoverIdx == null) return 0;

    const double maxSpacing = 80.0;

    if (dragIdx != null && hoverIdx != null && dragIdx != hoverIdx) {
      bool shouldMove = false;
      int direction = 0;

      if (dragIdx! < hoverIdx!) {
        if (currentIndex > dragIdx! && currentIndex <= hoverIdx!) {
          shouldMove = true;
          direction = -1;
        }
      } else {
        if (currentIndex >= hoverIdx! && currentIndex < dragIdx!) {
          shouldMove = true;
          direction = 1;
        }
      }

      if (shouldMove) {
        return direction * maxSpacing;
      }
    }

    return 0;
  }

  void _animateReturn() async {
    if (!mounted) return;

    setState(() {
      isReturning = true;
    });

    await Future.delayed(const Duration(milliseconds: 250));

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
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          dockItems.length,
          (idx) => AnimatedDraggableIcon(
            key: ValueKey(dockItems[idx]),
            icon: dockItems[idx],
            index: idx,
            totalItems: dockItems.length,
            isHovered: hoverIdx == idx,
            isAdjacentToActive: (hoverIdx != null &&
                    (idx == hoverIdx! - 1 || idx == hoverIdx! + 1)) ||
                (dragIdx != null &&
                    dropTargetIdx != null &&
                    (idx == dropTargetIdx! - 1 || idx == dropTargetIdx! + 1)),
            isDragging: dragIdx == idx,
            isDropTarget: dropTargetIdx == idx,
            isDraggedOutside: isDraggedOutside && dragIdx != idx,
            draggedIndex: dragIdx,
            isReturning: isReturning && dragIdx == idx,
            dragPositions: dragPositions,
            getCenterOffset: getCenterOffset,
            onHover: (hovering) {
              setState(() {
                if (dragIdx != null || !hovering) {
                  hoverIdx = hovering ? idx : null;
                  if (dragIdx != null && hovering) {
                    dropTargetIdx = idx;
                  }
                } else {
                  hoverIdx = hovering ? idx : null;
                }
              });
            },
            onDragStart: (idx) {
              setState(() {
                dragIdx = idx;
                hoverIdx = null;
                isDraggedOutside = false;
                isReturning = false;
                dragPositions.clear();
              });
            },
            onDragUpdate: (draggedIdx, isOutside, position) {
              setState(() {
                isDraggedOutside = isOutside;
                if (!isOutside && hoverIdx != null) {
                  dropTargetIdx = hoverIdx;
                } else {
                  dropTargetIdx = null;
                }
                dragPositions.add(position);
              });
            },
            onDragEnd: (details) {
              if (dropTargetIdx == null) {
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
            onReorder: (oldIdx, newIdx) {
              setState(() {
                dropTargetIdx = null;
                hoverIdx = null;
                dragPositions.clear();

                if (oldIdx < newIdx) {
                  newIdx -= 1;
                }

                final item = dockItems.removeAt(oldIdx);
                dockItems.insert(newIdx, item);

                dragIdx = null;
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
      duration: const Duration(milliseconds: 300),
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
              child: _buildIcon(iconColor, scale: 1.05),
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
          childWhenDragging: const SizedBox(width: 60, height: 60),
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
                  duration: const Duration(milliseconds: 300),
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
                duration: const Duration(milliseconds: 300),
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

  Widget _buildIcon(Color color, {required double scale}) {
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
}

Widget instructionText() {
  return Column(
    children: [
      Text(
        "INSTRUCTIONS",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            children: [
              const TextSpan(
                text:
                    "\n1. The Mouse Pointer [Cursor] acts as Center and the point of impact and not the hovered icon\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text: "2. Drag an icon to see dynamic spacing effect\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "3. When dragging, other icons will ",
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: "move away",
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: " from the cursor\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const TextSpan(
                text: "4. Release to drop the icon in its new position\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "5. Icons will ",
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: "automatically rearrange",
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: " based on cursor position",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextSpan(
                text: "\n # The animations might feel fast  ",
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: "automatically rearrange",
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: " drag and drop",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
