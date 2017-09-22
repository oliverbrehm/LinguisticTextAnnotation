class Word:

    def __init__(self, text, syllables, stressed):
        self.text = text
        self.syllables = syllables
        self.stressed = stressed

    syllables = []  # list of String
    stressed = -1   # index of stressed syllable

    def pattern(self):
        s = ""
        for i, syllable in enumerate(self.syllables):
            if i == self.stressed:
                s += "'"
            s += syllable
            if i != len(self.syllables) - 1:
                s += "-"

        return s

class Celex2:
    def __init__(self):
        # list of words
        self.words = []

    def add_word(self, text, syllables, stressed):
        word = Word(text, syllables, stressed)
        self.words.append(word)

    def to_string(self):
        s = ""
        for word in self.words:
            s += word.text + ": " + word.to_string() + '\n'

        return s