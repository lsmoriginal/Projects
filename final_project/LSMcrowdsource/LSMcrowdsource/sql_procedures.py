from django.db import connection

def sqlquery(query, fetch = True):
    c = connection.cursor()
    c.execute(query)

    # a list of tuples containing results
    if fetch:
        results = c.fetchall()
        return results

def donate(sender, receiver, amt):
    query = f'''CALL donate_to('{sender}', '{receiver}', {amt});'''
    sqlquery(query, fetch=False)