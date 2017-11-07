module game.objects.gameobject;

import std.stdio;
import std.math;

import game.objects.entity;
import game.collision;
import game.map.tile;
import game.map.tilemap;
import utils.wpos;
import data.objectdata;
import data.condition;

class Momentum
{
    public float speed;
    public float facing;

    public GameObject host;

    public this(GameObject host)
    {
        this.host = host;
    }

    public bool move(float dt)
    {
        float velocityX = speed * cos(facing);
        float velocityY = speed * sin(facing);

        float toX = host.x + velocityX * dt;
        float toY = host.y + velocityY * dt;

        float l = host.pos().dst(toX, toY);
        int steps = cast(int) round(l);
        WPos nPos;

        for (int i = 0; i < steps; i++)
        {
            WPos pos = WPos.step(host.pos(), WPos(toX, toY), i);
            modifyStep(pos.x, pos.y, &nPos);
            bool moved = host.moveTo(nPos.x, nPos.y);
            if (!moved) return false;
        }
        modifyStep(toX, toY, &nPos);
        return host.moveTo(nPos.x, nPos.y);
    }

    public void modifyStep(float x, float y, WPos* nextPos)
    {
        float nextXBorder = 0.0;
        float nextYBorder = 0.0;
        bool xCross = host.x % 0.5 == 0.0 && x != host.x || cast(int) (host.x / 0.5) != cast(int) (x / 0.5);
        bool yCross = host.y % 0.5 == 0.0 && y != host.y || cast(int) (host.y / 0.5) != cast(int) (y / 0.5);
        if (!xCross && !yCross || isValidPosition(x, y))
        {
            nextPos.x = x;
            nextPos.y = y;
            return;
        }
        if (xCross)
        {
            nextXBorder = x > host.x ?  cast(int) (x * 2) / 2.0 : cast(int) (host.x * 2) / 2.0;
            if (cast(int) (nextXBorder) > cast(int) (host.x))
            {
                nextXBorder = nextXBorder - 0.01;
            }
        }
        if (yCross)
        {
            nextYBorder = y > host.y ? cast(int) (y * 2) / 2.0 : cast(int) (host.y * 2) / 2.0;
            if (cast(int) (nextYBorder) > cast(int) (host.y))
            {
                nextYBorder = nextYBorder - 0.01;
            }
        }
        if (!xCross)
        {
            nextPos.x = x;
            nextPos.y = nextYBorder;
            return;
        }
        if (!yCross)
        {
            nextPos.x = nextXBorder;
            nextPos.y = y;
            return;
        }
        float xBorderDist = x > host.x ? x - nextXBorder : nextXBorder - x;
        float yBorderDist = y > host.y ? y - nextYBorder : nextYBorder - y;
        if (xBorderDist > yBorderDist)
        {
            if (isValidPosition(x, nextYBorder))
            {
                nextPos.x = x;
                nextPos.y = nextYBorder;
                return;
            }
            if (isValidPosition(nextXBorder, y))
            {
                nextPos.x = nextXBorder;
                nextPos.y = y;
                return;
            }
        }
        else
        {
            if (isValidPosition(nextXBorder, y))
            {
                nextPos.x = nextXBorder;
                nextPos.y = y;
                return;
            }
            if (isValidPosition(x, nextYBorder))
            {
                nextPos.x = x;
                nextPos.y = nextYBorder;
                return;
            }
        }
        nextPos.x = nextXBorder;
        nextPos.y = nextYBorder;
    }

    public bool isValidPosition(float x, float y)
    {
        Tile toTile = host.world.tileMap.getTile(cast(int)x, cast(int)y);
        if ((host.tile != toTile) && (toTile is null || !toTile.isPassable()))
        {
            return (false);
        }

        float xFrac = x - cast(int) (x);
        float yFrac = y - cast(int) (y);
        if (xFrac < 0.5)
        {
            if (isFullOccupy(x - 1, y))
            {
                return false;
            }
            if (yFrac < 0.5)
            {
                if (isFullOccupy(x, y - 1) || isFullOccupy(x - 1, y - 1))
                {
                    return false;
                }
            }
            else if (yFrac > 0.5)
            {
                if (isFullOccupy(x, y + 1) || isFullOccupy(x - 1, y + 1))
                {
                    return false;
                }
            }
        }
        else if (xFrac > 0.5)
        {
            if (isFullOccupy(x + 1, y))
            {
                return false;
            }
            if (yFrac < 0.5)
            {
                if (isFullOccupy(x, y - 1) || isFullOccupy(x + 1, y - 1))
                {
                    return false;
                }
            }
            else if (yFrac > 0.5)
            {
                if (isFullOccupy(x, y + 1) || isFullOccupy(x + 1, y + 1))
                {
                    return false;
                }
            }
        }
        else if (yFrac < 0.5)
        {
            if (isFullOccupy(x, y - 1))
            {
                return false;
            }
        }
        else if (yFrac > 0.5)
        {
            if (isFullOccupy(x, y + 1))
            {
                return false;
            }
        }
        return true;
    }

    public bool isFullOccupy(float x, float y)
    {
        Tile toTile = host.world.tileMap.lookUpTile(x, y);
        return toTile is null || toTile.type == 255 || toTile.go !is null && toTile.go.data.fullOccupy;
    }
}

class GameObject : Entity
{
    public CollisionMap parent;
    public CollisionNode node;

    public ObjectData data;

    public bool isDead;

    public Momentum momentum;


    public string name;
    public int lvl;
    public int exp;
    public int max_hp;
    public int max_mp;
    public int hp;
    public int mp;
    public int atk;
    public int def;
    public int spd;
    public int dex;
    public int vit;
    public int wis;

    public long condition;


    private float[] _conditionTimers;

    this(ObjectData data)
    {
        this.data = data;
        this.momentum = new Momentum(this);
        this._conditionTimers = new float[](cast(int) ConditionEffectIndex.Max);
    }

    public override bool tick(float dt)
    {
        tickCondition(dt);
        tickRegen(dt);

        tickAi(dt);
        return true;
    }

    void tickCondition(float dt)
    {
        for (int i = 0; i < _conditionTimers.length; i++)
        {
            if (_conditionTimers[i] >= 0)
            {
                _conditionTimers[i] -= dt;

                if (_conditionTimers[i] <= 0)
                {
                    _conditionTimers[i] = 0;
                    removeConditionEffect(cast(ConditionEffectIndex) i);
                }
            }
        }
    }

    void tickRegen(float dt)
    {
        // todo: finish
    }

    void tickAi(float dt)
    {
        // todo: finish
    }

    //region Movement
    public bool moveTo(float x, float y)
    {
         Tile toTile = world.tileMap.getTile(cast(int) x, cast(int) y);

         if (toTile is null)
             return false;
         if (toTile.isPassable() == false)
             return false;


         if (data.isPlayer)
             world.collisionMap_players.move(this, x, y);
         else
             world.collisionMap_go.move(this, x, y);

         this.x = x;
         this.y = y;

         if (data.isStatic)
         {
             if (tile !is null)
             {
                 tile.go = null;
             }
             toTile.go = this;
         }

         tile = toTile;
         return true;
     }

    public bool moveToward(WPos target, float speed, bool avoidWaterMaybe = true)
    {
        float angle = angleTo(target);

        float velocityX = speed * cos(angle);
        float velocityY = speed * sin(angle);

        float toX = x + velocityX;
        float toY = y + velocityY;
        WPos nPos;

        {   // step line to check collision
            WPos myPos = pos();
            float l = myPos.dst(toX, toY);
            int steps = cast(int)round(l);
            for (int i = 0; i < steps; i++)
            {
                WPos p = WPos.step(myPos, WPos(toX, toY), i);
                momentum.modifyStep(p.x, p.y, &nPos);

                if (avoidWaterMaybe)
                {
                    Tile toTile = world.tileMap.lookUpTile(nPos.x, nPos.y);
                    if (toTile is null) return false;
                    if (toTile.isWater()) return false;
                }

                bool moved = moveTo(nPos.x, nPos.y);
                if (!moved) return false;
            }
        }


        momentum.modifyStep(toX,toY, &nPos);
        if (avoidWaterMaybe)
        {
            Tile toTile = world.tileMap.lookUpTile(nPos.x, nPos.y);
            if (toTile is null) return false;
            if (toTile.isWater()) return false;
        }

        return moveTo(nPos.x, nPos.y);
    }
    //endregion

    //region Condition
    public bool hasCondition(ConditionEffectIndex eff)
    {
        return (condition & (cast(long) 1 << cast(int) eff - 1)) != 0;
    }

    public bool hasCondition(ConditionEffectBit eff)
    {
        return (condition & cast(long)eff) != 0;
    }

    public void removeConditionEffect(ConditionEffectIndex effect)
    {
        int index = cast(int) effect;
        _conditionTimers[index] = 0;
        condition &= ~cast(ConditionEffectBit) (cast(long) 1 << index - 1);
    }

    public void clearConditionEffects()
    {
        for (int i = 0; i < _conditionTimers.length; i++)
        {
            _conditionTimers[i] = 0;
            condition = 0;
        }
    }

    public void applyConditionEffect(ConditionEffectIndex effect, float duration = float.max)
    {
        if (isImmune(effect))
        {
            return;
        }

        int index = cast(int) effect;

        if(!hasCondition(effect))
            condition |= cast(ConditionEffectBit)(cast(long)1 << index - 1);

        _conditionTimers[index] = duration;
    }

    private bool isImmune(ConditionEffectIndex effect)
    {
        if (effect == ConditionEffectIndex.Stunned &&
            hasCondition(ConditionEffectBit.StunImmume))
            return true;

        if (effect == ConditionEffectIndex.Stasis &&
            hasCondition(ConditionEffectBit.StasisImmune))
            return true;

        if (effect == ConditionEffectIndex.Paralyzed &&
            hasCondition(ConditionEffectBit.ParalyzeImmune))
            return true;

        if (effect == ConditionEffectIndex.ArmorBroken &&
            hasCondition(ConditionEffectBit.ArmorBreakImmune))
            return true;

        if (effect == ConditionEffectIndex.Curse &&
            hasCondition(ConditionEffectBit.CurseImmune))
            return true;

        if (effect == ConditionEffectIndex.Petrify &&
            hasCondition(ConditionEffectBit.PetrifiedImmune))
            return true;

        if (effect == ConditionEffectIndex.Dazed &&
            hasCondition(ConditionEffectBit.DazedImmune))
            return true;

        if (effect == ConditionEffectIndex.Slowed &&
            hasCondition(ConditionEffectBit.SlowedImmune))
            return true;

        return false;
    }
    //endregion
}

