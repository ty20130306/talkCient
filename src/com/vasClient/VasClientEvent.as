package com.vasClient
{
	import flash.events.Event;
	import flash.utils.ByteArray;

	public class VasClientEvent extends Event
	{
		public static const CONNECT:String	= "com.talk.VasClientEvent::CONNECT";
		public static const DATA:String		= "com.talk.VasClientEvent::DATA";
		public static const CORRUPT:String	= "com.talk.VasClientEvent::CORRUPT";
		
		private var _data:ByteArray;
		
		public function VasClientEvent(type:String, vasData:ByteArray = null)
		{
			super(type);
			
			_data	= vasData;
		}

		public function get data():ByteArray
		{
			return _data;
		}

	}
}