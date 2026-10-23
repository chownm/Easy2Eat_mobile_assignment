import 'package:flutter/material.dart';

class TopHeaderWidget extends StatefulWidget {
  const TopHeaderWidget({super.key});

  @override
  State<TopHeaderWidget> createState() => _TopHeaderWidgetState();
}

class _TopHeaderWidgetState extends State<TopHeaderWidget> {
  bool _isOpen = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'M',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'Kitchen Central',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.circle, size: 8, color: Colors.black),
                      ],
                    ),
                    const Text(
                      'Live Dashboard',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 右侧：用户头像 (已修复点号为逗号的语法错误)
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.black12,
              child: Icon(Icons.person, color: Colors.black54),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 左侧：店铺图标与店名
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.black26,
                    child: Icon(Icons.store, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            'Artisan Kitchen',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.verified, size: 16, color: Colors.black),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Live Kitchen Sync',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    _isOpen ? 'OPEN' : 'CLOSED',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: _isOpen ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isOpen,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.black,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey.shade400,
                    onChanged: (bool value) {
                      setState(() {
                        _isOpen = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.access_time, size: 18, color: Colors.black87),
                  SizedBox(width: 8),
                  Text(
                    'Est. Prep Window: ', // 修正了拼写
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  Text(
                    '18 min',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'OPTIMAL FLOW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}