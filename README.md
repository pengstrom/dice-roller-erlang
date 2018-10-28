# Dice Roller

An OTP application.

Start the server
```
$ rebar3 shell
```
and then post some dice specs
```
$ curl -d "3d12+d6+5" -X POST http://localhost:2938
1: 10
$ curl -d "3d12+d6+5" -X POST http://localhost:2938
2: 21
```

## Build
```
$ rebar3 compile
```

# Test
```
$ rebar3 proper
```
