#!/usr/bin/awk -f

BEGIN {OFS="\t"} 
{
  if (NR>5) {
    $11 = 10^$11;
  }
  if (NR>5 && $11 < 10^-180) {
    $11 = 0; print $0;
  } 
  else if (NR>5 && $4 > 30) 
    print $0
}
