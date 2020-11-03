from django.shortcuts import render
from django.db import connection
from LSMcrowdsource import sql_functions

# Create your views here.


def adminpage(request):
    username = request.session['username']

    user_list = sql_functions.get_users(username)
    proj_list = sql_functions.get_project(username)
    donate_list = sql_functions.get_donates(username)

    return render(
        request,
        'AppAdminAccess/adminpage.html',
        {
            'fullname': request.session['fullname'],
            'user_list': user_list,
            'proj_list': proj_list,
            'donate_list': donate_list,

        }
    )

def edit_user(request, user_id=None, update = None, uid=None):
    idd = user_id if user_id else uid
    query = f"SELECT * FROM users WHERE users.uid = '{idd}';"
    print(query)
    print(user_id, update, uid)
    results = sql_functions.sqlquery(query)[0]
    data = ["username", "fullname", "password", "upicurl", "ucash"]

    if update == None:
        html = dict(zip(data, results))
        html.update({'user_id':user_id, "my_fullname": request.session['fullname']})
        return render(
            request,
            "AppAdminAccess/edit_user.html",
            html
        )

    # else it will come from the form submission
    upicurl = request.POST.get('upicurl')
    username = request.POST.get('username')
    fullname = request.POST.get('fullname')
    ucash = request.POST.get('ucash')
    password = request.POST.get('password')

    query = f'''
    UPDATE users
    SET
        uid = '{username}',
        uname = '{fullname}',
        upassword = '{password}',
        upicurl = '{upicurl}',
        ucash = {ucash}
    WHERE uid = '{uid}';
    '''

    values = [username, fullname, password, upicurl, ucash]
    html_temp = dict(zip(data, values))

    try:
        sql_functions.sqlquery(query, fetch=False)
        html_temp.update({"message": "Values Updated", "msg_col": "green"})
        # successfully update uid
        request.session['fullname'] = fullname
        html_temp.update({"user_id":username})
        
    except Exception as e:
        e = str(e)
        html_temp.update({"user_id":idd})

        if 'duplicate key value violates unique constraint "users_pkey"'  in  e:
            message = f"username: {username} already exist!"
        elif 'value too long' in e:
            message = "Value String is too long!"
        elif 'violates check constraint "users_ucash_check"' in e:
            message = 'Cannot have negative cash!'
        else:
            message = "Dont try anything funny! " + e

        html_temp.update({"message": message, "msg_col": "red", "my_fullname": request.session['fullname']})

    # print(html_temp['user_id'])
    return render(
        request,
        "AppAdminAccess/edit_user.html",
        html_temp
        )

def edit_proj(request, proj_id = None, update = None):
    idd = proj_id if proj_id else pid

    # display the present values
    query = f'''
    SELECT * FROM projects WHERE projects.pid = '{idd}';
    '''
    results = sql_functions.sqlquery(query)[0]
    # pid, uid, ptarget, pstartdate, pduration, keywords, pdesc, ppicurl = results
    keys = ["pid", "uid", "ptar", 'pstartdate', 'pdur', 'pkeywd', 'pdesc', 'ppicurl']
    html = dict(zip(keys, results))

    html.update({"p_id": idd})
    if update == None:
        # first entering this page, send from admin access
        # render the template

        return render(
            request,
            'AppAdminAccess/edit_project.html',
            html
        )
    
    # else, enter via filling form submission

    # fist try gathering the form submission  
    ppicurl = request.POST.get('ppicurl')
    proj_id = request.POST.get('proj_id')
    pkeywd = request.POST.get('pkeywd')
    pdesc = request.POST.get('pdesc')
    pdur = request.POST.get('pdur')
    ptar = request.POST.get('ptar')

    # try updating the values  
    query = f'''
    UPDATE projects
    SET
        pid = '{proj_id}',
        ptarget = '{ptar}',
        pduration = '{pdur}',
        keywords = '{pkeywd}',
        pdesc = '{pdesc}',
        ppicurl = '{ppicurl}'
    WHERE pid = '{idd}';
    '''
    html.update({
            'ppicurl': ppicurl,
            'pid': proj_id,
            'pkeywd': pkeywd,
            'pdesc': pdesc,
            'pdur':pdur,
            'ptar': ptar,
        })
    try:
        sql_functions.sqlquery(query, fetch=False)
        html.update({"message": "Values Updated", "msg_col": "green"})
    except Exception as e:
        e = str(e)

        if 'violates unique constraint "projects_pkey" ' in e:
            message = f"{proj_id} already exist!"
        elif 'check constraint "projects_pduration_check"' in e:
            message = "Duration cannot be negative!"
        elif 'violates check constraint "projects_pduration_check2"' in e:
            message = "Duration cannot be more than 1 year!"
        elif 'check constraint "projects_ptarget_check"' in e:
            message = 'Target must be positive!'
        else:
            message = "Don't do anything funny! " + e
        html.update({"message": message, "msg_col": "red"})  
    
    return render(
        request,
        "AppAdminAccess/edit_project.html",
        html
        )
    

def edit_donation(request, u_id=None, proj_id=None, d_time=None, update=None):

    html = {'uid': u_id, 'pid': proj_id, 'dtime': d_time}

    if update == None:
        query = f'''
        SELECT * FROM donates WHERE
        uid = '{u_id}' AND pid = '{proj_id}'  AND dtime = '{d_time}';
        '''
        result = sql_functions.sqlquery(query)[0]
        damt = result[-1]
        html['damt'] = damt
        return render(
            request,
            'AppAdminAccess/edit_donates.html',
            html
        )
    
    new_damt = request.POST['damt']
    html['damt'] = new_damt
    try:
        query = f'''
        UPDATE donates 
        SET damt = {new_damt}
        WHERE uid = '{u_id}' AND pid = '{proj_id}' AND dtime = '{d_time}';
        '''
        sql_functions.sqlquery(query, fetch=False)
        html.update({'message': 'Value updated', 'msg_col': 'green'})
    except Exception as e:
        e = str(e)
        if 'donates_damt_check' in e:
            message = 'Donation cannot be negative!'
        else:
            message = "Dont't try anything funny! " + e 
        html.update({"message": message, "msg_col": "red"})
    
    return render(
        request,
        'AppAdminAccess/edit_donates.html',
        html
    )

def del_donate(request, u_id, proj_id, d_time):
    # simply delete to Trigger refund
    query = f'''
    DELETE FROM donates
    WHERE
    uid = '{u_id}' AND
    pid = '{proj_id}' AND
    dtime = '{d_time}';
    '''
    sql_functions.sqlquery(query, fetch=False)

    return adminpage(request)

def del_proj(request, proj_id):
    query = f'''
    DELETE FROM projects
    WHERE pid = '{proj_id}';
    '''
    sql_functions.sqlquery(query, fetch=False)
    return adminpage(request)

def del_user(request, uid):
    query = f'''
    DELETE FROM users
    WHERE uid = '{uid}';
    '''
    sql_functions.sqlquery(query, fetch=False)
    return adminpage(request)



