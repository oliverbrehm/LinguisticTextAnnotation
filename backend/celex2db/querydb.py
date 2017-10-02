import sqlite3

DATABASE_PATH = '../db/celex.db'

db = sqlite3.connect(DATABASE_PATH)
cursor = db.cursor()

cursor.execute("SELECT * FROM word")

print("fetchall:")
result = cursor.fetchall()

print("entries: " + str(len(result)))

for r in result:
    print(r)