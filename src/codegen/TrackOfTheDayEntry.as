class TrackOfTheDayEntry {
  /* Properties // Mixin: Default Properties */
  private uint _campaignId;
  private string _mapUid;
  private uint _day;
  private uint _monthDay;
  private string _seasonUid;
  private uint _startTimestamp;
  private uint _endTimestamp;

  /* Methods // Mixin: Default Constructor */
  TrackOfTheDayEntry(uint campaignId, const string &in mapUid, uint day, uint monthDay, const string &in seasonUid, uint startTimestamp, uint endTimestamp) {
    this._campaignId = campaignId;
    this._mapUid = mapUid;
    this._day = day;
    this._monthDay = monthDay;
    this._seasonUid = seasonUid;
    this._startTimestamp = startTimestamp;
    this._endTimestamp = endTimestamp;
  }

  /* Methods // Mixin: ToFrom JSON Object */
  TrackOfTheDayEntry(const Json::Value@ j) {
    this._campaignId = uint(j["campaignId"]);
    this._mapUid = string(j["mapUid"]);
    this._day = uint(j["day"]);
    this._monthDay = uint(j["monthDay"]);
    this._seasonUid = string(j["seasonUid"]);
    this._startTimestamp = uint(j["startTimestamp"]);
    this._endTimestamp = uint(j["endTimestamp"]);
  }

  Json::Value@ ToJson() {
    Json::Value@ j = Json::Object();
    j["campaignId"] = _campaignId;
    j["mapUid"] = _mapUid;
    j["day"] = _day;
    j["monthDay"] = _monthDay;
    j["seasonUid"] = _seasonUid;
    j["startTimestamp"] = _startTimestamp;
    j["endTimestamp"] = _endTimestamp;
    return j;
  }

  void OnFromJsonError(const Json::Value@ j) const {
    warn('Parsing json failed: ' + Json::Write(j));
    throw('Failed to parse JSON: ' + getExceptionInfo());
  }

  /* Methods // Mixin: Getters */
  uint get_campaignId() const {
    return this._campaignId;
  }

  const string get_mapUid() const {
    return this._mapUid;
  }

  uint get_day() const {
    return this._day;
  }

  uint get_monthDay() const {
    return this._monthDay;
  }

  const string get_seasonUid() const {
    return this._seasonUid;
  }

  uint get_startTimestamp() const {
    return this._startTimestamp;
  }

  uint get_endTimestamp() const {
    return this._endTimestamp;
  }

  /* Methods // Mixin: ToString */
  const string ToString() {
    return 'TrackOfTheDayEntry('
      + string::Join({'campaignId=' + tostring(campaignId), 'mapUid=' + mapUid, 'day=' + tostring(day), 'monthDay=' + tostring(monthDay), 'seasonUid=' + seasonUid, 'startTimestamp=' + tostring(startTimestamp), 'endTimestamp=' + tostring(endTimestamp)}, ', ')
      + ')';
  }

  /* Methods // Mixin: Op Eq */
  bool opEquals(const TrackOfTheDayEntry@ other) {
    if (other is null) {
      return false; // this obj can never be null.
    }
    return true
      && _campaignId == other.campaignId
      && _mapUid == other.mapUid
      && _day == other.day
      && _monthDay == other.monthDay
      && _seasonUid == other.seasonUid
      && _startTimestamp == other.startTimestamp
      && _endTimestamp == other.endTimestamp
      ;
  }

  /* Methods // Mixin: ToFromBuffer */
  void WriteToBuffer(MemoryBuffer@ buf) {
    buf.Write(_campaignId);
    WTB_LP_String(buf, _mapUid);
    buf.Write(_day);
    buf.Write(_monthDay);
    WTB_LP_String(buf, _seasonUid);
    buf.Write(_startTimestamp);
    buf.Write(_endTimestamp);
  }

  uint CountBufBytes() {
    uint bytes = 0;
    bytes += 4;
    bytes += 4 + _mapUid.Length;
    bytes += 4;
    bytes += 4;
    bytes += 4 + _seasonUid.Length;
    bytes += 4;
    bytes += 4;
    return bytes;
  }

  void WTB_LP_String(MemoryBuffer@ buf, const string &in s) {
    buf.Write(uint(s.Length));
    buf.Write(s);
  }
}

namespace _TrackOfTheDayEntry {
  /* Namespace // Mixin: ToFromBuffer */
  TrackOfTheDayEntry@ ReadFromBuffer(MemoryBuffer@ buf) {
    /* Parse field: campaignId of type: uint */
    uint campaignId = buf.ReadUInt32();
    /* Parse field: mapUid of type: string */
    string mapUid = RFB_LP_String(buf);
    /* Parse field: day of type: uint */
    uint day = buf.ReadUInt32();
    /* Parse field: monthDay of type: uint */
    uint monthDay = buf.ReadUInt32();
    /* Parse field: seasonUid of type: string */
    string seasonUid = RFB_LP_String(buf);
    /* Parse field: startTimestamp of type: uint */
    uint startTimestamp = buf.ReadUInt32();
    /* Parse field: endTimestamp of type: uint */
    uint endTimestamp = buf.ReadUInt32();
    return TrackOfTheDayEntry(campaignId, mapUid, day, monthDay, seasonUid, startTimestamp, endTimestamp);
  }

  const string RFB_LP_String(MemoryBuffer@ buf) {
    uint len = buf.ReadUInt32();
    return buf.ReadString(len);
  }
}
