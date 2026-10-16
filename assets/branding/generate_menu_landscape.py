"""Render original NOVATERRA main-menu landscape as a deterministic PNG.

Standard-library only. This is branded illustrative art, not a captured game
screenshot or a rendered interactive 3D menu. The game itself remains 3D.
"""
from __future__ import annotations

from math import sin, pi
from pathlib import Path
import random
import struct
import zlib

WIDTH, HEIGHT = 1440, 810


def _png_chunk(label: bytes, data: bytes) -> bytes:
    payload = label + data
    return struct.pack(">I", len(data)) + payload + struct.pack(">I", zlib.crc32(payload) & 0xFFFFFFFF)


def render_menu_background(destination: Path) -> Path:
    """Write a fully offline, reproducible, original mountain-and-village scene."""
    w, h = WIDTH, HEIGHT
    image = bytearray(w * h * 3)

    def rgb(x: int, y: int, color: tuple[int, int, int]) -> None:
        if 0 <= x < w and 0 <= y < h:
            k = (y*w + x)*3
            image[k:k+3] = bytes(color)

    def span(y: int, left: int, right: int, color: tuple[int, int, int]) -> None:
        if not 0 <= y < h:
            return
        x0, x1 = max(0, int(left)), min(w, int(right))
        if x0 < x1:
            b = (y*w + x0)*3
            image[b:b+(x1-x0)*3] = bytes(color)*(x1-x0)

    def rect(x: int, y: int, width: int, height: int, color: tuple[int,int,int]) -> None:
        for yy in range(max(y,0), min(h,y+height)):
            span(yy,x,x+width,color)

    def polygon(points: list[tuple[int,int]], color: tuple[int,int,int]) -> None:
        lo, hi = max(0,min(p[1] for p in points)), min(h,max(p[1] for p in points)+1)
        for yy in range(lo,hi):
            xs = []
            for (ax,ay),(bx,by) in zip(points,points[1:]+points[:1]):
                if ay != by and min(ay,by) <= yy < max(ay,by):
                    xs.append(ax+(yy-ay)*(bx-ax)/(by-ay))
            xs.sort()
            for j in range(0,len(xs)-1,2):
                span(yy,round(xs[j]),round(xs[j+1]),color)

    def ellipse(cx:int,cy:int,rx:int,ry:int,color:tuple[int,int,int]) -> None:
        for yy in range(max(0,cy-ry),min(h,cy+ry+1)):
            t=(yy-cy)/max(1,ry)
            d=rx*max(0,1-t*t)**0.5
            span(yy,cx-d,cx+d,color)

    def cube(cx:int,cy:int,s:int,top:tuple[int,int,int],left:tuple[int,int,int],right:tuple[int,int,int]) -> None:
        polygon([(cx,cy-s),(cx+s,cy-s//2),(cx,cy),(cx-s,cy-s//2)],top)
        polygon([(cx-s,cy-s//2),(cx,cy),(cx,cy+s),(cx-s,cy+s//2)],left)
        polygon([(cx,cy),(cx+s,cy-s//2),(cx+s,cy+s//2),(cx,cy+s)],right)

    # Dawn sky with warm light over a rugged alpine valley.
    for yy in range(h):
        t=min(1,yy/620)
        top=(11,29,57)
        low=(230,157,112)
        c=tuple(int((1-t)*top[k]+t*low[k]) for k in range(3))
        span(yy,0,w,c)
    for rad,color in [(168,(89,87,83)),(124,(136,108,88)),(89,(205,154,100)),(59,(247,203,135))]:
        ellipse(790,268,rad,rad,color)
    ellipse(790,268,44,44,(255,225,158))

    # High mountains, jagged ridges and snow-clad summits.
    polygon([(0,518),(0,392),(80,304),(138,357),(227,182),(316,356),(414,241),
             (538,430),(660,330),(768,470),(883,274),(974,425),(1102,216),
             (1210,407),(1302,268),(1440,446),(1440,518)],(83,117,136))
    polygon([(0,545),(0,467),(155,396),(245,475),(371,320),(499,483),
             (666,361),(786,462),(920,377),(1028,503),(1182,335),
             (1307,470),(1440,390),(1440,545)],(39,78,95))
    for x,y,size in [(227,182,101),(414,241,65),(883,274,77),(1102,216,104),(1302,268,62)]:
        polygon([(x-size,y+size+32),(x,y),(x+size,y+size+32),
                 (x+size//3,y+size//2),(x+4,y+size//3),(x-size//3,y+size//2)],(215,225,217))
        polygon([(x,y),(x+size//3,y+size//2),(x+size,y+size+32)],(170,201,200))
    polygon([(0,611),(0,492),(200,520),(305,449),(457,543),(558,465),
             (721,546),(874,481),(1010,547),(1180,468),(1440,530),(1440,611)],(44,91,85))

    # River winding towards the viewer, fields on either shore.
    polygon([(0,570),(404,558),(593,622),(610,739),(548,810),(0,810)],(45,112,67))
    polygon([(902,572),(1440,556),(1440,810),(951,810),(854,719)],(40,103,67))
    polygon([(595,551),(815,537),(913,616),(853,677),(1043,810),(528,810),
             (608,714),(561,632)],(35,104,130))
    polygon([(616,558),(785,550),(858,610),(798,664),(949,810),(872,810),
             (738,668),(785,607)],(74,151,158))
    for j in range(20):
        yy=570+j*11
        xx=700+int(68*sin(yy*.026))
        rect(xx,yy,16+(j%4)*9,2,(137,195,182))

    # Fortress, tiled roofs and mountain hamlet, all original voxel geometry.
    polygon([(971,502),(971,429),(1213,429),(1213,522)],(155,129,98))
    rect(980,443,225,67,(174,145,111))
    rect(1027,394,33,118,(104,87,78))
    rect(1152,380,41,132,(108,84,74))
    for x,y in [(1009,405),(1135,392)]:
        polygon([(x,y+10),(x+37,y-25),(x+75,y+10)],(119,70,60))
    polygon([(982,439),(1097,365),(1210,439)],(119,78,62))
    for x in (995,1037,1080,1125,1170):
        rect(x,462,16,24,(57,60,64))
    rect(1091,472,32,49,(73,56,49))
    for x,y,s in [(870,488,51),(1251,503,52),(1338,527,43),(760,517,28)]:
        polygon([(x-s,y),(x,y-s*.64),(x+s,y)],(127,72,54))
        rect(x-s+8,y,s*2-16,int(s*.76),(183,147,108))
        rect(x-8,y+9,18,22,(74,77,73))

    # Original tree silhouettes: dozens of layered needle branches, variable sizes.
    randomizer=random.Random(12643)
    def pine(x:int,y:int,height:int) -> None:
        rect(x-3,y-height//6,6,height//5+8,(62,55,45))
        for j in range(4):
            yy=y-height+(j*height)//5
            half=int(height*(0.21+j*0.037))
            polygon([(x,yy),(x-half,yy+height//3),(x+half,yy+height//3)],
                    [(21,78,61),(34,100,61),(48,115,66),(29,87,61)][j])
    for _ in range(91):
        x=randomizer.randint(0,w)
        if 585<x<960:
            continue
        ground=505+int(55*sin(x*.012))+randomizer.randrange(0,48)
        pine(x,ground,randomizer.randrange(32,109))
    for _ in range(29):
        x=randomizer.choice([randomizer.randint(25,465),randomizer.randint(1130,1430)])
        y=randomizer.randint(635,833)
        pine(x,y,randomizer.randint(74,158))

    # Isometric foreground outcrops and wildflower accents for depth.
    for cx,cy,s in [(119,737,57),(237,790,62),(1304,746,65),(1418,807,59),
                    (412,785,37),(1202,793,44)]:
        cube(cx,cy,s,(109,142,73),(64,95,61),(79,111,65))
        cube(cx,cy+13,s//2,(112,124,100),(73,82,85),(87,94,96))
    for _ in range(170):
        x=randomizer.randrange(w)
        y=randomizer.randrange(650,810)
        if 530 < x < 1050:
            continue
        rgb(x,y,randomizer.choice([(230,179,98),(232,218,141),(205,149,92)]))

    # Tiny atmospheric grain adds texture while preserving the premium palette.
    for _ in range(18000):
        x=randomizer.randrange(w); y=randomizer.randrange(440,810)
        k=(y*w+x)*3
        light=randomizer.choice([-8,-5,5,8])
        for channel in range(3):
            image[k+channel]=max(0,min(255,image[k+channel]+light))

    destination=Path(destination)
    destination.parent.mkdir(parents=True,exist_ok=True)
    scanlines=b"".join(b"\x00"+image[y*w*3:(y+1)*w*3] for y in range(h))
    png=(b"\x89PNG\r\n\x1a\n"
         +_png_chunk(b"IHDR",struct.pack(">IIBBBBB",w,h,8,2,0,0,0))
         +_png_chunk(b"IDAT",zlib.compress(scanlines,7))
         +_png_chunk(b"IEND",b""))
    destination.write_bytes(png)
    return destination
