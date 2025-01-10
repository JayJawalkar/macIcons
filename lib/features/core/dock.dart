import 'package:assignment/widget/abimated_draggable_icon.dart';
import 'package:flutter/material.dart';

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