module game.objects.entity;

import std.stdio;
import std.math;

import game.world;
import game.map.tile;
import utils.wpos;

abstract class Entity
{
    private static int _fake = 0;
    private static int _internal = 0;
    public static int nextFakeId()
    {
        return 0x7F000000 | _fake++;
    }
    public static int nextId()
    {
        return _internal++;
    }

    public int objectId;
    public float x;
    public float y;

    public Tile tile;
    public World world;

    public abstract bool tick(float dt);

    public bool addTo(World world, float toX, float toY)
    {
        this.tile = world.tileMap.getTile(cast(int) toX,cast(int) toY);

        if(this.tile is null) return false;

        this.world = world;
        this.x = toX;
        this.y = toY;

        return true;
    }

    public void removeFromMap()
    {
        this.tile = null;
        this.world = null;
    }

    public WPos pos()
    {
        return WPos(x, y);
    }

    public WPosi ipos()
    {
        return WPosi(cast(int) x, cast(int)y);
    }

    public float distTo(Entity entity)
    {
        return pos().dst(entity.x, entity.y);
    }

    public float distTo(float toX, float toY)
    {
        return pos().dst(toX, toY);
    }

    public float angleTo(Entity other)
    {
        return atan2(other.y - y, other.x - x);
    }

    public float angleTo(WPos other)
    {
        return atan2(other.y - y, other.x - x);
    }

    public float angleTo(float tX, float tY)
    {
        return atan2(tY - y, tX - x);
    }
}

