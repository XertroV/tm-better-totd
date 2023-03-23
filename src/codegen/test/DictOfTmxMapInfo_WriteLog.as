#if UNIT_TEST
namespace Test_DictOfTmxMapInfo_WriteLog {
  /* Test // Mixin: Common Testing */
  void Tests_RegisterAll_DictOfTmxMapInfo_WriteLog_CommonTesting() {
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
  
  bool unitTestResults_DictOfTmxMapInfo_WriteLog_CommonTesting = runAsync(Tests_RegisterAll_DictOfTmxMapInfo_WriteLog_CommonTesting);
  
  /* Test // Mixin: Dict Backing */
  void Tests_RegisterAll_DictOfTmxMapInfo_WriteLog_DictBacking() {
    RegisterUnitTest('UnitTest_DictBacking_DictOfTmxMapInfo_WriteLog', UnitTest_DictBacking_DictOfTmxMapInfo_WriteLog);
  }
  
  bool Test_ProxyFns_DictOfTmxMapInfo_WriteLog(DictOfTmxMapInfo_WriteLog@ testDict, uint n, const string &in key, TmxMapInfo@ value) {
    testDict.Set(key, value);
    _DictOfTmxMapInfo_WriteLog::KvPair@ tmpKV = _DictOfTmxMapInfo_WriteLog::KvPair(key, value);
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
  
  void UnitTest_DictBacking_DictOfTmxMapInfo_WriteLog() {
    if (IO::FileExists(IO::FromDataFolder('Storage/codegenTest/test') + '/' + 'DictOfTmxMapInfo_WriteLog.txt')) {
      IO::Delete(IO::FromDataFolder('Storage/codegenTest/test') + '/' + 'DictOfTmxMapInfo_WriteLog.txt');
    }
    DictOfTmxMapInfo_WriteLog@ testDict = DictOfTmxMapInfo_WriteLog(IO::FromDataFolder('Storage/codegenTest/test'), 'DictOfTmxMapInfo_WriteLog.txt');
    if (testDict.GetSize() > 0) {
      testDict.DeleteAll();
    }
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 1, "⃐빌ᗙᕱ꥞䞥᭖䍵", TmxMapInfo(806449, "㦁", MaybeOfString("셜睟捡ᑽ계揨"), {-327966, 584122, 450933}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 2, "㵜", TmxMapInfo(444245, "뼙﷞䷨乄", MaybeOfString("㩩捠蛅躒횪"), {325502, -172486}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 3, "댷턾", TmxMapInfo(451852, "㰎ॵ覫돬홊稛㏭捪氏鰥", MaybeOfString("쳘䛋��"), {729753, -681338, 949667, -927237}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 4, "㏣咊䈍4ᥜ勼ⲓ", TmxMapInfo(922877, "㕈�뙷瀊喘ٵ搕霆ս", MaybeOfString("땫쿅鑚豾ꗄ慙벗篽"), {-383238, -349923, 250335, -151673}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 5, "暹", TmxMapInfo(95984, "㤯沣﯄ஂ", MaybeOfString("줅櫹է"), {691526, 585107, -135072}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 6, "쁇愾ࡽ", TmxMapInfo(839412, "", MaybeOfString("Ѱѡ꣐찊튩筪㮪"), {-255495, -401011}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 7, "싣Ｋꚛ躩˔�", TmxMapInfo(97308, "悂ꝁ聞풖Ⓑ㘇径밋", MaybeOfString("ꩰ宍�뤯Ԥ妳᧡鷲"), {304899, -268162, 729909}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 8, "㥾ﹲ", TmxMapInfo(201094, "⬺ʁ籁蔒헃", MaybeOfString("⟳"), {-958925, 491609, 312418}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 9, "뜟�", TmxMapInfo(463145, "뗖튧", MaybeOfString("苀睇�८詙ퟶ釘躟ᇗ"), {-802982, -402401, 275210, 548107}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 10, "⤫愪ᑐ", TmxMapInfo(525381, "숑㚯붣쮑", MaybeOfString("ઝ紤⛍射톀먿်ছ"), {-223171, 669588, 38734}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 11, "똘ꌣ皈", TmxMapInfo(275291, "ᣃ刖ꛥ", MaybeOfString("䠋"), {-480985, 502637, -473581}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 12, "徱ﱋ⌎媑", TmxMapInfo(568243, "ꣵ죰爲", MaybeOfString("밹硞䫜"), {-106857, 928716}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 13, "홨�䛊", TmxMapInfo(65272, "撏雇", MaybeOfString(), {411556, 698106, 381848, 432401}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 14, "簁劀ޓ匴薻릃难꘱䮲", TmxMapInfo(585360, "͒桝흭扑㒽㰹Ἒ", MaybeOfString("㷾䎠뿺䗱ⰟΗ픚딦"), {-193242, 921016, -83800, 946614}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 15, "氊❘刑ᡅ㿎", TmxMapInfo(658988, "죃ٽ鋷⠺닮䤡", MaybeOfString("杯✺萫埻"), {-103944}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 16, "呱鋜髫➙꟒", TmxMapInfo(86311, "橩먴�ຸ趓", MaybeOfString("時ﭠ宂귓ᚑ蠠輥흳"), {-489890}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 17, "�", TmxMapInfo(669843, "", MaybeOfString("艿"), {746274, -743685, 992595}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 18, "巧滯鷚�詛芑", TmxMapInfo(531935, "⇗㸣ᠼ❰Ꝁ둑❶宄᮰", MaybeOfString("珡欣芏훓ﯱꎸ"), {604082, -623796, 251008, 642628}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 19, "펥䑽ࡰ�뎽䡚俄岵ᨪ敢", TmxMapInfo(416798, "ꀞ㪑蔇ꈟ", MaybeOfString("薂姯"), {910429, -295385, 610575, -894187}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 20, "ꑐ㷠얌苫頜", TmxMapInfo(937066, "┪�ဩ쓋乪剤", MaybeOfString("鬌"), {-153374, -764722, 864384, 226219}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 21, "렀둭껦퓵뺟⪂", TmxMapInfo(411634, "攃嶁ড়", MaybeOfString("榟줢딥륡䍼ﶌ쾎賍⚠싉"), {-185439, 841143, -229893, 489156}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 22, "杒Ꜯɔ⺫晋败", TmxMapInfo(464164, "᱒ꑽ", MaybeOfString("笣戇"), {889671, -834551}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 23, "㥄伟녈ꎨ", TmxMapInfo(748245, "꛸�蔵ጄ㱛㩧⸎", MaybeOfString(), {-786714, 444121, -47754, 563116}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 24, "ㄠ", TmxMapInfo(876609, "덲ᆰ", MaybeOfString("ꠎ믱礵晴츽"), {215078, 172472}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 25, "௥�漉ᖔ⬚줏藜㯓㑫", TmxMapInfo(662270, "㢺䰍亿⟻᏷椈", MaybeOfString("紭켩Ȭ쀤Ꚅ"), {-496613}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 26, "밃끻年鴔꠿र칛", TmxMapInfo(193441, "럀", MaybeOfString(), {-613807, -186690, 597450, 616677}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 27, "保", TmxMapInfo(217361, "퇰�", MaybeOfString("薦䨷"), {360516}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 28, "ꫯ詡ࣲ'壯⹋࡭Þ찙", TmxMapInfo(648241, "꼮䱹㠀ʿ穅�㡲걟蕅꠭", MaybeOfString("▵�蠚ʿ"), {764980, 551147, 577275}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 29, "鳃왚꛾䄁អ棩", TmxMapInfo(589488, "ꀠ", MaybeOfString(), {441812}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 30, "ꊟ", TmxMapInfo(517188, "펼藹嶦巯ฐ�悅", MaybeOfString("﵋쏥暸冫敬霧랜佘�ײ"), {799635, 933037, -62072}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 31, "뻏䎟鷇㧭뚳틽駌", TmxMapInfo(633782, "쟴訛팖Śਛ젦釞吠", MaybeOfString("㛨했䷂⛇≌㯩"), {647879, -634216, -330800, 917094}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 32, "㽗뜐텙è핊摝", TmxMapInfo(710114, "熭贮봣靈샣", MaybeOfString(), {794855, -658450, -105268, 874906}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 33, "俚ʊ郰ፄ훺Ṁ龪흛뾫", TmxMapInfo(238190, "⃱혳ᬪ섣", MaybeOfString("ﹳ͂"), {-111030}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 34, "恱", TmxMapInfo(485744, "", MaybeOfString(""), {-367569, 779662}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 35, "夞芨웪鑟", TmxMapInfo(900678, "㵾⚿벣", MaybeOfString(), {-424898, -626647, -328090}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 36, "돍뾔뻲͉", TmxMapInfo(978462, "䱒ገ䒥㝬⽈쏎ﴣ", MaybeOfString("᫔临侖Ṥ"), {-778130, 810100}));
    Test_ProxyFns_DictOfTmxMapInfo_WriteLog(testDict, 37, "୫", TmxMapInfo(932372, "", MaybeOfString("綞꽌ؓᏪ"), {44070}));
    // del testDict; // todo: destroy obj but not data.
    auto kvs = testDict.GetItems();
    @testDict = DictOfTmxMapInfo_WriteLog(IO::FromDataFolder('Storage/codegenTest/test'), 'DictOfTmxMapInfo_WriteLog.txt');
    testDict.AwaitInitialized();
    assert(37 == testDict.GetSize(), 'Init size after reloading from disk, was: ' + testDict.GetSize() + ' from file ' + IO::FromDataFolder('Storage/codegenTest/test') + '/' + 'DictOfTmxMapInfo_WriteLog.txt');
    for (uint i = 0; i < kvs.Length; i++) {
      auto kv = kvs[i];
      assert(kv.val == testDict.Get(kv.key), 'Key ' + kv.key + ' did not match expected.');
    }
    testDict.DeleteAll();
    assert(0 == testDict.GetSize(), '.DeleteAll');
  }
  
  bool unitTestResults_DictOfTmxMapInfo_WriteLog_DictBacking = runAsync(Tests_RegisterAll_DictOfTmxMapInfo_WriteLog_DictBacking);
}
#endif