from django.shortcuts import render
from django.db import connection
from . import gen_homepage

# use sessions to keep track of username
# request.session

# Create your views here.
def index(request):
    return render(request, 'AppLogin/start.html', {})

def create_account(request):
    return render(request, 'AppLogin/create.html', {})


def process_login(request):
    '''
    extract the username and password,
    check with sql server
    
    if username exist and password matching:
        add username to session
        proceed to userhome
    else:
        send to log in fail page
    '''

    # extract information from POST forms
    username = request.POST.get('username')
    password = request.POST.get('password')

    query = f'''
    SELECT *
    FROM users 
    WHERE uid = '{username}' AND
    upassword = '{password}';
    '''

    c = connection.cursor()
    c.execute(query)
    results = c.fetchall()

    if len(results) == 0:
        # if dont exist such
        # show user fail log in page
        return render(request, 'AppLogin/loginfail.html', {})

    # if log in successful, record the user's name in session
    fullname = results[0][1]
    request.session['username'] = username
    request.session['fullname'] = fullname

    # incomplete
    # return render(
    #    request, 
    #    'AppUserhome/userhome.html',
    #    {
    #        'fullname': fullname
    #    })

    # generate the user's home page
    return gen_homepage.render_homepage(request)

def registered(request):

    username = request.POST.get('username')
    fullname = request.POST.get('fullname')
    topupamt = float(request.POST.get('topup_amt'))
    password = request.POST.get('password')
    password_re = request.POST.get('password_re')

    if password != password_re:
        error_msg = 'Password not the same!'
        
        return render(
        request, 
        'AppLogin/registered.html',
        {
            'message': error_msg
         })
    elif topupamt < 0:
        error_msg = 'Top-Up cannot be negative!'
        
        return render(
        request, 
        'AppLogin/registered.html',
        {
            'message': error_msg
         })    

    query = f'''
    SELECT *
    FROM users 
    WHERE uid = '{username}';
    '''

    c = connection.cursor()
    c.execute(query)
    results = c.fetchall()

    if len(results) != 0:
        # if dont exist such
        error_msg = 'Username has been taken!'
        
        return render(
        request, 
        'AppLogin/registered.html',
        {
            'message': error_msg
         })
    
    query = f'''
    insert into users 
    (uid, uname, upassword, upicurl, ucash) 
    values 
    ('{username}', '{fullname}', '{password}', 'null', {topupamt});
    '''

    c.execute(query)

    return render(
        request, 
        'AppLogin/registered.html',
        {
            'message': 'Registeration Sucessful!'
         })