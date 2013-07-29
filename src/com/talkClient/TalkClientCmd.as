package com.talkClient
{
	import flash.utils.ByteArray;

	public class TalkClientCmd
	{
		public static const TYPE_LOGIN:int			= 0x01;
		public static const TYPE_LOGOUT:int			= 0x02;
		public static const TYPE_HEARTBEAT:int		= 0x03;
		
		public static const TYPE_MULTICAST:int		= 0x04;
		public static const TYPE_BROADCAST:int		= 0x05;
		
		public static const TYPE_ENTER_ROOM:int		= 0x06;
		public static const TYPE_QUIT_ROOM:int		= 0x07;
		
		public static const TYPE_GET_ROOM_USER:int	= 0x08;
		public static const TYPE_GET_ONLINE_USER:int= 0x09;
		
		private var _type:int;
		private var _ret:int;
		private var _content:ByteArray;
		
		private var _userList:Vector.<TalkClientUser>;
		private var _msg:String;
		private var _roomId:int;
		
		public function TalkClientCmd(type:int, ret:int, content:ByteArray = null)
		{
			_type		= type;
			_ret		= ret;
			_content	= content;
			
			_userList	= new Vector.<TalkClientUser>();
			_msg		= "";
			_roomId		= -1;
			
			parseContent();
		}
		
		private function parseContent():void
		{
			if(_content == null){
				return;
			}
			
			// TODO Auto Generated method stub
			switch(_type){
				case TYPE_MULTICAST:
				case TYPE_BROADCAST:
					_msg	= _content.readMultiByte(_content.length, TalkClient.ENCODING);
					break;
				
				case TYPE_GET_ONLINE_USER:
					parseUserList(_content);
					break;
				
				case TYPE_GET_ROOM_USER:
					_roomId	= _content.readUnsignedShort();
					var userListData:ByteArray	= new ByteArray();
					_content.readBytes(userListData, 0);
					parseUserList(userListData);
					break;
				
				case TYPE_ENTER_ROOM:
					_roomId	= _content.readUnsignedShort();
					break;
			}
		}
		
		private function parseUserList(userListData:ByteArray):void
		{
			// TODO Auto Generated method stub
			var userNum:int	= userListData.readUnsignedShort();
			var len:int;
			
			for(var i:int = 0; i < userNum; ++i){
				// 获取id
				len		= userListData.readUnsignedByte();
				var id:String	= userListData.readMultiByte(len, TalkClient.ENCODING);

				// 获取name
				len		= userListData.readUnsignedByte();
				var name:String	= userListData.readMultiByte(len, TalkClient.ENCODING);
				
				// 获取icon
				len		= userListData.readUnsignedByte();
				var icon:String	= userListData.readMultiByte(len, TalkClient.ENCODING);

				var user:TalkClientUser	= new TalkClientUser(id, name, icon);
				_userList.push(user);
			}
		}
		
		public function get msg():String
		{
			return _msg;
		}

		public function set msg(value:String):void
		{
			_msg = value;
		}

		public function get userList():Vector.<TalkClientUser>
		{
			return _userList;
		}

		public function set userList(value:Vector.<TalkClientUser>):void
		{
			_userList = value;
		}

		public function get ret():int
		{
			return _ret;
		}

		public function get content():ByteArray
		{
			return _content;
		}
		
		public function get type():int
		{
			return _type;
		}
	}
}