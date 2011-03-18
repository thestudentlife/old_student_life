Time::DATE_FORMATS[:month_and_year] = "%B %Y"
Time::DATE_FORMATS[:pretty] = lambda do |time|
  time.strftime("%a, %b %e at %l:%M") + time.strftime("%p").downcase
end
Time::DATE_FORMATS[:default] = Time::DATE_FORMATS[:pretty]

Time::DATE_FORMATS[:sql] = "%Y-%m-%dT%H:%M:%S+00:00"