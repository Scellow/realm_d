module game.map.tilemap;

import std.stdio;

import game.map.tile;

class TileMap
{
    public Tile[] tiles;

    public int width;
    public int height;

    this(int width, int height)
    {
        this.width = width;
        this.height = height;
        this.tiles = new Tile[](width * height);
    }

    public Tile getTile(int x, int y)
    {
        if(x < 0 || y < 0 || x > width || y > height) return null;

        int index = x + y * width;

        if(tiles[index] is null)
            tiles[index] = new Tile(x, y);

        return tiles[index];
    }

    public Tile setTile(int x, int y, int type)
    {
        auto tile = getTile(x, y);
        if(tile !is null)
            tile.setType(type);
        return tile;
    }

    public Tile lookUpTile(float x, float y)
    {
        if (x < 0 || x >= width || y < 0 || y >= height)
        {
            return null;
        }

        int index = cast(int)x + cast(int)y * width;
        return tiles[index];
    }

}