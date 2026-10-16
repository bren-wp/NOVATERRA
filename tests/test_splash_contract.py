"""NOVATERRA Android splash resource regression and responsive layout contract."""
from pathlib import Path
import unittest
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
RES = ROOT / "res"
ANDROID = "{http://schemas.android.com/apk/res/android}"


def attr(name):
    return ANDROID + name


class SplashContract(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.layout = ET.parse(RES / "layout/novaterra_splash.xml").getroot()
        cls.landscape = ET.parse(RES / "drawable/novaterra_landscape.xml").getroot()
        cls.overlay = ET.parse(RES / "drawable/novaterra_splash_background.xml").getroot()

    def test_original_splash_art_and_scaling(self):
        self.assertEqual(self.layout.tag, "FrameLayout")
        images = self.layout.findall("ImageView")
        self.assertEqual(len(images), 1, "Landscape must remain a real image layer")
        self.assertEqual(images[0].get(attr("src")), "@drawable/novaterra_landscape")
        self.assertEqual(images[0].get(attr("scaleType")), "centerCrop")
        self.assertEqual(self.landscape.tag, "vector")
        self.assertEqual(self.landscape.get(attr("viewportWidth")), "1080")
        self.assertEqual(self.landscape.get(attr("viewportHeight")), "1920")
        paths = self.landscape.findall("path")
        self.assertGreaterEqual(len(paths), 14)
        self.assertTrue(all(p.get(attr("pathData")) and p.get(attr("fillColor")) for p in paths))
        self.assertEqual(self.overlay.tag, "shape")
        self.assertIsNotNone(self.overlay.find("gradient"))

    def test_native_loading_hooks_survive(self):
        bars = [x for x in self.layout.iter() if x.get(attr("id")) == "@+id/progressBar"]
        labels = [x for x in self.layout.iter() if x.get(attr("id")) == "@+id/textView"]
        self.assertEqual(len(bars), 1)
        self.assertEqual(len(labels), 1)
        self.assertEqual(bars[0].tag, "ProgressBar")
        self.assertEqual(labels[0].tag, "TextView")
        self.assertEqual(bars[0].get(attr("indeterminate")), "false")
        self.assertEqual(bars[0].get(attr("max")), "100")
        self.assertEqual(bars[0].get(attr("visibility")), "gone")
        self.assertEqual(labels[0].get(attr("visibility")), "gone")
        self.assertEqual(labels[0].get(attr("text")), "@string/loading")

    def test_no_cropping_or_overlaps_from_fixed_screen_sizes(self):
        content = self.layout.find("LinearLayout")
        self.assertEqual(content.get(attr("layout_height")), "match_parent")
        self.assertEqual(content.get(attr("layout_width")), "match_parent")
        spacers = [node for node in content.findall("Space")]
        self.assertEqual(len(spacers), 2)
        for spacer in spacers:
            self.assertEqual(spacer.get(attr("layout_height")), "0dp")
            self.assertGreater(float(spacer.get(attr("layout_weight"))), 0)
        title = [x for x in content.findall("TextView") if x.get(attr("text")) == "NOVATERRA"]
        self.assertEqual(len(title), 1)
        self.assertEqual(title[0].get(attr("maxLines")), "1")
        self.assertIn("TVOJ SVIJET. BEZ GRANICA.",
                      [x.get(attr("text")) for x in content.findall("TextView")])


if __name__ == "__main__":
    unittest.main()
