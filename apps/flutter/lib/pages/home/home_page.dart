// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/mouse_drag_scroll.dart';
import '../../pages/home/app/app_list_page.dart';
import '../../pages/home/feed/home_feed_page.dart';
import '../../pages/home/return_top_controller.dart';
import '../../pages/home/topic/home_topic_page.dart';
import '../../utils/storage_util.dart';

enum TabType {
  FOLLOW,
  APP,
  FEED,
  HOT,
  NEWS,
  TOPIC,
  PRODUCT,
  COOLPIC,
  NONE;

  String get label => switch (this) {
        TabType.FOLLOW => '关注',
        TabType.APP => '应用',
        TabType.FEED => '动态',
        TabType.HOT => '热门',
        TabType.NEWS => '快讯',
        TabType.TOPIC => '话题',
        TabType.PRODUCT => '数码',
        TabType.COOLPIC => '酷图',
        TabType.NONE => '其他',
      };
}

class HomeTabSettings {
  static List<TabType> get defaultTabs {
    return [
      TabType.FEED,
      TabType.NEWS,
      TabType.HOT,
      TabType.TOPIC,
      TabType.PRODUCT,
      TabType.COOLPIC,
    ];
  }

  static List<TabType> loadVisibleTabs() {
    final savedNames = GStorage.homeTabOrder;
    if (savedNames.isEmpty) {
      return defaultTabs;
    }

    final selected = <TabType>[];
    for (final tab in defaultTabs) {
      if (savedNames.contains(tab.name)) {
        selected.add(tab);
      }
    }

    return selected.isNotEmpty ? selected : defaultTabs;
  }

  static void saveVisibleTabs(List<TabType> tabs) {
    GStorage.setHomeTabOrder(tabs.map((tab) => tab.name).toList());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  StreamSubscription<int>? _returnTopSubscription;
  final ReturnTopController _pageScrollController =
      Get.find<ReturnTopController>(tag: 'home');
  late List<TabType> _tabTypes;

  List<Widget> _buildPages(List<TabType> tabTypes) {
    final pages = <Widget>[];
    for (final tabType in tabTypes) {
      switch (tabType) {
        case TabType.APP:
          pages.add(const AppListPage());
        case TabType.FEED:
          pages.add(const HomeFeedPage(tabType: TabType.FEED));
        case TabType.HOT:
          pages.add(const HomeFeedPage(tabType: TabType.HOT));
        case TabType.NEWS:
          pages.add(const HomeFeedPage(tabType: TabType.NEWS));
        case TabType.TOPIC:
          pages.add(const HomeTopicPage(tabType: TabType.TOPIC));
        case TabType.PRODUCT:
          pages.add(const HomeTopicPage(tabType: TabType.PRODUCT));
        case TabType.COOLPIC:
          pages.add(const HomeFeedPage(tabType: TabType.COOLPIC));
        case TabType.FOLLOW:
        case TabType.NONE:
          pages.add(const SizedBox());
      }
    }
    return pages;
  }

  bool _tabsEqual(List<TabType> left, List<TabType> right) {
    if (left.length != right.length) {
      return false;
    }
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) {
        return false;
      }
    }
    return true;
  }

  void _syncTabsFromSettings() {
    final nextTabs = HomeTabSettings.loadVisibleTabs();
    if (_tabsEqual(_tabTypes, nextTabs)) {
      return;
    }

    final currentIndex = _tabController.index.clamp(0, nextTabs.length - 1);
    _tabController.dispose();
    _tabController = TabController(
      vsync: this,
      initialIndex: currentIndex,
      length: nextTabs.length,
    );
    _tabTypes = nextTabs;
  }

  void scrollToTop(int index) {
    _pageScrollController.setIndex(_tabTypes[index].index);
  }

  @override
  void initState() {
    super.initState();
    _tabTypes = HomeTabSettings.loadVisibleTabs();
    _tabController = TabController(
      vsync: this,
      initialIndex: _tabTypes.indexOf(TabType.FEED) >= 0
          ? _tabTypes.indexOf(TabType.FEED)
          : 0,
      length: _tabTypes.length,
    );

    _returnTopSubscription = _pageScrollController.index.listen((index) {
      if (index == 998) {
        scrollToTop(_tabController.index);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextTabs = HomeTabSettings.loadVisibleTabs();
    if (!_tabsEqual(_tabTypes, nextTabs)) {
      _syncTabsFromSettings();
    }
  }

  @override
  void dispose() {
    _returnTopSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _syncTabsFromSettings();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: MouseDragScroll(
          child: TabBar(
            controller: _tabController,
            tabs: _tabTypes.map((type) => Tab(text: type.label)).toList(),
            isScrollable: true,
            onTap: (index) {
              if (!_tabController.indexIsChanging) {
                scrollToTop(index);
              }
            },
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/search'),
            icon: const Icon(Icons.search),
            tooltip: '搜索',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: _buildPages(_tabTypes),
      ),
    );
  }
}

