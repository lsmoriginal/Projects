from django.shortcuts import render
from datetime import datetime
from django.db import connection
from django.http import JsonResponse

# Create your views here.
def index(request):
	return render(request, "AppTPCC/index.html")
	# load the AppDate/index.html in the templates directory

def result(request):
    action_type = request.GET.get('action_type', 'nothing is here')
    search_str = request.GET.get('search', 'nothing is here')

    # Query
    if action_type == "sql":
        query = search_str
    else:
        query = f'SELECT * FROM item WHERE i_name ~ \'{search_str}\''

    c = connection.cursor()
    c.execute(query)
    results = c.fetchall()
    
    result_dict = {
        'the_text': search_str,
        'records': results,
    }

    return render(request, 'AppTPCC/result.html', result_dict)

def query(request):

    query = """
    SELECT w.w_id, COALESCE(s.s_qty, 0) as qty
    FROM 
	    item i INNER JOIN
	    stock s ON i.i_id = s.i_id RIGHT OUTER JOIN
	    warehouse w ON  s.w_id = w.w_id AND i.i_name = 'Aspirin'
    ORDER BY qty DESC;
    """

    c = connection.cursor()
    c.execute(query)
    results = c.fetchall()

    return JsonResponse(results, safe=False)

def report(request):
    return render(request,'AppTPCC/report.html')