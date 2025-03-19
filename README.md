# compiler

## Run 

```bash
bash run.sh
```

Expeted output:

```
Program:
  Task(Notify("Send email to team"))
  If("sales > 1000")
    Task(Log("Record high sales"))
  Else
    Task(Alert("Low sales detected"))
```