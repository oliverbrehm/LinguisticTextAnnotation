import pyphen


class Word:

    def __init__(self, text, stress_pattern, hyphenation):
        self.text = text
        self.stress_pattern = stress_pattern
        self.hyphenation = hyphenation

    def to_string(self):
        return self.text + ", " + self.stress_pattern + ", " + self.hyphenation


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
        # compute stress pattern
        stress_pattern = ""

        # syllables are split by - delimiter
        parts = phon_pattern.split('-')

        for i, p in enumerate(parts):
            syllable = p
            if len(p) > 0 and p[0] == '\'':
                # stressed syllables have ' annotation as first char
                stress_pattern += "1"
            else:
                stress_pattern += "0"

        # compute hyphenation
        hyphenation = self.pyphen_dict.inserted(text)
        # TODO check number of syllables same as stress pattern length

        word = Word(text, stress_pattern, hyphenation)
        self.words.append(word)

    def to_string(self):
        s = ""
        for word in self.words:
            s += word.to_string() + '\n'

        return s