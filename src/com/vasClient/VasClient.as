package com.vasClient
{
	import com.tcpClient.TcpClient;
	import com.tcpClient.TcpClientEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class VasClient extends EventDispatcher
	{
		public static const VAS_HEAD:int	= 0xaa;
		public static const VAS_TAIL:int	= 0x7e;
		
		public static const HEAD_BYTE_NUM:int		= 1;
		public static const TAIL_BYTE_NUM:int		= 1;
		public static const LEN_BYTE_NUM:int		= 4;
		
		private var _tcpClient:TcpClient;
		private var _inBufferArr:Array;
		
		public function VasClient(host:String, port:int, reconnectInterval:int = -1)
		{
			reconnectInterval = (reconnectInterval == -1) ? TcpClient.DEFAULT_RECONNECT_INTERVAL : reconnectInterval;
			_tcpClient	= new TcpClient(host, port, reconnectInterval);
			_tcpClient.addEventListener(TcpClientEvent.DATA, onTcpData);
		}
		
		public function connect():void
		{
			_tcpClient.connect();
			_tcpClient.addEventListener(TcpClientEvent.CONNECT, onConnect);
		}
		
		protected function onConnect(event:Event):void
		{
			// TODO Auto-generated method stub
			dispatchEvent(new VasClientEvent(VasClientEvent.CONNECT));
		}
		
		public function send(vasData:ByteArray):void
		{
			trace("VasClient send");
			
			var data:ByteArray	= new ByteArray();
			data.endian			= Endian.BIG_ENDIAN;
			
			data.writeByte(VAS_HEAD);
			data.writeInt(HEAD_BYTE_NUM + LEN_BYTE_NUM + vasData.length + TAIL_BYTE_NUM);
			data.writeBytes(vasData);
			data.writeByte(VAS_TAIL);
			
			_tcpClient.send(data);
		}
		
		public function sendRaw(data:ByteArray):void
		{
			_tcpClient.send(data);
		}
		
		public function close():void
		{
			_tcpClient.close();
		}
		
		public function dispose():void
		{
			_tcpClient.dispose();
		}
		
		protected function onTcpData(event:TcpClientEvent):void
		{
			trace("onTcpData");
			// TODO Auto-generated method stub
			var i:int;
			var data:ByteArray;
			while(true){
				while(true){
					data =  _tcpClient.inBuffer.peek();
					for(i = 0; i < data.length; ++i){
						if(data[i] == VAS_HEAD){
							break;
						} else {
							_tcpClient.inBuffer.read(1); //垃圾数据，从buffer中读取掉
						}
					}
					
					if(data.length <= 0){
						break;	// 没有找到包头
					}
					if(data[0] == VAS_HEAD){
						break;
					}
				}
				
				if(data.length < HEAD_BYTE_NUM + LEN_BYTE_NUM){
					return;
				}
				
				data.position	= HEAD_BYTE_NUM;
				var len:uint	= data.readUnsignedInt();
				if(data.length < len){
					return ;
				}
				
				data	= _tcpClient.inBuffer.read(len);
				if(data[data.length - TAIL_BYTE_NUM] != VAS_TAIL){
					dispatchEvent(new VasClientEvent(VasClientEvent.CORRUPT));
					continue;
				}
				
				var vasData:ByteArray	= new ByteArray();
				vasData.endian	= Endian.BIG_ENDIAN;
				data.position	= HEAD_BYTE_NUM + LEN_BYTE_NUM;
				data.readBytes(vasData, 0, len - (HEAD_BYTE_NUM + LEN_BYTE_NUM + TAIL_BYTE_NUM));
				
				dispatchEvent(new VasClientEvent(VasClientEvent.DATA, vasData));
			}
		}
	}
}