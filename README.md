# README

This is an even period calender implementation heavily inspired by https://wiki.xxiivv.com/site/arvelie.html. 






- Only support year 2000 and beyond.
- Year is first two digits (e.g. 21A00 is the year 2021).
- The year is divided into 26 "months", each being 14 days.
- Each month is added as ascii 'A' to 'Z'.
- That leaves the last 1 or 2 days in the year (depending on if it is a leap year or not). Those days uses ascii '+'.
- Finally add the day in the "month", zero-based (i.e. 0 - 13).

Usings those rules we get.

- 2000-01-01 -> 00A00
- 2021-01-01 -> 21A00
- 2020-12-31 -> 21+01 // leap year
- 2021-12-31 -> 21+00
- 2021-06-01 -> 21K11

