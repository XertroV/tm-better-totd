class MaybeOfString {
  /* Properties // Mixin: Default Properties */
  private string _val;
  private bool _hasVal;

  /* Methods // Mixin: JMaybes */
  MaybeOfString(const string &in val) {
    _hasVal = true;
    _val = val;
  }

  MaybeOfString() {
    _hasVal = false;
  }

  MaybeOfString(const Json::Value@ j) {
    if (j is null || j.GetType() % Json::Type::Null == 0) {
      _hasVal = false;
    } else {
      _hasVal = true;
      _val = string(j);
    }
  }

  bool opEquals(const MaybeOfString@ other) {
    if (IsJust()) {
      return other.IsJust() && (_val == other.val);
    }
    return other.IsNothing();
  }

  const string ToString() {
    string ret = 'MaybeOfString(';
    if (IsJust()) {
      ret += _val;
    }
    return ret + ')';
  }

  Json::Value@ ToJson() {
    if (IsNothing()) {
      return Json::Value(); // json null
    }
    return Json::Value(_val);
  }

  void WriteToBuffer(MemoryBuffer@ buf) {
    if (IsNothing()) {
      buf.Write(uint8(0));
    } else {
      buf.Write(uint8(1));
      WTB_LP_String(buf, _val);
    }
  }

  void WTB_LP_String(MemoryBuffer@ buf, const string &in s) {
    buf.Write(uint(s.Length));
    buf.Write(s);
  }

  uint CountBufBytes() {
    if (IsNothing()) {
      return 1;
    }
    return 1 + 4 + _val.Length;
  }

  const string get_val() const {
    if (!_hasVal) {
      throw('Attempted to access .val of a Nothing');
    }
    return _val;
  }

  const string GetOr(const string &in _default) {
    return _hasVal ? _val : _default;
  }

  bool IsJust() const {
    return _hasVal;
  }

  bool IsSome() const {
    return IsJust();
  }

  bool IsNothing() const {
    return !_hasVal;
  }

  bool IsNone() const {
    return IsNothing();
  }
}

namespace _MaybeOfString {
  MaybeOfString@ ReadFromBuffer(MemoryBuffer@ buf) {
    bool isNothing = 0 == buf.ReadUInt8();
    if (isNothing) {
      return MaybeOfString();
    } else {
      /* Parse field: val of type: string */
      string val = RFB_LP_String(buf);
      return MaybeOfString(val);
    }
  }

  const string RFB_LP_String(MemoryBuffer@ buf) {
    uint len = buf.ReadUInt32();
    return buf.ReadString(len);
  }
}
