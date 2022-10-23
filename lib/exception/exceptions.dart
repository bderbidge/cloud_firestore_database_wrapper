class CloudFirestoreHelperError extends Error {
  final String message;
  final StackTrace stackTrace;
  CloudFirestoreHelperError(this.message, this.stackTrace);

  @override
  String toString() {
    return this.message;
  }
}

class GetSingleDocumentError extends CloudFirestoreHelperError {
  GetSingleDocumentError(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class FirestoreReferenceError extends CloudFirestoreHelperError {
  FirestoreReferenceError(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class DeleteSingleError extends CloudFirestoreHelperError {
  DeleteSingleError(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class UpdateSingleError extends CloudFirestoreHelperError {
  UpdateSingleError(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class CreateSingleError extends CloudFirestoreHelperError {
  CreateSingleError(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class FailedQueryConstructionError extends CloudFirestoreHelperError {
  FailedQueryConstructionError(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class CollectionStreamWithParamsError extends CloudFirestoreHelperError {
  CollectionStreamWithParamsError(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class CollectionWithParamsError extends CloudFirestoreHelperError {
  CollectionWithParamsError(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class GetCollectionError extends CloudFirestoreHelperError {
  GetCollectionError(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class GetCollectionGroupError extends CloudFirestoreHelperError {
  GetCollectionGroupError(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class OnlyUseOneError extends CloudFirestoreHelperError {
  OnlyUseOneError(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class UnableToCombineError extends CloudFirestoreHelperError {
  UnableToCombineError(StackTrace stackTrace)
      : super(
            'Can\'t use ArrayContainsAny and ArrayContains clauses in the same query',
            stackTrace);
}

class ArrayUseError extends CloudFirestoreHelperError {
  ArrayUseError(StackTrace stackTrace)
      : super(
            'Can\'t use ArrayContainsAny and ArrayContains clauses in the same query',
            stackTrace);
}

class QueryRangeConditionError extends CloudFirestoreHelperError {
  QueryRangeConditionError(String value, String? key, StackTrace stackTrace)
      : super('Duplicate range: $value condition for key: $key', stackTrace);
}

class UnknownQueryError extends CloudFirestoreHelperError {
  UnknownQueryError(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class ModelNotFoundError extends CloudFirestoreHelperError {
  ModelNotFoundError(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}
