
local ffi = require "ffi"
local C = ffi.load "clipper"

ffi.cdef[[
typedef struct __CPoint { int32_t x; int32_t y; } CPoint;
typedef struct __CRect { int32_t left, top, right, bottom; } CRect;
typedef struct __CPath CPath;
typedef struct __CPaths CPaths;
typedef struct __CClipper CClipper;
typedef struct __CClipperOffset CClipperOffset;
typedef struct __CClipperTri CClipperTri;

// Point
CPoint* CPointNew(int32_t x, int32_t y);
void CPointDelete(CPoint* self);
int CPointInPolygon(const CPoint* self, const CPath* path);

// Path
CPath* CPathNew();
void CPathDelete(CPath* self);
CPoint* CPathGet(CPath* self, int i);
void CPathAdd(CPath* self, CPoint* pt);
int CPathSize(CPath* self);
double CPathArea(const CPath* self);
bool CPathOrientation(const CPath* self);
void CPathReverse(CPath* self);
CPaths* CPathSimplify(CPath* self, int fillRule);

// Paths
CPaths* CPathsNew();
void CPathsDelete(CPaths* self);
CPath* CPathsGet(CPaths* self, int i);
void CPathsAdd(CPaths* self, CPath* path);
int CPathsSize(CPaths* self);
void CPathsReverse(CPaths* self);
CPaths* CPathsSimplify(CPaths* self, int fillRule);

// Clipper
CClipper* CClipperNew();
void CClipperDelete(CClipper* self);
void CClipperAddPath(CClipper* self, CPath* path, int type, bool open);
void CClipperAddPaths(CClipper* self, CPaths* paths, int type, bool open);
CPaths* CClipperExecute(CClipper* self, int clipType, int fillRule);

// ClipperOffset
CClipperOffset* COffsetNew(double miterLimit, double arcTolerance);
void COffsetDelete(CClipperOffset* self);
CPaths* COffsetPaths(CClipperOffset* self, CPaths* paths, double delta, int joinType, int endType);

// ClipperTri
CClipperTri* CTriangulateNew();
void CTriangulateDelete(CClipperTri* self);
void CTriangulateAddPaths(CClipperTri* self, CPaths* paths);
CPaths* CTriangulateExecute(CClipperTri* self, int fillRule);
]]

_G.ClipperLib = {
	ClipType = {None = 0, Intersection = 1, Union = 2, Difference = 3, Xor = 4},
	FillRule = {EvenOdd = 0, NonZero = 1, Positive = 2, Negative = 3},
	PathType = {Subject = 0, Clip = 1},
	JoinType = {Square = 0, Round = 1, Mitter = 2},
	EndType = {Polygon = 0, OpenJoined = 1, OpenButt = 2, OpenSquare = 3, OpenRound = 4}
}

-- Point

local Point = {}

function Point.New(x, y)
	return ffi.gc(C.CPointNew(x, y), C.CPointDelete)
end

function Point:InPolygon(path)
	return C.CPointInPolygon(self, path)
end

-- Path

local Path = {}

function Path.New()
	return ffi.gc(C.CPathNew(), C.CPathDelete)
end

function Path:Get(i)
	return C.CPathGet(self, i - 1)
end

function Path:Add(pt)
	return C.CPathAdd(self, pt)
end

function Path:Size()
	return C.CPathSize(self)
end

function Path:Area()
	return C.CPathArea(self)
end

function Path:Orientation()
	return C.CPathOrientation(self)
end

function Path:Reverse()
	return C.CPathReverse(self)
end

function Path:Simplify(fillRule)
	local fillRule = fillRule or ClipperLib.FillRule.EvenOdd
	return C.CPathSimplify(self, fillRule)
end

-- Paths

local Paths = {}

function Paths.New()
	return ffi.gc(C.CPathsNew(), C.CPathsDelete)
end

function Paths:Get(i)
	return C.CPathsGet(self, i - 1)
end

function Paths:Add(path)
	return C.CPathsAdd(self, path)
end

function Paths:Size()
	return C.CPathsSize(self)
end

function Paths:Reverse()
	return C.CPathsReverse(self)
end

function Paths:Simplify(fillRule)
	local fillRule = fillRule or ClipperLib.FillRule.EvenOdd
	return C.CPathsSimplify(self, fillRule)
end

-- Clipper

local Clipper = {}

function Clipper.New()
	return ffi.gc(C.CClipperNew(), C.CClipperDelete)
end

function Clipper:AddPath(path, pathType, open)
	local open = open or false
	C.CClipperAddPath(self, path, pathType, open)
end

function Clipper:AddPaths(paths, pathType, open)
	local open = open or false
	C.CClipperAddPaths(self, paths, pathType, open)
end

function Clipper:ClipPaths(clipType, fillRule)
	local clipType = clipType or ClipperLib.ClipType.Intersection
	local fillRule = fillRule or ClipperLib.FillRule.EvenOdd
	return C.CClipperExecute(self, clipType, fillRule)
end

-- ClipperOffset

local ClipperOffset = {}

function ClipperOffset.New(miterLimit, arcTolerance)
	local miterLimit = miterLimit or 2.0
	local arcTolerance = arcTolerance or 0.0
	return ffi.gc(C.COffsetNew(miterLimit, arcTolerance), C.COffsetDelete)
end

function ClipperOffset:OffsetPaths(paths, delta, joinType, endType)
	local joinType = joinType or ClipperLib.JoinType.Round
	local endType = endType or ClipperLib.EndType.Polygon
	return C.COffsetPaths(self, paths, delta, joinType, endType)
end

-- ClipperTri

local ClipperTri = {}

function ClipperTri.New()
	return ffi.gc(C.CTriangulateNew(), C.CTriangulateDelete)
end

function ClipperTri:AddPaths(paths)
	return C.CTriangulateAddPaths(self, paths)
end

function ClipperTri:TriangulatePaths(fillRule)
	local fillRule = fillRule or ClipperLib.FillRule.EvenOdd
	return C.CTriangulateExecute(self, fillRule)
end

ffi.metatype("CPoint", {__index = Point})
ffi.metatype("CPath", {__index = Path})
ffi.metatype("CPaths", {__index = Paths})
ffi.metatype("CClipper", {__index = Clipper})
ffi.metatype("CClipperOffset", {__index = ClipperOffset})
ffi.metatype("CClipperTri", {__index = ClipperTri})

return {
	Point = Point.New,
	Path = Path.New,
	Paths = Paths.New,
	Clipper = Clipper.New,
	ClipperOffset = ClipperOffset.New,
	ClipperTri = ClipperTri.New
}
