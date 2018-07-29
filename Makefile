# vim: noexpandtab filetype=make
# $                                                             .a$      $`
#  `$                                                          $       ,$`
#   `$                                                      a$$        $
#     a'                   '                $'         $    $         $
#     $                   $               $$'          `$ $$'    `$ ,$
#     $.,                  $'            a$'            `$$'       "$'
#     `$"                 $'         $' $'               `$       a,$,
#     `$,a         '    a$'           $$$                $         $`$
#       $'           $, $              $'                             $' `$,
#     ,$'             a$'                                                  $
#     $               $                                                    `$
#      '$                                  .                               $'
#      $    ,a"                                                           , '$
#     `,a" $    a,$             +++           BONE KIDZ          +++       'a
#     a'    "$$' , `a$                                                       $
#     $     a'  ,$,                   +++  Burning Man 2018 +++            a,.$
#     $.,a$"' ,$'`$                                                       '"$`
#     `$"' ,a$'   `$,                                                     a,$`
#     `$,a$'        $                   ,aaaa$""  $$$$$$$$$$$aaa,         '$
#       $'          `a$            ,aa$""   aa"aa$$$"$$$$$$$$$$$$$aa       '$,
#     ,$'             ;          a$$$" aa$$$a   $$a$$$$$$l$$$$"$" ""$a       $
#     $    ,a"$       $        a$$$"a$$$"$$$ $$ "aa""aa""$ $"$$a a"$  ",     $
#     $' ,$"  `     ,$'    $  $"$$$$"$$$$$ $$a  "aa$ a a""" a$a " $$     $
#     $  $          $a   a'  $$$$$$$$$$""""$$$$$ia$$$$$,1$$$$a$$$$$$$a1$$   $'
#     ',$'     ,a$a   `a    $$$$$$$$$aa$$$$a  ""$$$$$$$"$$ l$$'$$$$$$$a$$$ $'
#      $    ,a"    `a'  `  ,$$$$$$$$$$$$$$$$$,   """"$$$$$$a$$$$`$$$$$$$$$,
#     $' ,$"               $$$$$$$$"$$$$$$$$$" a$$$$$aa`"$$$""$;$$$$$"aa$a
#     `,a" $    a,$        $$$$$$$$$$$$"$$$$$ a$$$$$"""$$aa`$$a$$ $$""a$$$$$$
#     a'    "a$'   `a$     $$$$$$$$$$'   ""' a$$$"       "$$a`$"" aa$$$"$$$$'
#     $              $      "$$$$"""'      a$$$$           `$$$a"$$$$"a"  "
#     $.            'a       a"$a$$"  a  $$$$$$'             `""$$$$'
#     `$'$            $      1  $$" a$$   $$$$$               a$$"
#     `$,`$            `a   ,`$  $  "$$a   $$$$$             $$$'           ,
#      `$ `             $   $ `$  $$" aaa  "$$$$$a          $$$'           a1
#      ,$               `$a'    " 1a$$$$$$$aaa"""$$$$$$$aa $$$l     laaaa""$a
#     .$'                          $    `"""$aa$$$$$$$$$$"$$$$$     $$$aa$$"
#     $'                           `"aaa""$$$" $$$$$$$$" "$a1$$  a  $$$$$$'
#     $                                "" z`""  $""""     1$$$a$$$$$"$$"'
#     `a     a'                                 $$$aa  a$al$$$$$$$a$'
#       `a,aa,"                                 a"" $$,$$$"l$$"$$"$ $
#                                                $" a""aa",a $"aa""a" a
#                                                ' ,`$ "$$l $$$ $$"$"
#                                                        " `$  `$ $' `
#
# make all = Make software.
# make clean = Clean out built project files.
# make upload = Upload the hex file to the device

# Valid targets == LC,36
TEENSY = 36
TARGET = bonez
COREPATH = teensy3
LIBRARYPATH = libraries
TOOLSPATH = $(CURDIR)/tools
COMPILERPATH = $(TOOLSPATH)/arm/bin
BUILDDIR = $(abspath $(CURDIR)/build)
COMPILER_OPTIMIZATION = Os  # Embedded systems love space

#TEENSY_CORE_SPEED = 180000000
TEENSY_CORE_SPEED = 48000000

OPTIONS = -DUSB_SERIAL -DLAYOUT_US_ENGLISH

# CPPFLAGS = compiler options for C and C++ preprocessor
CPPFLAGS = \
	-DARDUINO=10805 \
	-DF_CPU=$(TEENSY_CORE_SPEED) \
	-DTEENSYDUINO=141 \
	-I$(COREPATH) \
	-Isrc \
	-MMD \
	-$(COMPILER_OPTIMIZATION) \
	-Wall \
	-fdata-sections \
	-ffunction-sections \
	-fsingle-precision-constant \
	-g \
	-mthumb \
	-nostdlib \
	$(OPTIONS)

# compiler options for C++ only
CXXFLAGS = \
	-std=gnu++14 \
	-felide-constructors \
	-fno-exceptions \
	-fno-rtti

# compiler options for C only
CFLAGS =

# linker options
LDFLAGS = \
	-$(COMPILER_OPTIMIZATION) \
	-Wl,--gc-sections,--defsym=__rtc_localtime=0 \
	-mthumb

# additional libraries to link
LIBS = -lm

# names for the compiler programs
CC = $(abspath $(COMPILERPATH))/arm-none-eabi-gcc
CXX = $(abspath $(COMPILERPATH))/arm-none-eabi-g++
OBJCOPY = $(abspath $(COMPILERPATH))/arm-none-eabi-objcopy
SIZE = $(abspath $(COMPILERPATH))/arm-none-eabi-size

# automatically create lists of the sources and objects
LC_FILES := $(wildcard $(LIBRARYPATH)/*/*.c)
LCPP_FILES := $(wildcard $(LIBRARYPATH)/*/*.cpp)
TC_FILES := $(wildcard $(COREPATH)/*.c)
TCPP_FILES := $(wildcard $(COREPATH)/*.cpp)
C_FILES := $(wildcard src/*.c)
CPP_FILES := $(wildcard src/*.cpp)
INO_FILES := $(wildcard src/*.ino)

# include paths for libraries
L_INC = $(foreach lib,$(filter %/, $(wildcard $(LIBRARYPATH)/*/)), -I$(lib))

SOURCES := \
	$(C_FILES:.c=.o) \
	$(CPP_FILES:.cpp=.o) \
	$(INO_FILES:.ino=.o) \
	$(TC_FILES:.c=.o) \
	$(TCPP_FILES:.cpp=.o) \
	$(LC_FILES:.c=.o) \
	$(LCPP_FILES:.cpp=.o)
OBJS := $(foreach src,$(SOURCES), $(BUILDDIR)/$(src))

ifeq ($(TEENSY), 36)
    CPPFLAGS += -D__MK66FX1M0__ -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16
    LDSCRIPT = $(COREPATH)/mk66fx1m0.ld
    LDFLAGS += -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -T$(LDSCRIPT)
    LIBS += -larm_cortexM4lf_math
else ifeq ($(TEENSY), LC)
    CPPFLAGS += -D__MKL26Z64__ -mcpu=cortex-m0plus
    LDSCRIPT = $(COREPATH)/mkl26z64.ld
    LDFLAGS += -mcpu=cortex-m0plus -T$(LDSCRIPT)
    LIBS += -larm_cortexM0l_math
else
    $(error Invalid setting for TEENSY $(TEENSY) != LC or 36 )
endif

begin:
	@echo "`cat skull.txt`\n"
	@echo =============================================================================
	@echo ============= Compile starting .. $(shell date) ==============

end:
	@echo ============= Compile complete .. $(shell date) ==============
	@echo

all: begin hex end

build: $(TARGET).elf

hex: $(TARGET).hex

post_compile: $(TARGET).hex
	@echo "Informing the Teensy Loader of freshly compiled code..."
	@$(abspath $(TOOLSPATH))/teensy_post_compile \
		-file="$(basename $<)" \
		-path=$(CURDIR) \
		-tools="$(abspath $(TOOLSPATH))"

reboot:
	@echo "Rebooting Teensy..."
	@-$(abspath $(TOOLSPATH))/teensy_reboot

upload: begin post_compile reboot end

$(BUILDDIR)/%.o: %.c
	@echo -e "[CC]\t$<"
	@mkdir -p "$(dir $@)"
	@$(CC) $(CPPFLAGS) $(CFLAGS) $(L_INC) -o "$@" -c "$<"

$(BUILDDIR)/%.o: %.cpp
	@echo -e "[CXX]\t$<"
	@mkdir -p "$(dir $@)"
	@$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(L_INC) -o "$@" -c "$<"

$(BUILDDIR)/%.o: %.ino
	@echo -e "[CXX]\t$<"
	@mkdir -p "$(dir $@)"
	@$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(L_INC) -o "$@" -x c++ -include Arduino.h -c "$<"

$(TARGET).elf: $(OBJS) $(LDSCRIPT)
	@echo -e "[LD]\t$@"
	@$(CC) $(LDFLAGS) -o "$@" $(OBJS) $(LIBS)

%.hex: %.elf
	@echo -e "[HEX]\t$@"
	@$(SIZE) "$<"
	@$(OBJCOPY) -O ihex -R .eeprom "$<" "$@"

# compiler generated dependency info
-include $(OBJS:.o=.d)

clean:
	@echo "Deleting files:"
	@rm -rfv "$(BUILDDIR)"
	@rm -fv "$(TARGET).elf" "$(TARGET).hex"
