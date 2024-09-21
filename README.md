# Lithium is in it's WIP stage. Do not expect much from it right now!
[Workshop item](https://steamcommunity.com/sharedfiles/filedetails/?id=3334367687)
## Description
Lithium is a multipurpose multirealm performance improvement addon aimed at trying to optimise gmod's parts that can be accessed through addons as much as possible.
This addon will improve your performance, especially with poorly-written addons.

## Known incompabilities and issues
- ANY mod that modifies hook table. That means that at the moment this is incompatible with DLib and similar addons.
- Exception: This mod is compatible with ULX and ULib.

## Features
- New hook system (see what it means below)
- Improved some render calls
- Automatic garbage collection. (gmod should lag less and take less RAM)

## FAQ
Q: What does "new hook system" means?
A: TL;DR: This makes Garry's mod faster.
A: Lithium provides a drop-in hook module replacement which ranks at about 40% best-case and 25% average performance increase in C++ -> Lua tests.
   Hooks are an essential part of Garry's mod which allow addons to "hook into" events that game calls from time to time. While some hooks are called
   just once in a while, others can be called multiple times every frame, so optimised hook module can give anywhere from 0 improvement to "the best
   you would even imagine".
