module utils.io;

import std.stdio;
import std.bitmanip;
import std.file;

class BinaryReader
{
	ubyte[] _data;
	private int currentPos;

	bool littleEndian = true;

	this(ubyte[] data, int offset = 0)
	 {

		_data = data.dup;
		currentPos = offset;
	}

	ubyte readByte()
	 {
		ubyte value =  _data[currentPos];
		currentPos++;
		return value;
	}

	ubyte[] readBytes(ushort len)
	 {
		ubyte[] value = new ubyte[len];
		for(int i  =0; i < len; i++)
		{
			value[i] = readByte();
		}
		//_data = _data[len..$];
		return value;
	}

	int readInt()
	{
		ubyte[4] data = readBytes(4);
        if(littleEndian)
    		return *cast(int*)data;
		else
	    	return bigEndianToNative!int(data);
	}

	uint readUInt()
	 {
		ubyte[4] data = readBytes(4);
        if(littleEndian)
    		return *cast(uint*)data;
		else
	    	return bigEndianToNative!uint(data);
	}

	short readShort()
	 {
		ubyte[2] data = readBytes(2);

        if(littleEndian)
    		return *cast(short*)data;
		else
	    	return bigEndianToNative!short(data);
	}

	ushort readUShort()
	 {
		ubyte[2] data = readBytes(2);
        if(littleEndian)
    		return *cast(ushort*)data;
		else
	    	return bigEndianToNative!ushort(data);
	}

	double readDouble()
	{
		ubyte[8] data = readBytes(8);
        if(littleEndian)
    		return *cast(double*)data;
		else
	    	return bigEndianToNative!double(data);
	}

    int read7bitEncodedInt()
    {
        int num1 = 0;
        int num2 = 0;
        while (num2 != 35)
        {
          byte num3 = readByte();
          num1 |= (cast(int) num3 & cast(int) byte.max) << num2;
          num2 += 7;
          if ((cast(int) num3 & 128) == 0)
            return num1;
        }
        throw new Exception("unknown");
    }

	string readString()
	{
		int size = read7bitEncodedInt();
		if(size == 0) return "";
		ubyte[] data = readBytes(cast(ushort) size);
		return cast(string) cast(char[]) data;
	}

	char[] readUTFBytes(ushort size)
	{
		ubyte[] data = readBytes(size);
		char[] string = cast(char[])data;
		return string;
	}

	bool readBool()
	{
		bool value = true;
		if(readByte() == 0) return false;
		return value;
	}

	ubyte[] getData()
	{
		return _data;
	}

	void seek(int pos)
	{
		currentPos = pos;
	}

	ushort bytesAvailable()
	{
		return cast(ushort)(this._data.length - currentPos);
	}
}

// todo: do like BinaryReader about the endianess
class BinaryWriter
{
	ubyte[] _data;
	uint _index;

	this()
	{

	}

	void writeByte(ubyte data)
	 {
		_data ~= data;
	}

	void writeBytes(ubyte[] data)
	{
		_data ~= data;
	}

	void writeInt(int data)
	 {
		ubyte[4] value = nativeToBigEndian(data);
		writeBytes(value);
	}

	void writeUInt(uint data)
	 {
		ubyte[4] value = nativeToBigEndian(data);
		writeBytes(value);
	}

	void writeShort(short data)
	 {
		ubyte[2] value = nativeToBigEndian(data);
		writeBytes(value);
	}

	void writeUShort(ushort data)
	 {
		ubyte[2] value = nativeToBigEndian(data);
		writeBytes(value);
	}

	void writeDouble(double data)
	{
		ubyte[8] value = nativeToBigEndian(data);
		writeBytes(value);
	}

	void writeUTF(char[] data)
	{
		ushort size = cast(ushort)data.length;
		ubyte[] string = cast(ubyte[])data;
		writeUShort(size);
		writeBytes(string);
	}

	void writeUTFBytes(char[] data)
	 {
		ubyte[] string = cast(ubyte[])data;
		writeBytes(string);
	}

	void writeBool(bool data)
	{
		if(data) writeByte(1);
		if(!data) writeByte(0);
	}

	ubyte[] getData()
	{
		return _data;
	}
}


ubyte[] readFile(string path)
{
    auto data = cast(ubyte[]) std.file.read(path);
    return data;
}

bool isFileExist(string path)
{
    return exists(path);
}