module assets;

import std.stdio;

import data.objectdata;
import data.tiledata;
import data.mapserializer;

class Assets
{
    public int[string] id_to_type;
    public string[int] type_to_id;

    public ObjectData[int] objectData_type;
    public ObjectData[string] objectData_id;

    public TileData[int] tileData_type;
    public TileData[string] tileData_id;

    public ParsedMap[string] maps;

    public void load()
    {
        maps["nexus"] = MapSerializer.deserialize("data/maps/nexus_prod.wmap");
        maps["realm_0"] = MapSerializer.deserialize("data/maps/realm/0.wmap");
    }
}