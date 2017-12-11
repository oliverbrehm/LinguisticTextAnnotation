import pyphen

class CelexLemma:
    def __init__(self, id_num_lemma, text, pos_tag):
        self.id_num_lemma = id_num_lemma
        self.text = text
        self.pos_tag = pos_tag

    def __str__(self):
        return str(self.id_num_lemma) \
               + ', ' + str(self.text) \
               + ', ' + str(self.pos_tag)

class CelexWord:
    def __init__(self, text, stress_pattern, hyphenation, lemma, pos):
        self.text = text
        self.stress_pattern = stress_pattern
        self.hyphenation = hyphenation
        self.pos = pos
        self.lemma = lemma


class CelexDictionary:
    def __init__(self):
        # list of words
        self.words = []

        # hashmap of lemmas
        self.lemmas = {}

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

            lemma = CelexLemma(lemma_id, text, pos_tag)
            self.lemmas[lemma_id] = lemma

            # read only max lines
            numParsed = numParsed + 1
            if current >= max_lines:
                break

        print("parsed " + str(numParsed) + " lemmas in total, no pos tags for " + str(numErrors) + " lemmas.")


    def parse_words(self, max_lines, step_size):
        # open celex2 file (gpw.cd)
        gpwFile = open("./celex2/german/gpw/gpw.cd")
        gowFile = open("./celex2/german/gow/gow.cd")

        current = 0
        numParsed = 0
        numErrors = 0

        while True:
            lineGpw = gpwFile.readline()
            lineGow = gowFile.readline()
            if not lineGpw or not lineGow:
                break

            if current > 0 and current % step_size == 0:
                print("parsed " + str(numParsed) + " words...", "ERRORS:", numErrors)

            current = current + 1

            text, word_id, lemma, phon, pos_tag = self.parsePhoneticEntry(lineGpw)
            if not text:
                numErrors = numErrors + 1
                continue

            hyphenation = self.parseOrthograficEntry(lineGow, word_id)
            if not hyphenation:
                numErrors = numErrors + 1
                continue

            if not self.add_word(text, phon, hyphenation, pos_tag, lemma):
                numErrors = numErrors + 1

            # read only max lines
            numParsed = numParsed + 1
            if current >= max_lines:
                break

        print("parsed " + str(numParsed) + " words in total.", "ERRORS:", numErrors)

    def add_word(self, text, phon_pattern, hyphenation, pos_tag, lemma):
        # preprocessing
        text = text.lower()
        hyphenation = hyphenation\
            .replace('"a', 'ä')\
            .replace('"o', 'ö')\
            .replace('"u', 'ü')\
            .replace('"A', 'Ä')\
            .replace('"O', 'Ö')\
            .replace('"U', 'Ü')\
            .replace('$', 'ß')\
            .replace('=', '-')

        if '$' in text or '$' in hyphenation:
            print(text, hyphenation)

        # determine stress pattern
        stress_pattern = ""

        # syllables are split by - or = delimiter
        syllables_orth = hyphenation.split('-')
        syllables_phon = phon_pattern.split('-')

        for s in syllables_phon:
            if len(s) > 0:
                if s[0] == '\'':
                    # stressed syllables have ' annotation as first char
                    stress_pattern += "1"
                else:
                    stress_pattern += "0"

        # check if orthographic syllables agree with phonological syllables
        num_syllables_orth = 0
        for s in syllables_orth:
            if len(s) > 0:
                num_syllables_orth = num_syllables_orth + 1

        if len(stress_pattern) != num_syllables_orth:
            print('orth and phon syllables do not match (', phon_pattern, ", ", hyphenation, "), phon: ", len(stress_pattern), ", orth:", num_syllables_orth)
            return False

        word = CelexWord(text, stress_pattern, hyphenation, lemma, pos_tag)
        #print(str(word))
        self.words.append(word)

        return True

    def to_string(self):
        s = ""
        for word in self.words:
            s += word.to_string() + '\n'

        return s

    def parsePhoneticEntry(self, line):
        components = line.split('\\')
        if len(components) < 5:
            # phonetic pattern should be the 5th part
            return None

        word_id = components[0]
        text = components[1]
        lemma_id = components[3]
        phon = components[4]

        lemma = None
        if lemma_id in self.lemmas:
            lemma = self.lemmas[lemma_id]

        pos_tag = 'na'

        if lemma:
            pos_tag = lemma.pos_tag
        else:
            print('no lemma for word', text, ", id:", lemma_id)

        return text, word_id, lemma.text, phon, pos_tag

    def parseOrthograficEntry(self, line, word_id_phon):
        components = line.split('\\')
        if len(components) < 5:
            # phonetic pattern should be the 5th part
            return None

        word_id = components[0]

        if word_id != word_id_phon:
            print('phon and orth ids not identical (orth:', word_id, ", phon:", word_id_phon, ")")
            return None

        hyphenation = components[4]

        return hyphenation