
hex
0f002 constant rand
0fffe constant screen

: random-chars begin rand @ 01f and 020 and screen ! again ;

