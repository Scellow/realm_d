module logic.state;

import std.stdio;
import std.math;

import game.objects.gameobject;
import utils.wpos;
import data.condition;

class State : IStateChildren
{
    public string name;
    public State parent;
    public State[] states;
    public Behavior[] behaviors;
    public Transition[] transitions;

    private int _selector;

    public this(string name = "", IStateChildren...)(IStateChildren child)
    {
        this.name = name;
        this(child);
    }

    public this(IStateChildren...)(IStateChildren child)
    {
        this.name = "";

        foreach(c; child)
        {
            if(cast(State) c)
            {
                auto s = cast(State) c;
                states ~= s;
                s.parent = this;
            }
            else if(cast(Behavior) c)
            {
                auto b = cast(Behavior) c;
                behaviors ~= b;
            }
            else if(cast(Transition) c)
            {
                auto t = cast(Transition) c;
                transitions ~= t;
            }
        }
    }

    public void onDeath(GameObject host, GameObject killer)
    {
        for(int i = 0; i < behaviors.length; i++)
        {
            behaviors[i].onDeath(host, killer);
        }
        if(parent !is null)
            parent.onDeath(host, killer);
    }

    public void onPlayerText(GameObject host, string text)
    {
        for(int i = 0; i < transitions.length; i++)
        {
            transitions[i].onPlayerText(host, text);
        }
        if(parent !is null)
            parent.onPlayerText(host, text);
    }

    public void onStateEntry(GameObject host)
    {
        State tmp = this;

        while (tmp !is null)
        {
            for(int i = 0; i < tmp.behaviors.length; i++)
            {
                behaviors[i].onStateEntry(host);
            }
            tmp = tmp.getActiveSubState();
        }
    }

    public void onStateExit(GameObject host)
    {
        State tmp = this;

        while (tmp !is null)
        {
            for(int i = 0; i < tmp.behaviors.length; i++)
            {
                behaviors[i].onStateExit(host);
            }
            tmp = tmp.getActiveSubState();
        }
    }

    public void tick(GameObject host, float dt)
    {
        if(states.length > 0)
        {
            states[_selector].tick(host, dt);
        }

        for(int i = 0; i < behaviors.length; i++)
        {
            behaviors[i].tick(host, dt);
        }
        for(int i = 0; i < transitions.length; i++)
        {
            bool success = transitions[i].tick(host, dt);
            if(success)
            {
                string targetStateName = transitions[i].targetState;
                if(parent !is null)
                    parent.switchTo(host, targetStateName);
            }
        }
    }

    public bool switchTo(GameObject host, string targetState)
    {
        for(int i = 0; i < states.length; i++)
        {
            State state = states[i];
            if(state.name == targetState)
            {
                switchTo(host, i);
                return true;
            }
        }
        return false;
    }

    public bool switchTo(GameObject host, int index, bool force = false)
    {
        if(states.length == 0) return false;

          if(!force)
            if(_selector == index) return true;

             // exist current state
             states[_selector].onStateExit(host);
             // maybe i should use directly onstateexit so it call it for current behviors ???

             // set slector
             _selector = index;

             // enter new state
             State s = states[_selector];
             s.onStateEntry(host);

             while (true)
             {
                 s = s.getActiveSubState();
                 if(s is null) break;
                 s.onStateEntry(host);
             }

        return true;
    }

     public void switchToDeep(GameObject host,string targetState)
     {
         State tmp = this;

         while (tmp !is null)
         {
             if(!tmp.switchTo(host, targetState))
                 tmp = tmp.getActiveSubState();
             else
                 break;
         }
     }

     public State getActiveSubState()
     {
         if(states.length > 0) return states[_selector];
         return null;
     }
}

abstract class Behavior : IStateChildren
{
     public void onDeath(GameObject host, GameObject killer)
     {}

     public void onStateEntry(GameObject host){}
     public void onStateExit(GameObject host){}

     public abstract bool tick(GameObject host, float dt);
}

abstract class Transition : IStateChildren
{
    public string targetState;

    public void onPlayerText(GameObject host, string text)
    {}

    public abstract bool tick(GameObject host, float dt);
}

interface IStateChildren
{}

abstract class CycleBehavior : Behavior
{

}

class BackAndForth : CycleBehavior
{
    private float _speed;
    private float _acceleration;
    private float _angle;
    private float _turnRate;
    private float _radius;

    private bool _hasCenter;
    private WPos _center;
    private bool _moveInward;
    private bool _direction;

    public this(float speed = 1.0, float angle = 0.0, float turnRate = 0.0, float radius = 4.0)
    {
        _hasCenter = false;
        _moveInward = false;
        _direction = false;

        _speed = speed;
        //_acceleration = acceleration;
        _angle = angle;
        _turnRate = turnRate;
        _radius = radius;
    }

    public override void onStateEntry(GameObject host)
    {
        _hasCenter = false;
    }

    public override bool tick(GameObject host, float dt)
    {
        if (host.hasCondition(ConditionEffectIndex.Paralyzed)) return false;

        if (!_hasCenter)
        {
            _hasCenter = true;
            _center.x = host.x;
            _center.y = host.y;
        }

        _angle += _turnRate * dt;

        float targetX = _center.x + cos(_angle) * _radius;
        float targetY = _center.y + sin(_angle) * _radius;

        if (!host.moveToward(WPos(targetX, targetY), _speed * dt * 5, false) || (host.x == targetX && host.y == targetY))
        {
            _angle += PI;
        }
        return true;
    }
}