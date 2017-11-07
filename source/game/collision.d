module game.collision;

import std.stdio;

import game.objects.gameobject;

class CollisionNode
{
    public int data;
    public GameObject parent;
    public CollisionNode next;
    public CollisionNode previous;

    public void insertAfter(CollisionNode node)
    {
        if(next !is null)
        {
            node.next = next;
            next.previous = node;
        }
        else
            node.next = null;

        node.previous = this;
        next = node;
    }

    public CollisionNode remove()
    {
        CollisionNode ret = null;
        if (previous !is null)
        {
            ret = previous;
            previous.next = next;
        }
        if (next !is null)
        {
            ret = next;
            next.previous = previous;
        }
        previous = null;
        next = null;
        return ret;
    }
}

class CollisionMap
{
    public const int CHUNK_SIZE = 16;
    private const int ACTIVE_RADIUS = 2; // was 3
    private int _cH;
    private int _cW;
    private CollisionNode[][] _chunks;
    private int _h;
    private int _w;
    private byte _type;

    public this(byte type, int w, int h)
    {
        _type = type;
        _w = w;
        _h = h;

        _cW = (w + CHUNK_SIZE - 1)/CHUNK_SIZE;
        _cH = (h + CHUNK_SIZE - 1)/CHUNK_SIZE;

        _chunks = new CollisionNode[][](_cW, _cH);
    }

    private int getData(int chunkX, int chunkY)
    {
        return (chunkX) | (chunkY << 8) | (_type << 16);
    }

    public void insert(GameObject obj)
    {
        if (obj.node !is null)
            throw new Exception("Object already added into collision map.");

        try
        {
            int x = cast(int) (obj.x/CHUNK_SIZE);
            int y = cast(int) (obj.y/CHUNK_SIZE);
            obj.node = new CollisionNode;
            obj.node.data = getData(x, y);
            obj.node.parent = obj;
            obj.parent = this;

            if (_chunks[x][y] is null)
                _chunks[x][y] = obj.node;
            else
                _chunks[x][y].insertAfter(obj.node);
        }
        catch (Exception e)
        {
            throw e;
        }
    }

    public void move(GameObject obj, float newX, float newY)
    {
        if (obj.node is null)
        {
            insert(obj);
            return;
        }
        if (obj.parent != this)
        {
            throw new Exception("Cannot move object across different map.");
        }

        int x = cast(int) (newX/CHUNK_SIZE);
        int y = cast(int) (newY/CHUNK_SIZE);
        int newDat = getData(x, y);
        if (obj.node.data != newDat)
        {
            int oldX = cast(int) (obj.x/CHUNK_SIZE);
            int oldY = cast(int) (obj.y/CHUNK_SIZE);
            if (_chunks[oldX][oldY] == obj.node)
                _chunks[oldX][oldY] = obj.node.remove();
            else
                obj.node.remove();

            if (_chunks[x][y] is null)
                _chunks[x][y] = obj.node;
            else
                _chunks[x][y].insertAfter(obj.node);
            obj.node.data = newDat;
        }
    }

    public void remove(GameObject obj)
    {
        if (obj.node is null)
            return;
        if (obj.parent != this)
            throw new Exception("Cannot remove object across different map.");

        int x = cast(int) (obj.x/CHUNK_SIZE);
        int y = cast(int) (obj.y/CHUNK_SIZE);
        if (_chunks[x][y] == obj.node)
            _chunks[x][y] = obj.node.remove();
        else
            obj.node.remove();
    }

    public void fetchActiveChunks(CollisionMap from, GameObject[] ret)
    {
        if (from._w != _w || from._h != _h)
            throw new Exception("from");

        for (int y = 0; y < _cH; y++)
            for (int x = 0; x < _cW; x++)
                if (from._chunks[x][y] !is null)
                {
                    for (int i = -ACTIVE_RADIUS; i <= ACTIVE_RADIUS; i++)
                        for (int j = -ACTIVE_RADIUS; j <= ACTIVE_RADIUS; j++)
                        {
                            if (x + j < 0 || x + j >= _cW || y + i < 0 || y + i >= _cH)
                                continue;
                            CollisionNode node = _chunks[x + j][y + i];
                            while (node !is null)
                            {
                                ret ~= node.parent;
                                node = node.next;
                            }
                        }
                }
    }
}