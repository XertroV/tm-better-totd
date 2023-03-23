class DictOfTrackOfTheDayEntry_WriteLog {
  /* Properties // Mixin: Default Properties */
  private dictionary@ _d;

  /* Properties // Mixin: Dict Backing */
  private string _logPath;
  private bool _initialized = false;

  /* Methods // Mixin: Dict Backing */
  DictOfTrackOfTheDayEntry_WriteLog(const string &in logDir, const string &in logFile) {
    @_d = dictionary();
    InitLog(logDir, logFile);
  }

  private const string K(const string &in key) const {
    return key;
  }

  TrackOfTheDayEntry@ Get(const string &in key) const {
    return cast<TrackOfTheDayEntry@>(_d[K(key)]);
  }

  const TrackOfTheDayEntry@[]@ GetMany(const string[] &in keys) const {
    array<TrackOfTheDayEntry@> ret = {};
    for (uint i = 0; i < keys.Length; i++) {
      auto key = keys[i];
      ret.InsertLast(Get(key));
    }
    return ret;
  }


  void Set(const string &in key, TrackOfTheDayEntry@ value) {
    @_d[K(key)] = value;
    WriteOnSet(key, value);
  }

  bool Exists(const string &in key) {
    return _d.Exists(K(key));
  }

  uint CountExists(const string[] &in keys) {
    uint ret = 0;
    for (uint i = 0; i < keys.Length; i++) {
      auto key = keys[i];
      if (Exists(key)) ret++;
    }
    return ret;
  }

  array<string>@ GetKeys() const {
    return _d.GetKeys();
  }

  _DictOfTrackOfTheDayEntry_WriteLog::KvPair@ GetItem(const string &in key) const {
    return _DictOfTrackOfTheDayEntry_WriteLog::KvPair(key, Get(key));
  }

  array<_DictOfTrackOfTheDayEntry_WriteLog::KvPair@>@ GetItems() const {
    array<_DictOfTrackOfTheDayEntry_WriteLog::KvPair@> ret = array<_DictOfTrackOfTheDayEntry_WriteLog::KvPair@>(GetSize());
    array<string> keys = GetKeys();
    for (uint i = 0; i < keys.Length; i++) {
      auto key = keys[i];
      @ret[i] = GetItem(key);
    }
    return ret;
  }

  TrackOfTheDayEntry@ opIndex(const string &in key) {
    return Get(key);
  }

  uint GetSize() const {
    return _d.GetSize();
  }

  bool Delete(const string &in key) {
    return _d.Delete(K(key));
  }

  void DeleteAll() {
    WriteLogOnResetAll();
    _d.DeleteAll();
  }

  /* Dict Optional: Write Log = True */
  private void InitLog(const string &in logDir, const string &in logFile) {
    _logPath = logDir + '/' + logFile;
    trace('DictOfTrackOfTheDayEntry_WriteLog dir: ' + logDir + ' | logFile: ' + logFile);
    if (logDir.Length == 0) {
      throw('Invalid path: ' + _logPath);
    }
    if (!IO::FolderExists(logDir)) {
      IO::CreateFolder(logDir, true);
    }
    LoadWriteLogFromDisk();
  }

  private void LoadWriteLogFromDisk() {
    if (IO::FileExists(_logPath)) {
      uint start = Time::Now;
      IO::File f(_logPath, IO::FileMode::Read);
      MemoryBuffer@ fb = MemoryBuffer(f.Read(f.Size()));
      f.Close();
      while (!fb.AtEnd()) {
        auto kv = _DictOfTrackOfTheDayEntry_WriteLog::_KvPair::ReadFromBuffer(fb);
        @_d[K(kv.key)] = kv.val;
      }
      trace('\\$a4fDictOfTrackOfTheDayEntry_WriteLog\\$777 loaded \\$a4f' + GetSize() + '\\$777 entries from: \\$a4f' + _logPath + '\\$777 in \\$a4f' + (Time::Now - start) + ' ms\\$777.');
      f.Close();
    } else {
      IO::File f(_logPath, IO::FileMode::Write);
      f.Close();
    }
    _initialized = true;
  }

  bool get_Initialized() {
    return _initialized;
  }

  void AwaitInitialized() {
    while (!_initialized) {
      yield();
    }
  }

  private void WriteOnSet(const string &in key, TrackOfTheDayEntry@ value) {
    _DictOfTrackOfTheDayEntry_WriteLog::KvPair@ p = _DictOfTrackOfTheDayEntry_WriteLog::KvPair(key, value);
    MemoryBuffer@ buf = MemoryBuffer();
    p.WriteToBuffer(buf);
    buf.Seek(0, 0);
    IO::File f(_logPath, IO::FileMode::Append);
    f.Write(buf);
    f.Close();
  }

  private void WriteLogOnResetAll() {
    IO::File f(_logPath, IO::FileMode::Write);
    f.Write('');
    f.Close();
  }
}

namespace _DictOfTrackOfTheDayEntry_WriteLog {
  /* Namespace // Mixin: Dict Backing */
  class KvPair {
    /* Properties // Mixin: Default Properties */
    private string _key;
    private TrackOfTheDayEntry@ _val;

    /* Methods // Mixin: Default Constructor */
    KvPair(const string &in key, TrackOfTheDayEntry@ val) {
      this._key = key;
      @this._val = val;
    }

    /* Methods // Mixin: Getters */
    const string get_key() const {
      return this._key;
    }

    TrackOfTheDayEntry@ get_val() const {
      return this._val;
    }

    /* Methods // Mixin: ToString */
    const string ToString() {
      return 'KvPair('
        + string::Join({'key=' + key, 'val=' + val.ToString()}, ', ')
        + ')';
    }

    /* Methods // Mixin: Op Eq */
    bool opEquals(const KvPair@ &in other) {
      if (other is null) {
        return false; // this obj can never be null.
      }
      return true
        && _key == other.key
        && _val == other.val
        ;
    }

    /* Methods // Mixin: ToFromBuffer */
    void WriteToBuffer(MemoryBuffer@ buf) {
      WTB_LP_String(buf, _key);
      _val.WriteToBuffer(buf);
    }

    uint CountBufBytes() {
      uint bytes = 0;
      bytes += 4 + _key.Length;
      bytes += _val.CountBufBytes();
      return bytes;
    }

    void WTB_LP_String(MemoryBuffer@ buf, const string &in s) {
      buf.Write(uint(s.Length));
      buf.Write(s);
    }
  }

  namespace _KvPair {
    /* Namespace // Mixin: ToFromBuffer */
    KvPair@ ReadFromBuffer(MemoryBuffer@ buf) {
      /* Parse field: key of type: string */
      string key = RFB_LP_String(buf);
      /* Parse field: val of type: TrackOfTheDayEntry@ */
      TrackOfTheDayEntry@ val = _TrackOfTheDayEntry::ReadFromBuffer(buf);
      return KvPair(key, val);
    }

    const string RFB_LP_String(MemoryBuffer@ buf) {
      uint len = buf.ReadUInt32();
      return buf.ReadString(len);
    }
  }
}
