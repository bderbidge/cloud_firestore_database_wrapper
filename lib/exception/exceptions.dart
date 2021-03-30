class CloudFirestoreHelperError extends Error {
  final String message;
  final StackTrace stackTrace;
  CloudFirestoreHelperError(this.message, this.stackTrace);
}

class GetSingleDocumentException extends CloudFirestoreHelperError {
  GetSingleDocumentException(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class FirestoreReferenceException extends CloudFirestoreHelperError {
  FirestoreReferenceException(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class DeleteSingleException extends CloudFirestoreHelperError {
  DeleteSingleException(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class UpdateSingleException extends CloudFirestoreHelperError {
  UpdateSingleException(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class CreateSingleException extends CloudFirestoreHelperError {
  CreateSingleException(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class FailedQueryConstructionException extends CloudFirestoreHelperError {
  FailedQueryConstructionException(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class CollectionStreamWithParamsException extends CloudFirestoreHelperError {
  CollectionStreamWithParamsException(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class CollectionWithParamsException extends CloudFirestoreHelperError {
  CollectionWithParamsException(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class GetCollectionException extends CloudFirestoreHelperError {
  GetCollectionException(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class GetCollectionGroupException extends CloudFirestoreHelperError {
  GetCollectionGroupException(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class OnlyUseOneException extends CloudFirestoreHelperError {
  OnlyUseOneException(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}

class UnableToCombineException extends CloudFirestoreHelperError {
  UnableToCombineException(StackTrace stackTrace)
      : super(
            'Can\'t use ArrayContainsAny and ArrayContains clauses in the same query',
            stackTrace);
}

class ArrayUseException extends CloudFirestoreHelperError {
  ArrayUseException(StackTrace stackTrace)
      : super(
            'Can\'t use ArrayContainsAny and ArrayContains clauses in the same query',
            stackTrace);
}

class QueryRangeConditionException extends CloudFirestoreHelperError {
  QueryRangeConditionException(String value, String key, StackTrace stackTrace)
      : super('Duplicate range: $value condition for key: $key', stackTrace);
}

class UnknownQueryException extends CloudFirestoreHelperError {
  UnknownQueryException(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}
