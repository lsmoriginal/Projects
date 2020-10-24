from django.shortcuts import render
from django.db import connection

def sqlquery(query):
    c = connection.cursor()
    c.execute(query)

    # a list of tuples containing results
    results = c.fetchall()
    return results

# Create your views here.
def index(request):
    return render(request, 'AppUserhome/userhome.html', {})

def view_project(request, proj_id):

    # is this user the owner of the project?
    query =  f'''
    SELECT *
    FROM projects
    WHERE projects.pid = '{proj_id}';
    '''
    query_result = sqlquery(query)
    pid, uid, ptarget, pdeadline, pdesc, ppicurl = query_result[0]
    owner = uid
    is_owner = owner == request.session['username'] or request.session['username'] == "admin"

    # find the donors of the projects
    query = f'''
    SELECT donates.uid, SUM(donates.damt)
    FROM projects, donates
    WHERE projects.pid = donates.pid AND
    projects.pid = '{proj_id}'
    GROUP BY donates.uid
    ORDER BY SUM(donates.damt) DESC;
    '''
    donor_query_result = sqlquery(query)
    donor_header = ['Donor ID', 'Donated Amount']
    total_sum = sum(x[1] for x in donor_query_result)

    

    return render(
        request, 
        'AppUserhome/projectdesc.html', 
        {
            'project_name': proj_id,
            'is_owner': is_owner,
            'project_owner': owner,
            'prj_img': ppicurl,
            'pdeadline': pdeadline.date(),
            'ptarget': ptarget,
            'pdesc': pdesc,
            'donor_header': donor_header,
            'donor_query_result': donor_query_result,
            'total_sum': total_sum,
            'progress': round(total_sum/ptarget * 100),
        })