import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterInitial()) {
    on<CounterInc>((event, emit) {
      String email = event.email;
      String password = event.password;
      print(email);
      emit(CounterIncState("sky", password));
    });
  }
}
