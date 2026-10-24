import '../../../logic/network/network_repo.dart';
import '../../../logic/state/loading_state.dart';
import '../../../pages/common/common_controller.dart';
import '../../../pages/home/home_page.dart' show TabType;

class HomeFeedController extends CommonController {
  HomeFeedController({
    required this.tabType,
    required this.installTime,
    this.url,
    this.title,
  });

  final TabType tabType;
  final String installTime;
  int firstLaunch = 1;
  String? url;
  String? title;

  @override
  Future<LoadingState> customGetData() {
    return switch (tabType) {
      TabType.FEED => NetworkRepo.getHomeFeed(
          page: page,
          firstLaunch: firstLaunch,
          installTime: installTime,
          firstItem: firstItem,
          lastItem: lastItem,
        ),
      TabType.HOT => NetworkRepo.getDataList(
          url: '/page?url=V9_HOME_TAB_RANKING',
          title: '热榜',
          subTitle: '',
          firstItem: firstItem,
          lastItem: lastItem,
          page: page,
        ),
      TabType.NEWS => NetworkRepo.getDataList(
          url: '/page?url=V11_HOME_TAB_NEWS',
          title: '快讯',
          subTitle: '',
          firstItem: firstItem,
          lastItem: lastItem,
          page: page,
        ),
      TabType.COOLPIC => NetworkRepo.getDataList(
          url: '/page?url=V11_FIND_COOLPIC',
          title: '酷图',
          subTitle: '',
          firstItem: firstItem,
          lastItem: lastItem,
          page: page,
        ),
      _ => NetworkRepo.getDataList(
          url: url ?? '',
          title: title ?? '首页',
          subTitle: '',
          firstItem: firstItem,
          lastItem: lastItem,
          page: page,
        ),
    };
  }

  @override
  void onInit() {
    super.onInit();
    onGetData();
  }
}

