/**
 * Autogenerated by Frugal Compiler (0.0.1)
 * DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
 */



import com.workiva.frugal.Provider;
import com.workiva.frugal.Transport;
import com.workiva.frugal.TransportFactory;
import com.workiva.frugal.Subscription;
import org.apache.thrift.TException;
import org.apache.thrift.protocol.*;
import org.apache.thrift.TApplicationException;

import org.apache.thrift.transport.TTransportException;

import org.apache.thrift.transport.TTransportFactory;

import javax.annotation.Generated;



@Generated(value = "Autogenerated by Frugal Compiler (0.0.1)", date = "2015-10-2")
public class EventsSubscriber {

	private static final String delimiter = ".";

	private final Provider provider;

	public EventsSubscriber(Provider provider) {
		this.provider = provider;
	}

	public interface EventCreatedHandler {
		void onEventCreated(Event req);
	}

	public Subscription subscribeEventCreated(String user, final EventCreatedHandler handler) throws TException {
		final String op = "EventCreated";
		String prefix = String.format("foo.%s.", user);
		String topic = String.format("%sEvents%s%s", prefix, delimiter, op);
		final Provider.Client client = provider.build();
		Transport transport = client.getTransport();
		transport.subscribe(topic);

		final Subscription sub = new Subscription(topic, transport);
		new Thread(new Runnable() {
			public void run() {
				while (true) {
					try {
						Event received = recvEventCreated(op, client.getProtocol());
						handler.onEventCreated(received);
					} catch (TException e) {
						if (e instanceof TTransportException) {
							TTransportException transportException = (TTransportException) e;
							if (transportException.getType() == TTransportException.END_OF_FILE) {
								return;
							}
						}
						e.printStackTrace();
						sub.signal(e);
						try {
							sub.unsubscribe();
						} catch (TTransportException e1) {
							e1.printStackTrace();
						}
					}
				}
			}
		}).start();

		return sub;
	}

	private Event recvEventCreated(String op, TProtocol iprot) throws TException {
		TMessage msg = iprot.readMessageBegin();
		if (!msg.name.equals(op)) {
			TProtocolUtil.skip(iprot, TType.STRUCT);
			iprot.readMessageEnd();
			throw new TApplicationException(TApplicationException.UNKNOWN_METHOD);
		}
		Event req = new Event();
		req.read(iprot);
		iprot.readMessageEnd();
		return req;
	}
}