<?php

$useYahooResults = true;

if ($useYahooResults) {
	$rawJSON = file_get_contents("http://query.yahooapis.com/v1/public/yql?q=select%20item%20from%20weather.forecast%20where%20location%3D%2248907%22&format=json");
	$rawData = json_decode($rawJSON);

	/*
	 * parse results similar to this example response:
	 * 
	 * {
	 *     "query": {
	 *         "count": 1,
	 *         "created": "2012-05-18T02:14:27Z",
	 *         "lang": "en-US",
	 *         "results": {
	 *             "channel": {
	 *                 "item": {
	 *                     "title": "Conditions for Richmond, VA at 8:53 pm EDT",
	 *                     "lat": "37.54",
	 *                     "long": "-77.44",
	 *                     "link": "http://us.rd.yahoo.com/dailynews/rss/weather/Richmond__VA/*http://weather.yahoo.com/forecast/USVA0652_f.html",
	 *                     "pubDate": "Thu, 17 May 2012 8:53 pm EDT",
	 *                     "condition": {
	 *                         "code": "27",
	 *                         "date": "Thu, 17 May 2012 8:53 pm EDT",
	 *                         "temp": "66",
	 *                         "text": "Mostly Cloudy"
	 *                     },
	 *                     "description": "\n<img src=\"http://l.yimg.com/a/i/us/we/52/27.gif\"/><br />\n<b>Current Conditions:</b><br />\nMostly Cloudy, 66 F<BR />\n<BR /><b>Forecast:</b><BR />\nThu - Partly Cloudy. High: 75 Low: 52<br />\nFri - Partly Cloudy. High: 77 Low: 51<br />\n<br />\n<a href=\"http://us.rd.yahoo.com/dailynews/rss/weather/Richmond__VA/*http://weather.yahoo.com/forecast/USVA0652_f.html\">Full Forecast at Yahoo! Weather</a><BR/><BR/>\n(provided by <a href=\"http://www.weather.com\" >The Weather Channel</a>)<br/>\n",
	 *                     "forecast": [
	 *                         {
	 *                             "code": "29",
	 *                             "date": "17 May 2012",
	 *                             "day": "Thu",
	 *                             "high": "75",
	 *                             "low": "52",
	 *                             "text": "Partly Cloudy"
	 *                         },
	 *                         {
	 *                             "code": "30",
	 *                             "date": "18 May 2012",
	 *                             "day": "Fri",
	 *                             "high": "77",
	 *                             "low": "51",
	 *                             "text": "Partly Cloudy"
	 *                         }
	 *                     ],
	 *                     "guid": {
	 *                         "isPermaLink": "false",
	 *                         "content": "USVA0652_2012_05_18_7_00_EDT"
	 *                     }
	 *                 }
	 *             }
	 *         }
	 *     }
	 * }
	 */
	$currentTemperature = $rawData->query->results->channel->item->condition->temp;
	$currentConditions = $rawData->query->results->channel->item->condition->text;

} else {
	$rawJSON = file_get_contents("http://weather.yahooapis.com/forecastjson?w=12518996");
	$rawData = json_decode($rawJSON);
	/*
	 * parse results similar to this example response:
	 * 
	 * {
	 *     "units": {
	 *         "temperature": "F",
	 *         "speed": "mph",
	 *         "distance": "mi",
	 *         "pressure": "in"
	 *     },
	 *     "location": {
	 *         "location_id": "USVA0683",
	 *         "city": "Sandston",
	 *         "state_abbreviation": "VA",
	 *         "country_abbreviation": "US",
	 *         "elevation": 108,
	 *         "latitude": 37.52,
	 *         "longitude": -77.32
	 *     },
	 *     "wind": {
	 *         "speed": 6,
	 *         "direction": "NNE"
	 *     },
	 *     "atmosphere": {
	 *         "humidity": "81",
	 *         "visibility": "10",
	 *         "pressure": "30.09",
	 *         "rising": "rising"
	 *     },
	 *     "url": "http://weather.yahoo.com/forecast/USVA0683.html",
	 *     "logo": "http://l.yimg.com/a/i/us/nt/ma/ma_nws-we_1.gif",
	 *     "astronomy": {
	 *         "sunrise": "05:58",
	 *         "sunset": "20:14"
	 *     },
	 *     "condition": {
	 *         "text": "Mostly Cloudy",
	 *         "code": "27",
	 *         "image": "http://l.yimg.com/a/i/us/we/52/27.gif",
	 *         "temperature": 63
	 *     },
	 *     "forecast": [
	 *         {
	 *             "day": "Today",
	 *             "condition": "Partly Cloudy",
	 *             "high_temperature": "74",
	 *             "low_temperature": "53"
	 *         },
	 *         {
	 *             "day": "Tomorrow",
	 *             "condition": "Partly Cloudy",
	 *             "high_temperature": "76",
	 *             "low_temperature": "51"
	 *         }
	 *     ]
	 * }
	 */
	$currentTemperature = (string)$rawData->condition->temperature;
	$currentConditions = $rawData->condition->text;
}

$response = array("city" => "Richmond",
				  "state" => "Virginia",
				  "currentTemperature" => $currentTemperature);

/*
 * output final results:
 *
 * {"city":"Richmond","state":"Virginia","currentTemperature":"63"}
 */
print json_encode($response);

?>