import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/actions_provider.dart';
import '../../models/action_item.dart';

class ActionSettingsScreen extends ConsumerWidget {
  const ActionSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = [...ref.watch(actionsProvider)]..sort((a, b) => a.order.compareTo(b.order));

    return Scaffold(
      appBar: AppBar(
        title: const Text('항목 설정'),
        centerTitle: true,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1B8A5A),
                foregroundColor: Colors.white,
              ),
              onPressed: () => context.push('/actions/add'),
              child: const Text('항목 추가', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: actions.length,
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) newIndex -= 1;
          ref.read(actionsProvider.notifier).reorder(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final a = actions[index];

          return Dismissible(
            key: ValueKey('action_settings_${a.id}'),
            direction: a.isBuiltIn ? DismissDirection.none : DismissDirection.endToStart,
            confirmDismiss: (_) async {
              if (a.isBuiltIn) return false;

              return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('삭제할까요?'),
                  content: Text('${a.name} 항목을 삭제할까요?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('취소'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              ) ??
                  false;
            },
            onDismissed: (_) {
              ref.read(actionsProvider.notifier).removeCustomById(a.id);
            },
            background: Container(
              color: Colors.red.withOpacity(0.15),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete_outline),
            ),
            child: _ActionTile(
              action: a,
              index: index,
              onToggleHidden: () => ref.read(actionsProvider.notifier).toggleHidden(a.id),
              onTapDelete: a.isBuiltIn
                  ? null
                  : () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('삭제할까요?'),
                    content: Text('${a.name} 항목을 삭제할까요?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                ) ??
                    false;

                if (ok == true) {
                  ref.read(actionsProvider.notifier).removeCustomById(a.id);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final ActionItem action;
  final int index;
  final VoidCallback onToggleHidden;
  final VoidCallback? onTapDelete;

  const _ActionTile({
    required this.action,
    required this.index,
    required this.onToggleHidden,
    required this.onTapDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dim = action.isHidden;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: action.color.withOpacity(0.16),
        ),
        child: Icon(action.icon, color: action.color),
      ),
      title: Text(
        action.name,
        style: TextStyle(fontWeight: FontWeight.w800, color: dim ? Theme.of(context).hintColor : null),
      ),
      subtitle: action.units.isEmpty
          ? null
          : Text(
        action.units.join(' · '),
        style: TextStyle(color: Theme.of(context).hintColor),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: dim ? '숨김 해제' : '숨김',
            onPressed: onToggleHidden,
            icon: Icon(dim ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          ),
          if (onTapDelete != null)
            IconButton(
              tooltip: '삭제',
              onPressed: onTapDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.drag_indicator),
            ),
          ),
        ],
      ),
    );
  }
}
