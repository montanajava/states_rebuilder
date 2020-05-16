import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

enum CounterGridTag { remoteWidget }

class CounterBlocRemote {
  int counter = 0;
  increment() {
    counter++;
  }
}

class RebuildRemoteExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject<CounterBlocRemote>(() => CounterBlocRemote())],
      builder: (_) => CounterGrid(),
    );
  }
}

class CounterGrid extends StatefulWidget {
  @override
  _CounterGridState createState() => _CounterGridState();
}

class _CounterGridState extends State<CounterGrid> {
  bool isEven;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              StateBuilder<CounterBlocRemote>(
                observe: () => Injector.getAsReactive<CounterBlocRemote>(),
                tag: CounterGridTag.remoteWidget,
                builder: (_, counterRM) {
                  print('rebuild');
                  return isEven == null
                      ? CircularProgressIndicator()
                      : isEven ? Icon(Icons.looks_two) : Icon(Icons.looks_one);
                },
              ),
              Text("Rebuild remote widget with tag"),
            ],
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: <Widget>[
                for (var i = 0; i < 12; i++)
                  StateBuilder(
                    tag: i % 2,
                    observe: () => Injector.getAsReactive<CounterBlocRemote>(),
                    builder: (_, counterRM) => GridItem(
                      count: counterRM.state.counter,
                      onTap: () => counterRM.setState(
                        (state) => state.increment(),
                        filterTags: [i % 2, CounterGridTag.remoteWidget],
                        onSetState: (context) {
                          isEven = i % 2 == 0;
                        },
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final int count;
  final Function onTap;
  GridItem({this.count, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.lightBlue,
          border:
              Border.all(color: Theme.of(context).primaryColorDark, width: 4),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            "$count",
            style: TextStyle(
              color: Colors.white,
              fontSize: 50,
            ),
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
