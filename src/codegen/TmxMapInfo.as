class TmxMapInfo {
  /* Properties // Mixin: Default Properties */
  private uint _TrackID;
  private string _Name;
  private array<int> _Tags;

  /* Methods // Mixin: Default Constructor */
  TmxMapInfo(uint TrackID, const string &in Name, const int[] &in Tags) {
    this._TrackID = TrackID;
    this._Name = Name;
    this._Tags = Tags;
  }

  /* Methods // Mixin: ToFrom JSON Object */
  TmxMapInfo(const Json::Value@ j) {
    this._TrackID = uint(j["MapId"]);
    this._Name = string(j["Name"]);
    auto tags = j["Tags"];

    this._Tags = array<int>(tags.Length);
    for (uint i = 0; i < tags.Length; i++) {
      auto tag = tags[i];
      auto tagId = int(tag["TagId"]);
      if (tagId > 0 && tagId <= NUM_TAGS) {
        this._Tags[i] = tagId;
      }
    }
  }

  Json::Value@ ToJson() {
    Json::Value@ j = Json::Object();
    j["TrackID"] = _TrackID;
    j["Name"] = _Name;
    j["Tags"] = _Tags.ToJson();
    return j;
  }

  void OnFromJsonError(const Json::Value@ j) const {
    log_warn('Parsing json failed: ' + Json::Write(j));
    throw('Failed to parse JSON: ' + getExceptionInfo());
  }

  /* Methods // Mixin: Getters */
  uint get_TrackID() const {
    return this._TrackID;
  }

  const string get_Name() const {
    return this._Name;
  }

  const int[]@ get_Tags() const {
    return this._Tags;
  }

  /* Methods // Mixin: ToString */
  const string ToString() {
    return 'TmxMapInfo('
      + string::Join({'TrackID=' + tostring(TrackID), 'Name=' + Name, 'Tags=' + TS_Array_int(Tags)}, ', ')
      + ')';
  }

  private const string TS_Array_int(const array<int> &in arr) {
    string ret = '{';
    for (uint i = 0; i < arr.Length; i++) {
      if (i > 0) ret += ', ';
      ret += tostring(arr[i]);
    }
    return ret + '}';
  }

  /* Methods // Mixin: Op Eq */
  bool opEquals(const TmxMapInfo@ other) {
    if (other is null) {
      return false; // this obj can never be null.
    }
    bool _tmp_arrEq_Tags = _Tags.Length == other.Tags.Length;
    for (uint i = 0; i < _Tags.Length; i++) {
      if (!_tmp_arrEq_Tags) {
        break;
      }
      _tmp_arrEq_Tags = _tmp_arrEq_Tags && (_Tags[i] == other.Tags[i]);
    }
    return true
      && _TrackID == other.TrackID
      && _Name == other.Name
      && _tmp_arrEq_Tags
      ;
  }

  /* Methods // Mixin: ToFromBuffer */
  void WriteToBuffer(MemoryBuffer@ buf) {
    buf.Write(_TrackID);
    WTB_LP_String(buf, _Name);
    WTB_Array_Int(buf, _Tags);
  }

  uint CountBufBytes() {
    uint bytes = 0;
    bytes += 4;
    bytes += 4 + _Name.Length;
    bytes += CBB_Array_Int(_Tags);
    return bytes;
  }

  void WTB_LP_String(MemoryBuffer@ buf, const string &in s) {
    buf.Write(uint(s.Length));
    buf.Write(s);
  }

  void WTB_Array_Int(MemoryBuffer@ buf, const array<int> &in arr) {
    buf.Write(uint(arr.Length));
    for (uint ix = 0; ix < arr.Length; ix++) {
      auto el = arr[ix];
      buf.Write(el);
    }
  }

  uint CBB_Array_Int(const array<int> &in arr) {
    uint bytes = 4;
    for (uint ix = 0; ix < arr.Length; ix++) {
      auto el = arr[ix];
      bytes += 4;
    }
    return bytes;
  }
}

namespace _TmxMapInfo {
  /* Namespace // Mixin: ToFromBuffer */
  TmxMapInfo@ ReadFromBuffer(MemoryBuffer@ buf) {
    /* Parse field: TrackID of type: uint */
    uint TrackID = buf.ReadUInt32();
    /* Parse field: Name of type: string */
    string Name = RFB_LP_String(buf);
    /* Parse field: Tags of type: array<int> */
    array<int> Tags = RFB_Array_Int(buf);
    return TmxMapInfo(TrackID, Name, Tags);
  }

  const string RFB_LP_String(MemoryBuffer@ buf) {
    uint len = buf.ReadUInt32();
    return buf.ReadString(len);
  }

  const array<int>@ RFB_Array_Int(MemoryBuffer@ buf) {
    uint len = buf.ReadUInt32();
    array<int> arr = array<int>(len);
    for (uint i = 0; i < arr.Length; i++) {
      arr[i] = buf.ReadInt32();
    }
    return arr;
  }
}
