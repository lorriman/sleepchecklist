import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insomnia_checklist/app/home/checklistitems/empty_content.dart';
import 'package:insomnia_checklist/services/utils.dart';

/// Copyright Andrea Bozito, with modifications.
/// Notable additions and classes by Greg Lorriman as noted.

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class ListItemsBuilder<T> extends StatelessWidget {
  ListItemsBuilder({
    Key? key,
    required this.data,
    required this.itemBuilder,
    this.reorderable = false,
    this.onReorder,
    this.filter,
    this.emptyContent,
  }) : super(key: key);

  final AsyncValue data;
  final ItemWidgetBuilder<T> itemBuilder;
  final bool reorderable;
  final ReorderCallback? onReorder;
  final bool Function(T item)? filter;
  final _random = Random(3); //used for keys
  final Widget? emptyContent;

  @override
  Widget build(BuildContext context) {
    return data.when(
      data: (dynamic items) {
        late List<T> renderedItems;
        if (items is Map) {
          renderedItems = items.values.toList() as List<T>;
        } else if (items is List) {
          renderedItems = items as List<T>;
        } else {
          throw Exception(
              'items must be a List or Map in ListItemsBuilder.build');
        }
        if (renderedItems.isNotEmpty) {
          return _buildList(renderedItems, filter: filter);
        } else {
          return emptyContent ?? const EmptyContent();
        }
      },
      loading: () => Center(child: basicLoadingIndicator()),
      error: (e, st) => EmptyContent(
        title: e.toString(), //'Something went wrong',
        message:
            st?.toString() ?? 'no stack trace', //'Can\'t load items right now',
      ),
    );
  }

  bool _defaultFilter(T item) => true;

  Widget _buildList(List<T> unFilteredItems, {bool Function(T item)? filter}) {
    filter ??= _defaultFilter;
    final items = unFilteredItems.where(filter).toList();

    if (!reorderable || onReorder == null) {
      return ListView.builder(
        physics: BouncingScrollPhysics(),
        primary: true,
        itemCount: items.length + 2,
        itemBuilder: (context, index) {
          if (index == 0 || index == items.length + 1) {
            return Container(
                key: Key(
                    'special container ${_random.nextDouble().toString()}')); // zero height: not visible
          }
          return itemBuilder(context, items[index - 1]);
        },
      );
    } else {
      return ReorderableListView.builder(
        physics: BouncingScrollPhysics(),
        onReorder: onReorder!,
        primary: true,
        itemCount: items.length + 2,
        itemBuilder: (context, index) {
          if (index == 0 || index == items.length + 1) {
            return Container(
                key: Key(
                    'special container ${_random.nextDouble().toString()}')); // zero height: not visible
          }
          return itemBuilder(context, items[index - 1]);
        },
      );
    }
  }
}
