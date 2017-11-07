module realmmanager;

import std.stdio;

import data.mapserializer;
import game.world;
import assets;
import server;

class RealmManager
{
    public World[int] worlds;

    public void load()
    {
        worlds[-2] = World.fromDef("Nexus", Server.assets.maps["nexus"]);
        worlds[-3] = World.fromDef("Realm 0", Server.assets.maps["realm_0"]);
    }
}
