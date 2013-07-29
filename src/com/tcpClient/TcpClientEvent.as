package com.tcpClient
{
	import flash.events.Event;
	import flash.utils.ByteArray;

	public class TcpClientEvent extends Event
	{
		public static const DATA:String		= "com.talk.TcpClientEvent::DATA";
		public static const CONNECT:String	= "com.talk.TcpClientEvent::CONNECT";
		public static const CLOSE:String	= "com.talk.TcpClientEvent::CLOSE";
		public static const ERROR:String	= "com.talk.TcpClientEvent::ERROR";
		
		public function TcpClientEvent(type:String)
		{
			super(type);
		}
	}
}