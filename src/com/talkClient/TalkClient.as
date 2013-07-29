package com.talkClient
{
	import com.tcpClient.TcpClient;
	import com.vasClient.VasClient;
	import com.vasClient.VasClientEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	public class TalkClient extends EventDispatcher
	{
		public static const CMD_TYPE_BYTE_NUM:int		= 1;
		public static const RET_BYTE_NUM:int			= 1;
		public static const CONTENT_LEN_BYTE_NUM:int	= 4;
		
		public static const ENCODING:String		= 'utf-8';
		public static const HEARTBEAT_DELAY:int	= 5000; // 单位毫秒
		public static const RET_SUCC:int		= 0;
		
		private var _vasClient:VasClient;
		private var _heartbeatTimer:Timer;
		
		public function TalkClient(host:String, port:int, reconnectInterval:int = -1)
		{
			reconnectInterval = (reconnectInterval == -1) ? HEARTBEAT_DELAY : reconnectInterval;
			_vasClient	= new VasClient(host, port, reconnectInterval);
			_vasClient.addEventListener(VasClientEvent.CONNECT, onConnect);
			_vasClient.addEventListener(VasClientEvent.DATA, onVasData);
			
			_heartbeatTimer	= new Timer(reconnectInterval);
			_heartbeatTimer.addEventListener(TimerEvent.TIMER, onHeartbeatTimer);
		}
		
		protected function onHeartbeatTimer(event:TimerEvent):void
		{
			sendTalkCmd(TalkClientCmd.TYPE_HEARTBEAT);
		}
		
		public function connect():void
		{
			_vasClient.connect();
		}
		
		public function sendRaw(data:ByteArray):void
		{
			_vasClient.sendRaw(data);
		}
		
		public function login(id:String, name:String, icon:String):void
		{
			var content:ByteArray	= new ByteArray();
			var nameByte:ByteArray = new ByteArray();
			
			content.writeByte(id.length);
			content.writeMultiByte(id, ENCODING);
			nameByte.writeMultiByte(name, ENCODING);
			content.writeByte(nameByte.length);
			content.writeMultiByte(name, ENCODING);
			content.writeByte(icon.length);
			content.writeMultiByte(icon, ENCODING);
			
			sendTalkCmd(TalkClientCmd.TYPE_LOGIN, content);
		}
		
		private function sendTalkCmd(type:int, content:ByteArray = null):void
		{
			trace("sendTalkCmd,type=" + type.toString());
			// TODO Auto Generated method stub
			var data:ByteArray	= new ByteArray();
			
			data.writeByte(type);
			if(content == null){
				data.writeInt(0);
			} else {
				data.writeInt(content.length);
				data.writeBytes(content);
			}
			
			_vasClient.send(data);
		}
		
		public function logout():void
		{
			sendTalkCmd(TalkClientCmd.TYPE_LOGOUT);
		}
		
		public function multicast(msg:String):void
		{
			var content:ByteArray	= new ByteArray();
			content.writeMultiByte(msg, ENCODING);
			sendTalkCmd(TalkClientCmd.TYPE_MULTICAST, content);
		}
		
		public function broadcast(msg:String):void
		{
			var content:ByteArray	= new ByteArray();
			content.writeMultiByte(msg, ENCODING);
			sendTalkCmd(TalkClientCmd.TYPE_BROADCAST, content);
		}
		
		
		public function enterRoom(roomId:int):void
		{
			var content:ByteArray	= new ByteArray();
			content.writeShort(roomId);
			sendTalkCmd(TalkClientCmd.TYPE_ENTER_ROOM, content);
		}
		
		public function quitRoom():void
		{
			sendTalkCmd(TalkClientCmd.TYPE_QUIT_ROOM);
		}
		
		public function getRoomUser(roomId:int):void
		{
			var content:ByteArray	= new ByteArray();
			content.writeShort(roomId);
			sendTalkCmd(TalkClientCmd.TYPE_GET_ROOM_USER, content);
		}
		
		public function getOnlineUser():void
		{
			sendTalkCmd(TalkClientCmd.TYPE_GET_ONLINE_USER);
		}
		
		private function onConnect(event:VasClientEvent):void
		{
			_heartbeatTimer.start();
			dispatchEvent(new TalkClientEvent(TalkClientEvent.CONNECT));
		}
		
		private function onVasData(event:VasClientEvent):void
		{
			trace("onVasData");
			var cmd:TalkClientCmd	= decode(event.data);
			dispatchEvent(new TalkClientEvent(TalkClientEvent.CMD, cmd));
		}
		
		private function decode(data:ByteArray):TalkClientCmd
		{
			if(data.length < CMD_TYPE_BYTE_NUM + RET_BYTE_NUM + CONTENT_LEN_BYTE_NUM){
				dispatchEvent(new TalkClientEvent(TalkClientEvent.CORRUPT));
				return null;
			}
			var type:int	= data.readByte();
			var ret:int		= data.readByte();

			var contentLen:int	= data.readInt();
			if(data.length < CMD_TYPE_BYTE_NUM + RET_BYTE_NUM + CONTENT_LEN_BYTE_NUM + contentLen){
				dispatchEvent(new TalkClientEvent(TalkClientEvent.CORRUPT));
				return null;
			}
			
			var content:ByteArray	= new ByteArray();
			data.readBytes(content, 0, contentLen);
			
			var cmd:TalkClientCmd	= new TalkClientCmd(type, ret, content);
			
			trace("recv cmd, type="+type.toString());
			return cmd;
		}
		
		public function dispose():void
		{
			_heartbeatTimer.stop();
			_heartbeatTimer	= null;
			
			_vasClient.dispose();
		}
	}
}