# working and output directories
POS_DIR = pos
NEG_DIR = neg
OUT_DIR = out

# listings of files
POS_DAT = pos.txt
NEG_DAT = neg.txt

# raw data
POS_RAW = $(wildcard raw-data/pos/*.jpg)
NEG_RAW = $(wildcard raw-data/neg/*.jpg)

# raw data after conversion
POS = $(POS_RAW:raw-data/pos/%.jpg=$(POS_DIR)/%.jpg)
NEG = $(NEG_RAW:raw-data/neg/%.jpg=$(NEG_DIR)/%.jpg)

# vector files
OUT_VEC = out.vec

default: prepare $(OUT_VEC) $(NEG_DAT)
	opencv_traincascade -data $(OUT_DIR) -vec $(OUT_VEC) -bg $(NEG_DAT) -numPos 900 -numNeg 4 -w 25 -h 25 -numThreads 3 -numStages 25

prepare: $(POS_DIR) $(NEG_DIR) $(OUT_DIR)

$(POS_DIR):
	mkdir -p $@

$(NEG_DIR):
	mkdir -p $@

$(OUT_DIR):
	mkdir -p $@

$(POS_DIR)/%.jpg: raw-data/pos/%.jpg
	convert $^ -colorspace GRAY -resize 25x25 $@

$(NEG_DIR)/%.jpg: raw-data/neg/%.jpg
	convert $^ -colorspace GRAY $@

$(NEG_DAT): $(NEG)
	ls neg/* | tr ' ' '\n' > $@

$(OUT_VEC): $(POS) $(NEG_DAT)
	opencv_createsamples -vec $@ -img $(POS) -bg $(NEG_DAT) -num 1000 -w 25 -h 25

clean:
	@if [ -d "$(POS_DIR)" ]; then \
		rm -r $(POS_DIR) ; \
	fi
	@if [ -d "$(NEG_DIR)" ]; then \
		rm -r $(NEG_DIR) ; \
	fi
	@if [ -d "$(OUT_DIR)" ]; then \
		rm -r $(OUT_DIR) ; \
	fi
	@if [ -f "$(OUT_VEC)" ]; then \
		rm $(OUT_VEC) ; \
	fi
	@if [ -f "$(NEG_DAT)" ]; then \
		rm $(NEG_DAT) ; \
	fi

.PHONY: default prepare clean
