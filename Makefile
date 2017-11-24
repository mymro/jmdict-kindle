PYTHON ?= python

default: jmdict.mobi

edict2.gz enamdict.gz JMdict_e.gz JMnedict.xml.gz:
	wget -nv -N http://ftp.monash.edu.au/pub/nihongo/$@

KINDLEGEN_PKG ?= kindlegen_linux_2.6_i386_v2_9.tar.gz

$(KINDLEGEN_PKG):
	wget -nv -N https://kindlegen.s3.amazonaws.com/$@

kindlegen: $(KINDLEGEN_PKG)
	tar -xzf $(KINDLEGEN_PKG) kindlegen
	touch $@

%.txt: %.gz edict_to_txt.py
	$(PYTHON) edict_to_txt.py $< > $@

jmdict.opf: jmdict.py dictionary.py inflections.py kana.py JMdict_e.gz
	$(PYTHON) jmdict.py

cover.jpg: cover.py
	$(PYTHON) cover.py

# XXX: The Kindle Publishing Guidelines recommend -c2 (huffdic compression),
# but it is excruciatingly slow.
COMPRESSION ?= 1

jmdict.full.mobi: jmdict.opf cover.jpg style.css frontmatter.html kindlegen
	./kindlegen $< -c$(COMPRESSION) -verbose -o $@

%.mobi: %.full.mobi kindlestrip.py
	$(PYTHON) kindlestrip.py $< $@

clean:
	rm -f *.mobi *.opf entry-*.html cover.jpg

.PHONE: default clean
