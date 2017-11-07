module game.map.tile;

import std.stdio;

import game.objects.gameobject;
import data.tiledata;

class Tile
{
    public int x;
    public int y;

    public TileData data;
    public int type = 0xff;

    public GameObject go;

    this(int x, int y)
    {
        this.x = x;
        this.y = y;
        setType(type);
    }

    public void setType(int type)
    {
        this.type = type;

        // todo: set data
    }

    public bool isWater()
    {
        return data.isWater;
    }

    public bool isPassable()
    {
        if (data.noWalk) return false;
        if (go !is null && (go.data.occupySquare || go.data.fullOccupy)) return false;
        return true;
    }
}

