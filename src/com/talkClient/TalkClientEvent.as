package com.talkClient
{
	
	import flash.events.Event;

	public class TalkClientEvent extends Event
	{
		public static const CONNECT:String		= "com.talk.TalkClientEvent::CONNECT";
		public static const CORRUPT:String		= "com.talk.TalkClientEvent::CORRUPT";
		public static const CMD:String			= "com.talk.TalkClientEvent::CMD";
		
		private var _cmd:TalkClientCmd;
		
		public function TalkClientEvent(type:String, cmd:TalkClientCmd = null)
		{
			super(type);
			
			_cmd	= cmd;
		}

		public function get cmd():TalkClientCmd
		{
			return _cmd;
		}
	}
}