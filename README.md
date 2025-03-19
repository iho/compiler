# DSL Compiler

A simple DSL compiler that supports various programming constructs like tasks, conditionals, loops, and parallel execution.

## Run 

```bash
bash run.sh
```

Example input:
```
START
  TASK notify "Welcome to DSL test"
  TASK log "Starting test sequence"
  
  SET "counter" TO 0
  REPEAT 3 TIMES
    ADD 1 TO "counter"
    TASK log "Counter is now: ${counter}"
  ENDREPEAT
  
  WHILE CONDITION "counter < 5"
    ADD 1 TO "counter"
    TASK log "In while loop, counter: ${counter}"
  ENDWHILE
  
  PARALLEL
    TASK notify "Parallel task 1"
    WAIT 2 SECONDS
    TASK notify "Parallel task 2"
  ENDPARALLEL
  
  TRY
    TASK fetch "https://api.example.com/data" INTO "response"
    TASK write "${response}" TO FILE "output.json"
  CATCH
    TASK alert "Failed to fetch or write data"
  ENDTRY
  
  IF CONDITION "counter > 5"
    TASK log "High counter value: ${counter}"
    TASK read FILE "output.json" INTO "data"
  ELSE
    TASK alert "Counter is too low: ${counter}"
  ENDIF
  
  SUBTRACT 2 FROM "counter"
  TASK log "Final counter value: ${counter}"
  TASK notify "Test sequence completed"
  STOP
END
```

Expected output:
```
Program:
  Task(Notify("Welcome to DSL test"))
  Task(Log("Starting test sequence"))
  Set("counter", 0)
  Repeat(3 times)
    Add(1 to "counter")
    Task(Log("Counter is now: ${counter}"))
  While("counter < 5")
    Add(1 to "counter")
    Task(Log("In while loop, counter: ${counter}"))
  Parallel
    Task(Notify("Parallel task 1"))
    Wait(2 seconds)
    Task(Notify("Parallel task 2"))
  Try
    Task(Fetch("https://api.example.com/data", "response"))
    Task(Write("${response}", "output.json"))
  Catch
    Task(Alert("Failed to fetch or write data"))
  If("counter > 5")
    Task(Log("High counter value: ${counter}"))
    Task(Read("output.json", "data"))
  Else
    Task(Alert("Low sales detected"))
```