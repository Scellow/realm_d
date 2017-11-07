import std.stdio;
import std.datetime;
import core.thread;

import game.objects.gameobject;
import data.condition;
import data.objectdata;
import data.mapserializer;
import assets;
import server;



void testCondition()
{
    auto data = new ObjectData;
    data.id = "Test";
    data.type = 1;
    data.isPlayer = true;

    auto go = new GameObject(data);
    auto condition = ConditionEffectIndex.Paralyzed;

    writeln("Testing effect: ", condition);
    writeln("Has effect: ", go.hasCondition(condition));

    writeln("Apply effect..");
    go.applyConditionEffect(ConditionEffectIndex.Paralyzed, 10.0);

    writeln("Has effect: ", go.hasCondition(condition));

    writeln("Remove effect..");
    go.removeConditionEffect(ConditionEffectIndex.Paralyzed);

    writeln("Has effect: ", go.hasCondition(condition));
}

void testMap()
{
    writeln("Loading maps..");
    auto map_nexus = MapSerializer.deserialize("data/maps/nexus_prod.wmap");
    auto map_realm_0 = MapSerializer.deserialize("data/maps/realm/0.wmap");

    writeln("Map: nexus size:",map_nexus.width,":",map_nexus.height);
    writeln("Map: realm_0 size:",map_realm_0.width,":",map_realm_0.height);
}

void start()
{
    writeln("INFO: Starting server..");
    auto server = new Server;

    new Thread(
    {
        while(true)
        {
            write("Command: ");
            string input = stdin.readln();
            if(input == "exit\n")
            {
                writeln("> You asked to stop the server, alright!");
                server.stop();
                break;
            }
            else
                writeln("> I don't understand your command!");
        }

    }).start();

    server.run();
}

void main()
{
    start();
}
