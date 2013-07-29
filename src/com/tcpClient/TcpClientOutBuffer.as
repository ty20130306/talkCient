package com.tcpClient
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class TcpClientOutBuffer
	{
		private var _buffer:Array;
		
		public function TcpClientOutBuffer()
		{
			_buffer	= new Array();
		}
		
		public function push(data:ByteArray):void
		{
			_buffer.push(data);
		}
		
		public function shift():ByteArray
		{
			if(_buffer.length > 0){
				return _buffer.shift();
			} else {
				var eb:ByteArray	= new ByteArray();
				eb.endian	= Endian.BIG_ENDIAN;
				
				return eb;
			}
		}
		
		public function get length():int
		{
			return _buffer.length;
		}
	}
}