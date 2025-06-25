class TmxMapInfo {
  /* Properties // Mixin: Default Properties */
  private uint _TrackID;
  private string _Name;
  private MaybeOfString@ _Tags;
  private array<int> _TagList;

  /* Methods // Mixin: Default Constructor */
  TmxMapInfo(uint TrackID, const string &in Name, MaybeOfString@ Tags, const int[] &in TagList) {
    this._TrackID = TrackID;
    this._Name = Name;

    if (Tags != "") {
      @this._Tags = Tags;
      this._TagList = TagList;
    }
  }

  /* Methods // Mixin: ToFrom JSON Object */
  TmxMapInfo(const Json::Value@ j) {
    this._TrackID = uint(j["TrackID"]);
    this._Name = string(j["Name"]);
    @this._Tags = MaybeOfString(j["Tags"]);
    auto tagsStr = _Tags.GetOr("");

    if (tagsStr != "") {
      auto tags = tagsStr.Split(",");
      this._TagList = array<int>(tags.Length);
      for (uint i = 0; i < tags.Length; i++) {
        int tagId;
        if (Text::TryParseInt(tags[i], tagId) && tagId > 0 && tagId <= NUM_TAGS) {
          this._TagList[i] = tagId;
        }
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

  MaybeOfString@ get_Tags() const {
    return this._Tags;
  }

  const int[]@ get_TagList() const {
    return this._TagList;
  }

  /* Methods // Mixin: ToString */
  const string ToString() {
    return 'TmxMapInfo('
      + string::Join({'TrackID=' + tostring(TrackID), 'Name=' + Name, 'Tags=' + Tags.ToString(), 'TagList=' + TS_Array_int(TagList)}, ', ')
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
    bool _tmp_arrEq_TagList = _TagList.Length == other.TagList.Length;
    for (uint i = 0; i < _TagList.Length; i++) {
      if (!_tmp_arrEq_TagList) {
        break;
      }
      _tmp_arrEq_TagList = _tmp_arrEq_TagList && (_TagList[i] == other.TagList[i]);
    }
    return true
      && _TrackID == other.TrackID
      && _Name == other.Name
      && _Tags == other.Tags
      && _tmp_arrEq_TagList
      ;
  }

  /* Methods // Mixin: ToFromBuffer */
  void WriteToBuffer(MemoryBuffer@ buf) {
    buf.Write(_TrackID);
    WTB_LP_String(buf, _Name);
    _Tags.WriteToBuffer(buf);
    WTB_Array_Int(buf, _TagList);
  }

  uint CountBufBytes() {
    uint bytes = 0;
    bytes += 4;
    bytes += 4 + _Name.Length;
    bytes += _Tags.CountBufBytes();
    bytes += CBB_Array_Int(_TagList);
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
    /* Parse field: Tags of type: MaybeOfString@ */
    MaybeOfString@ Tags = _MaybeOfString::ReadFromBuffer(buf);
    /* Parse field: TagList of type: array<int> */
    array<int> TagList = RFB_Array_Int(buf);
    return TmxMapInfo(TrackID, Name, Tags, TagList);
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
