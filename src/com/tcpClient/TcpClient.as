package com.tcpClient
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;

	public class TcpClient extends EventDispatcher
	{
		public static const DEFAULT_RECONNECT_INTERVAL:int	= 5000; //单位毫秒
		
		private var _host:String;
		private var _port:int;
		
		/**
		 * 重连间隔，单位为毫秒，0表不自动重连 
		 */		
		private var _reconnectInterval:int;
		
		private var _socket:Socket;
		
		/**
		 * 标识是否手动关闭链接
		 * 手动关闭链接，即使设置了重新连接参数也不会重连 
		 */		
		private var _manualClose:Boolean;
		
		private var _connectTimer:Timer;
		private var _connected:Boolean;
		
		private var _outBuffer:TcpClientOutBuffer;
		private var _inBuffer:TcpClientInBuffer;
		
		public function TcpClient(host:String, port:int, reconnectInterval:int = -1)
		{
			_host	= host;
			_port	= port;
			_reconnectInterval	= reconnectInterval == -1 ? DEFAULT_RECONNECT_INTERVAL : reconnectInterval;
			
			_manualClose	= false;
			_connectTimer	= null;
			_connected		= false;
			
			_inBuffer		= new TcpClientInBuffer();
			_outBuffer		= new TcpClientOutBuffer();
			
			initSocket();
		}
		
		public function get inBuffer():TcpClientInBuffer
		{
			return _inBuffer;
		}

		private function initSocket():void
		{
			_socket	= new Socket();
			_socket.endian	= Endian.BIG_ENDIAN;
			
			_socket.addEventListener(Event.CLOSE, onClose);
			_socket.addEventListener(Event.CONNECT, onConnect);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
		}
		
		private function tryReconnectIfNeed():void
		{
			if( ! _manualClose && _reconnectInterval != 0 ){
				if(_connectTimer == null){
					_connectTimer	= new Timer(_reconnectInterval);
					_connectTimer.addEventListener(TimerEvent.TIMER, onConnectTimer);
				}
				
				_connectTimer.start();
			}
		}
		
		protected function onConnectTimer(event:TimerEvent):void
		{
			// TODO Auto-generated method stub
			connect();
		}
		
		public function connect():void
		{
			// TODO Auto Generated method stub
			
			_manualClose	= false;
			Security.loadPolicyFile("xmlsocket://" + _host + ":" + 843);
			_socket.connect(_host, _port);
		}
		
		public function send(data:ByteArray):void
		{
			if(_connected){
				write(data);
			} else {
				_outBuffer.push(data);
			}
		}
		
		public function close():void
		{
			_manualClose	= true;
			_socket.close();
		}
		
		protected function onSocketData(event:ProgressEvent):void
		{
			trace("onSocketData,available="+_socket.bytesAvailable.toString());
			// TODO Auto-generated method stub
			if(_socket.bytesAvailable > 0){
				var data:ByteArray	= new ByteArray();
				_socket.readBytes(data);
				_inBuffer.write(data);
				dispatchEvent(new TcpClientEvent(TcpClientEvent.DATA));
			}
		}
		
		protected function onError(event:IOErrorEvent):void
		{
			// TODO Auto-generated method stub
			_connected	= false;
			tryReconnectIfNeed();
			dispatchEvent(new TcpClientEvent(TcpClientEvent.ERROR));
		}
		
		protected function onConnect(event:Event):void
		{
			// TODO Auto-generated method stub
			_connected	= true;
			stopReconnectIfNeed();
			flushOutBuffer();
			
			dispatchEvent(new TcpClientEvent(TcpClientEvent.CONNECT));
		}
		
		private function flushOutBuffer():void
		{
			// TODO Auto Generated method stub
			while(_outBuffer.length > 0){
				write(_outBuffer.shift());
			}
		}
		
		private function write(data:ByteArray):void
		{
			trace("TcpClient write");
			// TODO Auto Generated method stub
			_socket.writeBytes(data);
			_socket.flush();
		}
		
		private function stopReconnectIfNeed():void
		{
			// TODO Auto Generated method stub
			if(_connectTimer != null){
				_connectTimer.stop();
			}
		}
		
		protected function onClose(event:Event):void
		{
			// TODO Auto-generated method stub
			_connected	= false;
			tryReconnectIfNeed();
			dispatchEvent(new TcpClientEvent(TcpClientEvent.CLOSE));
		}
		
		public function dispose():void
		{
			if(_connectTimer != null){
				_connectTimer.stop();
				_connectTimer.removeEventListener(TimerEvent.TIMER, onConnectTimer);
				_connectTimer	= null;
			}
			
			_socket.close();
			_socket.removeEventListener(Event.CLOSE, onClose);
			_socket.removeEventListener(Event.CONNECT, onConnect);
			_socket.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			_socket.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			_socket	= null;
		}
	}
}
