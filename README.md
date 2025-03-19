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
    Task(Alert("Counter is too low: ${counter}"))
  Subtract(2 from "counter")
  Task(Log("Final counter value: ${counter}"))
  Task(Notify("Test sequence completed"))
  Stop

Generated Python code:
import json
import asyncio
import aiohttp
import sys

async def main():
    async with aiohttp.ClientSession() as session:
        print("Welcome to DSL test")
        print("LOG: Starting test sequence")
        counter = 0
        for _ in range(3):
            counter += 1
            print("LOG: Counter is now: ${counter}")
        while counter < 5:
            counter += 1
            print("LOG: In while loop, counter: ${counter}")
        # Run tasks in parallel
        async def task_0():
            print("Parallel task 1")
        async def task_1():
            await asyncio.sleep(2)
        async def task_2():
            print("Parallel task 2")
        await asyncio.gather(
            task_0(),
            task_1(),
            task_2()
        )
        try:
            response = await session.get("https://api.example.com/data")
            response = await response.json()
            with open("output.json", 'w') as f:
                json.dump(${response}, f)
        except Exception as e:
            print("ALERT: Failed to fetch or write data")
        if counter > 5:
            print("LOG: High counter value: ${counter}")
            with open("output.json", 'r') as f:
                data = json.load(f)
        else:
            print("ALERT: Counter is too low: ${counter}")
        counter -= 2
        print("LOG: Final counter value: ${counter}")
        print("Test sequence completed")
        sys.exit(0)

if __name__ == '__main__':
    asyncio.run(main())
```