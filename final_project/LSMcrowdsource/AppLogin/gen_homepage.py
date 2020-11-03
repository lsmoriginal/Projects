from django.shortcuts import render
from django.db import connection

def sqlquery(query, fetch = True):
    c = connection.cursor()
    c.execute(query)

    # a list of tuples containing results
    if fetch:
        results = c.fetchall()
        return results


def render_homepage(request):
    '''
    render the home page once log in is successful
    the page should first have:
        * a list of ongoing projects
            * sort by deadline (increasing/decreasing)
            * sort by completion percentage(increasing/decreasing)
        * a list of expired projects
            * sorting enabled
    '''
    userid = request.session['username']

    # get all my ongoing projects, even if there is no donation
    query = f'''
    CREATE OR REPLACE VIEW new_view AS
    SELECT projects.pid, projects.ptarget, COALESCE(donates.damt,0) as damt
    FROM 
	    projects 
	    LEFT JOIN donates ON projects.pid = donates.pid
        LEFT JOIN users ON projects.uid = users.uid
    WHERE
        users.uid = '{userid}' AND
        projects.pstartdate + (projects.pduration * INTERVAL '1 day') > NOW();
    SELECT new_view.pid, CAST(new_view.ptarget AS MONEY), CAST(SUM(new_view.damt) AS MONEY)
    FROM new_view
    GROUP BY new_view.pid, new_view.ptarget;
    '''
    header_ongoing = ["Title", "Target", "Gathered Amount"]
    proj_ongoing = sqlquery(query)

    # get all my exspired projects, even if there is no donation
    query = f'''
    CREATE OR REPLACE VIEW new_view AS
    SELECT projects.pid, projects.ptarget, COALESCE(donates.damt,0) as damt
    FROM 
	    projects 
	    LEFT JOIN donates ON projects.pid = donates.pid
        LEFT JOIN users ON projects.uid = users.uid
    WHERE
        users.uid = '{userid}' AND
        projects.pstartdate + (projects.pduration * INTERVAL '1 day') <= NOW();
    SELECT new_view.pid, CAST(new_view.ptarget AS MONEY), CAST(SUM(new_view.damt) AS MONEY)
    FROM new_view
    GROUP BY new_view.pid, new_view.ptarget;
    '''
    proj_expired = sqlquery(query)
    header_expired = header_ongoing

    # get all the projects that I can donating to
    query = f'''
    SELECT p1.pid, 
    CAST(p1.ptarget AS MONEY), 
    CAST(SUM(d1.damt) AS MONEY)
    FROM users u1, projects p1, donates d1
    WHERE
	    u1.uid = p1.uid AND
	    d1.pid = p1.pid
    GROUP BY p1.pid
    HAVING '{userid}' IN (
	    SELECT d2.uid
	    FROM donates d2, projects p2
	    WHERE p2.pid = d2.pid  AND
	    p1.pid = p2.pid
    );'''
    proj_donated = sqlquery(query)
    header_donated = header_ongoing

    # how much does the user has left?
    query = f'''
    SELECT users.ucash, users.upicurl
    FROM users
    WHERE users.uid = '{userid}';
    ''' 
    results = sqlquery(query)
    acc_bal = round(int(results[0][0]))
    upicurl = results[0][1]

    return render(
        request, 
        'AppUserhome/userhome.html',
        {
            'fullname': request.session['fullname'],
            'user_img': upicurl,
            'ongoing_projects': proj_ongoing,
            'header_ongoing': header_ongoing,
            'expired_projects': proj_expired,
            'header_expired': header_expired,
            'header_donated': header_donated,
            'donated_projects': proj_donated,
            'acc_bal': acc_bal,
        })