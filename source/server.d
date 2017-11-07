module server;

import std.stdio;
import std.datetime;
import core.thread;

import game.objects.gameobject;
import data.condition;
import data.objectdata;
import data.mapserializer;
import assets;
import realmmanager;

abstract class App
{
    int _tps = 5;
    bool _started = true;

    public void run()
    {
        start();
        float accDT = 0.0;
        int timeElapsed = 0;
        float timePerTick = 1000.0 / _tps;
        StopWatch sw;
        sw.start();
        long timer = sw.peek().msecs;
        while(_started)
        {
            int dt = cast(int) (sw.peek().msecs - timer);
            timer = sw.peek().msecs;

            while (accDT > timePerTick)
            {
                tick(timePerTick / 1000.0);
                accDT -= timePerTick;
            }

            if (timePerTick > timeElapsed)
            {
                int timeToPause = cast(int) (timePerTick - timeElapsed);
                Thread.sleep( dur!("msecs")( timeToPause ) );
            }

            accDT += dt;
        }

        dispose();
    }

    public abstract void start();
    public abstract void tick(float dt);
    public abstract void dispose();

    public void stop()
    {
        _started = false;
    }
}

class Server : App
{
    public static Assets assets;
    public static RealmManager manager;


    public override void start()
    {
        writeln("INFO: Server started");

        writeln("INFO: Loading data..");
        assets = new Assets;
        assets.load();

        writeln("INFO: Load Realm Manager..");
        manager = new RealmManager;
        manager.load();
    }

    public override void tick(float dt)
    {
        //writeln("INFO: tick: ",dt);
    }

    public override void dispose()
    {
        writeln("INFO: Server disposed");
    }

}