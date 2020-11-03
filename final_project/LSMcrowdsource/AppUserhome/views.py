from django.shortcuts import render
from django.db import connection
import datetime

from AppLogin import gen_homepage
from LSMcrowdsource import sql_procedures
from LSMcrowdsource import sql_functions

def sqlquery(query):
    c = connection.cursor()
    c.execute(query)

    # a list of tuples containing results
    results = c.fetchall()
    return results

# Create your views here.
def index(request):
    return render(request, 'AppUserhome/userhome.html', {})

def view_project(request, proj_id, messgae = None, msg_col = None):

    # is this user the owner of the project?
    query =  f'''
    SELECT *
    FROM projects
    WHERE projects.pid = '{proj_id}';
    '''
    query_result = sqlquery(query)
    pid, uid, ptarget, pstartdate, pduration, keywords, pdesc, ppicurl = query_result[0]
    owner = uid
    pdeadline =  pstartdate + datetime.timedelta(days=int(pduration))
    admin_access = owner == request.session['username'] or request.session['username'] == "admin"

    still_running = sql_functions.is_donable(proj_id)
    print(still_running)
    style = 'green' if still_running else 'red'
    print(style)
    donable = owner != request.session['username'] and still_running

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
            'admin_access': admin_access,
            'donable': donable,
            'project_owner': owner,
            'prj_img': ppicurl,
            'pdeadline': pdeadline.date(),
            'ptarget': ptarget,
            'pdesc': pdesc,
            'donor_header': donor_header,
            'donor_query_result': donor_query_result,
            'total_sum': total_sum,
            'progress': round(total_sum/ptarget * 100),
            "proj_id": proj_id,
            "message": messgae,
            "msg_col": msg_col,
            'deadln_col': style,
        })

def new_project(request, state):
    if state == "new_proj":
        # page initiated from userhome
        return render(
            request,
            'AppUserhome/new_project.html',
            {
                "pg_status": "new_proj"
            }
        )
    # else, pre-fill the information 
    keys = ["picURL", "pid", "description", "keywords", "target_amt", "proj_dur", "message"]
    html_render_dict = dict(zip(keys, request.session["new_proj_form"]))
    del request.session["new_proj_form"]
    return render(
        request,
        'AppUserhome/new_project.html',
        html_render_dict
    )

def proj_editmsg(request):
    '''
    this is suppose to either:
        1: 
            report that there is an error in update/creation of project, 
            then direct back to new_project
        2:  
            successful update/creation
            direct back to home page
    '''

    picURL = request.POST.get('picURL')
    pid = request.POST.get('pid')
    description = request.POST.get('description')
    keywords = request.POST.get('keywords')
    target_amt = request.POST.get('target_amt')
    proj_dur = request.POST.get('proj_dur')
    query = f'''
    INSERT INTO projects (pid, uid, ptarget, pstartdate, pduration, keywords, pdesc, ppicurl)
    VALUES('{pid}','{request.session["username"]}', 
    {target_amt}, DATE(NOW()), {proj_dur}, 
    '{keywords}', '{description}', '{picURL}');
    '''

    try:
        gen_homepage.sqlquery(query, fetch = False)

        return render(
            request,
            'AppUserhome/project_CreateModify.html',
            {
                "main_text": "New Project Initiated"
            }
        )

    except Exception as e:
        print("=============")
        print(str(e))
        error_msg = str(e)
        if "value too long" in error_msg:
            message = "URL must be shorter than 500char;\n porject title shorter than 20;\n"
        elif "unique constraint" in error_msg:
            message = "Project Name is not unique"
        elif "projects_ptarget_check" in error_msg:
            message = "Project Target must be positive"
        elif "projects_pduration_check" in error_msg:
            message = "The duration must be in range [1, 60]"
        else:
            message = error_msg

        request.session["new_proj_form"] = [picURL, pid, description, keywords, target_amt, proj_dur, message]
        return new_project(request, "")
    

def donation(request, proj_title):

    dnt_amt = picURL = request.POST.get('dnt_amt')

    if not dnt_amt:
        # if no money, then just refresh the page
        return view_project(request, proj_title, "You can't donate nothing!", "red")
    elif float(dnt_amt) <= 0:
        return view_project(request, proj_title, "Dont try to donate negative amount!", "red")

    dnt_amt = int(dnt_amt)
    try:
        sql_procedures.donate(
            request.session['username'],
            proj_title,
            dnt_amt
        )
        return view_project(
            request, proj_title, 
            f"Successfully Donated ${dnt_amt}", "green")
    except Exception as e:
        error = str(e)

        if 'users_ucash_check' in error:
            return view_project(
            request, proj_title, 
            "Not enough money son",
            "red")

        return view_project(
            request, proj_title, 
            "Trying something funny? " + error,
             "red")
    





    