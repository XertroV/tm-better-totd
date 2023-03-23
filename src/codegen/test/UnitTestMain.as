#if UNIT_TEST
enum TestStatus {
  Waiting = 0, Started = 1, Failed = 2, Passed = 3
}

array<TestStatus> _unitTests_globalSingleton = {};
array<CoroutineFunc@> _unitTests_funcs = {};
array<string> _unitTests_names = {};
dictionary@ _unitTests_failureMessages = dictionary();
uint _unitTests_counter = 0;
uint _unitTests_nStarted = 0;
uint _unitTests_nRunning = 0;
uint _unitTests_nDone = 0;
uint _unitTests_nPassed = 0;
uint _unitTests_startedAt = 0;
bool unitTestsStarted = UnitTest_StartMainLoop();

bool RegisterUnitTest(const string &in name, CoroutineFunc@ &in func) {
  if (_unitTests_startedAt == 0) {
    while (_unitTests_globalSingleton is null) {
      yield();
    }
    while (_unitTests_failureMessages is null) {
      yield();
    }
    _unitTests_startedAt = Time::Now;
  }
  uint id = _unitTests_counter++;
  _unitTests_globalSingleton.InsertLast(TestStatus::Waiting);
  _unitTests_funcs.InsertLast(func);
  _unitTests_names.InsertLast(name);
  return true;
}

bool UnitTest_StartMainLoop() {
  startnew(UnitTest_MainLoop);
  return true;
}

void UnitTest_MainLoop() {
  while (_unitTests_globalSingleton.Length == 0) {
    yield();
  }
  sleep(25);
  while (_unitTests_counter > _unitTests_nDone) {
    if (_unitTests_nRunning < 10) {
      startnew(UnitTest_RunNext);
    }
    yield();
  }
  UnitTest_SuiteComplete_PrintResults();
  print('Completed ' + _unitTests_counter + ' unit tests.');
}

void UnitTest_RunNext() {
  while (_unitTests_nStarted >= _unitTests_counter) { yield(); }
  uint id = _unitTests_nStarted++;
  _unitTests_nRunning++;
  _unitTests_globalSingleton[id] = TestStatus::Started;
  try {
    _unitTests_funcs[id]();  // run directly -- not as coro since we're already a coro
    _unitTests_globalSingleton[id] = TestStatus::Passed;
    _unitTests_nPassed++;
  } catch {
    _unitTests_globalSingleton[id] = TestStatus::Failed;
    string exInfo = getExceptionInfo();
    _unitTests_failureMessages['' + id] = exInfo;
    print('\\$f21Test failed: ' + _unitTests_names[id] + ' => ' + exInfo);
  }
  _unitTests_nRunning--;
  _unitTests_nDone++;
  print('Test completed: ' + _unitTests_names[id]);
}

void UnitTest_SuiteComplete_PrintResults() {
  print('\\$3a3Tests run: ' + _unitTests_counter);
  print('\\$3a3Tests passed: ' + _unitTests_nPassed);
  for (uint id = 0; id < _unitTests_counter; id++) {
    if (_unitTests_globalSingleton[id] == TestStatus::Failed) {
      print('\\$f61' + _unitTests_names[id] + ' failed with message: ' + string(_unitTests_failureMessages['' + id]));
    }
  }
  print('Tests took: ' + (Time::Now - _unitTests_startedAt) + ' ms');
}

void WTB_LP_String(MemoryBuffer@ buf, const string &in s) {
  buf.Write(uint(s.Length));
  buf.Write(s);
}

shared const string RFB_LP_String(MemoryBuffer@ buf) {
  uint len = buf.ReadUInt32();
  return buf.ReadString(len);
}

shared enum SItemType {
  CarSport,
  CharacterPilot,
  CustomMesh
}

shared Json::Value Vec3ToJsonObj(vec3 &in v) {
  auto j = Json::Object();
  j['x'] = v.x;
  j['y'] = v.y;
  j['z'] = v.z;
  return j;
}
#endif
