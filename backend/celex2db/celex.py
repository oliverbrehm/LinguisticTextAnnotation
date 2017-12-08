import sys, os
sys.path.append(os.path.relpath('../API'))

import pyphen

import API.DictionaryService as DictionaryService

class Lemma:
    def __init__(self, id_num_lemma, text, pos_tag):
        self.id_num_lemma = id_num_lemma
        self.text = text
        self.pos_tag = pos_tag

    def __str__(self):
        return str(self.id_num_lemma) \
               + ', ' + str(self.text) \
               + ', ' + str(self.pos_tag)

class Dictionary:
    def __init__(self):
        # list of words
        self.words = []

        # list of lemmas
        self.lemmas = []

        # init pyphen
        language = 'de_DE'

        if language in pyphen.LANGUAGES:
            self.pyphen_dict = pyphen.Pyphen(lang=language)
        else:
            print('language not found.')
            self.pyphen_dict = pyphen.Pyphen()

        pyphen.language_fallback(language + '_variant1')

        self.pos_map = {
            'N': "noun",
            'A': "adj",
            'Q': "num",
            'V': "verb",
            'D': "det",
            'O': "pron",
            'B': "adv",
            'P': "adp",
            'C': "conj",
            'I': "propn",
            'X': "propn",
            'F': "na",
            'R': "na",
        }

    def find_lemma(self, id_num_lemma):
        # TODO bad iterating over list, use hashmap for lemmas
        for lemma in self.lemmas:
            if int(lemma.id_num_lemma) == int(id_num_lemma):
                return lemma

    def map_pos(self, pos_char):
        if pos_char in self.pos_map:
            return self.pos_map[pos_char]
        else:
            return "na"

    def parse_lemmas(self, max_lines, step_size):
        # open celex2 gml
        gpwFile = open("./celex2/german/gml/gml.cd")

        current = 0
        numParsed = 0
        numErrors = 0

        while True:
            line = gpwFile.readline()
            if not line:
                break

            if current > 0 and current % step_size == 0:
                print("parsed " + str(numParsed) + " lemmas...")

            current = current + 1

            components = line.split('\\')
            if len(components) < 14:
                # word class should be the 14th part
                continue

            lemma_id = components[0]
            text = components[1]
            word_class = components[13]

            pos_tag = 'na'

            index_end = word_class.rfind(']')
            if index_end < 2:
                numErrors = numErrors + 1
            else:
                pos_tag_char = word_class[index_end - 1]
                pos_tag = self.map_pos(pos_tag_char)
                error = False

            lemma = Lemma(lemma_id, text, pos_tag)
            self.lemmas.append(lemma)

            # read only max lines
            numParsed = numParsed + 1
            if current >= max_lines:
                break

        print("parsed " + str(numParsed) + " lemmas in total, no pos tags for " + str(numErrors) + " lemmas.")


    def parse_words(self, max_lines, step_size):
        # open celex2 file (gpw.cd)
        gpwFile = open("./celex2/german/gpw/gpw.cd")

        current = 0
        numParsed = 0
        numErrors = 0

        while True:
            line = gpwFile.readline()
            if not line:
                break

            if current > 0 and current % step_size == 0:
                print("parsed " + str(numParsed) + " words...", "ERRORS:", numErrors)

            current = current + 1

            components = line.split('\\')
            if len(components) < 5:
                # phonetic pattern should be the 5th part
                continue

            text = components[1]
            lemma_id = components[3]
            phon = components[4]

            lemma = self.find_lemma(int(lemma_id))

            pos_tag = 'na'
            if lemma:
                pos_tag = lemma.pos_tag
            else:
                print('no lemma for word', text, ", id:", lemma_id)

            if not self.add_word(text, phon, "", pos_tag): # TODO
                numErrors = numErrors + 1

            # read only max lines
            numParsed = numParsed + 1
            if current >= max_lines:
                break

        print("parsed " + str(numParsed) + " words in total.", "ERRORS:", numErrors)

    def add_word(self, text, phon_pattern, hyphenation, pos_tag):
        # preprocessing
        text = self.preprocess_entry(text)

        # determine stress pattern
        stress_pattern = ""

        # syllables are split by - delimiter
        parts = phon_pattern.split('-')

        for p in parts:
            if len(p) > 0 and p[0] == '\'':
                # stressed syllables have ' annotation as first char
                stress_pattern += "1"
            else:
                stress_pattern += "0"

        # compute hyphenation
        hyphenation = self.pyphen_dict.inserted(text)

        # check if phyphen syllables agree with celex syllables
        syllables_pyphen = hyphenation.split('-')
        if len(parts) != len(syllables_pyphen):
            return False

        word = DictionaryService.Word(text, stress_pattern, hyphenation, pos_tag)
        print(str(word))
        self.words.append(word)

        return True

    def preprocess_entry(self, text):
        # TODO ß, ae...
        text = text.lower()
        return text

    def to_string(self):
        s = ""
        for word in self.words:
            s += word.to_string() + '\n'

        return s