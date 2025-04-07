import sys
import digitalio
import busio
import board
from PIL import Image
from adafruit_epd.ssd1680 import Adafruit_SSD1680

spi = busio.SPI(board.SCK, MOSI=board.MOSI, MISO=board.MISO)
display = Adafruit_SSD1680(122, 250, spi,
    cs_pin=digitalio.DigitalInOut(board.CE0),
    dc_pin=digitalio.DigitalInOut(board.D22),
    sramcs_pin=None,
    rst_pin=digitalio.DigitalInOut(board.D27),
    busy_pin=digitalio.DigitalInOut(board.D17),
)
display.rotation = 1

img = Image.open(sys.argv[1])
display.image(img)
display.display()
