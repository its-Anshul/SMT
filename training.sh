    #! /bin/bash
	echo "Starting the Training. It might take 2-3 hours, so request you to have patience."
	mkdir corpus
	cd corpus
	wget https://www.isi.edu/natural-language/download/hansard/hansard.36.r2001-1a.house.debates.training.tar
	tar zxvf hansard.36.r2001-1a.house.debates.training.tar
	cd .\hansard.36\Release-2001.1a\sentence-pairs\house\debates\development\training
	gzip -d *
	cat *.e > hans.en
	cat *.f > hans.fr
	iconv -f iso-8859-1 -t utf-8 hans.en > hansard.en
	iconv -f iso-8859-1 -t utf-8 hans.fr > hansard.fr
	cp hansard.en ../../../../../../../hansard.en
	cp hansard.fr ../../../../../../../hansard.fr
	cd ../../../../../../../../
	/home/moses/mosesdecoder/scripts/tokenizer/tokenizer.perl -l en < /home/moses/corpus/hansard.en  > /home/moses/corpus/hansard.fr-en.tok.en
	/home/moses/mosesdecoder/scripts/tokenizer/tokenizer.perl -l fr < /home/moses/corpus/hansard.fr  > /home/moses/corpus/hansard.fr-en.tok.fr
	/home/moses/mosesdecoder/scripts/recaser/train-truecaser.perl --model /home/moses/corpus/truecase-model.en --corpus /home/moses/corpus/hansard.fr-en.tok.en
	/home/moses/mosesdecoder/scripts/recaser/train-truecaser.perl --model /home/moses/corpus/truecase-model.fr --corpus /home/moses/corpus/hansard.fr-en.tok.fr
	/home/moses/mosesdecoder/scripts/recaser/truecase.perl --model /home/moses/corpus/truecase-model.en < /home/moses/corpus/hansard.fr-en.tok.en > /home/moses/corpus/hansard.fr-en.true.en
	/home/moses/mosesdecoder/scripts/recaser/truecase.perl --model /home/moses/corpus/truecase-model.fr < /home/moses/corpus/hansard.fr-en.tok.fr > /home/moses/corpus/hansard.fr-en.true.fr
	/home/moses/mosesdecoder/scripts/training/clean-corpus-n.perl /home/moses/corpus/hansard.fr-en.true fr en /home/moses/corpus/hansard.fr-en.clean 1 80
	mkdir lm
	cd lm
	/home/moses/mosesdecoder/bin/lmplz -o 3 < /home/moses/corpus/hansard.fr-en.true.en > hansard.fr-en.arpa.en
	/home/moses/mosesdecoder/bin/build_binary hansard.fr-en.arpa.en hansard.fr-en.blm.en
	 echo "is this an English sentence ?" | /home/moses/mosesdecoder/bin/query news-commentary-v8.fr-en.blm.en
	 cd ..
	 ---------------------------------------------------------------------------------------------------------------------------------------------------------------
	 mkdir working
	 cd working
	 nohup nice /home/moses/mosesdecoder/scripts/training/train-model.perl -root-dir train -corpus /home/moses/corpus/hansard.fr-en.clean -f fr -e en -alignment grow-diag-final-and -reordering msd-bidirectional-fe -lm 0:3:/home/moses/lm/hansard.fr-en.blm.en:8 -external-bin-dir /home/moses/mosesdecoder/tools >& training.out 
	 mkdir binarised-model
	 /home/moses/mosesdecoder/bin/processPhraseTableMin -in train/model/phrase-table.gz -nscores 4 -out binarised-model/phrase-table
	 /home/moses/mosesdecoder/bin/processLexicalTableMin  -in train/model/reordering-table.wbe-msd-bidirectional-fe.gz -out binarised-model/reordering-table

