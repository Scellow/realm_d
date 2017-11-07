module game.world;

import std.stdio;
import std.format;

import game.map.tilemap;
import game.objects.entity;
import game.objects.gameobject;
import game.collision;
import data.mapserializer;
import server;

class World
{
    public TileMap tileMap;

    public GameObject[int] goDic;
    public GameObject[int] playerDic;
    public GameObject[int] questDic;
    public GameObject[int] interactiveDic;

    public int[] removeList;
    public Entity[] addList;

    public CollisionMap collisionMap_go;
    public CollisionMap collisionMap_players;

    private bool _isTicking = false;

    private GameObject[] _tickeables;

    this(string name, int width, int height)
    {
        tileMap = new TileMap(width, height);

        collisionMap_go = new CollisionMap(0, width, height);
        collisionMap_players = new CollisionMap(1, width, height);
    }

    public static World fromDef(string name, ParsedMap map)
    {
        auto ret = new World(name, map.width, map.height);
        for (int x = 0; x < map.width; x++)
        {
            for (int y = 0; y < map.height; y++)
            {
                auto parsedTile = map.tiles[x][y];

                auto wtile = ret.tileMap.setTile(x, y, parsedTile.type);
                //addTerrainType(tile.terrain, x, y);
                //addTileRegion(tile.region, x, y);

                if (parsedTile.objId != "")
                {
                    auto go = ret.createNewObject(parsedTile.objId, x + 0.5, y + 0.5);
                }
            }
        }
        return ret;
    }

    public void tick(float dt)
    {
        _isTicking = true;

        _tickeables.length = 0;

        collisionMap_go.fetchActiveChunks(collisionMap_players, _tickeables);
        foreach(go; interactiveDic.values)
        {
            _tickeables ~= go;
        }

        foreach(go; playerDic.values)
        {
            _tickeables ~= go;
        }

        foreach(go; questDic.values)
        {
            _tickeables ~= go;
        }

        for(int i = 0; i < _tickeables.length; i++)
        {
            GameObject go = _tickeables[i];
            if(!go.tick(dt) || go.isDead)
            {
                // remove it
            }
        }

        _isTicking = false;

        for(int i = 0; i < addList.length; i++)
        {
            addGo_direct(addList[i]);
        }
        addList.length = 0;

        for(int i = 0; i < removeList.length; i++)
        {
            removeObj_direct(removeList[i]);
        }
        removeList.length = 0;

    }

    public void addGo(Entity entity, float x, float y)
    {
        entity.x = x;
        entity.y = y;
        if(_isTicking)
            addList ~= entity;
        else
            addGo_direct(entity);
    }

    public void addGo_direct(Entity entity)
    {
        if(!entity.addTo(this, entity.x, entity.y))
            return;

        if(cast(GameObject) entity)
        {
            GameObject go = cast(GameObject) entity;

            if(go.data.isPlayer)
                playerDic[go.objectId] = go;
            else if(go.data.isInteractive)
                interactiveDic[go.objectId] = go;
            else if(go.data.isQuest)
                questDic[go.objectId] = go;
            else
                goDic[go.objectId] = go;
        }
        else
        {
            throw new Exception("Can't be added");
        }
    }

    public void removeObj(int objectId)
    {
        if(_isTicking)
            removeList ~= objectId;
        else
            removeObj_direct(objectId);
    }

    public void removeObj_direct(int objectId)
    {
        if(goDic[objectId])
        {
            GameObject go = goDic[objectId];
            goDic[objectId] = null;
            go.removeFromMap();
        }
        else if(interactiveDic[objectId])
        {
            GameObject go = interactiveDic[objectId];
            interactiveDic[objectId] = null;
            go.removeFromMap();
        }
        else if(questDic[objectId])
        {
            GameObject go = questDic[objectId];
            questDic[objectId] = null;
            go.removeFromMap();
        }
        else if(playerDic[objectId])
        {
            GameObject go = playerDic[objectId];
            playerDic[objectId] = null;
            go.removeFromMap();
        }
    }

    public GameObject createNewObject(string id, float x, float y)
    {
        if(Server.assets.id_to_type.get(id, -1) == -1)
            throw new Exception(format("Unable to convert %s", id));

        return createNewObject(Server.assets.id_to_type[id], x, y);
    }

    public GameObject createNewObject(int type, float x, float y)
    {
        auto data = Server.assets.objectData_type.get(type, null);
        if(!data) throw new Exception(format("Data not found for: %a", type));

        GameObject ret = new GameObject(data);
        ret.objectId = Entity.nextId();

        addGo(ret, x, y);
        ret.world = this;

        return ret;
    }
}

