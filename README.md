# ClipperLua

**Clipper** - The Clipper library performs clipping, offsetting and triangulation for lines or polygons.  
All four boolean clipping operations are supported - intersection, union, difference and exclusive-or.  

Polygons can be of any shape including self-intersecting polygons. The library is based on Vatti's clipping algorithm  
and runs on beta version 10.0 which is a significant rewrite of previous versions and it's improved in terms of performance.  

The repository contains the compiled dll library supporting both 32 and 64-bit Windows OS and uses FFI binding solution  
to work with LuaJIT (Just-In-Time) programming language.  

You can find more details in the official page: http://www.angusj.com/delphi/clipper/documentation/Docs/Overview/_Body.htm

## Demonstration

Linear polygons:

![A](http://www.angusj.com/delphi/clipper3.png)

Circular polygons:

![B](http://www.angusj.com/delphi/clipper4.png)

Offsetting options:

![C](http://www.angusj.com/delphi/clipper9.png)

## API

```lua
1. Point:
+ void. New(number x, number y)
+ number: InPolygon(Path path)

2. Path:
+ void. New()
+ Point: Get(number i)
+ void: Add(Point pt)
+ number: Size()
+ number: Area()
+ bool: Orientation()
+ void: Reverse()
+ Paths: Simplify(number fillRule = ClipperLib.FillRule.EvenOdd)

3. Paths:
+ void. New()
+ Path: Get(number i)
+ void: Add(Path path)
+ number: Size()
+ void: Reverse()
+ Paths: Simplify(number fillRule = ClipperLib.FillRule.EvenOdd)

4. Clipper:
+ void. New()
+ void: AddPath(Path path, number pathType, bool open = false)
+ void: AddPaths(Paths paths, number pathType, bool open = false)
+ Paths: ClipPaths(number clipType = ClipperLib.ClipType.Intersection,
   number fillRule = ClipperLib.FillRule.EvenOdd)

5. ClipperOffset:
+ void. New(number miterLimit = 2.0, number arcTolerance = 0.0)
+ Paths: OffsetPaths(Paths paths, number delta,
   number joinType = ClipperLib.JoinType.Round,
   number endType = ClipperLib.EndType.Polygon)

6. ClipperTri:
+ void. New()
+ Paths: TriangulatePaths(Paths paths,
   number fillRule = ClipperLib.FillRule.EvenOdd)
```
