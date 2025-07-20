import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_chat/configuration/config_invoke.dart';

class EasterEggPlayerInline extends StatefulWidget {
  final String asset_path;
  final Color text_color;

  const EasterEggPlayerInline({
    super.key,
    required this.asset_path,
    required this.text_color,
  });

  @override
  State<EasterEggPlayerInline> createState() => _EasterEggPlayerInlineState();
}

class _EasterEggPlayerInlineState extends State<EasterEggPlayerInline> {
  late AudioPlayer _player;
  bool _is_playing = false;
  Duration _total_duration = Duration.zero;
  Duration _current_position = Duration.zero;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();

    _player.onDurationChanged.listen((duration) {
      setState(() {
        _total_duration = duration;
      });
    });

    _player.onPositionChanged.listen((position) {
      setState(() {
        _current_position = position;
      });
    });

    _player.onPlayerStateChanged.listen((state) {
      setState(() {
        _is_playing = state == PlayerState.playing;
      });
    });
  }

  void _playPause() async {
    if (_is_playing) {
      await _player.pause();
    } else {
      if (_current_position >= _total_duration) {
        await _player.seek(Duration.zero);
      }
      await _player.play(AssetSource(widget.asset_path));
    }
  }

  void _seek(double value) {
    _player.seek(Duration(seconds: value.toInt()));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title text
        Text(
          "Found Easter Egg",
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: widget.text_color,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: config_data.background_color, // background color here
            borderRadius: BorderRadius.circular(8), // optional rounded corners
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Icon and slider
              Row(
                children: [
                  IconButton(
                    iconSize: 40,
                    icon: Icon(_is_playing ? Icons.pause_circle_filled : Icons.play_circle_fill),
                    onPressed: _playPause,
                    color: config_data.text_color,
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: config_data.app_bar_color, //left of the thumb
                        inactiveTrackColor: config_data.date_text_color, //right of the thumb
                        thumbColor: config_data.app_bar_color, // draggable thumb
                        overlayColor: config_data.ai_text_box_color, // overlay when pressed
                      ),
                      child: Slider(
                        min: 0,
                        max: _total_duration.inSeconds.toDouble(),
                        value: _current_position.inSeconds.clamp(0, _total_duration.inSeconds).toDouble(),
                        onChanged: _seek,
                      ),
                    ),
                  ),
                ],
              ),
              //Time display
              Text(
                "${_formatDuration(_current_position)}/${_formatDuration(_total_duration)}",
                style: TextStyle(
                  fontSize: 14,
                  color: widget.text_color.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
