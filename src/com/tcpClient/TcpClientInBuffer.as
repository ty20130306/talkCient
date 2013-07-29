package com.tcpClient
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class TcpClientInBuffer
	{
		public static const MAX_BUFFER_LEN:int	= 268435456; // 256K
		
		private var _buffer:ByteArray;
		private var _start:int;
		private var _end:int;
		
		public function TcpClientInBuffer()
		{
			_buffer	= new ByteArray();
			_buffer.endian	= Endian.BIG_ENDIAN;
			
			_start	= 0;
			_end	= 0;
		}

		public function peek():ByteArray
		{
			var data:ByteArray	= new ByteArray();
			data.endian			= Endian.BIG_ENDIAN;
			
			if(length == 0){
				return data;
			}
			
			if(_start < _end){
				data.writeBytes(_buffer, _start, length);
			} else {
				data.writeBytes(_buffer, _start, MAX_BUFFER_LEN - _start);
				data.writeBytes(_buffer, 0, length - (MAX_BUFFER_LEN - _start));
			}
			
			return data;
		}
		
		public function write(value:ByteArray):void
		{
			if(MAX_BUFFER_LEN - _end >= value.length){
				_buffer.position	= _end;
				_buffer.writeBytes(value);
				_end	= (_end + value.length) % MAX_BUFFER_LEN;
			} else {
				_buffer.position	= _end;
				_buffer.writeBytes(value, 0, MAX_BUFFER_LEN - _end);
				
				var offset:int		= MAX_BUFFER_LEN - _end;
				_buffer.position	= 0;
				_buffer.writeBytes(value, offset);
				
				_end	= offset;
			}
		}
		
		public function read(len:int):ByteArray
		{
			var data:ByteArray	= new ByteArray();
			data.endian			= Endian.BIG_ENDIAN;
			
			len	= len < this.length ? len : this.length;
			if(len == 0){
				return data;
			}
			
			if(_start < _end){
				data.writeBytes(_buffer, _start, len);
				_start	= _start + len;
			} else {
				data.writeBytes(_buffer, _start, MAX_BUFFER_LEN - _start);
				data.writeBytes(_buffer, 0, len - (MAX_BUFFER_LEN - _start));
				_start	= len - (MAX_BUFFER_LEN - _start);
			}
			
			return data;
		}
		
		public function get length():int
		{
			if(_end >= _start){
				return _end - _start;
			} else {
				return _end + MAX_BUFFER_LEN - _start;
			}
		}
	}
}