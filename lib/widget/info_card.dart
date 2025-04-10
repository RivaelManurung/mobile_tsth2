import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<InfoItem> items;

  const InfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => _buildInfoItem(item, items)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(InfoItem item, List<InfoItem> items) {
    return Column(
      children: [
        InkWell(
          onTap: item.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(item.icon, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.value != null)
                        Text(
                          item.value!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (item.isAction)
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
        if (item != items.last)
          Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }
}

class InfoItem {
  final IconData icon;
  final String title;
  final String value;
  final bool isAction;
  final VoidCallback? onTap;

  const InfoItem({
    required this.icon,
    required this.title,
    required this.value,
    this.isAction = false,
    this.onTap,
  });

  InfoItem copyWith({
    IconData? icon,
    String? title,
    String? value,
    bool? isAction,
    VoidCallback? onTap,
  }) {
    return InfoItem(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      value: value ?? this.value,
      isAction: isAction ?? this.isAction,
      onTap: onTap ?? this.onTap,
    );
  }
}