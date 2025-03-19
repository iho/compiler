echo "START
  TASK NOTIFY \"Welcome to DSL test\"
  TASK LOG \"Starting test sequence\"
  
  SET \"counter\" TO 0
  REPEAT 3 TIMES
    ADD 1 TO \"counter\"
    TASK LOG \"Counter is now: \${counter}\"
  ENDREPEAT
  
  WHILE CONDITION \"counter < 5\"
    ADD 1 TO \"counter\"
    TASK LOG \"In while loop, counter: \${counter}\"
  ENDWHILE
  
  PARALLEL
    TASK NOTIFY \"Parallel task 1\"
    WAIT 2 SECONDS
    TASK NOTIFY \"Parallel task 2\"
  ENDPARALLEL
  
  TRY
    TASK FETCH \"https://api.example.com/data\" INTO \"response\"
    TASK WRITE \"\${response}\" TO FILE \"output.json\"
  CATCH
    TASK ALERT \"Failed to fetch or write data\"
  ENDTRY
  
  IF CONDITION \"counter > 5\"
    TASK LOG \"High counter value: \${counter}\"
    TASK READ FILE \"output.json\" INTO \"data\"
  ELSE
    TASK ALERT \"Counter is too low: \${counter}\"
  ENDIF
  
  SUBTRACT 2 FROM \"counter\"
  TASK LOG \"Final counter value: \${counter}\"
  TASK NOTIFY \"Test sequence completed\"
  STOP
END" | ./_build/default/lib/main.exe