echo "START
  TASK notify \"Send email to team\"
  IF condition \"sales > 1000\"
    TASK log \"Record high sales\"
  ELSE
    TASK alert \"Low sales detected\"
  ENDIF
END" | ./_build/default/lib/main.exe