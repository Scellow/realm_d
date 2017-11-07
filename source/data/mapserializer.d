module data.mapserializer;

import std.stdio;
import std.zlib;
import std.conv;
import std.format;

import utils.io;

struct ParsedTile
{
    public int type;
    public string objId;
    public string objData;
    public float elevation;
    public float moisture;

    // public int mapType // this will be used to define the right enums for the terrain

    public byte region;
    public byte terrain;
}

struct ParsedMap
{
    public int width;
    public int height;
    public ParsedTile[][] tiles;
}

class MapSerializer
{
    public static ParsedMap deserialize(string path)
    {
        if(!isFileExist(path)) throw new Exception("File not found: ", path);

        auto buffer = readFile(path);
        auto reader = new BinaryReader(buffer);
        int v = reader.readByte();

        ubyte[] compressedBuffer = buffer[1 .. buffer.length];
        ubyte[] decompressedBuffer = cast(ubyte[]) uncompress(compressedBuffer);

        ParsedMap ret;

        switch(v)
        {
            case 2:
                handle_v2(&ret, decompressedBuffer);
            break;

            default:
                throw new Exception(format("Unhandled version: %a", v));
        }

        return ret;
    }

    public static void handle_v2(ParsedMap* map, ubyte[] buffer)
    {
        auto reader = new BinaryReader(buffer);

        ParsedTile[] dict;

        short c = reader.readShort();

        for(int i = 0; i < c; i++)
        {
            auto tile = ParsedTile();
            tile.type = reader.readShort();
            tile.objId = reader.readString();
            tile.objData = reader.readString();
            tile.terrain = reader.readByte();
            tile.region = reader.readByte();
            dict ~= tile;
        }

        int width = reader.readInt();
        int height = reader.readInt();

        map.width = width;
        map.height = height;
        map.tiles = new ParsedTile[][](width, height);
        for (int y = 0; y < height; y++)
        for (int x = 0; x < width; x++)
        {
            ParsedTile tile = dict[reader.readShort()];
            tile.elevation = reader.readByte();

            ParsedTile t;
            t.type = tile.type;
            t.objId = tile.objId;
            t.objData = tile.objData;
            t.elevation = tile.elevation;
            t.moisture = 0;
            t.region = tile.region;
            t.terrain = tile.terrain;
            map.tiles[x][y] = t;
        }
    }
}