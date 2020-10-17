from django.shortcuts import render
from datetime import datetime

# Create your views here.
def index(request):
	# load the AppDate/index.html in the templates directory
	return render(request, "AppDate/index.html")

def result(request):
	# abstract the datestring from the form 
	# result?date=2020-09-28
	date_string = request.GET.get('date', '')# default value is ''

	date = datetime.strptime(date_string, '%Y-%m-%d')

	year = date.strftime("%Y")
	iso_year = date.strftime("%G")
	month = date.strftime("%B")
	weekday = date.strftime("%A")
	iso_weekday = date.strftime("%u")
	iso_week = date.strftime("%V")

	result_dict = {
		
		'year': year,
		'iso_year': iso_year,
		'month': month,
		'weekday': weekday,
		'iso_weekday': iso_weekday,
		'iso_week': iso_week,
	}

	return render(request, 'AppDate/result.html', result_dict)