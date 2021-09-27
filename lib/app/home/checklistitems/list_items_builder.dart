import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insomnia_checklist/app/home/checklistitems/empty_content.dart';

/// Copyright Andrea Bozito, with modifications.
/// Notable additions and classes by Greg Lorriman as noted.

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class ListItemsBuilderV1<T> extends StatelessWidget {
  const ListItemsBuilderV1({
    Key? key,
    required this.data,
    required this.itemBuilder,
  }) : super(key: key);
  final AsyncValue<Map<DateTime, T>?> data;
  final ItemWidgetBuilder<T> itemBuilder;

  @override
  Widget build(BuildContext context) {
    return data.when(
      data: (items) => (items == null ? false : items.isNotEmpty)
          ? _buildList(items, null)
          : const EmptyContent(),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => EmptyContent(
        title: e.toString(), //'Something went wrong',
        message:
            st?.toString() ?? 'no stack trace', //'Can\'t load items right now',
      ),
    );
  }

  Widget _buildList(Map<DateTime, T>? unFilteredItems, String? search) {
    final items = unFilteredItems;
    if (items == null) {
      return Text('no items');
    }
    final List<T> itemsAsList = items.values.toList();

    return ListView.separated(
      physics: BouncingScrollPhysics(),
      itemCount: items.length + 2,
      separatorBuilder: (context, index) => const Divider(height: 1.0),
      itemBuilder: (context, index) {
        if (index == 0 || index == itemsAsList.length + 1) {
          return Container(); // zero height: not visible
        }
        return itemBuilder(context, itemsAsList[index - 1]);
      },
    );
  }
}

class ListItemsBuilderV2<T> extends StatelessWidget {
  ListItemsBuilderV2({
    Key? key,
    required this.data,
    required this.itemBuilder,
    this.reorderable = false,
    this.onReorder,
    this.filter,
  }) : super(key: key);
  final AsyncValue<List<T>> data;
  final ItemWidgetBuilder<T> itemBuilder;
  bool reorderable;
  ReorderCallback? onReorder;
  final bool Function(T item)? filter;
  final _random = Random(3); //used for keys

  @override
  Widget build(BuildContext context) {
    return data.when(
      data: (items) => items.isNotEmpty
          ? _buildList(items, filter: filter)
          : const EmptyContent(),
      loading: () => const Center(child: CircularProgressIndicator()),
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
