import 'package:supabase/supabase.dart';

void main() async {
  print('Connecting to Supabase...');
  
  final client = SupabaseClient(
    'https://ucflrdepeafyxkeasnda.supabase.co',
    'sb_publishable_4Jo9u2CJvfP_R8GsB5J7BQ_KwhlTzmC',
  );

  final payload = {
    'zone_id': 1,
    'sensor_data': {
      'avg': 86.8,
      'peak': 31743,
      'min': 0,
      'rms': 1504.4,
      'temperature_c': 24.5
    }
  };

  print('Sending fake sensor payload from Zone 1...');

  try {
    await client.from('data').insert(payload);
    print('✅ SUCCESS! Fake payload inserted into Supabase!');
    print('The Flutter Dashboard will now automatically update if it is running.');
  } catch (e) {
    print('❌ ERROR: Failed to insert data.');
    print(e);
  }
}
