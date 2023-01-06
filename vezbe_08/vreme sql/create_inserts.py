import pandas as pd
from copy import deepcopy


file_names = ["nis_data.csv", "belgrade_data.csv"]

table_name = '`podaci o vremenu`'

date = '`datum i vreme`'
city_name = '`naziv grada`'
lat = 'g_sirina'
lon = 'g_duzina'
temp = 'temperatura'
temp_min = '`min_temp`'
temp_max = '`max_temp`'
pressure = 'pritisak'
humidity = '`vlaznost vazduha`'
wind_speed = '`brzina vetra`'
wind_deg = '`ugao vetra`'
weather_description = '`vreme`'

column_names = list()
column_names.append(date)
column_names.append(city_name)
column_names.append(lat)
column_names.append(lon)
column_names.append(temp)
column_names.append(temp_min)
column_names.append(temp_max)
column_names.append(pressure)
column_names.append(humidity)
column_names.append(wind_speed)
column_names.append(wind_deg)
column_names.append(weather_description)

for filename in file_names:
    table = pd.read_csv(filename, usecols=["dt_iso", "city_name", "lat", "lon", "temp", "temp_min", "temp_max", "pressure", "humidity",
                                                 "wind_speed",  "wind_deg", "weather_description"])

    table = table.values.tolist()

    for row in table:
        row[0] = row[0][0:19]

    query_head = 'INSERT INTO ' + table_name + ' ' + str(column_names).replace('[', '(').replace(']', ')').replace('\'', '') + ' VALUES\n'

    query_values = []
    n = len(table)
    batch_size = 24 * 5
    j = 0

    insert_queries = []

    curr_query = None
    for i in range(n):
        if j == 0:
            curr_query = deepcopy(query_head)

        table[i] = str(table[i]).replace('[', '(').replace(']', ')')
        sep = ';' if j == batch_size - 1 or i == n -1 else ',\n'
        query_values.append('\t' + table[i] + sep)
        j += 1
        if j == batch_size or i == n - 1:
            curr_query += ''.join(query_values)
            if i < n - 1:
                curr_query += '\n\n'
            query_values = []
            j = 0
            insert_queries.append(curr_query)

    with open('insert_statement.sql', 'a+') as sql_file:
        for query in insert_queries:
            sql_file.write(query)
            sql_file.flush()
