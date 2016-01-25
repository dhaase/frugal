# Frugal

Frugal is an extension of [Apache Thrift](https://thrift.apache.org/) which
provides additional functionality. Specifically, it includes support for
request headers, request multiplexing, thread safety, and code-generated
pub/sub APIs. Frugal is intended to act as a superset of Thrift, meaning it
implements the same functionality as Thrift with some additional
features.

Currently supported languages are Go, Java, and Dart.

## Installation

```
$ go get github.com/Workiva/frugal
```

If you don't have a Go environment setup or don't want to install Thrift you
can use Docker. [Check the bottom of the Readme](#docker) for more info.

## Usage

Define your Frugal file which contains your pub/sub interface, or *scopes*, and
Thrift definitions.

```thrift
# event.frugal

// Anything allowed in a .thrift file is allowed in a .frugal file.
struct Event {
    1: i64 ID,
    2: string Message
}

// Scopes are a Frugal extension for pub/sub APIs.
scope Events {
    EventCreated: Event
}
```

Generate the code with `frugal`. Currently, only Go, Java, and Dart are
supported.

```
$ frugal -gen=go event.frugal
```

By default, generated code is placed in a `gen-*` directory. This code can then
be used as such:

```go
// publisher.go
func main() {
    conn, err := nats.Connect(nats.DefaultURL)
    if err != nil {
        panic(err)
    }

    var (
        protocolFactory  = frugal.NewFProtocolFactory(thrift.NewTBinaryProtocolFactoryDefault())
        transportFactory = frugal.NewFNatsScopeTransportFactory(conn)
        provider         = frugal.NewFScopeProvider(transportFactory, protocolFactory)
        publisher        = event.NewEventsPublisher(provider)
    )
    publisher.Open()
    defer publisher.Close()

    event := &event.Event{ID: 42, Message: "Hello, World!"}
    if err := publisher.PublishEventCreated(frugal.NewFContext(""), event); err != nil {
        panic(err)
    }
}
```

```go
// subscriber.go
func main() {
    conn, err := nats.Connect(nats.DefaultURL)
    if err != nil {
        panic(err)
    }

    var (
        protocolFactory  = frugal.NewFProtocolFactory(thrift.NewTBinaryProtocolFactoryDefault())
        transportFactory = frugal.NewFNatsScopeTransportFactory(conn)
        provider         = frugal.NewFScopeProvider(transportFactory, protocolFactory)
        subscriber       = event.NewEventsSubscriber(provider)
    )

    _, err = subscriber.SubscribeEventCreated(func(ctx *frugal.FContext, e *event.Event) {
        fmt.Println("Received event:", e.Message)
    })
    if err != nil {
        panic(err)
    }

    wait := make(chan bool)
    log.Println("Subscriber started...")
    <-wait
}
```

### Prefixes

By default, Frugal publishes messages on the topic `<scope>.<operation>`. For
example, the `EventCreated` operation in the following Frugal definition would
be published on `Events.EventCreated`:

```thrift
scope Events {
    EventCreated: Event
}
```

Custom topic prefixes can be defined on a per-scope basis:

```thrift
scope Events {
    prefix "foo.bar"
    
    EventCreated: Event
}
```

As a result, `EventCreated` would be published on `foo.bar.Events.EventCreated`.

Prefixes can also define variables which are provided at publish and subscribe
time:

```thrift
scope Events {
    prefix "foo.{user}"
    
    EventCreated: Event
}
```

This variable is then passed to publish and subscribe calls:

```go
var (
    event = &event.Event{ID: 42, Message: "hello, world!"}
    user  = "bill"
)
publisher.PublishEventCreated(frugal.NewFContext(""), event, user)

subscriber.SubscribeEventCreated(user, func(ctx *frugal.FContext, e *event.Event) {
    fmt.Printf("Received event for %s: %s\n", user, e.Message)
})
```

### Generated Comments

In Thrift, comments of the form `/** ... */` are included in generated code. In
Frugal, to include comments in generated code, they should be of the form `/**@
... */`.

```thrift
/**@
 * This comment is included in the generated code because
 * it has the @ sign.
 */
struct Foo {}

/**@ This comment is included too. */
service FooService {
    /** This comment isn't included because it doesn't have the @ sign. */
    Foo getFoo()
}
```

## Thrift Parity

Frugal is intended to be a superset of Thrift, meaning valid Thrift should be
valid Frugal. However, there are known Thrift features which are not currently
supported in Frugal, namely annotations. File an issue if you discover an
inconsistency with the IDL.

## Docker

### Via Shipyard

Grab the frugal Docker image id for the image you would like to use from
[Shipyard](https://shipyard.workiva.org/repo/Workiva/frugal).

Switch to the directory that has the files you would like to generate.

Then run the docker image. This command will mount your local directory into
the image. It supports all of the standard Frugal commands.

```
docker run -v "$(pwd):/data" drydock.workiva.org/workiva/frugal:{SHIPYARD_ID} frugal -gen={LANG} {FILE_TO_GEN}
```

An example to generate the Go code off the event.frugal definition in the
example directory.

```
$ cd example
$ docker run -v "$(pwd):/data" drydock.workiva.org/workiva/frugal:17352 frugal -gen=go event.frugal
```

