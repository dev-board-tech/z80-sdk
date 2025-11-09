IFNDEF SSD1306_S_H
DEFINE SSD1306_S_H

DEFC SSD1306_I2C_ADDRESS							= 0x3C << 1; 011110+SA0+RW - 0x3C or 0x3D


DEFC SSD1306_BLACK               					= 0    ;< Draw 'off' pixels
DEFC SSD1306_WHITE               					= 1    ;< Draw 'on' pixels
DEFC SSD1306_INVERSE             					= 2    ;< Invert pixels

DEFC SSD1306_MEMORYMODE          					= 0x20 ;< See datasheet
DEFC SSD1306_COLUMNADDR          					= 0x21 ;< See datasheet
DEFC SSD1306_PAGEADDR            					= 0x22 ;< See datasheet
DEFC SSD1306_SETCONTRAST         					= 0x81 ;< See datasheet
DEFC SSD1306_CHARGEPUMP          					= 0x8D ;< See datasheet
DEFC SSD1306_SEGREMAP            					= 0xA0 ;< See datasheet
DEFC SSD1306_DISPLAYALLON_RESUME 					= 0xA4 ;< See datasheet
DEFC SSD1306_DISPLAYALLON        					= 0xA5 ;< Not currently used
DEFC SSD1306_NORMALDISPLAY       					= 0xA6 ;< See datasheet
DEFC SSD1306_INVERTDISPLAY       					= 0xA7 ;< See datasheet
DEFC SSD1306_SETMULTIPLEX        					= 0xA8 ;< See datasheet
DEFC SSD1306_DISPLAYOFF          					= 0xAE ;< See datasheet
DEFC SSD1306_DISPLAYON           					= 0xAF ;< See datasheet
DEFC SSD1306_COMSCANINC          					= 0xC0 ;< Not currently used
DEFC SSD1306_COMSCANDEC          					= 0xC8 ;< See datasheet
DEFC SSD1306_SETDISPLAYOFFSET   					= 0xD3 ;< See datasheet
DEFC SSD1306_SETDISPLAYCLOCKDIV  					= 0xD5 ;< See datasheet
DEFC SSD1306_SETPRECHARGE        					= 0xD9 ;< See datasheet
DEFC SSD1306_SETCOMPINS          					= 0xDA ;< See datasheet
DEFC SSD1306_SETVCOMDETECT       					= 0xDB ;< See datasheet

DEFC SSD1306_SETLOWCOLUMN        					= 0x00 ;< Not currently used
DEFC SSD1306_SETHIGHCOLUMN       					= 0x10 ;< Not currently used
DEFC SSD1306_SETSTARTLINE        					= 0x40 ;< See datasheet

DEFC SSD1306_EXTERNALVCC         					= 0x01 ;< External display voltage source
DEFC SSD1306_SWITCHCAPVCC        					= 0x02 ;< Gen. display voltage from 3.3V

DEFC SSD1306_RIGHT_HORIZONTAL_SCROLL              	= 0x26 ;< Init rt scroll
DEFC SSD1306_LEFT_HORIZONTAL_SCROLL               	= 0x27 ;< Init left scroll
DEFC SSD1306_VERTICAL_AND_RIGHT_HORIZONTAL_SCROLL 	= 0x29 ;< Init diag scroll
DEFC SSD1306_VERTICAL_AND_LEFT_HORIZONTAL_SCROLL  	= 0x2A ;< Init diag scroll
DEFC SSD1306_DEACTIVATE_SCROLL                    	= 0x2E ;< Stop scroll
DEFC SSD1306_ACTIVATE_SCROLL                      	= 0x2F ;< Start scroll
DEFC SSD1306_SET_VERTICAL_SCROLL_AREA             	= 0xA3 ;< Set scroll range


ENDIF
