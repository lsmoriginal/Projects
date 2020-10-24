from django.shortcuts import render
from django.db import connection

def sqlquery(query):
    c = connection.cursor()
    c.execute(query)

    # a list of tuples containing results
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

    query = f'''
    SELECT projects.pid, DATE(projects.pdeadline), projects.ptarget, SUM(donates.damt) FROM
    users, projects, donates
    WHERE users.uid = projects.uid AND
    donates.pid = projects.pid AND
    users.uid = '{userid}' AND
    pdeadline > NOW()
    GROUP BY projects.pid;'''
    header_ongoing = ["Project ID", "Due Date", "Target", "Gathered Amount"]
    proj_ongoing = sqlquery(query)

    query = f'''
    SELECT projects.pid, DATE(projects.pdeadline), projects.ptarget, SUM(donates.damt) FROM
    users, projects, donates
    WHERE users.uid = projects.uid AND
    donates.pid = projects.pid AND
    users.uid = '{userid}' AND
    pdeadline <= NOW()
    GROUP BY projects.pid;'''
    proj_expired = sqlquery(query)
    header_expired = header_ongoing

    query = f'''
    SELECT p1.pid, DATE(p1.pdeadline), p1.ptarget, SUM(d1.damt)
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


    return render(
        request, 
        'AppUserhome/userhome.html',
        {
            'fullname': request.session['fullname'],
            'ongoing_projects': proj_ongoing,
            'header_ongoing': header_ongoing,
            'expired_projects': proj_expired,
            'header_expired': header_expired,
            'header_donated': header_donated,
            'donated_projects': proj_donated,
        })
