import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'home_page.dart' show TabType;

class HomeTabConfigPage extends StatefulWidget {
  const HomeTabConfigPage({super.key});

  @override
  State<HomeTabConfigPage> createState() => _HomeTabConfigPageState();
}

class _HomeTabConfigPageState extends State<HomeTabConfigPage> {
  late List<TabType> _tabs;

  static const List<TabType> _allTabs = [
    TabType.APP,
    TabType.FEED,
    TabType.HOT,
    TabType.NEWS,
    TabType.TOPIC,
    TabType.PRODUCT,
    TabType.COOLPIC,
  ];

  @override
  void initState() {
    super.initState();
    _tabs = _loadTabs();
  }

  List<TabType> _loadTabs() {
    final saved = Hive.box('settings').get('homeTabOrder', defaultValue: <String>[]) as List<dynamic>;
    final names = saved.map((item) => item.toString()).toList();
    final visible = <TabType>[];
    for (final tab in _allTabs) {
      if (names.contains(tab.name)) {
        visible.add(tab);
      }
    }
    if (visible.isEmpty) {
      return _allTabs;
    }
    return visible;
  }

  void _saveTabs() {
    final names = _tabs.map((tab) => tab.name).toList();
    Hive.box('settings').put('homeTabOrder', names);
  }

  void _toggleTab(TabType tab) {
    setState(() {
      if (_tabs.contains(tab)) {
        if (_tabs.length == 1) return;
        _tabs.remove(tab);
      } else {
        _tabs.add(tab);
      }
      _saveTabs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页栏目'),
      ),
      body: ReorderableListView(
        padding: const EdgeInsets.all(16),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = _tabs.removeAt(oldIndex);
            _tabs.insert(newIndex, item);
            _saveTabs();
          });
        },
        children: [
          for (int index = 0; index < _tabs.length; index++)
            CheckboxListTile(
              key: ValueKey(_tabs[index]),
              value: true,
              title: Text(_tabs[index].label),
              onChanged: (_) => _toggleTab(_tabs[index]),
            ),
          for (final tab in _allTabs)
            if (!_tabs.contains(tab))
              CheckboxListTile(
                key: ValueKey('hidden-${tab.name}'),
                value: false,
                title: Text(tab.label),
                onChanged: (_) => _toggleTab(tab),
              ),
        ],
      ),
    );
  }
}
