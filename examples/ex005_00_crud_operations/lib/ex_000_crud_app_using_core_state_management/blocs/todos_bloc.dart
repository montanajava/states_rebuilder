import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:uuid/uuid.dart';

import '../data_source/i_todos_repository.dart';
import '../data_source/todos_fake_repository.dart';
import '../data_source/todos_http_repository.dart';
import '../models/todo.dart';
import '../models/todo_filter.dart';

// TODO: Switch between implementations
final todosRepository = RM.inject<ITodosRepository>(
  // () => TodosHttpRepository(), // <== Real implementation
  // () => TodosFakeRepository(), // <== Fake implementation without error
  () => TodosFakeRepository(
      shouldThrowExceptions: () =>
          Random().nextBool()), // <== fake implementation with random error
);
const _uuid = Uuid();

@immutable
class TodosViewModel {
  void init() {
    _todosRM.setState((s) => todosRepository.state.getTodos());
  }

  late final Injected<List<Todo>> _todosRM = RM.inject(
    () => [],
    sideEffects: SideEffects.onError(
      (err, refresh) {
        if (_todosRM.state.isEmpty) return;
        RM.scaffold.showSnackBar(
          SnackBar(
            content: Text(err.message),
            action: SnackBarAction(
              label: 'Refresh',
              onPressed: refresh,
            ),
          ),
        );
      },
    ),
  );
  final _todoListFilterRM = RM.inject<TodoFilter>(
    () => TodoFilter.all,
  );
  TodoFilter get filter => _todoListFilterRM.state;
  set filter(TodoFilter value) => _todoListFilterRM.state = value;

  late final _uncompletedTodosCount = RM.inject<int>(
    () {
      final uncompleted = _todosRM.state.where((todo) => !todo.completed);
      return uncompleted.length;
    },
    initialState: 0,
    // uncompletedTodosCount depends on _todosRM. When the state of _todosRM changes
    // the uncompletedTodosCount is recalculated to get the new uncompleted count
    dependsOn: DependsOn({_todosRM}),
  );
  int get uncompletedTodosCount => _uncompletedTodosCount.state;
  bool get isAllCompleted => uncompletedTodosCount == 0;

  late final Injected<List<Todo>> _filteredTodosRM = RM.inject(
    () {
      switch (filter) {
        case TodoFilter.completed:
          return _todosRM.state.where((todo) => todo.completed).toList();
        case TodoFilter.active:
          return _todosRM.state.where((todo) => !todo.completed).toList();
        case TodoFilter.all:
          return _todosRM.state;
      }
    },
    initialState: const [],
    // the filteredTodosRM depended on two states. When any of them changes the
    // filteredTodosRM is recalculated
    dependsOn: DependsOn({_todosRM, _todoListFilterRM}),
  );
  List<Todo> get filteredTodos => [..._filteredTodosRM.state];
  late final onAll = _filteredTodosRM.onAll;

  // Methods to add, edit, remove and toggle todos item
  void add(String description) {
    final todoToAdd = Todo(
      id: _uuid.v4(),
      description: description,
    );

    _todosRM.setState(
      (s) async* {
        yield [..._todosRM.state, todoToAdd];
        try {
          await todosRepository.state.createTodo(todoToAdd);
        } catch (e) {
          yield [
            for (final todo in _todosRM.state)
              if (todo.id != todoToAdd.id) todo,
          ];
          rethrow;
        }
      },
      stateInterceptor: (current, next) {
        if (next.isWaiting) return current;
        return next;
      },
    );
  }

  void edit(Todo todoToEdit) {
    final oldTodo =
        _todosRM.state.firstWhere((todo) => todo.id == todoToEdit.id);

    _todosRM.setState(
      (s) async* {
        yield [
          for (final todo in _todosRM.state)
            if (todo.id == todoToEdit.id) todoToEdit else todo,
        ];
        currentTodo.refresh();
        try {
          await todosRepository.state.updateTodo(todoToEdit);
        } catch (e) {
          yield [
            for (final todo in _todosRM.state)
              if (todo.id == todoToEdit.id) oldTodo else todo,
          ];
          currentTodo.refresh();
          rethrow;
        }
      },
      stateInterceptor: (current, next) {
        if (next.isWaiting) return current;
        return next;
      },
    );
  }

  void remove(String id) {
    final oldState = [..._todosRM.state];

    _todosRM.setState(
      (s) async* {
        yield [
          for (final todo in _todosRM.state)
            if (todo.id != id) todo,
        ];
        try {
          await todosRepository.state.deleteTodo(id);
        } catch (e) {
          yield oldState;
          rethrow;
        }
      },
      stateInterceptor: (current, next) {
        if (next.isWaiting) return current;
        return next;
      },
    );
  }

  void toggleAll(bool to) {
    final oldState = [..._todosRM.state];
    _todosRM.setState(
      (s) async* {
        final toAwait = <Future>[];
        yield [
          for (final todo in _todosRM.state)
            if (todo.completed == to)
              todo
            else
              () {
                final toUpdate = todo.copyWith(
                  completed: to,
                );
                toAwait.add(todosRepository.state.updateTodo(toUpdate));
                return toUpdate;
              }(),
        ];
        currentTodo.refresh();
        try {
          await Future.wait(toAwait);
        } catch (e) {
          yield oldState;
          currentTodo.refresh();

          rethrow;
        }
      },
    );
  }

  // currentTodo used for local state todo items
  static final currentTodo = RM.inject<TodoItem>(
    () => throw UnimplementedError(),
    sideEffects: SideEffects.onData(
      (todo) {
        todosViewModel.edit(todo);
      },
    ),
  );
}

// TodoViewModel is a global state
final todosViewModel = TodosViewModel();

// We create a custom object for each todo items.
//
// Each todo item will have the Todo object with two FocusNode and one TextEditingController
// It will be used in the UI
@immutable
class TodoItem extends Todo {
  final FocusNode itemFocusNode;
  final FocusNode textFocusNode;
  final TextEditingController textEditingController;
  final bool isEditable;
  TodoItem({
    required Todo value,
    required this.itemFocusNode,
    required this.textFocusNode,
    required this.textEditingController,
    this.isEditable = false,
  }) : super(
          id: value.id,
          description: value.description,
          completed: value.completed,
        );

  @override
  TodoItem copyWith({
    bool? completed,
    String? description,
    String? id,
  }) {
    return TodoItem(
      value: super.copyWith(
        id: id,
        description: description,
        completed: completed,
      ),
      itemFocusNode: itemFocusNode,
      textFocusNode: textFocusNode,
      textEditingController: textEditingController,
    );
  }
}
