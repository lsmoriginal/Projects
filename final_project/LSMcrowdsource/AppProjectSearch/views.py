from django.shortcuts import render
from django.db import connection
import datetime

from LSMcrowdsource import sql_functions
from LSMcrowdsource import sql_procedures

#  from AppLogin import gen_homepage

def sqlquery(query):
    c = connection.cursor()
    c.execute(query)

    # a list of tuples containing results
    results = c.fetchall()
    return results

def gen_homepage(request):

    # first get all the ongoing projects
    # not due
    # can still receive donation even if they have met targets
    ongoing_header = ["Project Title", "Owner", "Project Target", "Amount", "Completion"]
    # using sql functions
    ongoing_projects = sql_functions.search_all_going_proj()

    # get all the funded project projects
    # funded means that they has exceeded the due, no longer accepting donations
    # and  they must have met their target
    # project that did not meet targets  are not displayed
    funded_headers = ["Project Title", "Owner", "Target", "Amount"]
    funded_projects = sql_functions.search_all_funded_proj()

    # projects that has expired but not met their goal
    failed_headers = ["Project Title", "Owner", "Target", "Amount"]
    failed_projects = sql_functions.search_all_failed_proj()

    return render(
        request,
        "AppProjectSearch/project_gallary.html",
        {
            "fullname": request.session["fullname"],
            "ongoing_header": ongoing_header,
            "ongoing_projects": ongoing_projects,
            "funded_headers": funded_headers,
            "funded_projects": funded_projects,
            'failed_headers': failed_headers,
            'failed_projects': failed_projects,
        }
    )

def search_proj(request, status):

    if status == "blank":
        return render(
            request,
            "AppProjectSearch/project_search.html",
            {
                "has_result": False,
                "fullname": request.session["fullname"],
            }
        )
    
    proj_title = request.POST.get('proj_title')
    proj_title_c = f'''projects.pid ~ \'{proj_title}\'''' if proj_title else ""

    owner_name = request.POST.get('owner_name')
    owner_name_c = f'''users.uid ~ \'{owner_name}\'''' if owner_name else ""

    proj_kwd = request.POST.get('proj_kwd')
    proj_kwd_c = f'''projects.keywords ~ \'{proj_kwd}\' OR 
    projects.pdesc ~ \'{proj_kwd}\'
    ''' if proj_kwd else ""

    min_fd = request.POST.get('min_fd')
    min_fd_c = min_fd if min_fd else 0

    conditions = [i for i in [proj_title_c, owner_name_c, proj_kwd_c] if i != ""]
    conditions_copy = conditions.copy()
    conditions = " OR ".join(list(conditions))
    conditions = "WHERE " + conditions + " "

    result_header = ["Project Title", "Owner", "Target", "Amount", "Completion"]
    query = f'''
    SELECT projects.pid, users.uid, CAST(projects.ptarget AS MONEY), 
    CAST(SUM(COALESCE(donates.damt,0)) AS MONEY) AS damt,
    to_char(ROUND(SUM(COALESCE(donates.damt,0))/projects.ptarget * 100),'999999D99%') AS completion
FROM 
	projects 
	LEFT JOIN donates ON projects.pid = donates.pid
    LEFT JOIN users ON projects.uid = users.uid
    {conditions}
GROUP BY users.uid, projects.pid, projects.ptarget
HAVING SUM(COALESCE(donates.damt,0))/projects.ptarget * 100 >= {min_fd_c};
    '''

    try:
        result_projects  = sqlquery(query)
        message  = ""
        error = ""
    except Exception as e:
        result_projects = []
        error = str(e)
        message = "Don't try anything funny!"

        if conditions_copy == []:
            return search_proj(request, "blank")
    return render(
            request,
            "AppProjectSearch/project_search.html",
            {
                "has_result": True,
                "fullname": request.session["fullname"],
                "result_header": result_header,
                "result_projects": result_projects,
                "message": message,
                "error": error,
                'proj_title': proj_title,
                "owner_name": owner_name,
                'proj_kwd': proj_kwd,
                'min_fd': min_fd,
            }
        )



