// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProblemDetail _$ProblemDetailFromJson(Map<String, dynamic> json) {
  return _ProblemDetail.fromJson(json);
}

/// @nodoc
mixin _$ProblemDetail {
  String get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int get status => throw _privateConstructorUsedError;
  String get detail => throw _privateConstructorUsedError;
  ProblemCode get code => throw _privateConstructorUsedError;

  /// Serializes this ProblemDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProblemDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProblemDetailCopyWith<ProblemDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProblemDetailCopyWith<$Res> {
  factory $ProblemDetailCopyWith(
          ProblemDetail value, $Res Function(ProblemDetail) then) =
      _$ProblemDetailCopyWithImpl<$Res, ProblemDetail>;
  @useResult
  $Res call(
      {String type, String title, int status, String detail, ProblemCode code});
}

/// @nodoc
class _$ProblemDetailCopyWithImpl<$Res, $Val extends ProblemDetail>
    implements $ProblemDetailCopyWith<$Res> {
  _$ProblemDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProblemDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = null,
    Object? status = null,
    Object? detail = null,
    Object? code = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      detail: null == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as ProblemCode,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProblemDetailImplCopyWith<$Res>
    implements $ProblemDetailCopyWith<$Res> {
  factory _$$ProblemDetailImplCopyWith(
          _$ProblemDetailImpl value, $Res Function(_$ProblemDetailImpl) then) =
      __$$ProblemDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String type, String title, int status, String detail, ProblemCode code});
}

/// @nodoc
class __$$ProblemDetailImplCopyWithImpl<$Res>
    extends _$ProblemDetailCopyWithImpl<$Res, _$ProblemDetailImpl>
    implements _$$ProblemDetailImplCopyWith<$Res> {
  __$$ProblemDetailImplCopyWithImpl(
      _$ProblemDetailImpl _value, $Res Function(_$ProblemDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProblemDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = null,
    Object? status = null,
    Object? detail = null,
    Object? code = null,
  }) {
    return _then(_$ProblemDetailImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      detail: null == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as ProblemCode,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$ProblemDetailImpl implements _ProblemDetail {
  const _$ProblemDetailImpl(
      {required this.type,
      required this.title,
      required this.status,
      required this.detail,
      required this.code});

  factory _$ProblemDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProblemDetailImplFromJson(json);

  @override
  final String type;
  @override
  final String title;
  @override
  final int status;
  @override
  final String detail;
  @override
  final ProblemCode code;

  @override
  String toString() {
    return 'ProblemDetail(type: $type, title: $title, status: $status, detail: $detail, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProblemDetailImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.detail, detail) || other.detail == detail) &&
            (identical(other.code, code) || other.code == code));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, title, status, detail, code);

  /// Create a copy of ProblemDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProblemDetailImplCopyWith<_$ProblemDetailImpl> get copyWith =>
      __$$ProblemDetailImplCopyWithImpl<_$ProblemDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProblemDetailImplToJson(
      this,
    );
  }
}

abstract class _ProblemDetail implements ProblemDetail {
  const factory _ProblemDetail(
      {required final String type,
      required final String title,
      required final int status,
      required final String detail,
      required final ProblemCode code}) = _$ProblemDetailImpl;

  factory _ProblemDetail.fromJson(Map<String, dynamic> json) =
      _$ProblemDetailImpl.fromJson;

  @override
  String get type;
  @override
  String get title;
  @override
  int get status;
  @override
  String get detail;
  @override
  ProblemCode get code;

  /// Create a copy of ProblemDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProblemDetailImplCopyWith<_$ProblemDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConfigFlags _$ConfigFlagsFromJson(Map<String, dynamic> json) {
  return _ConfigFlags.fromJson(json);
}

/// @nodoc
mixin _$ConfigFlags {
  bool get llmEnabled => throw _privateConstructorUsedError;
  bool get voiceEnabled => throw _privateConstructorUsedError;

  /// Serializes this ConfigFlags to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConfigFlags
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConfigFlagsCopyWith<ConfigFlags> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConfigFlagsCopyWith<$Res> {
  factory $ConfigFlagsCopyWith(
          ConfigFlags value, $Res Function(ConfigFlags) then) =
      _$ConfigFlagsCopyWithImpl<$Res, ConfigFlags>;
  @useResult
  $Res call({bool llmEnabled, bool voiceEnabled});
}

/// @nodoc
class _$ConfigFlagsCopyWithImpl<$Res, $Val extends ConfigFlags>
    implements $ConfigFlagsCopyWith<$Res> {
  _$ConfigFlagsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConfigFlags
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? llmEnabled = null,
    Object? voiceEnabled = null,
  }) {
    return _then(_value.copyWith(
      llmEnabled: null == llmEnabled
          ? _value.llmEnabled
          : llmEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      voiceEnabled: null == voiceEnabled
          ? _value.voiceEnabled
          : voiceEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConfigFlagsImplCopyWith<$Res>
    implements $ConfigFlagsCopyWith<$Res> {
  factory _$$ConfigFlagsImplCopyWith(
          _$ConfigFlagsImpl value, $Res Function(_$ConfigFlagsImpl) then) =
      __$$ConfigFlagsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool llmEnabled, bool voiceEnabled});
}

/// @nodoc
class __$$ConfigFlagsImplCopyWithImpl<$Res>
    extends _$ConfigFlagsCopyWithImpl<$Res, _$ConfigFlagsImpl>
    implements _$$ConfigFlagsImplCopyWith<$Res> {
  __$$ConfigFlagsImplCopyWithImpl(
      _$ConfigFlagsImpl _value, $Res Function(_$ConfigFlagsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConfigFlags
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? llmEnabled = null,
    Object? voiceEnabled = null,
  }) {
    return _then(_$ConfigFlagsImpl(
      llmEnabled: null == llmEnabled
          ? _value.llmEnabled
          : llmEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      voiceEnabled: null == voiceEnabled
          ? _value.voiceEnabled
          : voiceEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$ConfigFlagsImpl implements _ConfigFlags {
  const _$ConfigFlagsImpl(
      {required this.llmEnabled, required this.voiceEnabled});

  factory _$ConfigFlagsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConfigFlagsImplFromJson(json);

  @override
  final bool llmEnabled;
  @override
  final bool voiceEnabled;

  @override
  String toString() {
    return 'ConfigFlags(llmEnabled: $llmEnabled, voiceEnabled: $voiceEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConfigFlagsImpl &&
            (identical(other.llmEnabled, llmEnabled) ||
                other.llmEnabled == llmEnabled) &&
            (identical(other.voiceEnabled, voiceEnabled) ||
                other.voiceEnabled == voiceEnabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, llmEnabled, voiceEnabled);

  /// Create a copy of ConfigFlags
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConfigFlagsImplCopyWith<_$ConfigFlagsImpl> get copyWith =>
      __$$ConfigFlagsImplCopyWithImpl<_$ConfigFlagsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConfigFlagsImplToJson(
      this,
    );
  }
}

abstract class _ConfigFlags implements ConfigFlags {
  const factory _ConfigFlags(
      {required final bool llmEnabled,
      required final bool voiceEnabled}) = _$ConfigFlagsImpl;

  factory _ConfigFlags.fromJson(Map<String, dynamic> json) =
      _$ConfigFlagsImpl.fromJson;

  @override
  bool get llmEnabled;
  @override
  bool get voiceEnabled;

  /// Create a copy of ConfigFlags
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConfigFlagsImplCopyWith<_$ConfigFlagsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConfigLimits _$ConfigLimitsFromJson(Map<String, dynamic> json) {
  return _ConfigLimits.fromJson(json);
}

/// @nodoc
mixin _$ConfigLimits {
  int get maxTurns => throw _privateConstructorUsedError;
  int get maxDurationSeconds => throw _privateConstructorUsedError;
  int get idleTimeoutSeconds => throw _privateConstructorUsedError;
  int get maxRequestBodyBytes => throw _privateConstructorUsedError;
  int get retentionDays => throw _privateConstructorUsedError;

  /// Serializes this ConfigLimits to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConfigLimits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConfigLimitsCopyWith<ConfigLimits> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConfigLimitsCopyWith<$Res> {
  factory $ConfigLimitsCopyWith(
          ConfigLimits value, $Res Function(ConfigLimits) then) =
      _$ConfigLimitsCopyWithImpl<$Res, ConfigLimits>;
  @useResult
  $Res call(
      {int maxTurns,
      int maxDurationSeconds,
      int idleTimeoutSeconds,
      int maxRequestBodyBytes,
      int retentionDays});
}

/// @nodoc
class _$ConfigLimitsCopyWithImpl<$Res, $Val extends ConfigLimits>
    implements $ConfigLimitsCopyWith<$Res> {
  _$ConfigLimitsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConfigLimits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxTurns = null,
    Object? maxDurationSeconds = null,
    Object? idleTimeoutSeconds = null,
    Object? maxRequestBodyBytes = null,
    Object? retentionDays = null,
  }) {
    return _then(_value.copyWith(
      maxTurns: null == maxTurns
          ? _value.maxTurns
          : maxTurns // ignore: cast_nullable_to_non_nullable
              as int,
      maxDurationSeconds: null == maxDurationSeconds
          ? _value.maxDurationSeconds
          : maxDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      idleTimeoutSeconds: null == idleTimeoutSeconds
          ? _value.idleTimeoutSeconds
          : idleTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      maxRequestBodyBytes: null == maxRequestBodyBytes
          ? _value.maxRequestBodyBytes
          : maxRequestBodyBytes // ignore: cast_nullable_to_non_nullable
              as int,
      retentionDays: null == retentionDays
          ? _value.retentionDays
          : retentionDays // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConfigLimitsImplCopyWith<$Res>
    implements $ConfigLimitsCopyWith<$Res> {
  factory _$$ConfigLimitsImplCopyWith(
          _$ConfigLimitsImpl value, $Res Function(_$ConfigLimitsImpl) then) =
      __$$ConfigLimitsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int maxTurns,
      int maxDurationSeconds,
      int idleTimeoutSeconds,
      int maxRequestBodyBytes,
      int retentionDays});
}

/// @nodoc
class __$$ConfigLimitsImplCopyWithImpl<$Res>
    extends _$ConfigLimitsCopyWithImpl<$Res, _$ConfigLimitsImpl>
    implements _$$ConfigLimitsImplCopyWith<$Res> {
  __$$ConfigLimitsImplCopyWithImpl(
      _$ConfigLimitsImpl _value, $Res Function(_$ConfigLimitsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConfigLimits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxTurns = null,
    Object? maxDurationSeconds = null,
    Object? idleTimeoutSeconds = null,
    Object? maxRequestBodyBytes = null,
    Object? retentionDays = null,
  }) {
    return _then(_$ConfigLimitsImpl(
      maxTurns: null == maxTurns
          ? _value.maxTurns
          : maxTurns // ignore: cast_nullable_to_non_nullable
              as int,
      maxDurationSeconds: null == maxDurationSeconds
          ? _value.maxDurationSeconds
          : maxDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      idleTimeoutSeconds: null == idleTimeoutSeconds
          ? _value.idleTimeoutSeconds
          : idleTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      maxRequestBodyBytes: null == maxRequestBodyBytes
          ? _value.maxRequestBodyBytes
          : maxRequestBodyBytes // ignore: cast_nullable_to_non_nullable
              as int,
      retentionDays: null == retentionDays
          ? _value.retentionDays
          : retentionDays // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$ConfigLimitsImpl implements _ConfigLimits {
  const _$ConfigLimitsImpl(
      {required this.maxTurns,
      required this.maxDurationSeconds,
      required this.idleTimeoutSeconds,
      required this.maxRequestBodyBytes,
      required this.retentionDays});

  factory _$ConfigLimitsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConfigLimitsImplFromJson(json);

  @override
  final int maxTurns;
  @override
  final int maxDurationSeconds;
  @override
  final int idleTimeoutSeconds;
  @override
  final int maxRequestBodyBytes;
  @override
  final int retentionDays;

  @override
  String toString() {
    return 'ConfigLimits(maxTurns: $maxTurns, maxDurationSeconds: $maxDurationSeconds, idleTimeoutSeconds: $idleTimeoutSeconds, maxRequestBodyBytes: $maxRequestBodyBytes, retentionDays: $retentionDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConfigLimitsImpl &&
            (identical(other.maxTurns, maxTurns) ||
                other.maxTurns == maxTurns) &&
            (identical(other.maxDurationSeconds, maxDurationSeconds) ||
                other.maxDurationSeconds == maxDurationSeconds) &&
            (identical(other.idleTimeoutSeconds, idleTimeoutSeconds) ||
                other.idleTimeoutSeconds == idleTimeoutSeconds) &&
            (identical(other.maxRequestBodyBytes, maxRequestBodyBytes) ||
                other.maxRequestBodyBytes == maxRequestBodyBytes) &&
            (identical(other.retentionDays, retentionDays) ||
                other.retentionDays == retentionDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, maxTurns, maxDurationSeconds,
      idleTimeoutSeconds, maxRequestBodyBytes, retentionDays);

  /// Create a copy of ConfigLimits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConfigLimitsImplCopyWith<_$ConfigLimitsImpl> get copyWith =>
      __$$ConfigLimitsImplCopyWithImpl<_$ConfigLimitsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConfigLimitsImplToJson(
      this,
    );
  }
}

abstract class _ConfigLimits implements ConfigLimits {
  const factory _ConfigLimits(
      {required final int maxTurns,
      required final int maxDurationSeconds,
      required final int idleTimeoutSeconds,
      required final int maxRequestBodyBytes,
      required final int retentionDays}) = _$ConfigLimitsImpl;

  factory _ConfigLimits.fromJson(Map<String, dynamic> json) =
      _$ConfigLimitsImpl.fromJson;

  @override
  int get maxTurns;
  @override
  int get maxDurationSeconds;
  @override
  int get idleTimeoutSeconds;
  @override
  int get maxRequestBodyBytes;
  @override
  int get retentionDays;

  /// Create a copy of ConfigLimits
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConfigLimitsImplCopyWith<_$ConfigLimitsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConfigResponse _$ConfigResponseFromJson(Map<String, dynamic> json) {
  return _ConfigResponse.fromJson(json);
}

/// @nodoc
mixin _$ConfigResponse {
  ConfigFlags get flags => throw _privateConstructorUsedError;
  List<String> get languages => throw _privateConstructorUsedError;
  ConfigLimits get limits => throw _privateConstructorUsedError;

  /// Serializes this ConfigResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConfigResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConfigResponseCopyWith<ConfigResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConfigResponseCopyWith<$Res> {
  factory $ConfigResponseCopyWith(
          ConfigResponse value, $Res Function(ConfigResponse) then) =
      _$ConfigResponseCopyWithImpl<$Res, ConfigResponse>;
  @useResult
  $Res call({ConfigFlags flags, List<String> languages, ConfigLimits limits});

  $ConfigFlagsCopyWith<$Res> get flags;
  $ConfigLimitsCopyWith<$Res> get limits;
}

/// @nodoc
class _$ConfigResponseCopyWithImpl<$Res, $Val extends ConfigResponse>
    implements $ConfigResponseCopyWith<$Res> {
  _$ConfigResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConfigResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? flags = null,
    Object? languages = null,
    Object? limits = null,
  }) {
    return _then(_value.copyWith(
      flags: null == flags
          ? _value.flags
          : flags // ignore: cast_nullable_to_non_nullable
              as ConfigFlags,
      languages: null == languages
          ? _value.languages
          : languages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      limits: null == limits
          ? _value.limits
          : limits // ignore: cast_nullable_to_non_nullable
              as ConfigLimits,
    ) as $Val);
  }

  /// Create a copy of ConfigResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConfigFlagsCopyWith<$Res> get flags {
    return $ConfigFlagsCopyWith<$Res>(_value.flags, (value) {
      return _then(_value.copyWith(flags: value) as $Val);
    });
  }

  /// Create a copy of ConfigResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConfigLimitsCopyWith<$Res> get limits {
    return $ConfigLimitsCopyWith<$Res>(_value.limits, (value) {
      return _then(_value.copyWith(limits: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConfigResponseImplCopyWith<$Res>
    implements $ConfigResponseCopyWith<$Res> {
  factory _$$ConfigResponseImplCopyWith(_$ConfigResponseImpl value,
          $Res Function(_$ConfigResponseImpl) then) =
      __$$ConfigResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ConfigFlags flags, List<String> languages, ConfigLimits limits});

  @override
  $ConfigFlagsCopyWith<$Res> get flags;
  @override
  $ConfigLimitsCopyWith<$Res> get limits;
}

/// @nodoc
class __$$ConfigResponseImplCopyWithImpl<$Res>
    extends _$ConfigResponseCopyWithImpl<$Res, _$ConfigResponseImpl>
    implements _$$ConfigResponseImplCopyWith<$Res> {
  __$$ConfigResponseImplCopyWithImpl(
      _$ConfigResponseImpl _value, $Res Function(_$ConfigResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConfigResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? flags = null,
    Object? languages = null,
    Object? limits = null,
  }) {
    return _then(_$ConfigResponseImpl(
      flags: null == flags
          ? _value.flags
          : flags // ignore: cast_nullable_to_non_nullable
              as ConfigFlags,
      languages: null == languages
          ? _value._languages
          : languages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      limits: null == limits
          ? _value.limits
          : limits // ignore: cast_nullable_to_non_nullable
              as ConfigLimits,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$ConfigResponseImpl implements _ConfigResponse {
  const _$ConfigResponseImpl(
      {required this.flags,
      required final List<String> languages,
      required this.limits})
      : _languages = languages;

  factory _$ConfigResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConfigResponseImplFromJson(json);

  @override
  final ConfigFlags flags;
  final List<String> _languages;
  @override
  List<String> get languages {
    if (_languages is EqualUnmodifiableListView) return _languages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_languages);
  }

  @override
  final ConfigLimits limits;

  @override
  String toString() {
    return 'ConfigResponse(flags: $flags, languages: $languages, limits: $limits)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConfigResponseImpl &&
            (identical(other.flags, flags) || other.flags == flags) &&
            const DeepCollectionEquality()
                .equals(other._languages, _languages) &&
            (identical(other.limits, limits) || other.limits == limits));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, flags,
      const DeepCollectionEquality().hash(_languages), limits);

  /// Create a copy of ConfigResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConfigResponseImplCopyWith<_$ConfigResponseImpl> get copyWith =>
      __$$ConfigResponseImplCopyWithImpl<_$ConfigResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConfigResponseImplToJson(
      this,
    );
  }
}

abstract class _ConfigResponse implements ConfigResponse {
  const factory _ConfigResponse(
      {required final ConfigFlags flags,
      required final List<String> languages,
      required final ConfigLimits limits}) = _$ConfigResponseImpl;

  factory _ConfigResponse.fromJson(Map<String, dynamic> json) =
      _$ConfigResponseImpl.fromJson;

  @override
  ConfigFlags get flags;
  @override
  List<String> get languages;
  @override
  ConfigLimits get limits;

  /// Create a copy of ConfigResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConfigResponseImplCopyWith<_$ConfigResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScenarioGraphResponse _$ScenarioGraphResponseFromJson(
    Map<String, dynamic> json) {
  return _ScenarioGraphResponse.fromJson(json);
}

/// @nodoc
mixin _$ScenarioGraphResponse {
  List<StageId> get stageIds => throw _privateConstructorUsedError;
  List<LabelId> get labels => throw _privateConstructorUsedError;

  /// Serializes this ScenarioGraphResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScenarioGraphResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScenarioGraphResponseCopyWith<ScenarioGraphResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScenarioGraphResponseCopyWith<$Res> {
  factory $ScenarioGraphResponseCopyWith(ScenarioGraphResponse value,
          $Res Function(ScenarioGraphResponse) then) =
      _$ScenarioGraphResponseCopyWithImpl<$Res, ScenarioGraphResponse>;
  @useResult
  $Res call({List<StageId> stageIds, List<LabelId> labels});
}

/// @nodoc
class _$ScenarioGraphResponseCopyWithImpl<$Res,
        $Val extends ScenarioGraphResponse>
    implements $ScenarioGraphResponseCopyWith<$Res> {
  _$ScenarioGraphResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScenarioGraphResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stageIds = null,
    Object? labels = null,
  }) {
    return _then(_value.copyWith(
      stageIds: null == stageIds
          ? _value.stageIds
          : stageIds // ignore: cast_nullable_to_non_nullable
              as List<StageId>,
      labels: null == labels
          ? _value.labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<LabelId>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScenarioGraphResponseImplCopyWith<$Res>
    implements $ScenarioGraphResponseCopyWith<$Res> {
  factory _$$ScenarioGraphResponseImplCopyWith(
          _$ScenarioGraphResponseImpl value,
          $Res Function(_$ScenarioGraphResponseImpl) then) =
      __$$ScenarioGraphResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<StageId> stageIds, List<LabelId> labels});
}

/// @nodoc
class __$$ScenarioGraphResponseImplCopyWithImpl<$Res>
    extends _$ScenarioGraphResponseCopyWithImpl<$Res,
        _$ScenarioGraphResponseImpl>
    implements _$$ScenarioGraphResponseImplCopyWith<$Res> {
  __$$ScenarioGraphResponseImplCopyWithImpl(_$ScenarioGraphResponseImpl _value,
      $Res Function(_$ScenarioGraphResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScenarioGraphResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stageIds = null,
    Object? labels = null,
  }) {
    return _then(_$ScenarioGraphResponseImpl(
      stageIds: null == stageIds
          ? _value._stageIds
          : stageIds // ignore: cast_nullable_to_non_nullable
              as List<StageId>,
      labels: null == labels
          ? _value._labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<LabelId>,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$ScenarioGraphResponseImpl implements _ScenarioGraphResponse {
  const _$ScenarioGraphResponseImpl(
      {required final List<StageId> stageIds,
      required final List<LabelId> labels})
      : _stageIds = stageIds,
        _labels = labels;

  factory _$ScenarioGraphResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScenarioGraphResponseImplFromJson(json);

  final List<StageId> _stageIds;
  @override
  List<StageId> get stageIds {
    if (_stageIds is EqualUnmodifiableListView) return _stageIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stageIds);
  }

  final List<LabelId> _labels;
  @override
  List<LabelId> get labels {
    if (_labels is EqualUnmodifiableListView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_labels);
  }

  @override
  String toString() {
    return 'ScenarioGraphResponse(stageIds: $stageIds, labels: $labels)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScenarioGraphResponseImpl &&
            const DeepCollectionEquality().equals(other._stageIds, _stageIds) &&
            const DeepCollectionEquality().equals(other._labels, _labels));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_stageIds),
      const DeepCollectionEquality().hash(_labels));

  /// Create a copy of ScenarioGraphResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScenarioGraphResponseImplCopyWith<_$ScenarioGraphResponseImpl>
      get copyWith => __$$ScenarioGraphResponseImplCopyWithImpl<
          _$ScenarioGraphResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScenarioGraphResponseImplToJson(
      this,
    );
  }
}

abstract class _ScenarioGraphResponse implements ScenarioGraphResponse {
  const factory _ScenarioGraphResponse(
      {required final List<StageId> stageIds,
      required final List<LabelId> labels}) = _$ScenarioGraphResponseImpl;

  factory _ScenarioGraphResponse.fromJson(Map<String, dynamic> json) =
      _$ScenarioGraphResponseImpl.fromJson;

  @override
  List<StageId> get stageIds;
  @override
  List<LabelId> get labels;

  /// Create a copy of ScenarioGraphResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScenarioGraphResponseImplCopyWith<_$ScenarioGraphResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

InviteCreateRequest _$InviteCreateRequestFromJson(Map<String, dynamic> json) {
  return _InviteCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$InviteCreateRequest {
  AppLanguage get language => throw _privateConstructorUsedError;
  String? get cohort => throw _privateConstructorUsedError;

  /// Serializes this InviteCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InviteCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InviteCreateRequestCopyWith<InviteCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InviteCreateRequestCopyWith<$Res> {
  factory $InviteCreateRequestCopyWith(
          InviteCreateRequest value, $Res Function(InviteCreateRequest) then) =
      _$InviteCreateRequestCopyWithImpl<$Res, InviteCreateRequest>;
  @useResult
  $Res call({AppLanguage language, String? cohort});
}

/// @nodoc
class _$InviteCreateRequestCopyWithImpl<$Res, $Val extends InviteCreateRequest>
    implements $InviteCreateRequestCopyWith<$Res> {
  _$InviteCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InviteCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? language = null,
    Object? cohort = freezed,
  }) {
    return _then(_value.copyWith(
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as AppLanguage,
      cohort: freezed == cohort
          ? _value.cohort
          : cohort // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InviteCreateRequestImplCopyWith<$Res>
    implements $InviteCreateRequestCopyWith<$Res> {
  factory _$$InviteCreateRequestImplCopyWith(_$InviteCreateRequestImpl value,
          $Res Function(_$InviteCreateRequestImpl) then) =
      __$$InviteCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AppLanguage language, String? cohort});
}

/// @nodoc
class __$$InviteCreateRequestImplCopyWithImpl<$Res>
    extends _$InviteCreateRequestCopyWithImpl<$Res, _$InviteCreateRequestImpl>
    implements _$$InviteCreateRequestImplCopyWith<$Res> {
  __$$InviteCreateRequestImplCopyWithImpl(_$InviteCreateRequestImpl _value,
      $Res Function(_$InviteCreateRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of InviteCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? language = null,
    Object? cohort = freezed,
  }) {
    return _then(_$InviteCreateRequestImpl(
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as AppLanguage,
      cohort: freezed == cohort
          ? _value.cohort
          : cohort // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$InviteCreateRequestImpl implements _InviteCreateRequest {
  const _$InviteCreateRequestImpl({required this.language, this.cohort});

  factory _$InviteCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$InviteCreateRequestImplFromJson(json);

  @override
  final AppLanguage language;
  @override
  final String? cohort;

  @override
  String toString() {
    return 'InviteCreateRequest(language: $language, cohort: $cohort)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InviteCreateRequestImpl &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.cohort, cohort) || other.cohort == cohort));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, language, cohort);

  /// Create a copy of InviteCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InviteCreateRequestImplCopyWith<_$InviteCreateRequestImpl> get copyWith =>
      __$$InviteCreateRequestImplCopyWithImpl<_$InviteCreateRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InviteCreateRequestImplToJson(
      this,
    );
  }
}

abstract class _InviteCreateRequest implements InviteCreateRequest {
  const factory _InviteCreateRequest(
      {required final AppLanguage language,
      final String? cohort}) = _$InviteCreateRequestImpl;

  factory _InviteCreateRequest.fromJson(Map<String, dynamic> json) =
      _$InviteCreateRequestImpl.fromJson;

  @override
  AppLanguage get language;
  @override
  String? get cohort;

  /// Create a copy of InviteCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InviteCreateRequestImplCopyWith<_$InviteCreateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InviteResponse _$InviteResponseFromJson(Map<String, dynamic> json) {
  return _InviteResponse.fromJson(json);
}

/// @nodoc
mixin _$InviteResponse {
  String get inviteToken => throw _privateConstructorUsedError;
  String get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this InviteResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InviteResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InviteResponseCopyWith<InviteResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InviteResponseCopyWith<$Res> {
  factory $InviteResponseCopyWith(
          InviteResponse value, $Res Function(InviteResponse) then) =
      _$InviteResponseCopyWithImpl<$Res, InviteResponse>;
  @useResult
  $Res call({String inviteToken, String expiresAt});
}

/// @nodoc
class _$InviteResponseCopyWithImpl<$Res, $Val extends InviteResponse>
    implements $InviteResponseCopyWith<$Res> {
  _$InviteResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InviteResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inviteToken = null,
    Object? expiresAt = null,
  }) {
    return _then(_value.copyWith(
      inviteToken: null == inviteToken
          ? _value.inviteToken
          : inviteToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InviteResponseImplCopyWith<$Res>
    implements $InviteResponseCopyWith<$Res> {
  factory _$$InviteResponseImplCopyWith(_$InviteResponseImpl value,
          $Res Function(_$InviteResponseImpl) then) =
      __$$InviteResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String inviteToken, String expiresAt});
}

/// @nodoc
class __$$InviteResponseImplCopyWithImpl<$Res>
    extends _$InviteResponseCopyWithImpl<$Res, _$InviteResponseImpl>
    implements _$$InviteResponseImplCopyWith<$Res> {
  __$$InviteResponseImplCopyWithImpl(
      _$InviteResponseImpl _value, $Res Function(_$InviteResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of InviteResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inviteToken = null,
    Object? expiresAt = null,
  }) {
    return _then(_$InviteResponseImpl(
      inviteToken: null == inviteToken
          ? _value.inviteToken
          : inviteToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$InviteResponseImpl implements _InviteResponse {
  const _$InviteResponseImpl(
      {required this.inviteToken, required this.expiresAt});

  factory _$InviteResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$InviteResponseImplFromJson(json);

  @override
  final String inviteToken;
  @override
  final String expiresAt;

  @override
  String toString() {
    return 'InviteResponse(inviteToken: $inviteToken, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InviteResponseImpl &&
            (identical(other.inviteToken, inviteToken) ||
                other.inviteToken == inviteToken) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, inviteToken, expiresAt);

  /// Create a copy of InviteResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InviteResponseImplCopyWith<_$InviteResponseImpl> get copyWith =>
      __$$InviteResponseImplCopyWithImpl<_$InviteResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InviteResponseImplToJson(
      this,
    );
  }
}

abstract class _InviteResponse implements InviteResponse {
  const factory _InviteResponse(
      {required final String inviteToken,
      required final String expiresAt}) = _$InviteResponseImpl;

  factory _InviteResponse.fromJson(Map<String, dynamic> json) =
      _$InviteResponseImpl.fromJson;

  @override
  String get inviteToken;
  @override
  String get expiresAt;

  /// Create a copy of InviteResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InviteResponseImplCopyWith<_$InviteResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CurrentInviteResponse _$CurrentInviteResponseFromJson(
    Map<String, dynamic> json) {
  return _CurrentInviteResponse.fromJson(json);
}

/// @nodoc
mixin _$CurrentInviteResponse {
  String? get cohort => throw _privateConstructorUsedError;
  AppLanguage get language => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this CurrentInviteResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CurrentInviteResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CurrentInviteResponseCopyWith<CurrentInviteResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurrentInviteResponseCopyWith<$Res> {
  factory $CurrentInviteResponseCopyWith(CurrentInviteResponse value,
          $Res Function(CurrentInviteResponse) then) =
      _$CurrentInviteResponseCopyWithImpl<$Res, CurrentInviteResponse>;
  @useResult
  $Res call(
      {String? cohort,
      AppLanguage language,
      String createdAt,
      String expiresAt});
}

/// @nodoc
class _$CurrentInviteResponseCopyWithImpl<$Res,
        $Val extends CurrentInviteResponse>
    implements $CurrentInviteResponseCopyWith<$Res> {
  _$CurrentInviteResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CurrentInviteResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cohort = freezed,
    Object? language = null,
    Object? createdAt = null,
    Object? expiresAt = null,
  }) {
    return _then(_value.copyWith(
      cohort: freezed == cohort
          ? _value.cohort
          : cohort // ignore: cast_nullable_to_non_nullable
              as String?,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as AppLanguage,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CurrentInviteResponseImplCopyWith<$Res>
    implements $CurrentInviteResponseCopyWith<$Res> {
  factory _$$CurrentInviteResponseImplCopyWith(
          _$CurrentInviteResponseImpl value,
          $Res Function(_$CurrentInviteResponseImpl) then) =
      __$$CurrentInviteResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? cohort,
      AppLanguage language,
      String createdAt,
      String expiresAt});
}

/// @nodoc
class __$$CurrentInviteResponseImplCopyWithImpl<$Res>
    extends _$CurrentInviteResponseCopyWithImpl<$Res,
        _$CurrentInviteResponseImpl>
    implements _$$CurrentInviteResponseImplCopyWith<$Res> {
  __$$CurrentInviteResponseImplCopyWithImpl(_$CurrentInviteResponseImpl _value,
      $Res Function(_$CurrentInviteResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of CurrentInviteResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cohort = freezed,
    Object? language = null,
    Object? createdAt = null,
    Object? expiresAt = null,
  }) {
    return _then(_$CurrentInviteResponseImpl(
      cohort: freezed == cohort
          ? _value.cohort
          : cohort // ignore: cast_nullable_to_non_nullable
              as String?,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as AppLanguage,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$CurrentInviteResponseImpl implements _CurrentInviteResponse {
  const _$CurrentInviteResponseImpl(
      {this.cohort,
      required this.language,
      required this.createdAt,
      required this.expiresAt});

  factory _$CurrentInviteResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CurrentInviteResponseImplFromJson(json);

  @override
  final String? cohort;
  @override
  final AppLanguage language;
  @override
  final String createdAt;
  @override
  final String expiresAt;

  @override
  String toString() {
    return 'CurrentInviteResponse(cohort: $cohort, language: $language, createdAt: $createdAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CurrentInviteResponseImpl &&
            (identical(other.cohort, cohort) || other.cohort == cohort) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, cohort, language, createdAt, expiresAt);

  /// Create a copy of CurrentInviteResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CurrentInviteResponseImplCopyWith<_$CurrentInviteResponseImpl>
      get copyWith => __$$CurrentInviteResponseImplCopyWithImpl<
          _$CurrentInviteResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CurrentInviteResponseImplToJson(
      this,
    );
  }
}

abstract class _CurrentInviteResponse implements CurrentInviteResponse {
  const factory _CurrentInviteResponse(
      {final String? cohort,
      required final AppLanguage language,
      required final String createdAt,
      required final String expiresAt}) = _$CurrentInviteResponseImpl;

  factory _CurrentInviteResponse.fromJson(Map<String, dynamic> json) =
      _$CurrentInviteResponseImpl.fromJson;

  @override
  String? get cohort;
  @override
  AppLanguage get language;
  @override
  String get createdAt;
  @override
  String get expiresAt;

  /// Create a copy of CurrentInviteResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CurrentInviteResponseImplCopyWith<_$CurrentInviteResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SessionCreateRequest _$SessionCreateRequestFromJson(Map<String, dynamic> json) {
  return _SessionCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$SessionCreateRequest {
  bool get consent => throw _privateConstructorUsedError;
  bool get statsOptIn => throw _privateConstructorUsedError;
  SessionMode get mode => throw _privateConstructorUsedError;

  /// Serializes this SessionCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionCreateRequestCopyWith<SessionCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionCreateRequestCopyWith<$Res> {
  factory $SessionCreateRequestCopyWith(SessionCreateRequest value,
          $Res Function(SessionCreateRequest) then) =
      _$SessionCreateRequestCopyWithImpl<$Res, SessionCreateRequest>;
  @useResult
  $Res call({bool consent, bool statsOptIn, SessionMode mode});
}

/// @nodoc
class _$SessionCreateRequestCopyWithImpl<$Res,
        $Val extends SessionCreateRequest>
    implements $SessionCreateRequestCopyWith<$Res> {
  _$SessionCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? consent = null,
    Object? statsOptIn = null,
    Object? mode = null,
  }) {
    return _then(_value.copyWith(
      consent: null == consent
          ? _value.consent
          : consent // ignore: cast_nullable_to_non_nullable
              as bool,
      statsOptIn: null == statsOptIn
          ? _value.statsOptIn
          : statsOptIn // ignore: cast_nullable_to_non_nullable
              as bool,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as SessionMode,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionCreateRequestImplCopyWith<$Res>
    implements $SessionCreateRequestCopyWith<$Res> {
  factory _$$SessionCreateRequestImplCopyWith(_$SessionCreateRequestImpl value,
          $Res Function(_$SessionCreateRequestImpl) then) =
      __$$SessionCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool consent, bool statsOptIn, SessionMode mode});
}

/// @nodoc
class __$$SessionCreateRequestImplCopyWithImpl<$Res>
    extends _$SessionCreateRequestCopyWithImpl<$Res, _$SessionCreateRequestImpl>
    implements _$$SessionCreateRequestImplCopyWith<$Res> {
  __$$SessionCreateRequestImplCopyWithImpl(_$SessionCreateRequestImpl _value,
      $Res Function(_$SessionCreateRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? consent = null,
    Object? statsOptIn = null,
    Object? mode = null,
  }) {
    return _then(_$SessionCreateRequestImpl(
      consent: null == consent
          ? _value.consent
          : consent // ignore: cast_nullable_to_non_nullable
              as bool,
      statsOptIn: null == statsOptIn
          ? _value.statsOptIn
          : statsOptIn // ignore: cast_nullable_to_non_nullable
              as bool,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as SessionMode,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$SessionCreateRequestImpl implements _SessionCreateRequest {
  const _$SessionCreateRequestImpl(
      {required this.consent, this.statsOptIn = false, required this.mode});

  factory _$SessionCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionCreateRequestImplFromJson(json);

  @override
  final bool consent;
  @override
  @JsonKey()
  final bool statsOptIn;
  @override
  final SessionMode mode;

  @override
  String toString() {
    return 'SessionCreateRequest(consent: $consent, statsOptIn: $statsOptIn, mode: $mode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionCreateRequestImpl &&
            (identical(other.consent, consent) || other.consent == consent) &&
            (identical(other.statsOptIn, statsOptIn) ||
                other.statsOptIn == statsOptIn) &&
            (identical(other.mode, mode) || other.mode == mode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, consent, statsOptIn, mode);

  /// Create a copy of SessionCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionCreateRequestImplCopyWith<_$SessionCreateRequestImpl>
      get copyWith =>
          __$$SessionCreateRequestImplCopyWithImpl<_$SessionCreateRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionCreateRequestImplToJson(
      this,
    );
  }
}

abstract class _SessionCreateRequest implements SessionCreateRequest {
  const factory _SessionCreateRequest(
      {required final bool consent,
      final bool statsOptIn,
      required final SessionMode mode}) = _$SessionCreateRequestImpl;

  factory _SessionCreateRequest.fromJson(Map<String, dynamic> json) =
      _$SessionCreateRequestImpl.fromJson;

  @override
  bool get consent;
  @override
  bool get statsOptIn;
  @override
  SessionMode get mode;

  /// Create a copy of SessionCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionCreateRequestImplCopyWith<_$SessionCreateRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

OfficerLine _$OfficerLineFromJson(Map<String, dynamic> json) {
  return _OfficerLine.fromJson(json);
}

/// @nodoc
mixin _$OfficerLine {
  String get display => throw _privateConstructorUsedError;
  String get speak => throw _privateConstructorUsedError;
  AppLanguage get language => throw _privateConstructorUsedError;

  /// Serializes this OfficerLine to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OfficerLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OfficerLineCopyWith<OfficerLine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OfficerLineCopyWith<$Res> {
  factory $OfficerLineCopyWith(
          OfficerLine value, $Res Function(OfficerLine) then) =
      _$OfficerLineCopyWithImpl<$Res, OfficerLine>;
  @useResult
  $Res call({String display, String speak, AppLanguage language});
}

/// @nodoc
class _$OfficerLineCopyWithImpl<$Res, $Val extends OfficerLine>
    implements $OfficerLineCopyWith<$Res> {
  _$OfficerLineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OfficerLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? display = null,
    Object? speak = null,
    Object? language = null,
  }) {
    return _then(_value.copyWith(
      display: null == display
          ? _value.display
          : display // ignore: cast_nullable_to_non_nullable
              as String,
      speak: null == speak
          ? _value.speak
          : speak // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as AppLanguage,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OfficerLineImplCopyWith<$Res>
    implements $OfficerLineCopyWith<$Res> {
  factory _$$OfficerLineImplCopyWith(
          _$OfficerLineImpl value, $Res Function(_$OfficerLineImpl) then) =
      __$$OfficerLineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String display, String speak, AppLanguage language});
}

/// @nodoc
class __$$OfficerLineImplCopyWithImpl<$Res>
    extends _$OfficerLineCopyWithImpl<$Res, _$OfficerLineImpl>
    implements _$$OfficerLineImplCopyWith<$Res> {
  __$$OfficerLineImplCopyWithImpl(
      _$OfficerLineImpl _value, $Res Function(_$OfficerLineImpl) _then)
      : super(_value, _then);

  /// Create a copy of OfficerLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? display = null,
    Object? speak = null,
    Object? language = null,
  }) {
    return _then(_$OfficerLineImpl(
      display: null == display
          ? _value.display
          : display // ignore: cast_nullable_to_non_nullable
              as String,
      speak: null == speak
          ? _value.speak
          : speak // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as AppLanguage,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$OfficerLineImpl implements _OfficerLine {
  const _$OfficerLineImpl(
      {required this.display, required this.speak, required this.language});

  factory _$OfficerLineImpl.fromJson(Map<String, dynamic> json) =>
      _$$OfficerLineImplFromJson(json);

  @override
  final String display;
  @override
  final String speak;
  @override
  final AppLanguage language;

  @override
  String toString() {
    return 'OfficerLine(display: $display, speak: $speak, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OfficerLineImpl &&
            (identical(other.display, display) || other.display == display) &&
            (identical(other.speak, speak) || other.speak == speak) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, display, speak, language);

  /// Create a copy of OfficerLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OfficerLineImplCopyWith<_$OfficerLineImpl> get copyWith =>
      __$$OfficerLineImplCopyWithImpl<_$OfficerLineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OfficerLineImplToJson(
      this,
    );
  }
}

abstract class _OfficerLine implements OfficerLine {
  const factory _OfficerLine(
      {required final String display,
      required final String speak,
      required final AppLanguage language}) = _$OfficerLineImpl;

  factory _OfficerLine.fromJson(Map<String, dynamic> json) =
      _$OfficerLineImpl.fromJson;

  @override
  String get display;
  @override
  String get speak;
  @override
  AppLanguage get language;

  /// Create a copy of OfficerLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OfficerLineImplCopyWith<_$OfficerLineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TurnResponse _$TurnResponseFromJson(Map<String, dynamic> json) {
  return _TurnResponse.fromJson(json);
}

/// @nodoc
mixin _$TurnResponse {
  OfficerLine? get officerLine => throw _privateConstructorUsedError;
  StageId get stageId => throw _privateConstructorUsedError;
  int get pressure => throw _privateConstructorUsedError;
  TurnStatus get status => throw _privateConstructorUsedError;
  EndReason? get endReason => throw _privateConstructorUsedError;
  int get turnIndex => throw _privateConstructorUsedError;
  bool get fallbackUsed => throw _privateConstructorUsedError;
  bool get piiWarning => throw _privateConstructorUsedError;

  /// Serializes this TurnResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TurnResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TurnResponseCopyWith<TurnResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TurnResponseCopyWith<$Res> {
  factory $TurnResponseCopyWith(
          TurnResponse value, $Res Function(TurnResponse) then) =
      _$TurnResponseCopyWithImpl<$Res, TurnResponse>;
  @useResult
  $Res call(
      {OfficerLine? officerLine,
      StageId stageId,
      int pressure,
      TurnStatus status,
      EndReason? endReason,
      int turnIndex,
      bool fallbackUsed,
      bool piiWarning});

  $OfficerLineCopyWith<$Res>? get officerLine;
}

/// @nodoc
class _$TurnResponseCopyWithImpl<$Res, $Val extends TurnResponse>
    implements $TurnResponseCopyWith<$Res> {
  _$TurnResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TurnResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? officerLine = freezed,
    Object? stageId = null,
    Object? pressure = null,
    Object? status = null,
    Object? endReason = freezed,
    Object? turnIndex = null,
    Object? fallbackUsed = null,
    Object? piiWarning = null,
  }) {
    return _then(_value.copyWith(
      officerLine: freezed == officerLine
          ? _value.officerLine
          : officerLine // ignore: cast_nullable_to_non_nullable
              as OfficerLine?,
      stageId: null == stageId
          ? _value.stageId
          : stageId // ignore: cast_nullable_to_non_nullable
              as StageId,
      pressure: null == pressure
          ? _value.pressure
          : pressure // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TurnStatus,
      endReason: freezed == endReason
          ? _value.endReason
          : endReason // ignore: cast_nullable_to_non_nullable
              as EndReason?,
      turnIndex: null == turnIndex
          ? _value.turnIndex
          : turnIndex // ignore: cast_nullable_to_non_nullable
              as int,
      fallbackUsed: null == fallbackUsed
          ? _value.fallbackUsed
          : fallbackUsed // ignore: cast_nullable_to_non_nullable
              as bool,
      piiWarning: null == piiWarning
          ? _value.piiWarning
          : piiWarning // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of TurnResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OfficerLineCopyWith<$Res>? get officerLine {
    if (_value.officerLine == null) {
      return null;
    }

    return $OfficerLineCopyWith<$Res>(_value.officerLine!, (value) {
      return _then(_value.copyWith(officerLine: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TurnResponseImplCopyWith<$Res>
    implements $TurnResponseCopyWith<$Res> {
  factory _$$TurnResponseImplCopyWith(
          _$TurnResponseImpl value, $Res Function(_$TurnResponseImpl) then) =
      __$$TurnResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {OfficerLine? officerLine,
      StageId stageId,
      int pressure,
      TurnStatus status,
      EndReason? endReason,
      int turnIndex,
      bool fallbackUsed,
      bool piiWarning});

  @override
  $OfficerLineCopyWith<$Res>? get officerLine;
}

/// @nodoc
class __$$TurnResponseImplCopyWithImpl<$Res>
    extends _$TurnResponseCopyWithImpl<$Res, _$TurnResponseImpl>
    implements _$$TurnResponseImplCopyWith<$Res> {
  __$$TurnResponseImplCopyWithImpl(
      _$TurnResponseImpl _value, $Res Function(_$TurnResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TurnResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? officerLine = freezed,
    Object? stageId = null,
    Object? pressure = null,
    Object? status = null,
    Object? endReason = freezed,
    Object? turnIndex = null,
    Object? fallbackUsed = null,
    Object? piiWarning = null,
  }) {
    return _then(_$TurnResponseImpl(
      officerLine: freezed == officerLine
          ? _value.officerLine
          : officerLine // ignore: cast_nullable_to_non_nullable
              as OfficerLine?,
      stageId: null == stageId
          ? _value.stageId
          : stageId // ignore: cast_nullable_to_non_nullable
              as StageId,
      pressure: null == pressure
          ? _value.pressure
          : pressure // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TurnStatus,
      endReason: freezed == endReason
          ? _value.endReason
          : endReason // ignore: cast_nullable_to_non_nullable
              as EndReason?,
      turnIndex: null == turnIndex
          ? _value.turnIndex
          : turnIndex // ignore: cast_nullable_to_non_nullable
              as int,
      fallbackUsed: null == fallbackUsed
          ? _value.fallbackUsed
          : fallbackUsed // ignore: cast_nullable_to_non_nullable
              as bool,
      piiWarning: null == piiWarning
          ? _value.piiWarning
          : piiWarning // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$TurnResponseImpl implements _TurnResponse {
  const _$TurnResponseImpl(
      {this.officerLine,
      required this.stageId,
      required this.pressure,
      required this.status,
      this.endReason,
      required this.turnIndex,
      required this.fallbackUsed,
      required this.piiWarning})
      : assert(
            pressure >= 0 && pressure <= 3, 'pressure must be between 0 and 3'),
        assert(turnIndex >= 0, 'turn index must not be negative');

  factory _$TurnResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TurnResponseImplFromJson(json);

  @override
  final OfficerLine? officerLine;
  @override
  final StageId stageId;
  @override
  final int pressure;
  @override
  final TurnStatus status;
  @override
  final EndReason? endReason;
  @override
  final int turnIndex;
  @override
  final bool fallbackUsed;
  @override
  final bool piiWarning;

  @override
  String toString() {
    return 'TurnResponse(officerLine: $officerLine, stageId: $stageId, pressure: $pressure, status: $status, endReason: $endReason, turnIndex: $turnIndex, fallbackUsed: $fallbackUsed, piiWarning: $piiWarning)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TurnResponseImpl &&
            (identical(other.officerLine, officerLine) ||
                other.officerLine == officerLine) &&
            (identical(other.stageId, stageId) || other.stageId == stageId) &&
            (identical(other.pressure, pressure) ||
                other.pressure == pressure) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.endReason, endReason) ||
                other.endReason == endReason) &&
            (identical(other.turnIndex, turnIndex) ||
                other.turnIndex == turnIndex) &&
            (identical(other.fallbackUsed, fallbackUsed) ||
                other.fallbackUsed == fallbackUsed) &&
            (identical(other.piiWarning, piiWarning) ||
                other.piiWarning == piiWarning));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, officerLine, stageId, pressure,
      status, endReason, turnIndex, fallbackUsed, piiWarning);

  /// Create a copy of TurnResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TurnResponseImplCopyWith<_$TurnResponseImpl> get copyWith =>
      __$$TurnResponseImplCopyWithImpl<_$TurnResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TurnResponseImplToJson(
      this,
    );
  }
}

abstract class _TurnResponse implements TurnResponse {
  const factory _TurnResponse(
      {final OfficerLine? officerLine,
      required final StageId stageId,
      required final int pressure,
      required final TurnStatus status,
      final EndReason? endReason,
      required final int turnIndex,
      required final bool fallbackUsed,
      required final bool piiWarning}) = _$TurnResponseImpl;

  factory _TurnResponse.fromJson(Map<String, dynamic> json) =
      _$TurnResponseImpl.fromJson;

  @override
  OfficerLine? get officerLine;
  @override
  StageId get stageId;
  @override
  int get pressure;
  @override
  TurnStatus get status;
  @override
  EndReason? get endReason;
  @override
  int get turnIndex;
  @override
  bool get fallbackUsed;
  @override
  bool get piiWarning;

  /// Create a copy of TurnResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TurnResponseImplCopyWith<_$TurnResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionLimits _$SessionLimitsFromJson(Map<String, dynamic> json) {
  return _SessionLimits.fromJson(json);
}

/// @nodoc
mixin _$SessionLimits {
  int get maxTurns => throw _privateConstructorUsedError;
  int get maxDurationSeconds => throw _privateConstructorUsedError;
  int get idleTimeoutSeconds => throw _privateConstructorUsedError;

  /// Serializes this SessionLimits to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionLimits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionLimitsCopyWith<SessionLimits> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionLimitsCopyWith<$Res> {
  factory $SessionLimitsCopyWith(
          SessionLimits value, $Res Function(SessionLimits) then) =
      _$SessionLimitsCopyWithImpl<$Res, SessionLimits>;
  @useResult
  $Res call({int maxTurns, int maxDurationSeconds, int idleTimeoutSeconds});
}

/// @nodoc
class _$SessionLimitsCopyWithImpl<$Res, $Val extends SessionLimits>
    implements $SessionLimitsCopyWith<$Res> {
  _$SessionLimitsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionLimits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxTurns = null,
    Object? maxDurationSeconds = null,
    Object? idleTimeoutSeconds = null,
  }) {
    return _then(_value.copyWith(
      maxTurns: null == maxTurns
          ? _value.maxTurns
          : maxTurns // ignore: cast_nullable_to_non_nullable
              as int,
      maxDurationSeconds: null == maxDurationSeconds
          ? _value.maxDurationSeconds
          : maxDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      idleTimeoutSeconds: null == idleTimeoutSeconds
          ? _value.idleTimeoutSeconds
          : idleTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionLimitsImplCopyWith<$Res>
    implements $SessionLimitsCopyWith<$Res> {
  factory _$$SessionLimitsImplCopyWith(
          _$SessionLimitsImpl value, $Res Function(_$SessionLimitsImpl) then) =
      __$$SessionLimitsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int maxTurns, int maxDurationSeconds, int idleTimeoutSeconds});
}

/// @nodoc
class __$$SessionLimitsImplCopyWithImpl<$Res>
    extends _$SessionLimitsCopyWithImpl<$Res, _$SessionLimitsImpl>
    implements _$$SessionLimitsImplCopyWith<$Res> {
  __$$SessionLimitsImplCopyWithImpl(
      _$SessionLimitsImpl _value, $Res Function(_$SessionLimitsImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionLimits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxTurns = null,
    Object? maxDurationSeconds = null,
    Object? idleTimeoutSeconds = null,
  }) {
    return _then(_$SessionLimitsImpl(
      maxTurns: null == maxTurns
          ? _value.maxTurns
          : maxTurns // ignore: cast_nullable_to_non_nullable
              as int,
      maxDurationSeconds: null == maxDurationSeconds
          ? _value.maxDurationSeconds
          : maxDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      idleTimeoutSeconds: null == idleTimeoutSeconds
          ? _value.idleTimeoutSeconds
          : idleTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$SessionLimitsImpl implements _SessionLimits {
  const _$SessionLimitsImpl(
      {required this.maxTurns,
      required this.maxDurationSeconds,
      required this.idleTimeoutSeconds});

  factory _$SessionLimitsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionLimitsImplFromJson(json);

  @override
  final int maxTurns;
  @override
  final int maxDurationSeconds;
  @override
  final int idleTimeoutSeconds;

  @override
  String toString() {
    return 'SessionLimits(maxTurns: $maxTurns, maxDurationSeconds: $maxDurationSeconds, idleTimeoutSeconds: $idleTimeoutSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionLimitsImpl &&
            (identical(other.maxTurns, maxTurns) ||
                other.maxTurns == maxTurns) &&
            (identical(other.maxDurationSeconds, maxDurationSeconds) ||
                other.maxDurationSeconds == maxDurationSeconds) &&
            (identical(other.idleTimeoutSeconds, idleTimeoutSeconds) ||
                other.idleTimeoutSeconds == idleTimeoutSeconds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, maxTurns, maxDurationSeconds, idleTimeoutSeconds);

  /// Create a copy of SessionLimits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionLimitsImplCopyWith<_$SessionLimitsImpl> get copyWith =>
      __$$SessionLimitsImplCopyWithImpl<_$SessionLimitsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionLimitsImplToJson(
      this,
    );
  }
}

abstract class _SessionLimits implements SessionLimits {
  const factory _SessionLimits(
      {required final int maxTurns,
      required final int maxDurationSeconds,
      required final int idleTimeoutSeconds}) = _$SessionLimitsImpl;

  factory _SessionLimits.fromJson(Map<String, dynamic> json) =
      _$SessionLimitsImpl.fromJson;

  @override
  int get maxTurns;
  @override
  int get maxDurationSeconds;
  @override
  int get idleTimeoutSeconds;

  /// Create a copy of SessionLimits
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionLimitsImplCopyWith<_$SessionLimitsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionCreateResponse _$SessionCreateResponseFromJson(
    Map<String, dynamic> json) {
  return _SessionCreateResponse.fromJson(json);
}

/// @nodoc
mixin _$SessionCreateResponse {
  String get sessionId => throw _privateConstructorUsedError;
  String get sessionToken => throw _privateConstructorUsedError;
  TurnResponse get firstTurn => throw _privateConstructorUsedError;
  SessionLimits get limits => throw _privateConstructorUsedError;

  /// Serializes this SessionCreateResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionCreateResponseCopyWith<SessionCreateResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionCreateResponseCopyWith<$Res> {
  factory $SessionCreateResponseCopyWith(SessionCreateResponse value,
          $Res Function(SessionCreateResponse) then) =
      _$SessionCreateResponseCopyWithImpl<$Res, SessionCreateResponse>;
  @useResult
  $Res call(
      {String sessionId,
      String sessionToken,
      TurnResponse firstTurn,
      SessionLimits limits});

  $TurnResponseCopyWith<$Res> get firstTurn;
  $SessionLimitsCopyWith<$Res> get limits;
}

/// @nodoc
class _$SessionCreateResponseCopyWithImpl<$Res,
        $Val extends SessionCreateResponse>
    implements $SessionCreateResponseCopyWith<$Res> {
  _$SessionCreateResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? sessionToken = null,
    Object? firstTurn = null,
    Object? limits = null,
  }) {
    return _then(_value.copyWith(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      sessionToken: null == sessionToken
          ? _value.sessionToken
          : sessionToken // ignore: cast_nullable_to_non_nullable
              as String,
      firstTurn: null == firstTurn
          ? _value.firstTurn
          : firstTurn // ignore: cast_nullable_to_non_nullable
              as TurnResponse,
      limits: null == limits
          ? _value.limits
          : limits // ignore: cast_nullable_to_non_nullable
              as SessionLimits,
    ) as $Val);
  }

  /// Create a copy of SessionCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TurnResponseCopyWith<$Res> get firstTurn {
    return $TurnResponseCopyWith<$Res>(_value.firstTurn, (value) {
      return _then(_value.copyWith(firstTurn: value) as $Val);
    });
  }

  /// Create a copy of SessionCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionLimitsCopyWith<$Res> get limits {
    return $SessionLimitsCopyWith<$Res>(_value.limits, (value) {
      return _then(_value.copyWith(limits: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SessionCreateResponseImplCopyWith<$Res>
    implements $SessionCreateResponseCopyWith<$Res> {
  factory _$$SessionCreateResponseImplCopyWith(
          _$SessionCreateResponseImpl value,
          $Res Function(_$SessionCreateResponseImpl) then) =
      __$$SessionCreateResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String sessionId,
      String sessionToken,
      TurnResponse firstTurn,
      SessionLimits limits});

  @override
  $TurnResponseCopyWith<$Res> get firstTurn;
  @override
  $SessionLimitsCopyWith<$Res> get limits;
}

/// @nodoc
class __$$SessionCreateResponseImplCopyWithImpl<$Res>
    extends _$SessionCreateResponseCopyWithImpl<$Res,
        _$SessionCreateResponseImpl>
    implements _$$SessionCreateResponseImplCopyWith<$Res> {
  __$$SessionCreateResponseImplCopyWithImpl(_$SessionCreateResponseImpl _value,
      $Res Function(_$SessionCreateResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? sessionToken = null,
    Object? firstTurn = null,
    Object? limits = null,
  }) {
    return _then(_$SessionCreateResponseImpl(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      sessionToken: null == sessionToken
          ? _value.sessionToken
          : sessionToken // ignore: cast_nullable_to_non_nullable
              as String,
      firstTurn: null == firstTurn
          ? _value.firstTurn
          : firstTurn // ignore: cast_nullable_to_non_nullable
              as TurnResponse,
      limits: null == limits
          ? _value.limits
          : limits // ignore: cast_nullable_to_non_nullable
              as SessionLimits,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$SessionCreateResponseImpl implements _SessionCreateResponse {
  const _$SessionCreateResponseImpl(
      {required this.sessionId,
      required this.sessionToken,
      required this.firstTurn,
      required this.limits});

  factory _$SessionCreateResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionCreateResponseImplFromJson(json);

  @override
  final String sessionId;
  @override
  final String sessionToken;
  @override
  final TurnResponse firstTurn;
  @override
  final SessionLimits limits;

  @override
  String toString() {
    return 'SessionCreateResponse(sessionId: $sessionId, sessionToken: $sessionToken, firstTurn: $firstTurn, limits: $limits)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionCreateResponseImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.sessionToken, sessionToken) ||
                other.sessionToken == sessionToken) &&
            (identical(other.firstTurn, firstTurn) ||
                other.firstTurn == firstTurn) &&
            (identical(other.limits, limits) || other.limits == limits));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, sessionId, sessionToken, firstTurn, limits);

  /// Create a copy of SessionCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionCreateResponseImplCopyWith<_$SessionCreateResponseImpl>
      get copyWith => __$$SessionCreateResponseImplCopyWithImpl<
          _$SessionCreateResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionCreateResponseImplToJson(
      this,
    );
  }
}

abstract class _SessionCreateResponse implements SessionCreateResponse {
  const factory _SessionCreateResponse(
      {required final String sessionId,
      required final String sessionToken,
      required final TurnResponse firstTurn,
      required final SessionLimits limits}) = _$SessionCreateResponseImpl;

  factory _SessionCreateResponse.fromJson(Map<String, dynamic> json) =
      _$SessionCreateResponseImpl.fromJson;

  @override
  String get sessionId;
  @override
  String get sessionToken;
  @override
  TurnResponse get firstTurn;
  @override
  SessionLimits get limits;

  /// Create a copy of SessionCreateResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionCreateResponseImplCopyWith<_$SessionCreateResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TurnRequest _$TurnRequestFromJson(Map<String, dynamic> json) {
  return _TurnRequest.fromJson(json);
}

/// @nodoc
mixin _$TurnRequest {
  String get turnId => throw _privateConstructorUsedError;
  int get expectedTurnIndex => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;

  /// Serializes this TurnRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TurnRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TurnRequestCopyWith<TurnRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TurnRequestCopyWith<$Res> {
  factory $TurnRequestCopyWith(
          TurnRequest value, $Res Function(TurnRequest) then) =
      _$TurnRequestCopyWithImpl<$Res, TurnRequest>;
  @useResult
  $Res call({String turnId, int expectedTurnIndex, String text});
}

/// @nodoc
class _$TurnRequestCopyWithImpl<$Res, $Val extends TurnRequest>
    implements $TurnRequestCopyWith<$Res> {
  _$TurnRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TurnRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? turnId = null,
    Object? expectedTurnIndex = null,
    Object? text = null,
  }) {
    return _then(_value.copyWith(
      turnId: null == turnId
          ? _value.turnId
          : turnId // ignore: cast_nullable_to_non_nullable
              as String,
      expectedTurnIndex: null == expectedTurnIndex
          ? _value.expectedTurnIndex
          : expectedTurnIndex // ignore: cast_nullable_to_non_nullable
              as int,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TurnRequestImplCopyWith<$Res>
    implements $TurnRequestCopyWith<$Res> {
  factory _$$TurnRequestImplCopyWith(
          _$TurnRequestImpl value, $Res Function(_$TurnRequestImpl) then) =
      __$$TurnRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String turnId, int expectedTurnIndex, String text});
}

/// @nodoc
class __$$TurnRequestImplCopyWithImpl<$Res>
    extends _$TurnRequestCopyWithImpl<$Res, _$TurnRequestImpl>
    implements _$$TurnRequestImplCopyWith<$Res> {
  __$$TurnRequestImplCopyWithImpl(
      _$TurnRequestImpl _value, $Res Function(_$TurnRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of TurnRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? turnId = null,
    Object? expectedTurnIndex = null,
    Object? text = null,
  }) {
    return _then(_$TurnRequestImpl(
      turnId: null == turnId
          ? _value.turnId
          : turnId // ignore: cast_nullable_to_non_nullable
              as String,
      expectedTurnIndex: null == expectedTurnIndex
          ? _value.expectedTurnIndex
          : expectedTurnIndex // ignore: cast_nullable_to_non_nullable
              as int,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$TurnRequestImpl implements _TurnRequest {
  const _$TurnRequestImpl(
      {required this.turnId,
      required this.expectedTurnIndex,
      required this.text});

  factory _$TurnRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$TurnRequestImplFromJson(json);

  @override
  final String turnId;
  @override
  final int expectedTurnIndex;
  @override
  final String text;

  @override
  String toString() {
    return 'TurnRequest(turnId: $turnId, expectedTurnIndex: $expectedTurnIndex, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TurnRequestImpl &&
            (identical(other.turnId, turnId) || other.turnId == turnId) &&
            (identical(other.expectedTurnIndex, expectedTurnIndex) ||
                other.expectedTurnIndex == expectedTurnIndex) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, turnId, expectedTurnIndex, text);

  /// Create a copy of TurnRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TurnRequestImplCopyWith<_$TurnRequestImpl> get copyWith =>
      __$$TurnRequestImplCopyWithImpl<_$TurnRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TurnRequestImplToJson(
      this,
    );
  }
}

abstract class _TurnRequest implements TurnRequest {
  const factory _TurnRequest(
      {required final String turnId,
      required final int expectedTurnIndex,
      required final String text}) = _$TurnRequestImpl;

  factory _TurnRequest.fromJson(Map<String, dynamic> json) =
      _$TurnRequestImpl.fromJson;

  @override
  String get turnId;
  @override
  int get expectedTurnIndex;
  @override
  String get text;

  /// Create a copy of TurnRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TurnRequestImplCopyWith<_$TurnRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionEndRequest _$SessionEndRequestFromJson(Map<String, dynamic> json) {
  return _SessionEndRequest.fromJson(json);
}

/// @nodoc
mixin _$SessionEndRequest {
  EndReason get reason => throw _privateConstructorUsedError;

  /// Serializes this SessionEndRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionEndRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionEndRequestCopyWith<SessionEndRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionEndRequestCopyWith<$Res> {
  factory $SessionEndRequestCopyWith(
          SessionEndRequest value, $Res Function(SessionEndRequest) then) =
      _$SessionEndRequestCopyWithImpl<$Res, SessionEndRequest>;
  @useResult
  $Res call({EndReason reason});
}

/// @nodoc
class _$SessionEndRequestCopyWithImpl<$Res, $Val extends SessionEndRequest>
    implements $SessionEndRequestCopyWith<$Res> {
  _$SessionEndRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionEndRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reason = null,
  }) {
    return _then(_value.copyWith(
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as EndReason,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionEndRequestImplCopyWith<$Res>
    implements $SessionEndRequestCopyWith<$Res> {
  factory _$$SessionEndRequestImplCopyWith(_$SessionEndRequestImpl value,
          $Res Function(_$SessionEndRequestImpl) then) =
      __$$SessionEndRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({EndReason reason});
}

/// @nodoc
class __$$SessionEndRequestImplCopyWithImpl<$Res>
    extends _$SessionEndRequestCopyWithImpl<$Res, _$SessionEndRequestImpl>
    implements _$$SessionEndRequestImplCopyWith<$Res> {
  __$$SessionEndRequestImplCopyWithImpl(_$SessionEndRequestImpl _value,
      $Res Function(_$SessionEndRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionEndRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reason = null,
  }) {
    return _then(_$SessionEndRequestImpl(
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as EndReason,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$SessionEndRequestImpl implements _SessionEndRequest {
  const _$SessionEndRequestImpl({required this.reason});

  factory _$SessionEndRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionEndRequestImplFromJson(json);

  @override
  final EndReason reason;

  @override
  String toString() {
    return 'SessionEndRequest(reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionEndRequestImpl &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, reason);

  /// Create a copy of SessionEndRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionEndRequestImplCopyWith<_$SessionEndRequestImpl> get copyWith =>
      __$$SessionEndRequestImplCopyWithImpl<_$SessionEndRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionEndRequestImplToJson(
      this,
    );
  }
}

abstract class _SessionEndRequest implements SessionEndRequest {
  const factory _SessionEndRequest({required final EndReason reason}) =
      _$SessionEndRequestImpl;

  factory _SessionEndRequest.fromJson(Map<String, dynamic> json) =
      _$SessionEndRequestImpl.fromJson;

  @override
  EndReason get reason;

  /// Create a copy of SessionEndRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionEndRequestImplCopyWith<_$SessionEndRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EndResponse _$EndResponseFromJson(Map<String, dynamic> json) {
  return _EndResponse.fromJson(json);
}

/// @nodoc
mixin _$EndResponse {
  EndedStatus get status => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;

  /// Serializes this EndResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EndResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EndResponseCopyWith<EndResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EndResponseCopyWith<$Res> {
  factory $EndResponseCopyWith(
          EndResponse value, $Res Function(EndResponse) then) =
      _$EndResponseCopyWithImpl<$Res, EndResponse>;
  @useResult
  $Res call({EndedStatus status, String reason});
}

/// @nodoc
class _$EndResponseCopyWithImpl<$Res, $Val extends EndResponse>
    implements $EndResponseCopyWith<$Res> {
  _$EndResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EndResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? reason = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EndedStatus,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EndResponseImplCopyWith<$Res>
    implements $EndResponseCopyWith<$Res> {
  factory _$$EndResponseImplCopyWith(
          _$EndResponseImpl value, $Res Function(_$EndResponseImpl) then) =
      __$$EndResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({EndedStatus status, String reason});
}

/// @nodoc
class __$$EndResponseImplCopyWithImpl<$Res>
    extends _$EndResponseCopyWithImpl<$Res, _$EndResponseImpl>
    implements _$$EndResponseImplCopyWith<$Res> {
  __$$EndResponseImplCopyWithImpl(
      _$EndResponseImpl _value, $Res Function(_$EndResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of EndResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? reason = null,
  }) {
    return _then(_$EndResponseImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EndedStatus,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$EndResponseImpl implements _EndResponse {
  const _$EndResponseImpl({required this.status, required this.reason});

  factory _$EndResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$EndResponseImplFromJson(json);

  @override
  final EndedStatus status;
  @override
  final String reason;

  @override
  String toString() {
    return 'EndResponse(status: $status, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EndResponseImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, reason);

  /// Create a copy of EndResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EndResponseImplCopyWith<_$EndResponseImpl> get copyWith =>
      __$$EndResponseImplCopyWithImpl<_$EndResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EndResponseImplToJson(
      this,
    );
  }
}

abstract class _EndResponse implements EndResponse {
  const factory _EndResponse(
      {required final EndedStatus status,
      required final String reason}) = _$EndResponseImpl;

  factory _EndResponse.fromJson(Map<String, dynamic> json) =
      _$EndResponseImpl.fromJson;

  @override
  EndedStatus get status;
  @override
  String get reason;

  /// Create a copy of EndResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EndResponseImplCopyWith<_$EndResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuoteReference _$QuoteReferenceFromJson(Map<String, dynamic> json) {
  return _QuoteReference.fromJson(json);
}

/// @nodoc
mixin _$QuoteReference {
  String get text => throw _privateConstructorUsedError;
  int get start => throw _privateConstructorUsedError;
  int get end => throw _privateConstructorUsedError;

  /// Serializes this QuoteReference to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuoteReference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuoteReferenceCopyWith<QuoteReference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuoteReferenceCopyWith<$Res> {
  factory $QuoteReferenceCopyWith(
          QuoteReference value, $Res Function(QuoteReference) then) =
      _$QuoteReferenceCopyWithImpl<$Res, QuoteReference>;
  @useResult
  $Res call({String text, int start, int end});
}

/// @nodoc
class _$QuoteReferenceCopyWithImpl<$Res, $Val extends QuoteReference>
    implements $QuoteReferenceCopyWith<$Res> {
  _$QuoteReferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuoteReference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? start = null,
    Object? end = null,
  }) {
    return _then(_value.copyWith(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as int,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuoteReferenceImplCopyWith<$Res>
    implements $QuoteReferenceCopyWith<$Res> {
  factory _$$QuoteReferenceImplCopyWith(_$QuoteReferenceImpl value,
          $Res Function(_$QuoteReferenceImpl) then) =
      __$$QuoteReferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String text, int start, int end});
}

/// @nodoc
class __$$QuoteReferenceImplCopyWithImpl<$Res>
    extends _$QuoteReferenceCopyWithImpl<$Res, _$QuoteReferenceImpl>
    implements _$$QuoteReferenceImplCopyWith<$Res> {
  __$$QuoteReferenceImplCopyWithImpl(
      _$QuoteReferenceImpl _value, $Res Function(_$QuoteReferenceImpl) _then)
      : super(_value, _then);

  /// Create a copy of QuoteReference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? start = null,
    Object? end = null,
  }) {
    return _then(_$QuoteReferenceImpl(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as int,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$QuoteReferenceImpl implements _QuoteReference {
  const _$QuoteReferenceImpl(
      {required this.text, required this.start, required this.end})
      : assert(start >= 0 && end >= start, 'quote offsets must be ordered');

  factory _$QuoteReferenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuoteReferenceImplFromJson(json);

  @override
  final String text;
  @override
  final int start;
  @override
  final int end;

  @override
  String toString() {
    return 'QuoteReference(text: $text, start: $start, end: $end)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuoteReferenceImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, text, start, end);

  /// Create a copy of QuoteReference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuoteReferenceImplCopyWith<_$QuoteReferenceImpl> get copyWith =>
      __$$QuoteReferenceImplCopyWithImpl<_$QuoteReferenceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuoteReferenceImplToJson(
      this,
    );
  }
}

abstract class _QuoteReference implements QuoteReference {
  const factory _QuoteReference(
      {required final String text,
      required final int start,
      required final int end}) = _$QuoteReferenceImpl;

  factory _QuoteReference.fromJson(Map<String, dynamic> json) =
      _$QuoteReferenceImpl.fromJson;

  @override
  String get text;
  @override
  int get start;
  @override
  int get end;

  /// Create a copy of QuoteReference
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuoteReferenceImplCopyWith<_$QuoteReferenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DebriefEvent _$DebriefEventFromJson(Map<String, dynamic> json) {
  return _DebriefEvent.fromJson(json);
}

/// @nodoc
mixin _$DebriefEvent {
  int get turnIndex => throw _privateConstructorUsedError;
  LabelId get label => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  QuoteReference? get quote => throw _privateConstructorUsedError;

  /// Serializes this DebriefEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DebriefEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DebriefEventCopyWith<DebriefEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DebriefEventCopyWith<$Res> {
  factory $DebriefEventCopyWith(
          DebriefEvent value, $Res Function(DebriefEvent) then) =
      _$DebriefEventCopyWithImpl<$Res, DebriefEvent>;
  @useResult
  $Res call(
      {int turnIndex, LabelId label, double confidence, QuoteReference? quote});

  $QuoteReferenceCopyWith<$Res>? get quote;
}

/// @nodoc
class _$DebriefEventCopyWithImpl<$Res, $Val extends DebriefEvent>
    implements $DebriefEventCopyWith<$Res> {
  _$DebriefEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DebriefEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? turnIndex = null,
    Object? label = null,
    Object? confidence = null,
    Object? quote = freezed,
  }) {
    return _then(_value.copyWith(
      turnIndex: null == turnIndex
          ? _value.turnIndex
          : turnIndex // ignore: cast_nullable_to_non_nullable
              as int,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as LabelId,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      quote: freezed == quote
          ? _value.quote
          : quote // ignore: cast_nullable_to_non_nullable
              as QuoteReference?,
    ) as $Val);
  }

  /// Create a copy of DebriefEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $QuoteReferenceCopyWith<$Res>? get quote {
    if (_value.quote == null) {
      return null;
    }

    return $QuoteReferenceCopyWith<$Res>(_value.quote!, (value) {
      return _then(_value.copyWith(quote: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DebriefEventImplCopyWith<$Res>
    implements $DebriefEventCopyWith<$Res> {
  factory _$$DebriefEventImplCopyWith(
          _$DebriefEventImpl value, $Res Function(_$DebriefEventImpl) then) =
      __$$DebriefEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int turnIndex, LabelId label, double confidence, QuoteReference? quote});

  @override
  $QuoteReferenceCopyWith<$Res>? get quote;
}

/// @nodoc
class __$$DebriefEventImplCopyWithImpl<$Res>
    extends _$DebriefEventCopyWithImpl<$Res, _$DebriefEventImpl>
    implements _$$DebriefEventImplCopyWith<$Res> {
  __$$DebriefEventImplCopyWithImpl(
      _$DebriefEventImpl _value, $Res Function(_$DebriefEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of DebriefEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? turnIndex = null,
    Object? label = null,
    Object? confidence = null,
    Object? quote = freezed,
  }) {
    return _then(_$DebriefEventImpl(
      turnIndex: null == turnIndex
          ? _value.turnIndex
          : turnIndex // ignore: cast_nullable_to_non_nullable
              as int,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as LabelId,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      quote: freezed == quote
          ? _value.quote
          : quote // ignore: cast_nullable_to_non_nullable
              as QuoteReference?,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$DebriefEventImpl implements _DebriefEvent {
  const _$DebriefEventImpl(
      {required this.turnIndex,
      required this.label,
      required this.confidence,
      this.quote})
      : assert(confidence >= 0.0 && confidence <= 1.0,
            'confidence must be between 0 and 1');

  factory _$DebriefEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$DebriefEventImplFromJson(json);

  @override
  final int turnIndex;
  @override
  final LabelId label;
  @override
  final double confidence;
  @override
  final QuoteReference? quote;

  @override
  String toString() {
    return 'DebriefEvent(turnIndex: $turnIndex, label: $label, confidence: $confidence, quote: $quote)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DebriefEventImpl &&
            (identical(other.turnIndex, turnIndex) ||
                other.turnIndex == turnIndex) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.quote, quote) || other.quote == quote));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, turnIndex, label, confidence, quote);

  /// Create a copy of DebriefEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DebriefEventImplCopyWith<_$DebriefEventImpl> get copyWith =>
      __$$DebriefEventImplCopyWithImpl<_$DebriefEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DebriefEventImplToJson(
      this,
    );
  }
}

abstract class _DebriefEvent implements DebriefEvent {
  const factory _DebriefEvent(
      {required final int turnIndex,
      required final LabelId label,
      required final double confidence,
      final QuoteReference? quote}) = _$DebriefEventImpl;

  factory _DebriefEvent.fromJson(Map<String, dynamic> json) =
      _$DebriefEventImpl.fromJson;

  @override
  int get turnIndex;
  @override
  LabelId get label;
  @override
  double get confidence;
  @override
  QuoteReference? get quote;

  /// Create a copy of DebriefEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DebriefEventImplCopyWith<_$DebriefEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StatePathItem _$StatePathItemFromJson(Map<String, dynamic> json) {
  return _StatePathItem.fromJson(json);
}

/// @nodoc
mixin _$StatePathItem {
  StageId get stageId => throw _privateConstructorUsedError;
  int get turnIndex => throw _privateConstructorUsedError;

  /// Serializes this StatePathItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StatePathItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatePathItemCopyWith<StatePathItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatePathItemCopyWith<$Res> {
  factory $StatePathItemCopyWith(
          StatePathItem value, $Res Function(StatePathItem) then) =
      _$StatePathItemCopyWithImpl<$Res, StatePathItem>;
  @useResult
  $Res call({StageId stageId, int turnIndex});
}

/// @nodoc
class _$StatePathItemCopyWithImpl<$Res, $Val extends StatePathItem>
    implements $StatePathItemCopyWith<$Res> {
  _$StatePathItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatePathItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stageId = null,
    Object? turnIndex = null,
  }) {
    return _then(_value.copyWith(
      stageId: null == stageId
          ? _value.stageId
          : stageId // ignore: cast_nullable_to_non_nullable
              as StageId,
      turnIndex: null == turnIndex
          ? _value.turnIndex
          : turnIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StatePathItemImplCopyWith<$Res>
    implements $StatePathItemCopyWith<$Res> {
  factory _$$StatePathItemImplCopyWith(
          _$StatePathItemImpl value, $Res Function(_$StatePathItemImpl) then) =
      __$$StatePathItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({StageId stageId, int turnIndex});
}

/// @nodoc
class __$$StatePathItemImplCopyWithImpl<$Res>
    extends _$StatePathItemCopyWithImpl<$Res, _$StatePathItemImpl>
    implements _$$StatePathItemImplCopyWith<$Res> {
  __$$StatePathItemImplCopyWithImpl(
      _$StatePathItemImpl _value, $Res Function(_$StatePathItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of StatePathItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stageId = null,
    Object? turnIndex = null,
  }) {
    return _then(_$StatePathItemImpl(
      stageId: null == stageId
          ? _value.stageId
          : stageId // ignore: cast_nullable_to_non_nullable
              as StageId,
      turnIndex: null == turnIndex
          ? _value.turnIndex
          : turnIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$StatePathItemImpl implements _StatePathItem {
  const _$StatePathItemImpl({required this.stageId, required this.turnIndex});

  factory _$StatePathItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatePathItemImplFromJson(json);

  @override
  final StageId stageId;
  @override
  final int turnIndex;

  @override
  String toString() {
    return 'StatePathItem(stageId: $stageId, turnIndex: $turnIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatePathItemImpl &&
            (identical(other.stageId, stageId) || other.stageId == stageId) &&
            (identical(other.turnIndex, turnIndex) ||
                other.turnIndex == turnIndex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, stageId, turnIndex);

  /// Create a copy of StatePathItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatePathItemImplCopyWith<_$StatePathItemImpl> get copyWith =>
      __$$StatePathItemImplCopyWithImpl<_$StatePathItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StatePathItemImplToJson(
      this,
    );
  }
}

abstract class _StatePathItem implements StatePathItem {
  const factory _StatePathItem(
      {required final StageId stageId,
      required final int turnIndex}) = _$StatePathItemImpl;

  factory _StatePathItem.fromJson(Map<String, dynamic> json) =
      _$StatePathItemImpl.fromJson;

  @override
  StageId get stageId;
  @override
  int get turnIndex;

  /// Create a copy of StatePathItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatePathItemImplCopyWith<_$StatePathItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FirstCompliance _$FirstComplianceFromJson(Map<String, dynamic> json) {
  return _FirstCompliance.fromJson(json);
}

/// @nodoc
mixin _$FirstCompliance {
  int get turnIndex => throw _privateConstructorUsedError;
  StageId get stageId => throw _privateConstructorUsedError;
  LabelId get label => throw _privateConstructorUsedError;

  /// Serializes this FirstCompliance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FirstCompliance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FirstComplianceCopyWith<FirstCompliance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirstComplianceCopyWith<$Res> {
  factory $FirstComplianceCopyWith(
          FirstCompliance value, $Res Function(FirstCompliance) then) =
      _$FirstComplianceCopyWithImpl<$Res, FirstCompliance>;
  @useResult
  $Res call({int turnIndex, StageId stageId, LabelId label});
}

/// @nodoc
class _$FirstComplianceCopyWithImpl<$Res, $Val extends FirstCompliance>
    implements $FirstComplianceCopyWith<$Res> {
  _$FirstComplianceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FirstCompliance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? turnIndex = null,
    Object? stageId = null,
    Object? label = null,
  }) {
    return _then(_value.copyWith(
      turnIndex: null == turnIndex
          ? _value.turnIndex
          : turnIndex // ignore: cast_nullable_to_non_nullable
              as int,
      stageId: null == stageId
          ? _value.stageId
          : stageId // ignore: cast_nullable_to_non_nullable
              as StageId,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as LabelId,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FirstComplianceImplCopyWith<$Res>
    implements $FirstComplianceCopyWith<$Res> {
  factory _$$FirstComplianceImplCopyWith(_$FirstComplianceImpl value,
          $Res Function(_$FirstComplianceImpl) then) =
      __$$FirstComplianceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int turnIndex, StageId stageId, LabelId label});
}

/// @nodoc
class __$$FirstComplianceImplCopyWithImpl<$Res>
    extends _$FirstComplianceCopyWithImpl<$Res, _$FirstComplianceImpl>
    implements _$$FirstComplianceImplCopyWith<$Res> {
  __$$FirstComplianceImplCopyWithImpl(
      _$FirstComplianceImpl _value, $Res Function(_$FirstComplianceImpl) _then)
      : super(_value, _then);

  /// Create a copy of FirstCompliance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? turnIndex = null,
    Object? stageId = null,
    Object? label = null,
  }) {
    return _then(_$FirstComplianceImpl(
      turnIndex: null == turnIndex
          ? _value.turnIndex
          : turnIndex // ignore: cast_nullable_to_non_nullable
              as int,
      stageId: null == stageId
          ? _value.stageId
          : stageId // ignore: cast_nullable_to_non_nullable
              as StageId,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as LabelId,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$FirstComplianceImpl implements _FirstCompliance {
  const _$FirstComplianceImpl(
      {required this.turnIndex, required this.stageId, required this.label});

  factory _$FirstComplianceImpl.fromJson(Map<String, dynamic> json) =>
      _$$FirstComplianceImplFromJson(json);

  @override
  final int turnIndex;
  @override
  final StageId stageId;
  @override
  final LabelId label;

  @override
  String toString() {
    return 'FirstCompliance(turnIndex: $turnIndex, stageId: $stageId, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirstComplianceImpl &&
            (identical(other.turnIndex, turnIndex) ||
                other.turnIndex == turnIndex) &&
            (identical(other.stageId, stageId) || other.stageId == stageId) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, turnIndex, stageId, label);

  /// Create a copy of FirstCompliance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirstComplianceImplCopyWith<_$FirstComplianceImpl> get copyWith =>
      __$$FirstComplianceImplCopyWithImpl<_$FirstComplianceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FirstComplianceImplToJson(
      this,
    );
  }
}

abstract class _FirstCompliance implements FirstCompliance {
  const factory _FirstCompliance(
      {required final int turnIndex,
      required final StageId stageId,
      required final LabelId label}) = _$FirstComplianceImpl;

  factory _FirstCompliance.fromJson(Map<String, dynamic> json) =
      _$FirstComplianceImpl.fromJson;

  @override
  int get turnIndex;
  @override
  StageId get stageId;
  @override
  LabelId get label;

  /// Create a copy of FirstCompliance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirstComplianceImplCopyWith<_$FirstComplianceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DebriefContent _$DebriefContentFromJson(Map<String, dynamic> json) {
  return _DebriefContent.fromJson(json);
}

/// @nodoc
mixin _$DebriefContent {
  DebriefQuality get quality => throw _privateConstructorUsedError;
  bool get lowConfidence => throw _privateConstructorUsedError;
  List<StatePathItem> get statePath => throw _privateConstructorUsedError;
  List<DebriefEvent> get events => throw _privateConstructorUsedError;
  FirstCompliance? get firstCompliance => throw _privateConstructorUsedError;
  List<String> get didWellIds => throw _privateConstructorUsedError;
  HabitId get habitId => throw _privateConstructorUsedError;

  /// Serializes this DebriefContent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DebriefContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DebriefContentCopyWith<DebriefContent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DebriefContentCopyWith<$Res> {
  factory $DebriefContentCopyWith(
          DebriefContent value, $Res Function(DebriefContent) then) =
      _$DebriefContentCopyWithImpl<$Res, DebriefContent>;
  @useResult
  $Res call(
      {DebriefQuality quality,
      bool lowConfidence,
      List<StatePathItem> statePath,
      List<DebriefEvent> events,
      FirstCompliance? firstCompliance,
      List<String> didWellIds,
      HabitId habitId});

  $FirstComplianceCopyWith<$Res>? get firstCompliance;
}

/// @nodoc
class _$DebriefContentCopyWithImpl<$Res, $Val extends DebriefContent>
    implements $DebriefContentCopyWith<$Res> {
  _$DebriefContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DebriefContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? quality = null,
    Object? lowConfidence = null,
    Object? statePath = null,
    Object? events = null,
    Object? firstCompliance = freezed,
    Object? didWellIds = null,
    Object? habitId = null,
  }) {
    return _then(_value.copyWith(
      quality: null == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as DebriefQuality,
      lowConfidence: null == lowConfidence
          ? _value.lowConfidence
          : lowConfidence // ignore: cast_nullable_to_non_nullable
              as bool,
      statePath: null == statePath
          ? _value.statePath
          : statePath // ignore: cast_nullable_to_non_nullable
              as List<StatePathItem>,
      events: null == events
          ? _value.events
          : events // ignore: cast_nullable_to_non_nullable
              as List<DebriefEvent>,
      firstCompliance: freezed == firstCompliance
          ? _value.firstCompliance
          : firstCompliance // ignore: cast_nullable_to_non_nullable
              as FirstCompliance?,
      didWellIds: null == didWellIds
          ? _value.didWellIds
          : didWellIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      habitId: null == habitId
          ? _value.habitId
          : habitId // ignore: cast_nullable_to_non_nullable
              as HabitId,
    ) as $Val);
  }

  /// Create a copy of DebriefContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FirstComplianceCopyWith<$Res>? get firstCompliance {
    if (_value.firstCompliance == null) {
      return null;
    }

    return $FirstComplianceCopyWith<$Res>(_value.firstCompliance!, (value) {
      return _then(_value.copyWith(firstCompliance: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DebriefContentImplCopyWith<$Res>
    implements $DebriefContentCopyWith<$Res> {
  factory _$$DebriefContentImplCopyWith(_$DebriefContentImpl value,
          $Res Function(_$DebriefContentImpl) then) =
      __$$DebriefContentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DebriefQuality quality,
      bool lowConfidence,
      List<StatePathItem> statePath,
      List<DebriefEvent> events,
      FirstCompliance? firstCompliance,
      List<String> didWellIds,
      HabitId habitId});

  @override
  $FirstComplianceCopyWith<$Res>? get firstCompliance;
}

/// @nodoc
class __$$DebriefContentImplCopyWithImpl<$Res>
    extends _$DebriefContentCopyWithImpl<$Res, _$DebriefContentImpl>
    implements _$$DebriefContentImplCopyWith<$Res> {
  __$$DebriefContentImplCopyWithImpl(
      _$DebriefContentImpl _value, $Res Function(_$DebriefContentImpl) _then)
      : super(_value, _then);

  /// Create a copy of DebriefContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? quality = null,
    Object? lowConfidence = null,
    Object? statePath = null,
    Object? events = null,
    Object? firstCompliance = freezed,
    Object? didWellIds = null,
    Object? habitId = null,
  }) {
    return _then(_$DebriefContentImpl(
      quality: null == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as DebriefQuality,
      lowConfidence: null == lowConfidence
          ? _value.lowConfidence
          : lowConfidence // ignore: cast_nullable_to_non_nullable
              as bool,
      statePath: null == statePath
          ? _value._statePath
          : statePath // ignore: cast_nullable_to_non_nullable
              as List<StatePathItem>,
      events: null == events
          ? _value._events
          : events // ignore: cast_nullable_to_non_nullable
              as List<DebriefEvent>,
      firstCompliance: freezed == firstCompliance
          ? _value.firstCompliance
          : firstCompliance // ignore: cast_nullable_to_non_nullable
              as FirstCompliance?,
      didWellIds: null == didWellIds
          ? _value._didWellIds
          : didWellIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      habitId: null == habitId
          ? _value.habitId
          : habitId // ignore: cast_nullable_to_non_nullable
              as HabitId,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$DebriefContentImpl implements _DebriefContent {
  const _$DebriefContentImpl(
      {required this.quality,
      required this.lowConfidence,
      required final List<StatePathItem> statePath,
      required final List<DebriefEvent> events,
      this.firstCompliance,
      required final List<String> didWellIds,
      required this.habitId})
      : _statePath = statePath,
        _events = events,
        _didWellIds = didWellIds;

  factory _$DebriefContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$DebriefContentImplFromJson(json);

  @override
  final DebriefQuality quality;
  @override
  final bool lowConfidence;
  final List<StatePathItem> _statePath;
  @override
  List<StatePathItem> get statePath {
    if (_statePath is EqualUnmodifiableListView) return _statePath;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_statePath);
  }

  final List<DebriefEvent> _events;
  @override
  List<DebriefEvent> get events {
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_events);
  }

  @override
  final FirstCompliance? firstCompliance;
  final List<String> _didWellIds;
  @override
  List<String> get didWellIds {
    if (_didWellIds is EqualUnmodifiableListView) return _didWellIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_didWellIds);
  }

  @override
  final HabitId habitId;

  @override
  String toString() {
    return 'DebriefContent(quality: $quality, lowConfidence: $lowConfidence, statePath: $statePath, events: $events, firstCompliance: $firstCompliance, didWellIds: $didWellIds, habitId: $habitId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DebriefContentImpl &&
            (identical(other.quality, quality) || other.quality == quality) &&
            (identical(other.lowConfidence, lowConfidence) ||
                other.lowConfidence == lowConfidence) &&
            const DeepCollectionEquality()
                .equals(other._statePath, _statePath) &&
            const DeepCollectionEquality().equals(other._events, _events) &&
            (identical(other.firstCompliance, firstCompliance) ||
                other.firstCompliance == firstCompliance) &&
            const DeepCollectionEquality()
                .equals(other._didWellIds, _didWellIds) &&
            (identical(other.habitId, habitId) || other.habitId == habitId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      quality,
      lowConfidence,
      const DeepCollectionEquality().hash(_statePath),
      const DeepCollectionEquality().hash(_events),
      firstCompliance,
      const DeepCollectionEquality().hash(_didWellIds),
      habitId);

  /// Create a copy of DebriefContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DebriefContentImplCopyWith<_$DebriefContentImpl> get copyWith =>
      __$$DebriefContentImplCopyWithImpl<_$DebriefContentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DebriefContentImplToJson(
      this,
    );
  }
}

abstract class _DebriefContent implements DebriefContent {
  const factory _DebriefContent(
      {required final DebriefQuality quality,
      required final bool lowConfidence,
      required final List<StatePathItem> statePath,
      required final List<DebriefEvent> events,
      final FirstCompliance? firstCompliance,
      required final List<String> didWellIds,
      required final HabitId habitId}) = _$DebriefContentImpl;

  factory _DebriefContent.fromJson(Map<String, dynamic> json) =
      _$DebriefContentImpl.fromJson;

  @override
  DebriefQuality get quality;
  @override
  bool get lowConfidence;
  @override
  List<StatePathItem> get statePath;
  @override
  List<DebriefEvent> get events;
  @override
  FirstCompliance? get firstCompliance;
  @override
  List<String> get didWellIds;
  @override
  HabitId get habitId;

  /// Create a copy of DebriefContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DebriefContentImplCopyWith<_$DebriefContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DebriefResponse _$DebriefResponseFromJson(Map<String, dynamic> json) {
  return _DebriefResponse.fromJson(json);
}

/// @nodoc
mixin _$DebriefResponse {
  DebriefStatus get status => throw _privateConstructorUsedError;
  DebriefQuality get quality => throw _privateConstructorUsedError;
  DebriefContent? get debrief => throw _privateConstructorUsedError;

  /// Serializes this DebriefResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DebriefResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DebriefResponseCopyWith<DebriefResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DebriefResponseCopyWith<$Res> {
  factory $DebriefResponseCopyWith(
          DebriefResponse value, $Res Function(DebriefResponse) then) =
      _$DebriefResponseCopyWithImpl<$Res, DebriefResponse>;
  @useResult
  $Res call(
      {DebriefStatus status, DebriefQuality quality, DebriefContent? debrief});

  $DebriefContentCopyWith<$Res>? get debrief;
}

/// @nodoc
class _$DebriefResponseCopyWithImpl<$Res, $Val extends DebriefResponse>
    implements $DebriefResponseCopyWith<$Res> {
  _$DebriefResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DebriefResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? quality = null,
    Object? debrief = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DebriefStatus,
      quality: null == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as DebriefQuality,
      debrief: freezed == debrief
          ? _value.debrief
          : debrief // ignore: cast_nullable_to_non_nullable
              as DebriefContent?,
    ) as $Val);
  }

  /// Create a copy of DebriefResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DebriefContentCopyWith<$Res>? get debrief {
    if (_value.debrief == null) {
      return null;
    }

    return $DebriefContentCopyWith<$Res>(_value.debrief!, (value) {
      return _then(_value.copyWith(debrief: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DebriefResponseImplCopyWith<$Res>
    implements $DebriefResponseCopyWith<$Res> {
  factory _$$DebriefResponseImplCopyWith(_$DebriefResponseImpl value,
          $Res Function(_$DebriefResponseImpl) then) =
      __$$DebriefResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DebriefStatus status, DebriefQuality quality, DebriefContent? debrief});

  @override
  $DebriefContentCopyWith<$Res>? get debrief;
}

/// @nodoc
class __$$DebriefResponseImplCopyWithImpl<$Res>
    extends _$DebriefResponseCopyWithImpl<$Res, _$DebriefResponseImpl>
    implements _$$DebriefResponseImplCopyWith<$Res> {
  __$$DebriefResponseImplCopyWithImpl(
      _$DebriefResponseImpl _value, $Res Function(_$DebriefResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of DebriefResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? quality = null,
    Object? debrief = freezed,
  }) {
    return _then(_$DebriefResponseImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DebriefStatus,
      quality: null == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as DebriefQuality,
      debrief: freezed == debrief
          ? _value.debrief
          : debrief // ignore: cast_nullable_to_non_nullable
              as DebriefContent?,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$DebriefResponseImpl implements _DebriefResponse {
  const _$DebriefResponseImpl(
      {required this.status, required this.quality, this.debrief});

  factory _$DebriefResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DebriefResponseImplFromJson(json);

  @override
  final DebriefStatus status;
  @override
  final DebriefQuality quality;
  @override
  final DebriefContent? debrief;

  @override
  String toString() {
    return 'DebriefResponse(status: $status, quality: $quality, debrief: $debrief)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DebriefResponseImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.quality, quality) || other.quality == quality) &&
            (identical(other.debrief, debrief) || other.debrief == debrief));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, quality, debrief);

  /// Create a copy of DebriefResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DebriefResponseImplCopyWith<_$DebriefResponseImpl> get copyWith =>
      __$$DebriefResponseImplCopyWithImpl<_$DebriefResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DebriefResponseImplToJson(
      this,
    );
  }
}

abstract class _DebriefResponse implements DebriefResponse {
  const factory _DebriefResponse(
      {required final DebriefStatus status,
      required final DebriefQuality quality,
      final DebriefContent? debrief}) = _$DebriefResponseImpl;

  factory _DebriefResponse.fromJson(Map<String, dynamic> json) =
      _$DebriefResponseImpl.fromJson;

  @override
  DebriefStatus get status;
  @override
  DebriefQuality get quality;
  @override
  DebriefContent? get debrief;

  /// Create a copy of DebriefResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DebriefResponseImplCopyWith<_$DebriefResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShareRequest _$ShareRequestFromJson(Map<String, dynamic> json) {
  return _ShareRequest.fromJson(json);
}

/// @nodoc
mixin _$ShareRequest {
  bool get consent => throw _privateConstructorUsedError;

  /// Serializes this ShareRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShareRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShareRequestCopyWith<ShareRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShareRequestCopyWith<$Res> {
  factory $ShareRequestCopyWith(
          ShareRequest value, $Res Function(ShareRequest) then) =
      _$ShareRequestCopyWithImpl<$Res, ShareRequest>;
  @useResult
  $Res call({bool consent});
}

/// @nodoc
class _$ShareRequestCopyWithImpl<$Res, $Val extends ShareRequest>
    implements $ShareRequestCopyWith<$Res> {
  _$ShareRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShareRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? consent = null,
  }) {
    return _then(_value.copyWith(
      consent: null == consent
          ? _value.consent
          : consent // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShareRequestImplCopyWith<$Res>
    implements $ShareRequestCopyWith<$Res> {
  factory _$$ShareRequestImplCopyWith(
          _$ShareRequestImpl value, $Res Function(_$ShareRequestImpl) then) =
      __$$ShareRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool consent});
}

/// @nodoc
class __$$ShareRequestImplCopyWithImpl<$Res>
    extends _$ShareRequestCopyWithImpl<$Res, _$ShareRequestImpl>
    implements _$$ShareRequestImplCopyWith<$Res> {
  __$$ShareRequestImplCopyWithImpl(
      _$ShareRequestImpl _value, $Res Function(_$ShareRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ShareRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? consent = null,
  }) {
    return _then(_$ShareRequestImpl(
      consent: null == consent
          ? _value.consent
          : consent // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$ShareRequestImpl implements _ShareRequest {
  const _$ShareRequestImpl({required this.consent});

  factory _$ShareRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShareRequestImplFromJson(json);

  @override
  final bool consent;

  @override
  String toString() {
    return 'ShareRequest(consent: $consent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShareRequestImpl &&
            (identical(other.consent, consent) || other.consent == consent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, consent);

  /// Create a copy of ShareRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShareRequestImplCopyWith<_$ShareRequestImpl> get copyWith =>
      __$$ShareRequestImplCopyWithImpl<_$ShareRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShareRequestImplToJson(
      this,
    );
  }
}

abstract class _ShareRequest implements ShareRequest {
  const factory _ShareRequest({required final bool consent}) =
      _$ShareRequestImpl;

  factory _ShareRequest.fromJson(Map<String, dynamic> json) =
      _$ShareRequestImpl.fromJson;

  @override
  bool get consent;

  /// Create a copy of ShareRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShareRequestImplCopyWith<_$ShareRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShareResponse _$ShareResponseFromJson(Map<String, dynamic> json) {
  return _ShareResponse.fromJson(json);
}

/// @nodoc
mixin _$ShareResponse {
  String get reportToken => throw _privateConstructorUsedError;
  String get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this ShareResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShareResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShareResponseCopyWith<ShareResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShareResponseCopyWith<$Res> {
  factory $ShareResponseCopyWith(
          ShareResponse value, $Res Function(ShareResponse) then) =
      _$ShareResponseCopyWithImpl<$Res, ShareResponse>;
  @useResult
  $Res call({String reportToken, String expiresAt});
}

/// @nodoc
class _$ShareResponseCopyWithImpl<$Res, $Val extends ShareResponse>
    implements $ShareResponseCopyWith<$Res> {
  _$ShareResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShareResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reportToken = null,
    Object? expiresAt = null,
  }) {
    return _then(_value.copyWith(
      reportToken: null == reportToken
          ? _value.reportToken
          : reportToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShareResponseImplCopyWith<$Res>
    implements $ShareResponseCopyWith<$Res> {
  factory _$$ShareResponseImplCopyWith(
          _$ShareResponseImpl value, $Res Function(_$ShareResponseImpl) then) =
      __$$ShareResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String reportToken, String expiresAt});
}

/// @nodoc
class __$$ShareResponseImplCopyWithImpl<$Res>
    extends _$ShareResponseCopyWithImpl<$Res, _$ShareResponseImpl>
    implements _$$ShareResponseImplCopyWith<$Res> {
  __$$ShareResponseImplCopyWithImpl(
      _$ShareResponseImpl _value, $Res Function(_$ShareResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ShareResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reportToken = null,
    Object? expiresAt = null,
  }) {
    return _then(_$ShareResponseImpl(
      reportToken: null == reportToken
          ? _value.reportToken
          : reportToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$ShareResponseImpl implements _ShareResponse {
  const _$ShareResponseImpl(
      {required this.reportToken, required this.expiresAt});

  factory _$ShareResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShareResponseImplFromJson(json);

  @override
  final String reportToken;
  @override
  final String expiresAt;

  @override
  String toString() {
    return 'ShareResponse(reportToken: $reportToken, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShareResponseImpl &&
            (identical(other.reportToken, reportToken) ||
                other.reportToken == reportToken) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, reportToken, expiresAt);

  /// Create a copy of ShareResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShareResponseImplCopyWith<_$ShareResponseImpl> get copyWith =>
      __$$ShareResponseImplCopyWithImpl<_$ShareResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShareResponseImplToJson(
      this,
    );
  }
}

abstract class _ShareResponse implements ShareResponse {
  const factory _ShareResponse(
      {required final String reportToken,
      required final String expiresAt}) = _$ShareResponseImpl;

  factory _ShareResponse.fromJson(Map<String, dynamic> json) =
      _$ShareResponseImpl.fromJson;

  @override
  String get reportToken;
  @override
  String get expiresAt;

  /// Create a copy of ShareResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShareResponseImplCopyWith<_$ShareResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReportResponse _$ReportResponseFromJson(Map<String, dynamic> json) {
  return _ReportResponse.fromJson(json);
}

/// @nodoc
mixin _$ReportResponse {
  String get reportToken => throw _privateConstructorUsedError;
  String get sharedAt => throw _privateConstructorUsedError;
  DebriefContent get debrief => throw _privateConstructorUsedError;

  /// Serializes this ReportResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportResponseCopyWith<ReportResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportResponseCopyWith<$Res> {
  factory $ReportResponseCopyWith(
          ReportResponse value, $Res Function(ReportResponse) then) =
      _$ReportResponseCopyWithImpl<$Res, ReportResponse>;
  @useResult
  $Res call({String reportToken, String sharedAt, DebriefContent debrief});

  $DebriefContentCopyWith<$Res> get debrief;
}

/// @nodoc
class _$ReportResponseCopyWithImpl<$Res, $Val extends ReportResponse>
    implements $ReportResponseCopyWith<$Res> {
  _$ReportResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reportToken = null,
    Object? sharedAt = null,
    Object? debrief = null,
  }) {
    return _then(_value.copyWith(
      reportToken: null == reportToken
          ? _value.reportToken
          : reportToken // ignore: cast_nullable_to_non_nullable
              as String,
      sharedAt: null == sharedAt
          ? _value.sharedAt
          : sharedAt // ignore: cast_nullable_to_non_nullable
              as String,
      debrief: null == debrief
          ? _value.debrief
          : debrief // ignore: cast_nullable_to_non_nullable
              as DebriefContent,
    ) as $Val);
  }

  /// Create a copy of ReportResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DebriefContentCopyWith<$Res> get debrief {
    return $DebriefContentCopyWith<$Res>(_value.debrief, (value) {
      return _then(_value.copyWith(debrief: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReportResponseImplCopyWith<$Res>
    implements $ReportResponseCopyWith<$Res> {
  factory _$$ReportResponseImplCopyWith(_$ReportResponseImpl value,
          $Res Function(_$ReportResponseImpl) then) =
      __$$ReportResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String reportToken, String sharedAt, DebriefContent debrief});

  @override
  $DebriefContentCopyWith<$Res> get debrief;
}

/// @nodoc
class __$$ReportResponseImplCopyWithImpl<$Res>
    extends _$ReportResponseCopyWithImpl<$Res, _$ReportResponseImpl>
    implements _$$ReportResponseImplCopyWith<$Res> {
  __$$ReportResponseImplCopyWithImpl(
      _$ReportResponseImpl _value, $Res Function(_$ReportResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reportToken = null,
    Object? sharedAt = null,
    Object? debrief = null,
  }) {
    return _then(_$ReportResponseImpl(
      reportToken: null == reportToken
          ? _value.reportToken
          : reportToken // ignore: cast_nullable_to_non_nullable
              as String,
      sharedAt: null == sharedAt
          ? _value.sharedAt
          : sharedAt // ignore: cast_nullable_to_non_nullable
              as String,
      debrief: null == debrief
          ? _value.debrief
          : debrief // ignore: cast_nullable_to_non_nullable
              as DebriefContent,
    ));
  }
}

/// @nodoc

@JsonSerializable(
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
    fieldRename: FieldRename.snake)
class _$ReportResponseImpl implements _ReportResponse {
  const _$ReportResponseImpl(
      {required this.reportToken,
      required this.sharedAt,
      required this.debrief});

  factory _$ReportResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportResponseImplFromJson(json);

  @override
  final String reportToken;
  @override
  final String sharedAt;
  @override
  final DebriefContent debrief;

  @override
  String toString() {
    return 'ReportResponse(reportToken: $reportToken, sharedAt: $sharedAt, debrief: $debrief)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportResponseImpl &&
            (identical(other.reportToken, reportToken) ||
                other.reportToken == reportToken) &&
            (identical(other.sharedAt, sharedAt) ||
                other.sharedAt == sharedAt) &&
            (identical(other.debrief, debrief) || other.debrief == debrief));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, reportToken, sharedAt, debrief);

  /// Create a copy of ReportResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportResponseImplCopyWith<_$ReportResponseImpl> get copyWith =>
      __$$ReportResponseImplCopyWithImpl<_$ReportResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportResponseImplToJson(
      this,
    );
  }
}

abstract class _ReportResponse implements ReportResponse {
  const factory _ReportResponse(
      {required final String reportToken,
      required final String sharedAt,
      required final DebriefContent debrief}) = _$ReportResponseImpl;

  factory _ReportResponse.fromJson(Map<String, dynamic> json) =
      _$ReportResponseImpl.fromJson;

  @override
  String get reportToken;
  @override
  String get sharedAt;
  @override
  DebriefContent get debrief;

  /// Create a copy of ReportResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportResponseImplCopyWith<_$ReportResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
