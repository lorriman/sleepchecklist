import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insomnia_checklist/app/home/models/check_list_item.dart';
import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:insomnia_checklist/app/top_level_providers.dart';
import 'package:insomnia_checklist/constants/keys.dart';
import 'package:insomnia_checklist/routing/app_router.dart';
import 'package:insomnia_checklist/services/globals.dart';
import 'package:insomnia_checklist/services/repository.dart';

/// Copyright Andrea Bozito, with modifications by GL.
/// Notable additions and classes by Greg Lorriman as noted.

class EditChecklistItemPage extends ConsumerStatefulWidget {
  const EditChecklistItemPage({Key? key, this.checklistItem}) : super(key: key);
  final ChecklistItem? checklistItem;

  static Future<void> show(BuildContext context,
      {ChecklistItem? checklistItem}) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.editChecklistItemPage,
      arguments: checklistItem,
    );
  }

  @override
  _EditChecklistItemPageState createState() => _EditChecklistItemPageState();
}

class _EditChecklistItemPageState extends ConsumerState<EditChecklistItemPage> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  String? _description;

  @override
  void initState() {
    super.initState();
    _name = widget.checklistItem?.name;
    _description = widget.checklistItem?.description;
    //}
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit(WidgetRef ref) async {
    if (_validateAndSaveForm()) {
      try {
        final database = ref.read<Repository>(databaseProvider);
        final checklistItems = await database.checklistItemsStream().first;
        final allLowerCaseNames = checklistItems
            .map((checklistItem) => checklistItem.name.toLowerCase())
            .toList();
        if (widget.checklistItem != null) {
          allLowerCaseNames.remove(widget.checklistItem!.name.toLowerCase());
        }
        if (allLowerCaseNames.contains(_name?.toLowerCase())) {
          unawaited(showAlertDialog(
            context: context,
            title: 'Name already used',
            content: 'Please choose a different label',
            defaultActionText: 'OK',
          ));
        } else {
          final id = widget.checklistItem?.id ?? ChecklistItem.newId();
          final checklistItem = ChecklistItem(
            id: id,
            name: _name ?? '',
            description: _description ?? '',
            startDate: DateTime.now(),
          );
          await database.setChecklistItem(checklistItem);
          Navigator.of(context).pop();
        }
      } catch (e) {
        logger.e('_EditChecklistItemPageState._submit', e);
        if (mounted) {
          unawaited(showExceptionAlertDialog(
            context: context,
            title: 'Operation failed',
            exception: e,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton.extended(
        key: Key(Keys.testEditItemSaveButton),
        label: Text('Save'),
        onPressed: () => _submit(ref),
      ),
      appBar: AppBar(
        elevation: 2.0,
        title: Text(widget.checklistItem == null ? 'New Item' : 'Edit Item'),
        actions: const <Widget>[],
      ),
      body: _buildContents(),
    );
  }

  Widget _buildContents() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        key: Key(Keys.testEditItemTextName),
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        maxLength: 30,
        decoration: const InputDecoration(labelText: 'Item name'),
        keyboardAppearance: Brightness.light,
        initialValue: _name,
        validator: (value) =>
            (value ?? '').isNotEmpty ? null : 'Name can\'t be empty',
        onSaved: (value) => _name = value,
      ),
      TextFormField(
        key: Key(Keys.testEditItemTextDescription),
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        maxLength: 255,
        decoration: const InputDecoration(labelText: 'Description (optional)'),
        keyboardAppearance: Brightness.light,
        initialValue: _description,
        onSaved: (value) => _description = value?.trim() ?? '',
      ),
    ];
  }
}
