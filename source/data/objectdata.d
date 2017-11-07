module data.objectdata;

import std.stdio;

class ObjectData
{
    public string id;
    public int type;
    public string description;
    public string className;
    public string group;

    public bool isPlayer;
    public bool isEnemy;
    public bool isQuest;
    public bool isInteractive;
    public bool isStatic;

    public bool fullOccupy;
    public bool occupySquare;
}