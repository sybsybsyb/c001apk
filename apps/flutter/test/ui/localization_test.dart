        await tester.drag(target, const Offset(260, 0), kind: kind);
        await tester.pumpAndSettle();
        expect(position.pixels, closeTo(before, 2));
        await tester.tap(find.widgetWithText(Tab, '热门'));
        await tester.pumpAndSettle();
        final hotIndex = tester
            .widget<TabBar>(find.byType(TabBar).first)
            .tabs
            .indexWhere((widget) => widget is Tab && widget.text == '热门');
        expect(homeTabs.index, hotIndex,
            reason: 'The selected home tab should follow the actual tab order');
        await tester.pumpWidget(const SizedBox.shrink());