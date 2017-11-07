module utils.wpos;

import std.stdio;
import std.math;

struct WPos
{

    public float x;
    public float y;

    this(float x, float y)
    {
        this.x = x;
        this.y = y;
    }

    // todo: maybe check if the step distance is longer than the distance between a and b (length) ?
    public static WPos step(WPos a, WPos b, int distance)
    {
        WPos vector = WPos(b.x - a.x, b.y - a.y);
        float length = sqrt(vector.x * vector.x + vector.y * vector.y);
        WPos unitvector = WPos( (vector.x / length),  (vector.y / length));
        return WPos( (a.x + unitvector.x * distance),  (a.y + unitvector.y * distance));
    }

    public float dst(float x, float y)
    {
        float v1 = this.x - x, v2 = this.y - y;
        return sqrt((v1 * v1) + (v2 * v2));
    }
}

struct WPosi
{

    public int x;
    public int y;

    this(int x, int y)
    {
        this.x = x;
        this.y = y;
    }
}

