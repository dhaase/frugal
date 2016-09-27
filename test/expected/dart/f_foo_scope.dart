// Autogenerated by Frugal Compiler (1.19.0)
// DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING

library valid.src.f_foo_scope;

import 'dart:async';

import 'package:thrift/thrift.dart' as thrift;
import 'package:frugal/frugal.dart' as frugal;

import 'package:valid/valid.dart' as t_valid;


const String delimiter = '.';

/// And this is a scope docstring.
class FooPublisher {
  frugal.FScopeTransport fTransport;
  frugal.FProtocol fProtocol;
  Map<String, frugal.FMethod> _methods;
  frugal.Lock _writeLock;

  FooPublisher(frugal.FScopeProvider provider, [List<frugal.Middleware> middleware]) {
    fTransport = provider.fTransportFactory.getTransport();
    fProtocol = provider.fProtocolFactory.getProtocol(fTransport);
    _writeLock = new frugal.Lock();
    this._methods = {};
    this._methods['Foo'] = new frugal.FMethod(this._publishFoo, 'Foo', 'publishFoo', middleware);
    this._methods['Bar'] = new frugal.FMethod(this._publishBar, 'Foo', 'publishBar', middleware);
  }

  Future open() {
    return fTransport.open();
  }

  Future close() {
    return fTransport.close();
  }

  /// This is an operation docstring.
  Future publishFoo(frugal.FContext ctx, String baz, t_valid.Thing req) {
    return this._methods['Foo']([ctx, baz, req]);
  }

  Future _publishFoo(frugal.FContext ctx, String baz, t_valid.Thing req) async {
    await _writeLock.lock();
    try {
      var op = "Foo";
      var prefix = "foo.bar.${baz}.qux.";
      var topic = "${prefix}Foo${delimiter}${op}";
      fTransport.setTopic(topic);
      var oprot = fProtocol;
      var msg = new thrift.TMessage(op, thrift.TMessageType.CALL, 0);
      oprot.writeRequestHeader(ctx);
      oprot.writeMessageBegin(msg);
      req.write(oprot);
      oprot.writeMessageEnd();
      await oprot.transport.flush();
    } finally {
      _writeLock.unlock();
    }
  }


  Future publishBar(frugal.FContext ctx, String baz, t_valid.Stuff req) {
    return this._methods['Bar']([ctx, baz, req]);
  }

  Future _publishBar(frugal.FContext ctx, String baz, t_valid.Stuff req) async {
    await _writeLock.lock();
    try {
      var op = "Bar";
      var prefix = "foo.bar.${baz}.qux.";
      var topic = "${prefix}Foo${delimiter}${op}";
      fTransport.setTopic(topic);
      var oprot = fProtocol;
      var msg = new thrift.TMessage(op, thrift.TMessageType.CALL, 0);
      oprot.writeRequestHeader(ctx);
      oprot.writeMessageBegin(msg);
      req.write(oprot);
      oprot.writeMessageEnd();
      await oprot.transport.flush();
    } finally {
      _writeLock.unlock();
    }
  }
}


/// And this is a scope docstring.
class FooSubscriber {
  final frugal.FScopeProvider provider;
  final List<frugal.Middleware> _middleware;

  FooSubscriber(this.provider, [this._middleware]) {}

  /// This is an operation docstring.
  Future<frugal.FSubscription> subscribeFoo(String baz, dynamic onThing(frugal.FContext ctx, t_valid.Thing req)) async {
    var op = "Foo";
    var prefix = "foo.bar.${baz}.qux.";
    var topic = "${prefix}Foo${delimiter}${op}";
    var transport = provider.fTransportFactory.getTransport();
    await transport.subscribe(topic, _recvFoo(op, provider.fProtocolFactory, onThing));
    return new frugal.FSubscription(topic, transport);
  }

  _recvFoo(String op, frugal.FProtocolFactory protocolFactory, dynamic onThing(frugal.FContext ctx, t_valid.Thing req)) {
    frugal.FMethod method = new frugal.FMethod(onThing, 'Foo', 'subscribeThing', this._middleware);
    callbackFoo(thrift.TTransport transport) {
      var iprot = protocolFactory.getProtocol(transport);
      var ctx = iprot.readRequestHeader();
      var tMsg = iprot.readMessageBegin();
      if (tMsg.name != op) {
        thrift.TProtocolUtil.skip(iprot, thrift.TType.STRUCT);
        iprot.readMessageEnd();
        throw new thrift.TApplicationError(
        thrift.TApplicationErrorType.UNKNOWN_METHOD, tMsg.name);
      }
      var req = new t_valid.Thing();
      req.read(iprot);
      iprot.readMessageEnd();
      method([ctx, req]);
    }
    return callbackFoo;
  }


  Future<frugal.FSubscription> subscribeBar(String baz, dynamic onStuff(frugal.FContext ctx, t_valid.Stuff req)) async {
    var op = "Bar";
    var prefix = "foo.bar.${baz}.qux.";
    var topic = "${prefix}Foo${delimiter}${op}";
    var transport = provider.fTransportFactory.getTransport();
    await transport.subscribe(topic, _recvBar(op, provider.fProtocolFactory, onStuff));
    return new frugal.FSubscription(topic, transport);
  }

  _recvBar(String op, frugal.FProtocolFactory protocolFactory, dynamic onStuff(frugal.FContext ctx, t_valid.Stuff req)) {
    frugal.FMethod method = new frugal.FMethod(onStuff, 'Foo', 'subscribeStuff', this._middleware);
    callbackBar(thrift.TTransport transport) {
      var iprot = protocolFactory.getProtocol(transport);
      var ctx = iprot.readRequestHeader();
      var tMsg = iprot.readMessageBegin();
      if (tMsg.name != op) {
        thrift.TProtocolUtil.skip(iprot, thrift.TType.STRUCT);
        iprot.readMessageEnd();
        throw new thrift.TApplicationError(
        thrift.TApplicationErrorType.UNKNOWN_METHOD, tMsg.name);
      }
      var req = new t_valid.Stuff();
      req.read(iprot);
      iprot.readMessageEnd();
      method([ctx, req]);
    }
    return callbackBar;
  }
}

