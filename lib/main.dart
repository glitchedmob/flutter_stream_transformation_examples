import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(const MyApp());
}


extension StreamExtensions<T> on Stream<T> {
  ValueStream<T> toValueStreamSeeded(T seedValue) {
    final subject = BehaviorSubject<T>.seeded(seedValue);

    subject.sink.addStream(this);

    return subject.stream;
  }

  ValueStream<T?> toValueStream() {
    final subject = BehaviorSubject<T?>.seeded(null);

    subject.sink.addStream(this);

    return subject.stream;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stream Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Stream Demo Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _count$ = BehaviorSubject.seeded(0);
  final _allCounts$ = BehaviorSubject<List<int>>.seeded([]);

  late final _countDouble$ =
      _count$.map((count) => count * 2).toValueStreamSeeded(0);

  late final _countEven$ =
      _count$.where((count) => count % 2 == 0);

  late final _allCounts3Multiple$ = _allCounts$
      .map((counts) => counts.isNotEmpty && counts.length % 3 == 0)
      .distinct();

  void _incrementCounter() {
    _count$.add(_count$.value + 1);
    _allCounts$.add([..._allCounts$.value, _count$.value]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            StreamBuilder<int>(
              stream: _count$,
              builder: (context, snapshot) {
                return Text(
                  '${snapshot.data}',
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            ),
            StreamBuilder<int>(
              stream: _countDouble$,
              builder: (context, snapshot) {
                return Text(
                  '${snapshot.data}',
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            ),
            StreamBuilder<int>(
              stream: _countEven$,
              builder: (context, snapshot) {
                return Text(
                  '${snapshot.data}',
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            ),
            StreamBuilder<List<int>>(
              stream: _allCounts$,
              builder: (context, snapshot) {
                return Text(
                  '${snapshot.data?.join(' ,')}',
                );
              },
            ),
            StreamBuilder<bool>(/**/
              stream: _allCounts3Multiple$,
              builder: (context, snapshot) {
                return Text(
                  'all counts multiple of 3 = ${snapshot.data}',
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
