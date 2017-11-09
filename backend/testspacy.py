import spacy

# Load English tokenizer, tagger, parser, NER and word vectors
nlp = spacy.load('de')
nlpe = spacy.load('en')

# Process a document, of any size
text = 'Aus den Sondierungsgesprächen von Union, Grünen und FDP dringen erste Kompromissangebote nach außen.'
doc = nlp(text)

# Find named entities, phrases and concepts
#for entity in doc.ents:
#    print(entity.text, entity.label_)

# Determine semantic similarities
doc1 = nlpe(u'the fries were gross')
doc2 = nlpe(u'worst fries ever')
print(doc1.similarity(doc2))