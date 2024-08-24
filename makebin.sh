if [ $# -eq 1 ]
  then
    vasm6502_oldstyle -Fbin -dotdir $1
    hexdump -C a.out
  else
    echo "input file not supplied"
fi
