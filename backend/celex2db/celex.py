import pyphen

import API.DictionaryService as DictionaryService

sys.path.append(os.path.relpath('../common'))
from common import common

class Dictionary:
    def __init__(self):
        # list of words
        self.words = []

        # init pyphen
        language = 'de_DE'

        if language in pyphen.LANGUAGES:
            self.pyphen_dict = pyphen.Pyphen(lang=language)
        else:
            print('language not found.')
            self.pyphen_dict = pyphen.Pyphen()

        pyphen.language_fallback(language + '_variant1')

    def add_word(self, text, phon_pattern):
        # preprocessing
        text = common.preprocess_entry(text)

        phon_pattern = phon_pattern.lower()

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

        word = DictionaryService.Word(text, stress_pattern, hyphenation)
        self.words.append(word)

        return True

    def to_string(self):
        s = ""
        for word in self.words:
            s += word.to_string() + '\n'

        return s