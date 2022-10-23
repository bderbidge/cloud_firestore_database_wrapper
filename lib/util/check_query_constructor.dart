import 'package:cloud_firestore_database_wrapper/exception/exceptions.dart';
import 'package:cloud_firestore_database_wrapper/interfaces/i_data_source.dart';

checkQueryConstructor(List<QueryType> queries) {
  //Validate query list
  Map<String?, QueryType> idmap = {};
  Set<WhereQueryType?> setQuery = {};
  Map<String?, List> rangeMap = {};

  for (var query in queries) {
    if (rangeMap.containsKey(query.id)) {
      rangeMap[query.id]!.add(query.whereQueryType);
    } else {
      rangeMap[query.id] = [query.whereQueryType];
    }

    //You can use at most one in, not-in, or array-contains-any clause per query.
    //You can't combine in , not-in, and array-contains-any in the same query.
    if (setQuery.contains(WhereQueryType.whereIn)) {
      if (setQuery.contains(WhereQueryType.whereNotIn)) {
        throw OnlyUseOneError(
            'Can\'t use whereIn and whereNotIn clauses in the same query',
            StackTrace.current);
      } else if (setQuery.contains(WhereQueryType.arrayContainsAny)) {
        throw OnlyUseOneError(
            'Can\'t use whereIn and ArrayContainsAny clauses in the same query',
            StackTrace.current);
      }
    }
    if (setQuery.contains(WhereQueryType.whereNotIn)) {
      if (setQuery.contains(WhereQueryType.whereIn)) {
        throw OnlyUseOneError(
            'Can\'t use whereIn and WhereNotIn clauses in the same query',
            StackTrace.current);
      } else if (setQuery.contains(WhereQueryType.arrayContainsAny)) {
        throw OnlyUseOneError(
            'Can\'t use ArrayContainsAny and WhereNotIn clauses in the same query',
            StackTrace.current);
      }
    }
    if (setQuery.contains(WhereQueryType.arrayContainsAny)) {
      if (setQuery.contains(WhereQueryType.whereIn)) {
        throw OnlyUseOneError(
            'Can\'t use ArrayContainsAny and WhereIn clauses in the same query',
            StackTrace.current);
      } else if (setQuery.contains(WhereQueryType.whereNotIn)) {
        throw OnlyUseOneError(
            'Can\'t use ArrayContainsAny and WhereNotIn clauses in the same query',
            StackTrace.current);
      }
    }
    if ((query.whereQueryType == WhereQueryType.arrayContains &&
            setQuery.contains(WhereQueryType.arrayContainsAny)) ||
        query.whereQueryType == WhereQueryType.arrayContainsAny &&
            setQuery.contains(WhereQueryType.arrayContains)) {
      //You can't combine array-contains with array-contains-any
      throw UnableToCombineError(StackTrace.current);
    }
    if (query.whereQueryType == WhereQueryType.arrayContains &&
        setQuery.contains(WhereQueryType.arrayContains)) {
      //Use at most one array-contains clause per query.
      throw ArrayUseError(StackTrace.current);
    }
    if (idmap.containsKey(query.id)) {
      //If multiple where clauses on the same id then use where in
      if (idmap[query.id]!.whereQueryType == WhereQueryType.isEqualTo) {
        var oldQ = idmap[query.id]!;
        idmap[query.id] = QueryType(
            id: query.id,
            value: [query.value, oldQ.value],
            whereQueryType: WhereQueryType.whereIn);
      } else if (idmap[query.id]!.whereQueryType == WhereQueryType.whereIn) {
        var list = idmap[query.id]!.value as List;
        list.add(query.value);
      }
    } else {
      idmap[query.id] = query;
      setQuery.add(query.whereQueryType);
    }
  }

  //In a compound query, range (<, <=, >, >=)
  //and not equals (!=) comparisons must all filter on the same field.
  var isRange = false;
  Set keySet = {};
  rangeMap.forEach((key, value) {
    for (var v in value) {
      if (queryRange.contains(v)) {
        if (!isRange) {
          isRange = true;
          break;
        } else {
          if (!keySet.contains(key)) {
            throw QueryRangeConditionError(
                v.toString(), key, StackTrace.current);
          }
        }
      }
    }
    keySet.add(key);
  });

  return idmap.values.toList();
}
