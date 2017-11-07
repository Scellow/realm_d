module logic.behaviors;

import std.stdio;
import std.typecons;

import logic.state;

class Loot
{

}

alias Logic = Tuple!(State, "index", Loot, "value");

class Behaviors
{
    Logic delegate()[string] behaviorsBank;

    public void init()
    {
        Behavior b = new BackAndForth();
        //State s = new State({b, b});

        behaviorsBank["Pirate"] = () => Logic(null, null);
    }
}