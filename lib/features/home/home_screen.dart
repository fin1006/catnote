import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/cat_profile.dart';
import '../../providers/cats_provider.dart';
import '../../providers/selected_cat_provider.dart';
import '../../providers/computed_providers.dart';
import '../../utils/iterable_ext.dart';

import 'widgets/quick_actions.dart';
import 'widgets/today_summary_card.dart';
import 'widgets/timeline_section.dart';
import 'widgets/quick_entry_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _controller = ScrollController();

  // build에서 계산해서 넣음
  double _collapseRange = 0.0;

  bool _snapping = false;
  ValueNotifier<bool>? _isScrolling;

  @override
  void initState() {
    super.initState();

    // ✅ 가장 확실한 “스크롤 멈춤” 신호에 스냅을 연결
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_controller.hasClients) return;

      _isScrolling = _controller.position.isScrollingNotifier;
      _isScrolling!.addListener(_onIsScrollingChanged);
    });
  }

  void _onIsScrollingChanged() {
    final n = _isScrolling;
    if (n == null) return;
    // false = 완전히 멈춤(관성까지 끝)
    if (n.value == false) {
      _snapIfNeeded();
    }
  }

  @override
  void dispose() {
    _isScrolling?.removeListener(_onIsScrollingChanged);
    _controller.dispose();
    super.dispose();
  }

  void _snapIfNeeded() {
    if (_snapping) return;
    if (!_controller.hasClients) return;

    final offset = _controller.offset;

    // 헤더가 실제로 변하는 구간만 스냅
    if (offset <= 0 || offset >= _collapseRange) return;

    // ✅ 중간이면 둘 중 하나로 강제 스냅
    final target = (offset < _collapseRange / 2) ? 0.0 : _collapseRange;

    _snapping = true;
    _controller
        .animateTo(
      target,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
    )
        .whenComplete(() {
      _snapping = false;
    });
  }

  // ✅ 손 뗐을 때도 한 번 더 체크(누락 방지)
  void _onPointerUp(_) {
    Future.delayed(const Duration(milliseconds: 30), () {
      if (!mounted) return;
      if (!_controller.hasClients) return;

      // 아직 관성으로 움직이는 중이면 기다렸다가 isScrollingNotifier가 처리함
      if (_controller.position.isScrollingNotifier.value) return;
      _snapIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cats = ref.watch(catsProvider);
    final selectedCatId = ref.watch(selectedCatIdProvider);
    final selectedCat = cats.where((c) => c.id == selectedCatId).cast<CatProfile?>().firstOrNull;

    final entries = ref.watch(selectedCatEntriesProvider);
    final summary = ref.watch(todaySummaryProvider);

    final h = MediaQuery.of(context).size.height;

    // ✅ 상단 사진: 화면 1/3
    final expandedH = (h * 0.33).clamp(180.0, 320.0);

    // ✅ 접힘: 작게
    final collapsedH = (h * 0.14).clamp(84.0, 140.0);

    _collapseRange = expandedH - collapsedH;

    return Scaffold(
      body: Listener(
        onPointerUp: _onPointerUp,
        child: CustomScrollView(
          controller: _controller,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              stretch: false,
              floating: false,
              snap: false,
              expandedHeight: expandedH,
              collapsedHeight: collapsedH,
              toolbarHeight: 0,
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              flexibleSpace: _CatHeroHeader(cat: selectedCat),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderControlsRow(
                      cat: selectedCat,
                      onTapCatPicker: () => _showCatPickerSheet(context, ref, cats, selectedCatId),
                      onTapCatInfo: () => _showCatInfoSheet(context, selectedCat),
                      onTapSettings: () => context.push('/settings'),
                    ),
                    const SizedBox(height: 14),

                    // ✅ 팝업(QuickEntrySheet) 대신 입력 화면으로 이동하도록 QuickActions 자체가 라우팅함
                    if (selectedCatId != null)
                      QuickActions(catId: selectedCatId)
                    else
                      const SizedBox(height: 104),

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    TodaySummaryCard(summary: summary),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    TimelineSection(entries: entries),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCatInfoSheet(BuildContext context, CatProfile? cat) {
    if (cat == null) return;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: _CatThumb(photoUrl: cat.photoUrl, photoPath: cat.photoPath, size: 40),
                title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text([
                  if ((cat.sex ?? '').isNotEmpty) '성별 ${cat.sex}',
                  if ((cat.breed ?? '').isNotEmpty) '묘종 ${cat.breed}',
                ].join(' · ')),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/cats/${cat.id}/edit');
                },
                child: const Text('프로필 편집'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCatPickerSheet(
      BuildContext context,
      WidgetRef ref,
      List<CatProfile> cats,
      String? selectedCatId,
      ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 8, 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('반려묘 선택', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    IconButton(
                      tooltip: '설정',
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/cats/settings');
                      },
                      icon: const Icon(Icons.settings),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final c in cats)
                      ListTile(
                        leading: _CatThumb(photoUrl: c.photoUrl, photoPath: c.photoPath, size: 40),
                        title: Text(c.name),
                        trailing: (c.id == selectedCatId) ? const Icon(Icons.check) : null,
                        onTap: () {
                          ref.read(selectedCatIdProvider.notifier).select(c.id);
                          Navigator.pop(context);
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _CatHeroHeader extends StatelessWidget {
  final CatProfile? cat;

  const _CatHeroHeader({required this.cat});

  @override
  Widget build(BuildContext context) {
    final photoUrl = (cat?.photoUrl ?? '').trim();
    final photoPath = (cat?.photoPath ?? '').trim();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (photoPath.isNotEmpty)
            Image.file(File(photoPath), fit: BoxFit.cover)
          else if (_isNetworkUrl(photoUrl))
            Image.network(photoUrl, fit: BoxFit.cover)
          else
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(child: Icon(Icons.pets, size: 72)),
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00000000),
                  Color(0x66000000),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderControlsRow extends StatelessWidget {
  final CatProfile? cat;
  final VoidCallback onTapCatPicker;
  final VoidCallback onTapCatInfo;
  final VoidCallback onTapSettings;

  const _HeaderControlsRow({
    required this.cat,
    required this.onTapCatPicker,
    required this.onTapCatInfo,
    required this.onTapSettings,
  });

  @override
  Widget build(BuildContext context) {
    final name = cat?.name ?? '고양이 선택';

    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTapCatInfo,
          child: _CatThumb(photoUrl: cat?.photoUrl, photoPath: cat?.photoPath, size: 44),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTapCatPicker,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.expand_more, size: 20),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: '설정',
          onPressed: onTapSettings,
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }
}

class _CatThumb extends StatelessWidget {
  final String? photoUrl;
  final String? photoPath;
  final double size;

  const _CatThumb({required this.photoUrl, required this.photoPath, required this.size});

  @override
  Widget build(BuildContext context) {
    final url = (photoUrl ?? '').trim();
    final path = (photoPath ?? '').trim();
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        image: path.isNotEmpty
            ? DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover)
            : _isNetworkUrl(url)
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : null,
      ),
      child: (path.isEmpty && !_isNetworkUrl(url)) ? const Icon(Icons.pets) : null,
    );
  }
}

bool _isNetworkUrl(String s) => s.startsWith('http://') || s.startsWith('https://');
