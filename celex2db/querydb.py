import sqlite3

db = sqlite3.connect("celex.db")
cursor = db.cursor()

cursor.execute("SELECT * FROM word")

print("fetchall:")
result = cursor.fetchall()

for r in result:
    print(r)