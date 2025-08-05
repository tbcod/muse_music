import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:music_muse/util/log.dart';
import 'package:music_muse/util/tba/tba_util.dart';

class EventUtils {
  EventUtils._internal();

  static final EventUtils _instance = EventUtils._internal();

  static EventUtils get instance {
    return _instance;
  }

  //添加事件
  Future addEvent(String id, {Map<String, Object>? data}) async {
    //TODO 测试时候不处理事件
    // return;

    // AppLog.i("tbaevent name:$id,data:$data");

    id = "mm_$id";
    //事件上报接口
    postEventApi(id, data: data);

    //firebase事件
    await FirebaseAnalytics.instance.logEvent(name: id, parameters: data);
  }

  void postEventApi(String id, {Map<String, dynamic>? data}) async {
    var result = await TbaUtils.instance.postEvent(id, data);
    // Log.e("上报结果:${result.toJson()}");
  }
}
