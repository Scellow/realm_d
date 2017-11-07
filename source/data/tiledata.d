module data.tiledata;

import std.stdio;

class TileData
{
    public string id;
    public int type;
    public string description;

    public bool noWalk;
    public bool occupySquare;

    public bool isWater;
}