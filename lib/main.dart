import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title:'貪吃蛇'),
    );
  }
}

class MyHomePage extends StatefulWidget{
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

Offset _ball = Offset.zero; //球的位置
const double _size = 20; //寬度固定
List<Offset> _snakeList = [Offset(_size * 2, 0), Offset(_size * 3, 0)]; //貪吃蛇的位置
enum Direction{Up, Down, Left, Right} //貪吃蛇方向
enum GameStatus{Over, Start}
Direction _direction = Direction.Up;
GameStatus _gameStatus = GameStatus.Start;
late Timer _timer;

class _MyHomePageState extends State<MyHomePage>{
  @override
  void didChangeDependencies(){
    reSetGame();
    super.didChangeDependencies();
  }

  void reSetGame(){
    var period = Duration(milliseconds: 200);
    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height;
    double widthPad = maxWidth % _size;
    double heightPad = maxHeight % _size;
    maxWidth = maxWidth - widthPad;
    maxHeight -= heightPad;
    _ball = randomPosition(maxWidth, maxHeight);
    _timer = Timer.periodic(period, (timer){
      List<Offset> newSnakeList = List.generate(_snakeList.length, (index){
        if(index > 0){
          return _snakeList[index - 1];
        }
        else{
          final snakeHead = _snakeList[0];
          switch(_direction){
            case Direction.Up:
              return Offset(snakeHead.dx, (snakeHead.dy - _size + maxHeight) % maxHeight);
            case Direction.Down:
              return Offset(snakeHead.dx, (snakeHead.dy + _size) % maxHeight);
            case Direction.Left:
              return Offset((snakeHead.dx - _size + maxWidth) % maxWidth, snakeHead.dy);
            case Direction.Right:
              return Offset((snakeHead.dx + _size) % maxWidth, snakeHead.dy);
          }
        }
      });
      if (newSnakeList[0] == _ball){
        newSnakeList..add(_snakeList[_snakeList.length - 1]);
        setState(() {
          _ball = randomPosition(maxWidth, maxHeight);
        });
      }
      List<Offset> judgeSnakeList = List.from(newSnakeList);
      judgeSnakeList.removeAt(0);
      if(judgeSnakeList.contains(newSnakeList[0])){
        setState(() {
          _gameStatus = GameStatus.Over;
          _timer.cancel();
        });
      }
      setState(() {
        _snakeList = newSnakeList;
      });
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        body: RawKeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKey: (event){
            if(event.runtimeType == RawKeyDownEvent){
              Direction newDirection = Direction.Left;
              switch(event.logicalKey.keyLabel){
                case "Arrow Up":
                  if(_direction == Direction.Down){
                    return;
                  }
                  newDirection = Direction.Up;
                  break;
                case "Arrow Down":
                  if(_direction == Direction.Up){
                    return;
                  }
                  newDirection = Direction.Down;
                  break;
                case "Arrow Left":
                  if(_direction == Direction.Right){
                    return;
                  }
                  newDirection = Direction.Left;
                  break;
                case "Arrow Right":
                  if(_direction == Direction.Left){
                    return;
                  }
                  newDirection = Direction.Right;
                  break;
              }
              setState(() {
                _direction = newDirection;
              });
            }
          },
          child: _gameStatus == GameStatus.Start
              ? _buildGameStart()
              : _buildGameOver(),
        )
    );
  }
  GestureDetector _buildGameOver(){
    return GestureDetector(
      onTap: (){},
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            TextButton(
              onPressed: (){
                setState(() {
                  _gameStatus = GameStatus.Start;
                  reSetGame();
                });
              },
              child: Text("繼續遊戲", style: TextStyle(color: Colors.blueGrey),),
              style: TextButton.styleFrom(textStyle: TextStyle(fontSize: 22)),
            ),
            TextButton(
              onPressed: (){
                setState(() {
                  _gameStatus = GameStatus.Start;
                  _direction = Direction.Up;
                  _snakeList = [Offset(_size * 2, 0), Offset(_size * 3, 0)];
                  reSetGame();
                });
              },
              child: Text("重新遊戲", style: TextStyle(color: Colors.blueGrey),),
              style: TextButton.styleFrom(textStyle: TextStyle(fontSize: 22)),
            )
          ],
        ),
      ),
    );
  }

  _buildGameStart(){
    return Stack(
      children: _snakeList
          .map((snake) => Positioned.fromRect(
          rect: Rect.fromCenter(center: adjust(snake), width: _size, height: _size),
          child: Container(margin: EdgeInsets.all(1), color: Colors.brown,)
      ))
          .toList()
        ..add(Positioned.fromRect(
            rect: Rect.fromCenter(center: adjust(_ball), width: _size, height: _size),
            child: Container(margin: EdgeInsets.all(1), color: Colors.blue,)
        )),
    );
  }

  Offset adjust(Offset offset){
    return Offset(offset.dx + (_size / 2), offset.dy + (_size / 2));
  }

  Offset randomPosition(double widthRange, double heightRange){
    var rng = Random();
    int intWidthRange = widthRange.toInt();
    int intHeightRange = heightRange.toInt();
    int finalWidth = rng.nextInt(intWidthRange);
    int finalHeight = rng.nextInt(intHeightRange);
    double widthPad = finalWidth % _size;
    double heightPad = finalHeight % _size;
    double actualWidth = finalWidth - widthPad;
    double actualHeight = finalHeight - heightPad;
    return Offset(actualWidth, actualHeight);
  }
}
