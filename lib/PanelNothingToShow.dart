import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PanelNothingToShow extends StatefulWidget{

  final double width;

  PanelNothingToShow({
    required this.width
  });

  @override
  _PanelNothingToShow createState() => _PanelNothingToShow();
}

class _PanelNothingToShow extends State<PanelNothingToShow>{

  @override
  Widget build(BuildContext context){
    
    return Container(
      alignment: Alignment.center,
      child: Wrap(
        children: [
          Icon(Icons.info, color: Color.fromARGB(255, 252, 255, 255)),

          SizedBox(width: widget.width * 0.1),

          Text(
            'Nothing to show here',
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                fontSize: widget.width * 0.05,
                color: Color.fromARGB(255, 252, 255, 255),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      )
    );
  }
}