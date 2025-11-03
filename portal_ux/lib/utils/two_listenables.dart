import 'package:flutter/material.dart';

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  const ValueListenableBuilder2({
    super.key,
    required this.valueListenable1,
    required this.valueListenable2,
    required this.builder,
    this.child,
  });

  final ValueNotifier<A> valueListenable1;
  final ValueNotifier<B> valueListenable2;
  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<A>(
        valueListenable: valueListenable1,
        builder: (_, a, __) {
          return ValueListenableBuilder<B>(
            valueListenable: valueListenable2,
            builder: (context, b, __) {
              return builder(context, a, b, child);
            },
          );
        },
      );
}