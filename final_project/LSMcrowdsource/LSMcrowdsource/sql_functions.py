from django.db import connection

def sqlquery(query, fetch = True):
    c = connection.cursor()
    c.execute(query)

    # a list of tuples containing results
    if fetch:
        results = c.fetchall()
        return results

def get_users(access):
    query = f'''SELECT * FROM get_users('{access}');'''
    results = sqlquery(query)
    return results

def get_project(access):
    query = f'''SELECT * FROM get_projects('{access}');'''
    return sqlquery(query)

def get_donates(access):
    query = f'''SELECT uid, pid, dtime, CAST(damt AS MONEY) FROM get_donates('{access}');'''
    return sqlquery(query)

def is_donable(proj):
    query = f'''SELECT * FROM is_donable('{proj}');'''
    result = sqlquery(query)[0][0]
    print(result)
    return result

def search_all_going_proj():
    query = '''SELECT * FROM search_all_going_proj();'''
    results = sqlquery(query)
    return results

def search_all_funded_proj():
    query = '''SELECT * FROM search_all_funded_proj();'''
    results = sqlquery(query)
    return results

def search_all_failed_proj():
    query = '''SELECT * FROM search_all_failed_proj();'''
    results = sqlquery(query)
    return results