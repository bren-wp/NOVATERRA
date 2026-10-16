"""Original NOVATERRA embossed logo asset, rendered without external fonts."""
from __future__ import annotations
from pathlib import Path
import struct
import zlib

GLYPHS = {
    "N": ("10001","11001","10101","10011","10001","10001","10001"),
    "O": ("01110","10001","10001","10001","10001","10001","01110"),
    "V": ("10001","10001","10001","10001","10001","01010","00100"),
    "A": ("01110","10001","10001","11111","10001","10001","10001"),
    "T": ("11111","00100","00100","00100","00100","00100","00100"),
    "E": ("11111","10000","10000","11110","10000","10000","11111"),
    "R": ("11110","10001","10001","11110","10100","10010","10001"),
}
WIDTH, HEIGHT = 880, 210

def _png_chunk(kind: bytes, data: bytes) -> bytes:
    packet=kind+data
    return struct.pack(">I",len(data))+packet+struct.pack(">I",zlib.crc32(packet)&0xFFFFFFFF)

def render_menu_logo(destination: Path) -> Path:
    width,height=WIDTH,HEIGHT
    pixels=bytearray(width*height*4)

    def span(y:int,x0:int,x1:int,c:tuple[int,int,int,int])->None:
        if 0<=y<height:
            x0=max(0,int(x0));x1=min(width,int(x1))
            if x1>x0:
                k=(y*width+x0)*4
                pixels[k:k+(x1-x0)*4]=bytes(c)*(x1-x0)

    def rectangle(x:int,y:int,w:int,h:int,c:tuple[int,int,int,int])->None:
        for yy in range(max(0,y),min(height,y+h)):
            span(yy,x,x+w,c)

    def poly(pts:list[tuple[int,int]],color:tuple[int,int,int,int])->None:
        for yy in range(max(0,min(y for _,y in pts)),min(height,max(y for _,y in pts))):
            intersections=[]
            for (a,b),(c,d) in zip(pts,pts[1:]+pts[:1]):
                if b!=d and min(b,d)<=yy<max(b,d):
                    intersections.append(a+(yy-b)*(c-a)/(d-b))
            intersections.sort()
            for i in range(0,len(intersections)-1,2):
                span(yy,intersections[i],intersections[i+1],color)

    # Rich forest crystal. Six facet planes, distinct from the reference gem.
    mx=width//2
    poly([(mx,1),(mx+57,51),(mx,91),(mx-57,51)],(29,38,38,255))
    poly([(mx,5),(mx+53,51),(mx,87),(mx-53,51)],(17,118,69,255))
    poly([(mx,5),(mx+53,51),(mx,40)],(62,204,109,255))
    poly([(mx,5),(mx-53,51),(mx,40)],(121,241,154,255))
    poly([(mx-53,51),(mx,40),(mx,87)],(16,107,80,255))
    poly([(mx+53,51),(mx,40),(mx,87)],(8,72,61,255))
    poly([(mx,5),(mx,40),(mx-13,55)],(208,255,198,255))

    title="NOVATERRA"
    unit=14
    kerning=9
    character=5*unit+kerning
    x0=(width-(len(title)*character-kerning))//2
    y0=82
    # Dark dimensional extrusion and pale golden upper edge.
    for i,glyph in enumerate(title):
        x=x0+i*character
        for row,line in enumerate(GLYPHS[glyph]):
            for col,bit in enumerate(line):
                if bit!="1":
                    continue
                px=x+col*unit
                py=y0+row*unit
                rectangle(px+7,py+13,unit,unit,(36,24,23,255))
                rectangle(px+4,py+7,unit,unit,(94,55,35,255))
                rectangle(px-2,py-3,unit+4,unit+4,(39,34,29,255))
    for i,glyph in enumerate(title):
        x=x0+i*character
        for row,line in enumerate(GLYPHS[glyph]):
            for col,bit in enumerate(line):
                if bit!="1":
                    continue
                px=x+col*unit
                py=y0+row*unit
                golden=(min(250,241-row*9),max(123,202-row*9),max(66,121-row*7),255)
                rectangle(px,py,unit,unit,golden)
                rectangle(px+2,py+2,unit-4,2,(255,226,155,255))
                rectangle(px+unit-2,py+3,2,unit-3,(173,108,56,255))

    # Decorative gold rails to tie the large wordmark to the in-game controls.
    rectangle(x0+7,HEIGHT-9,170,3,(197,151,83,255))
    rectangle(WIDTH-x0-177,HEIGHT-9,170,3,(197,151,83,255))
    destination=Path(destination)
    destination.parent.mkdir(parents=True,exist_ok=True)
    scan=b"".join(b"\x00"+pixels[y*width*4:(y+1)*width*4] for y in range(height))
    data=(b"\x89PNG\r\n\x1a\n"
          +_png_chunk(b"IHDR",struct.pack(">IIBBBBB",width,height,8,6,0,0,0))
          +_png_chunk(b"IDAT",zlib.compress(scan,7))
          +_png_chunk(b"IEND",b""))
    destination.write_bytes(data)
    return destination
