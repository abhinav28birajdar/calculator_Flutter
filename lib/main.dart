import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';
import 'package:intl/intl.dart';
import 'buttons.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String equation = '';
  String result = '0';
  String expression = '';
  double equationFontSize = 24.0;
  double resultFontSize = 48.0;
  bool isRadians = false;

  buttonPressed(String buttonText) {
    setState(() {
      switch (buttonText) {
        case 'AC':
          equation = '';
          result = '0';
          expression = '';
          break;
        case '⌫':
          if (equation.isNotEmpty) {
            equation = equation.substring(0, equation.length - 1);
            if (equation.isEmpty) {
              result = '0';
            }
          }
          break;
        case '=':
          expression = equation;
          expression = expression.replaceAll('×', '*');
          expression = expression.replaceAll('÷', '/');
          expression = expression.replaceAll('%', '/100');

          try {
            Parser p = Parser();
            Expression exp = p.parse(expression);
            ContextModel cm = ContextModel();
            double evalResult = exp.evaluate(EvaluationType.REAL, cm);

            // Format result with comma separators and remove unnecessary decimals
            final formatter = NumberFormat('#,###.##########');
            result = formatter.format(evalResult);

            // Remove trailing zeros after decimal point
            if (result.contains('.')) {
              result = result.replaceAll(RegExp(r'\.?0*$'), '');
            }
          } catch (e) {
            result = 'Error';
          }
          break;
        case 'sin':
          if (equation.isNotEmpty) {
            double value = double.tryParse(equation) ?? 0;
            double angle = isRadians ? value : value * math.pi / 180;
            result = math.sin(angle).toString();
            equation = result;
          }
          break;
        case 'cos':
          if (equation.isNotEmpty) {
            double value = double.tryParse(equation) ?? 0;
            double angle = isRadians ? value : value * math.pi / 180;
            result = math.cos(angle).toString();
            equation = result;
          }
          break;
        case 'tan':
          if (equation.isNotEmpty) {
            double value = double.tryParse(equation) ?? 0;
            double angle = isRadians ? value : value * math.pi / 180;
            result = math.tan(angle).toString();
            equation = result;
          }
          break;
        case 'ln':
          if (equation.isNotEmpty) {
            double value = double.tryParse(equation) ?? 0;
            if (value > 0) {
              result = math.log(value).toString();
              equation = result;
            }
          }
          break;
        case 'log':
          if (equation.isNotEmpty) {
            double value = double.tryParse(equation) ?? 0;
            if (value > 0) {
              result = (math.log(value) / math.log(10)).toString();
              equation = result;
            }
          }
          break;
        case '√':
          if (equation.isNotEmpty) {
            double value = double.tryParse(equation) ?? 0;
            if (value >= 0) {
              result = math.sqrt(value).toString();
              equation = result;
            }
          }
          break;
        case 'π':
          equation += math.pi.toString();
          break;
        case 'e':
          equation += math.e.toString();
          break;
        case 'deg':
          isRadians = !isRadians;
          break;
        default:
          equation += buttonText;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 0.7, 1.0],
            colors: [
              Color(0xFF4A90E2).withOpacity(0.3), // Blue gradient top right
              Color(0xFF2C5282).withOpacity(0.2),
              Color(0xFF1a1a1a),
              Color(0xFF0a0a0a),
            ],
          ),
        ),
        child: Container(
          child: CustomPaint(
            painter: NoisePainter(),
            child: SafeArea(
              child: Column(
                children: [
                  // Display Area
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Equation
                          Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              equation.isEmpty ? '' : equation,
                              style: TextStyle(
                                fontSize: equationFontSize,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w300,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 10),
                          // Result
                          Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              result,
                              style: TextStyle(
                                fontSize: resultFontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Button Area
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          // First row - Scientific functions
                          buildButtonRow(['e', 'μ', 'sin', 'deg']),
                          // Second row - AC, backspace, division, multiplication
                          buildButtonRow(['AC', '⌫', '/', '*']),
                          // Third row - 7, 8, 9, minus
                          buildButtonRow(['7', '8', '9', '-']),
                          // Fourth row - 4, 5, 6, plus
                          buildButtonRow(['4', '5', '6', '+']),
                          // Fifth row - 1, 2, 3, equals
                          buildButtonRow(['1', '2', '3', '=']),
                          // Sixth row - Zero (wide), decimal
                          buildLastRow(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButtonRow(List<String> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((buttonText) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.all(6),
              child: MyButton(
                buttonText: buttonText,
                buttonTapped: () => buttonPressed(buttonText),
                color: getButtonColor(buttonText),
                textColor: getTextColor(buttonText),
                fontSize: getButtonFontSize(buttonText),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildLastRow() {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.all(6),
              child: MyButton(
                buttonText: '0',
                buttonTapped: () => buttonPressed('0'),
                color: Color(0xFF333333),
                textColor: Colors.white,
                fontSize: 28,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(6),
              child: MyButton(
                buttonText: '.',
                buttonTapped: () => buttonPressed('.'),
                color: Color(0xFF333333),
                textColor: Colors.white,
                fontSize: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color getButtonColor(String buttonText) {
    if (isOperator(buttonText)) {
      return Color(0xFF4A90E2); // Blue for operators
    } else if (isFunction(buttonText)) {
      return Color(0xFF333333); // Dark gray for functions
    } else {
      return Color(0xFF333333); // Dark gray for numbers
    }
  }

  Color getTextColor(String buttonText) {
    if (isSpecialFunction(buttonText)) {
      return Color(0xFF4A90E2); // Blue text for special functions
    }
    return Colors.white;
  }

  double getButtonFontSize(String buttonText) {
    if (buttonText == 'deg' ||
        buttonText == 'sin' ||
        buttonText == 'cos' ||
        buttonText == 'tan') {
      return 18;
    }
    return 24;
  }

  bool isOperator(String buttonText) {
    return ['+', '-', '*', '/', '='].contains(buttonText);
  }

  bool isFunction(String buttonText) {
    return [
      'AC',
      '⌫',
      'sin',
      'cos',
      'tan',
      'ln',
      'log',
      '√',
      'π',
      'e',
      'deg',
      '%'
    ].contains(buttonText);
  }

  bool isSpecialFunction(String buttonText) {
    return ['e', 'μ', 'sin', 'deg'].contains(buttonText);
  }
}

// Custom painter for noise texture
class NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent pattern

    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
