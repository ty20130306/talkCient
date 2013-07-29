package com.talkClient
{
	public class TalkClientUser
	{
		private var _id:String;
		private var _name:String;
		private var _icon:String;
		
		public function TalkClientUser(userId:String, userName:String, userIcon:String)
		{
			_id		= userId;
			_name	= userName;
			_icon	= userIcon;
		}

		public function get icon():String
		{
			return _icon;
		}

		public function get name():String
		{
			return _name;
		}

		public function get id():String
		{
			return _id;
		}

	}
}