import 'package:cloud_firestore_database_wrapper/exception/exceptions.dart';
import 'package:cloud_firestore_database_wrapper/interfaces/i_data_source.dart';

checkQueryConstructor(List<QueryType> queries) {
  //Validate query list
  Map<String, QueryType> idmap = {};
  Set<WhereQueryType> setQuery = {};
  Map<String, List> rangeMap = {};

  for (var query in queries) {
    if (rangeMap.containsKey(query.id)) {
      rangeMap[query.id].add(query.whereQueryType);
    } else {
      rangeMap[query.id] = [query.whereQueryType];
    }

    //You can use at most one in, not-in, or array-contains-any clause per query.
    //You can't combine in , not-in, and array-contains-any in the same query.
    if (setQuery.contains(WhereQueryType.WhereIn)) {
      if (setQuery.contains(WhereQueryType.WhereNotIn)) {
        throw OnlyUseOneException(
            'Can\'t use whereIn and whereNotIn clauses in the same query',
            StackTrace.current);
      } else if (setQuery.contains(WhereQueryType.ArrayContainsAny)) {
        throw OnlyUseOneException(
            'Can\'t use whereIn and ArrayContainsAny clauses in the same query',
            StackTrace.current);
      }
    }
    if (setQuery.contains(WhereQueryType.WhereNotIn)) {
      if (setQuery.contains(WhereQueryType.WhereIn)) {
        throw OnlyUseOneException(
            'Can\'t use whereIn and WhereNotIn clauses in the same query',
            StackTrace.current);
      } else if (setQuery.contains(WhereQueryType.ArrayContainsAny)) {
        throw OnlyUseOneException(
            'Can\'t use ArrayContainsAny and WhereNotIn clauses in the same query',
            StackTrace.current);
      }
    }
    if (setQuery.contains(WhereQueryType.ArrayContainsAny)) {
      if (setQuery.contains(WhereQueryType.WhereIn)) {
        throw OnlyUseOneException(
            'Can\'t use ArrayContainsAny and WhereIn clauses in the same query',
            StackTrace.current);
      } else if (setQuery.contains(WhereQueryType.WhereNotIn)) {
        throw OnlyUseOneException(
            'Can\'t use ArrayContainsAny and WhereNotIn clauses in the same query',
            StackTrace.current);
      }
    }
    if ((query.whereQueryType == WhereQueryType.ArrayContains &&
            setQuery.contains(WhereQueryType.ArrayContainsAny)) ||
        query.whereQueryType == WhereQueryType.ArrayContainsAny &&
            setQuery.contains(WhereQueryType.ArrayContains)) {
      //You can't combine array-contains with array-contains-any
      throw UnableToCombineException(StackTrace.current);
    }
    if (query.whereQueryType == WhereQueryType.ArrayContains &&
        setQuery.contains(WhereQueryType.ArrayContains)) {
      //Use at most one array-contains clause per query.
      throw ArrayUseException(StackTrace.current);
    }
    if (idmap.containsKey(query.id)) {
      //If multiple where clauses on the same id then use where in
      if (idmap[query.id].whereQueryType == WhereQueryType.IsEqualTo) {
        var oldQ = idmap[query.id];
        idmap[query.id] = QueryType(
            id: query.id,
            value: [query.value, oldQ.value],
            whereQueryType: WhereQueryType.WhereIn);
      } else if (idmap[query.id].whereQueryType == WhereQueryType.WhereIn) {
        var list = idmap[query.id].value as List;
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
  Set keySet = Set();
  rangeMap.forEach((key, value) {
    for (var v in value) {
      if (queryRange.contains(v)) {
        if (!isRange) {
          isRange = true;
          break;
        } else {
          if (!keySet.contains(key)) {
            throw QueryRangeConditionException(
                v.toString(), key, StackTrace.current);
          }
        }
      }
    }
    keySet.add(key);
  });

  return idmap.values.toList();
}
