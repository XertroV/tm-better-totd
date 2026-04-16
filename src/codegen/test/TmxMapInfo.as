#if UNIT_TEST
namespace Test_TmxMapInfo {
  /* Test // Mixin: Common Testing */
  void Tests_RegisterAll_TmxMapInfo_CommonTesting() {
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

  bool unitTestResults_TmxMapInfo_CommonTesting = runAsync(Tests_RegisterAll_TmxMapInfo_CommonTesting);

  /* Test // Mixin: Getters */
  void Tests_RegisterAll_TmxMapInfo_Getters() {
    RegisterUnitTest('UnitTest_TmxMapInfo_Getters', UnitTest_TmxMapInfo_Getters);
  }

  bool Test_CheckProps_TmxMapInfo(uint TrackID, const string &in Name, const int[] &in Tags) {
    TmxMapInfo@ tmp = TmxMapInfo(TrackID, Name, Tags);
    assert(TrackID == tmp.TrackID, 'field TrackID with value `' + TrackID + '`');
    assert(Name == tmp.Name, 'field Name with value `' + Name + '`');
    assert(Tags == tmp.Tags, 'field Tags');
    return true;
  }

  void UnitTest_TmxMapInfo_Getters() {
    Test_CheckProps_TmxMapInfo(394184, "馩", {-688098, -638276});
    Test_CheckProps_TmxMapInfo(378662, "╝㸌鐁", {-349523, -853677, 402441, -622649});
    Test_CheckProps_TmxMapInfo(464786, "鳔ꂆऒ涮�뗗", {36088, 212517, 440746, -191800});
    Test_CheckProps_TmxMapInfo(55244, "⨸۫芁≲彲⏈먳�", {321608});
    Test_CheckProps_TmxMapInfo(715346, "㷗᤾虝", {-2471});
    Test_CheckProps_TmxMapInfo(149817, "那", {-724051, -702926});
    Test_CheckProps_TmxMapInfo(425498, "", {-732789});
    Test_CheckProps_TmxMapInfo(719653, "�拣䵱䌏", {-863655, -723578});
    Test_CheckProps_TmxMapInfo(983172, "䤩䇢�뽥", {643726, 457496, 183274, 837902});
    Test_CheckProps_TmxMapInfo(6143, "뭷┼쿽騍큋㈣揘䢊儞祹", {458500, -180567, 191510});
    Test_CheckProps_TmxMapInfo(985736, "㪂", {-122193, -692074, -801994});
    Test_CheckProps_TmxMapInfo(945399, "", {-774052});
    Test_CheckProps_TmxMapInfo(363342, "", {702564, -47836, -683839, 258145});
    Test_CheckProps_TmxMapInfo(816997, "㩾껫墰菌㶑ꔘₜ齬", {-786142, -611149, 153273});
    Test_CheckProps_TmxMapInfo(853065, "�ꒉ㳀䈾뙱䕂륦홰", {-139333, 89935});
    Test_CheckProps_TmxMapInfo(469141, "胊의䉶杻�죝ᝫ᥾", {-147055, -693731, -301873});
    Test_CheckProps_TmxMapInfo(395859, "秉ⵑ᠟Ꮍ⁭豹理癙⤊", {-43258, 982620, -592072, -568754});
    Test_CheckProps_TmxMapInfo(978653, "벷쨭욢璞", {312816});
    Test_CheckProps_TmxMapInfo(315253, "森ⶍභࢆ⑧", {362086, 513331, 850420});
    Test_CheckProps_TmxMapInfo(22089, "짭", {529329, 78530});
    Test_CheckProps_TmxMapInfo(83328, "쐭ғ㒴퟽ᗦ㴟봨ￊ", {-957449, 2628});
    Test_CheckProps_TmxMapInfo(772861, "", {-881617});
    Test_CheckProps_TmxMapInfo(903157, "༏큝㫓", {-376175, 973039});
    Test_CheckProps_TmxMapInfo(431245, "ಟ", {679739});
    Test_CheckProps_TmxMapInfo(182317, "็۟弜", {309649, -85927, 983400});
    Test_CheckProps_TmxMapInfo(850147, "扚듍꩐瘁쪟怢瞱", {335576, 521868, 680498});
    Test_CheckProps_TmxMapInfo(485202, "䵌‱䘢먔᫣", {613923, 72793, 366682});
    Test_CheckProps_TmxMapInfo(480081, "㈾នﯸ滣轁竁怒ৈ", {-89168});
    Test_CheckProps_TmxMapInfo(396439, "�淲ﺆ跏㜤샱镧畉弐", {952652, 357901, -626658, -211511});
    Test_CheckProps_TmxMapInfo(684445, "檣袿", {612954, 647698});
    Test_CheckProps_TmxMapInfo(66200, "䬹칭", {140197, 355531, 925363});
    Test_CheckProps_TmxMapInfo(323729, "쯰㗟豺", {-663109, -290020, 990522, -694202});
    Test_CheckProps_TmxMapInfo(133511, "", {147555, 748571});
    Test_CheckProps_TmxMapInfo(303027, "扟킋泎", {-737311, -723488});
    Test_CheckProps_TmxMapInfo(969195, "ꏛᐰꭢធ沈v鬕绽ᅧ", {-507545, 361945, -820337, 650559});
    Test_CheckProps_TmxMapInfo(900907, "啕ኞ衍蛜", {-552542});
    Test_CheckProps_TmxMapInfo(487252, "揉筢㲸肅瞇", {717791, -499642, 656430});
    Test_CheckProps_TmxMapInfo(449432, "긽榈俍埯퐥ঠ἗넾ᅳ", {517511});
    Test_CheckProps_TmxMapInfo(900088, "诨⥇Ш", {-406450, 571451, -529715, 684845});
    Test_CheckProps_TmxMapInfo(914746, "悄௶揸ꥒ叵﨑밍뇘Ꜽ", {642519, -83490, -121713, 603343});
    Test_CheckProps_TmxMapInfo(490417, "", {-397913, -544800, -187818, -679722});
    Test_CheckProps_TmxMapInfo(237947, "", {284881, 489560, -122569});
  }

  bool unitTestResults_TmxMapInfo_Getters = runAsync(Tests_RegisterAll_TmxMapInfo_Getters);

  /* Test // Mixin: Op Eq */
  void Tests_RegisterAll_TmxMapInfo_OpEq() {
    RegisterUnitTest('UnitTest_OpEqSimple_TmxMapInfo', UnitTest_OpEqSimple_TmxMapInfo);
  }

  TmxMapInfo@ lastChecked = null;

  bool OpEqSimple_Check(uint TrackID, const string &in Name, const int[] &in Tags) {
    TmxMapInfo@ o1 = TmxMapInfo(TrackID, Name, Tags);
    TmxMapInfo@ o2 = TmxMapInfo(TrackID, Name, Tags);
    assert(o1 == o2, 'OpEqSimple_Check fail for obj: ' + o1.ToString());
    assert(o1 != lastChecked, 'OpEqSimple_Check failed comparing to last obj');
    @lastChecked = o1;
    return true;
  }

  void UnitTest_OpEqSimple_TmxMapInfo() {
    OpEqSimple_Check(393455, "ﷰ눵뭩㵷衟춗䵩", {-875436});
    OpEqSimple_Check(878215, "탏핈霋흽묌铱蝔ᔁ䀓⃩", {221991, 693970});
    OpEqSimple_Check(960330, "⇩㵣䎵甄壝玃", {-602225, 333816});
    OpEqSimple_Check(159512, "쇳濶鵛獔楷璊诛퇟", {-416957});
    OpEqSimple_Check(226958, "밑幖許ᬤ쿊菆︐", {-859114, -445943, 785460, 26440});
    OpEqSimple_Check(133463, "㞫䫆ើ鹆ʊ", {-662483});
    OpEqSimple_Check(288195, "", {-610864, 690858, -449551});
    OpEqSimple_Check(504118, "耏盧я␜", {179642, -919552});
    OpEqSimple_Check(145172, "", {854015});
    OpEqSimple_Check(222332, "娣", {20188, 840953});
    OpEqSimple_Check(208909, "䀐硩钗쏥䁏", {422278, -274274, 909595, 718449});
    OpEqSimple_Check(333641, "�㏊뻹媋痰", {147695, 4203});
    OpEqSimple_Check(766369, "⃠嚅", {-37522, 559404});
    OpEqSimple_Check(726400, "锲釹ឰ", {40481});
    OpEqSimple_Check(694261, "館胄ા즣", {704848, -635331, -455288, -95488});
    OpEqSimple_Check(780762, "�둕껅汆", {-634496});
    OpEqSimple_Check(814326, "⩮�ώ꒏퓂䉰ꋗ嗳ರ", {-843927, -168216, 843670});
    OpEqSimple_Check(909926, "⧙곢歒", {132045});
    OpEqSimple_Check(929297, "홌", {364509, 636291, -854843, 78939});
    OpEqSimple_Check(925658, "큽咪઼側", {279639, 937519, 557945, -916191});
    OpEqSimple_Check(759681, "粄⅝挝㠊", {157952, -832582, -604767, -468278});
    OpEqSimple_Check(475985, "뱜悶ꂋ鰲", {47786, 992454, 829588, -746952});
    OpEqSimple_Check(141600, "⟹驵盲ⓟ娣ዯ", {690603, -67493, -366355});
    OpEqSimple_Check(578377, "﨑", {-374957, 417084, -799102});
    OpEqSimple_Check(877689, "띟璦Ⴗ婑", {849219, -321289, -393101, -381690});
    OpEqSimple_Check(284057, "", {296593, -812904, -413969, -366844});
    OpEqSimple_Check(97859, "녮ง", {203988, -611502, 917838, -692325});
    OpEqSimple_Check(773250, "↟ڹ錠쟓쎭뗧䢼", {419116, -424360, 739364});
    OpEqSimple_Check(978412, "聿妒ᫍ", {-538153, 921986, -874280, -580971});
    OpEqSimple_Check(284973, "", {-816012});
    OpEqSimple_Check(463120, "磃헮躁潿鬐", {-430263});
    OpEqSimple_Check(574276, "", {518187, -448816});
    OpEqSimple_Check(971400, "䋰ꭔ", {-468156});
    OpEqSimple_Check(958667, "숬勯ﵜ쳮쬤", {707858});
    OpEqSimple_Check(1447, "⡋늟", {-353437, -274753, 836181});
    OpEqSimple_Check(796197, "膞坫窀훱Ⅺ", {});
    OpEqSimple_Check(363319, "ө㩣�轏", {-225964, 533724});
    OpEqSimple_Check(926220, "ᄈ믋왚ꯂ喿�", {-785715, 372367});
    OpEqSimple_Check(806802, "迒䌡ഘ�∁衽", {299172, 946673});
    OpEqSimple_Check(932418, "咂ﱉ皾澐쇞㍐དྷ썦癓簡", {48134});
    OpEqSimple_Check(619788, "䷫킹륦了挧ﳗ졝馺", {734945, 79137, -251304, 562413});
    OpEqSimple_Check(255600, "", {549628, 542692, -30192});
  }

  bool unitTestResults_TmxMapInfo_OpEq = runAsync(Tests_RegisterAll_TmxMapInfo_OpEq);

  /* Test // Mixin: ToFromBuffer */
  void Tests_RegisterAll_TmxMapInfo_ToFromBuffer() {
    RegisterUnitTest('UnitTest_ToFromBuffer_TmxMapInfo', UnitTest_ToFromBuffer_TmxMapInfo);
  }

  bool Test_ToFromBuffer_Check(uint TrackID, const string &in Name, const int[] &in Tags) {
    TmxMapInfo@ tmp = TmxMapInfo(TrackID, Name, Tags);
    MemoryBuffer@ buf = MemoryBuffer();
    tmp.WriteToBuffer(buf);
    buf.Seek(0, 0);
    assert(tmp == _TmxMapInfo::ReadFromBuffer(buf), 'ToFromBuffer fail: ' + tmp.ToString());
    return true;
  }

  void UnitTest_ToFromBuffer_TmxMapInfo() {
    Test_ToFromBuffer_Check(490366, "", {-131469, 208087});
    Test_ToFromBuffer_Check(184950, "㑽沒皔�", {-465845, -491818});
    Test_ToFromBuffer_Check(829354, "থ䤫ﯹ윶", {-272359, -286637, 980098, 394003});
    Test_ToFromBuffer_Check(542064, "�䓂ൗ㬬䱿학", {549906, -538914, -217452});
    Test_ToFromBuffer_Check(156703, "玵⌂玍뱑ự螸", {-116232, 500830});
    Test_ToFromBuffer_Check(215149, "벋⛩涻뼢ꏅ㜔", {-400843, 264122, 966690, 307951});
    Test_ToFromBuffer_Check(18419, "蒔銥", {-229795, -999444, 711944});
    Test_ToFromBuffer_Check(871047, "婗�嗇웖峔䞠", {-135141});
    Test_ToFromBuffer_Check(213099, "࡟记Ⴒ늴㐆", {-911577, 664733});
    Test_ToFromBuffer_Check(835031, "�", {-470320, -422981, 935627});
    Test_ToFromBuffer_Check(305848, "�髨", {-631575, 319227, 520261});
    Test_ToFromBuffer_Check(861842, "㴑", {599204, -726942});
    Test_ToFromBuffer_Check(873537, "ℤ", {691552, -815981, -259701});
    Test_ToFromBuffer_Check(740264, "蛬讽", {182755, -71101});
    Test_ToFromBuffer_Check(373377, "褺끤찙뗿", {79569, -869218, -388165});
    Test_ToFromBuffer_Check(692075, "", {-506405, 196468, 349336});
    Test_ToFromBuffer_Check(933514, "賵ঃ굈꒍쉫탑", {-342126, 385463});
    Test_ToFromBuffer_Check(674685, "먫ᣆ", {-593560});
    Test_ToFromBuffer_Check(473825, "㇮ᛏ큎뒏⫛", {});
    Test_ToFromBuffer_Check(506392, "", {-306469, 173894, -510644, 919387});
    Test_ToFromBuffer_Check(712180, "湧섳⒜㓚苵孇᚞粷", {-756628, 898687, 406274, 632768});
    Test_ToFromBuffer_Check(319491, "볞", {-251685});
    Test_ToFromBuffer_Check(119549, "밦󻴑ւꈒ戚춭袺㙒౫", {164935, 463721, -42045});
    Test_ToFromBuffer_Check(328793, "镇混�禳蓮鿞겮鴆", {781705, -921049, 186933, -514823});
    Test_ToFromBuffer_Check(709551, "㻿틛䚙Չ찐", {-790168, 681555, 645363});
    Test_ToFromBuffer_Check(998119, "໩", {-525877, -669283, 171001, -651053});
    Test_ToFromBuffer_Check(155863, "", {35511, 512740, -808479, -461199});
    Test_ToFromBuffer_Check(107080, "紮㾶傻竨罽", {975482, 381756, -141531});
    Test_ToFromBuffer_Check(508626, "匥ᄯ", {585311, 35178, 70328, -2463});
    Test_ToFromBuffer_Check(949646, "㭿", {908455, 100513, -901272});
    Test_ToFromBuffer_Check(281342, "晭�ꉼ", {-921606, -76857, -625519, 875210});
    Test_ToFromBuffer_Check(589319, "", {-893315});
    Test_ToFromBuffer_Check(560058, "䜎㊟焱쑔ᣛﻃ瞽�쀮ꢸ", {849299});
    Test_ToFromBuffer_Check(534295, "䐭ǘ钶옠挏䆭䐜", {-738673, -945010, -25369, 991105});
    Test_ToFromBuffer_Check(611797, "㤞㱸", {987116, -534633, -155739, 326125});
    Test_ToFromBuffer_Check(647385, "캣ᮅᔜ�䛝쏔", {95318, -989212, -554863});
    Test_ToFromBuffer_Check(133548, "鼋皿ꮺ玚疭爿㰙ḋ", {605952});
    Test_ToFromBuffer_Check(63954, "푭", {41008});
    Test_ToFromBuffer_Check(996068, "魠齁⣔蓷璉", {914083, 554244});
    Test_ToFromBuffer_Check(843199, "�쉐⽚̿划㠒", {-747370, 654169, 790541, -373706});
    Test_ToFromBuffer_Check(825340, "粙", {784257, 615343, -32333, 95161});
    Test_ToFromBuffer_Check(682330, "쀐㴔", {-807878, 640719, 301561});
  }

  bool unitTestResults_TmxMapInfo_ToFromBuffer = runAsync(Tests_RegisterAll_TmxMapInfo_ToFromBuffer);
}
#endif
