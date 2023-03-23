#if UNIT_TEST
namespace Test_DictOfTrackOfTheDayEntry_WriteLog {
  /* Test // Mixin: Common Testing */
  void Tests_RegisterAll_DictOfTrackOfTheDayEntry_WriteLog_CommonTesting() {
    RegisterUnitTest('UnitTest_Common_Nop', UnitTest_Common_Nop);
  }
  
  bool runAsync(CoroutineFunc@ func) {
    startnew(func);
    return true;
  }
  
  void assert(bool condition, const string &in msg) {
    if (!condition) {
      throw('Assert failed: ' + msg);
    }
  }
  
  void debug_trace(const string &in msg) {
    trace(msg);
  }
  
  int countFileLines(const string &in path) {
    IO::File f(path, IO::FileMode::Read);
    string contents = f.ReadToEnd();
    f.Close();
    return contents.Split('\n').Length - (contents.EndsWith('\n') ? 1 : 0);
  }
  
  void UnitTest_Common_Nop() {
  }
  
  bool unitTestResults_DictOfTrackOfTheDayEntry_WriteLog_CommonTesting = runAsync(Tests_RegisterAll_DictOfTrackOfTheDayEntry_WriteLog_CommonTesting);
  
  /* Test // Mixin: Dict Backing */
  void Tests_RegisterAll_DictOfTrackOfTheDayEntry_WriteLog_DictBacking() {
    RegisterUnitTest('UnitTest_DictBacking_DictOfTrackOfTheDayEntry_WriteLog', UnitTest_DictBacking_DictOfTrackOfTheDayEntry_WriteLog);
  }
  
  bool Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(DictOfTrackOfTheDayEntry_WriteLog@ testDict, uint n, const string &in key, TrackOfTheDayEntry@ value) {
    testDict.Set(key, value);
    _DictOfTrackOfTheDayEntry_WriteLog::KvPair@ tmpKV = _DictOfTrackOfTheDayEntry_WriteLog::KvPair(key, value);
    string e = ' for test #' + n + ', k: ' + key;
    assert(value == testDict.Get(key), '.Get' + e);
    assert(value == testDict[key], '.opIndex' + e);
    assert(testDict.Exists(key), '.Exists' + e);
    assert(testDict.GetItem(key) == tmpKV, '.GetItem' + e);
    assert(n == testDict.GetSize(), '.GetSize' + e);
    assert(n == testDict.GetKeys().Length, '.GetKeys.Length' + e);
    assert(n == testDict.GetItems().Length, '.GetItems.Length' + e);
    assert(0 <= testDict.GetKeys().Find(key), '.GetKeys.Find' + e);
    assert(testDict.Delete(key), '.Delete' + e);
    assert(n == testDict.GetSize() + 1, '.GetSize+1' + e);
    assert(!testDict.Exists(key), '!.Exists' + e);
    testDict.Set(key, value);
    yield();
    return true;
  }
  
  void UnitTest_DictBacking_DictOfTrackOfTheDayEntry_WriteLog() {
    if (IO::FileExists(IO::FromDataFolder('Storage/codegenTest/test') + '/' + 'DictOfTrackOfTheDayEntry_WriteLog.txt')) {
      IO::Delete(IO::FromDataFolder('Storage/codegenTest/test') + '/' + 'DictOfTrackOfTheDayEntry_WriteLog.txt');
    }
    DictOfTrackOfTheDayEntry_WriteLog@ testDict = DictOfTrackOfTheDayEntry_WriteLog(IO::FromDataFolder('Storage/codegenTest/test'), 'DictOfTrackOfTheDayEntry_WriteLog.txt');
    if (testDict.GetSize() > 0) {
      testDict.DeleteAll();
    }
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 1, "⃐빌ᗙᕱ꥞䞥᭖䍵", TrackOfTheDayEntry(806449, "㦁", 158112, 26688, "籤뗷쫷", 495249, 450933));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 2, "㵜ܘ閿", TrackOfTheDayEntry(444245, "뼙﷞䷨乄", 226339, 770474, "칍", 325502, 225525));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 3, "䚃ꑒ鼑혅凐優缴댷", TrackOfTheDayEntry(451852, "㰎ॵ覫돬홊稛㏭捪氏鰥", 510574, 705053, "ʿꤜ즱妖䜇붧", 183742, 679591));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 4, "霆ս㈖瑅㏣咊䈍4ᥜ", TrackOfTheDayEntry(936167, "ٵ", 834852, 695690, "謓฼叆䈋㷸㕈�", 461061, 188916));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 5, "暹ꝝ벤゜皁뾞䉫ޒ", TrackOfTheDayEntry(95984, "㤯沣﯄ஂ", 432877, 369191, "㠘풂", 585107, 691526));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 6, "쁇愾ࡽ", TrackOfTheDayEntry(839412, "", 446794, 236480, "堙艚泄釳", 751539, 474842));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 7, "˔", TrackOfTheDayEntry(716096, "㘇径밋㧀䊧쪘싣Ｋ", 734568, 318816, "璢뎙�葘ꫵ悂ꝁ", 900978, 26839));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 8, "㥾ﹲ缂釺耄隒喠�", TrackOfTheDayEntry(201094, "⬺ʁ籁蔒헃", 925762, 639814, "�燨捞ῧ泦", 463145, 18461));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 9, "柳䊬폥꒠퉝更誓皵䯬", TrackOfTheDayEntry(548107, "ᑐ㥠⍟", 512590, 479693, "믕㸊奯숑㚯붣쮑ꡛ쏜", 607425, 321767));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 10, "ƣ튧", TrackOfTheDayEntry(797693, "�餥娧礁밵", 423678, 703463, "ᣃ刖ꛥｇ믡", 975376, 502637));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 11, "ﱋ⌎媑", TrackOfTheDayEntry(568243, "ꣵ죰爲", 158875, 33820, "㧱홨�䛊⳱獡", 537084, 432401));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 12, "쐁", TrackOfTheDayEntry(411556, "簁劀ޓ匴薻릃难꘱䮲", 585360, 580942, "膺ᓣ㔺͒桝흭扑㒽㰹", 403509, 482398));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 13, "ᡅ㿎휹ᬸꤏꋹ᧿뛀", TrackOfTheDayEntry(761761, "쫫", 411220, 413050, "ख़쿘죃ٽ鋷⠺", 619189, 233768));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 14, "", TrackOfTheDayEntry(594041, "", 503641, 723321, "㊚⊚嘄﬛၇橩먴", 849589, 902000));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 15, "寗��饾㦐", TrackOfTheDayEntry(416852, "：쫂ᜪꥶ詊讳", 746274, 737342, "宄᮰㍟퐮巧滯", 238760, 934685));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 16, "畗⚻ꜚ嵡᷂ꏨ", TrackOfTheDayEntry(429315, "敢諗뗛悗畆", 340926, 790018, "딫펥䑽ࡰ�", 416798, 333499));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 17, "ម흃鑳耮⠸ꀞ㪑蔇", TrackOfTheDayEntry(610575, "箱ﴩ", 543551, 937066, "┪�ဩ쓋乪剤", 94078, 226219));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 18, "۸", TrackOfTheDayEntry(230141, "嶁ড়鏧呲䞿렀", 159506, 880099, "멃㳦꛹槛컙瞘䝩땑", 489156, 841143));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 19, "땒", TrackOfTheDayEntry(811641, "ɔ⺫", 466790, 745872, "ꑽ欄풼♃", 252552, 884560));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 20, "ꕱ⵺ᬒ", TrackOfTheDayEntry(889671, "", 975797, 446175, "ᨛ清鏵�Ḏ", 744201, 374046));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 21, "췲뫤귷軿賨㠙", TrackOfTheDayEntry(988757, "厘읶㥄伟", 748245, 296832, "�蔵ጄ㱛㩧", 434959, 477704));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 22, "덲ᆰ씳҄�ㄠꍝ芉햺䎬", TrackOfTheDayEntry(231734, "䅠", 536618, 172472, "藜㯓㑫峋", 761573, 65550));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 23, "亿⟻᏷椈佟䏼௥�漉", TrackOfTheDayEntry(659197, "", 175893, 248962, "蓐", 372790, 295452));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 24, "年鴔꠿र칛첑彠", TrackOfTheDayEntry(263770, "", 687257, 683444, "�츺⋧保퓖躱阘㸄ꖡ", 677495, 958630));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 25, "찙婁", TrackOfTheDayEntry(360745, "ꅥ﫵ꫯ詡ࣲ'壯⹋", 532580, 111985, "꼮䱹㠀", 846539, 603080));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 26, "蘗膐Ζ쇛台柖ꞑ䉾", TrackOfTheDayEntry(501966, "펌㙪ᮑ䲲㜡鞰帚ꮛ", 297191, 490607, "鳃왚꛾䄁អ棩", 589488, 492686));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 27, "䎏燑ﻜ檈쾮蛣", TrackOfTheDayEntry(933037, "鷇㧭뚳틽駌䅋", 738252, 633782, "쟴訛팖Śਛ젦釞吠", 740808, 67327));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 28, "ᢪꃀݝ㢗鏯", TrackOfTheDayEntry(917094, "짭", 647879, 919191, "텙è", 710114, 313471));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 29, "ꕈ⃱혳ᬪ섣婄筙俚ʊ郰", TrackOfTheDayEntry(225203, "껍Ṑ䰯繷⩷謝㱮奜", 158208, 409653, "⸹䅒ꉓ虸팊ᐢ", 649272, 945936));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 30, "⛫꧷ᑛ开�퓔炵Ⴏ", TrackOfTheDayEntry(547731, "", 472215, 264308, "", 837904, 822710));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 31, "㎄䰸࢕쿅", TrackOfTheDayEntry(107012, "Ფ褐怺㠂챡ὰ䙛", 838377, 513575, "", 703490, 485744));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 32, "", TrackOfTheDayEntry(779662, "웪鑟㓹", 773127, 900678, "㵾⚿벣", 149057, 994865));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 33, "뻲͉", TrackOfTheDayEntry(776412, "⽈쏎ﴣ㩔Ἃ", 894474, 544849, "㭘⹯탳ꍏ趼㏰栝", 567702, 932372));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 34, "ꦰ⾩錛居芟큳괛䆏䨄ᤰ", TrackOfTheDayEntry(44703, "廥绢␪䅇瓉赼끓切ꎕ", 770614, 711502, "", 134600, 811));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 35, "ᲁᝁ꾿൚Ӑ鲵粮", TrackOfTheDayEntry(45715, "㮚", 946620, 336000, "ೆ", 179049, 388704));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 36, "拲艱ឥͶ葾볡怡ݴⰄ", TrackOfTheDayEntry(629138, "清ↈ髞鼻䧭", 958545, 68787, "폁趗婆引兘뛮��", 80948, 811357));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 37, "燷⑅┠◚〥鑨釅艵", TrackOfTheDayEntry(865567, "肮⇭�ራ䀄乡웪ǿ", 982822, 330394, "ꓻ親꬈䂺", 106838, 614309));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 38, "ẕᶯ낪辸⏱霅眾讅䃻", TrackOfTheDayEntry(934603, "虰ҭ㶂㲺ㄖઃ", 597830, 741691, "툩晍睵A雖ᖦ", 395476, 306396));
    Test_ProxyFns_DictOfTrackOfTheDayEntry_WriteLog(testDict, 39, "흱病磙", TrackOfTheDayEntry(911765, "꧈ົͥ瓩ᦽ�∠၌", 539335, 984252, "", 957359, 742441));
    // del testDict; // todo: destroy obj but not data.
    auto kvs = testDict.GetItems();
    @testDict = DictOfTrackOfTheDayEntry_WriteLog(IO::FromDataFolder('Storage/codegenTest/test'), 'DictOfTrackOfTheDayEntry_WriteLog.txt');
    testDict.AwaitInitialized();
    assert(39 == testDict.GetSize(), 'Init size after reloading from disk, was: ' + testDict.GetSize() + ' from file ' + IO::FromDataFolder('Storage/codegenTest/test') + '/' + 'DictOfTrackOfTheDayEntry_WriteLog.txt');
    for (uint i = 0; i < kvs.Length; i++) {
      auto kv = kvs[i];
      assert(kv.val == testDict.Get(kv.key), 'Key ' + kv.key + ' did not match expected.');
    }
    testDict.DeleteAll();
    assert(0 == testDict.GetSize(), '.DeleteAll');
  }
  
  bool unitTestResults_DictOfTrackOfTheDayEntry_WriteLog_DictBacking = runAsync(Tests_RegisterAll_DictOfTrackOfTheDayEntry_WriteLog_DictBacking);
}
#endif