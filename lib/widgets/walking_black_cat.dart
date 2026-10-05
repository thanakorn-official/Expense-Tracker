import 'package:flutter/material.dart';
import 'dart:math' as math;

class WalkingBlackCat extends StatefulWidget {
  const WalkingBlackCat({super.key});

  @override
  State<WalkingBlackCat> createState() => _WalkingBlackCatState();
}

class _WalkingBlackCatState extends State<WalkingBlackCat>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // ให้แมวเดินช้าๆ ชิลๆ ใช้เวลา 15 วินาทีในการเดินจากซ้ายไปขวา
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(); // เดินวนลูปไปเรื่อยๆ
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // IgnorePointer สำคัญมาก! ช่วยให้เรากดรายการที่อยู่หลังแมวได้ ทะลุตัวแมวไปเลย
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // คำนวณตำแหน่ง X จากซ้ายสุด (-1.2) ไปขวาสุด (1.2)
          final xPos = -1.2 + (_controller.value * 2.4);

          // โยกตัวขึ้นลงเบาๆ ถี่ๆ จำลองจังหวะการก้าวขาเดิน
          final bounce = math.sin(_controller.value * math.pi * 60) * 1.5;
          // แกว่งหาง
          final tailAngle = math.sin(_controller.value * math.pi * 30) * 0.5;

          return Align(
            alignment: Alignment(xPos, 1.0), // ให้อยู่ด้านล่างของจอ
            child: Transform.translate(
              offset: Offset(
                  0, bounce - 20), // ลอยขึ้นมาจากขอบล่างนิดหน่อย ไม่ให้บังขอบ
              child: SizedBox(
                width: 45,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // หางแมว (แกว่งไปมา)
                    Positioned(
                      left: 4,
                      bottom: 12,
                      child: Transform.rotate(
                        angle: tailAngle,
                        child: Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    // ตัวแมว
                    Positioned(
                      bottom: 10,
                      child: Container(
                        width: 26,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    // หัวแมว (หันหน้าไปทางขวาตามทิศที่เดิน)
                    Positioned(
                      right: 4,
                      top: 8,
                      child: Container(
                        width: 16,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Stack(
                          children: [
                            // หูแมว
                            const Positioned(
                                top: -4,
                                left: -1,
                                child: Icon(Icons.change_history,
                                    size: 10, color: Colors.black87)),
                            const Positioned(
                                top: -4,
                                right: -1,
                                child: Icon(Icons.change_history,
                                    size: 10, color: Colors.black87)),
                            // ตาแมว (หันขวา)
                            Positioned(
                                top: 4,
                                right: 2,
                                child: Container(
                                    width: 2,
                                    height: 2,
                                    decoration: const BoxDecoration(
                                        color: Colors.amber,
                                        shape: BoxShape.circle))),
                            Positioned(
                                top: 4,
                                right: 7,
                                child: Container(
                                    width: 2,
                                    height: 2,
                                    decoration: const BoxDecoration(
                                        color: Colors.amber,
                                        shape: BoxShape.circle))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
