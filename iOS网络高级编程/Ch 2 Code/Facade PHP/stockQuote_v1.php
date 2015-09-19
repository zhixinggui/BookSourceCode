<?php

$useYahooResults = true;
$ticker = "AAPL";

if ($useYahooResults) {
	$rawData = rtrim(file_get_contents("http://finance.yahoo.com/d/quotes.csv?s=".$ticker."&f=snl1p2o"),"\r\n");

	/*
	 * parse results similar to this example response:
	 *
	 * "AAPL","Apple Inc.",530.12,"-2.92%",545.31
	 * {ticker symbol},{name},{last trade price},{percentage change},{opening price}
	 */
	$data = explode(",",$rawData);

	$symbol = trim($data[0],'"');
	$name = trim($data[1],'"');
	$currentPrice = trim($data[2],'"');

} else {
	$rawXML = file_get_contents("http://www.webservicex.net/stockquote.asmx/GetQuote?symbol=".$ticker);
	$wrapperData = simplexml_load_string($rawXML);
	
	/*
	 * parse results similar to this example response:
	 * 
	 * <StockQuotes>
	 *   <Stock>
	 *     <Symbol>AAPL</Symbol>
	 *     <Last>530.12</Last>
	 *     <Date>5/17/2012</Date>
	 *     <Time>4:00pm</Time>
	 *     <Change>-15.955</Change>
	 *     <Open>545.31</Open>
	 *     <High>547.50</High>
	 *     <Low>530.12</Low>
	 *     <Volume>25614960</Volume>
	 *     <MktCap>495.7B</MktCap>
	 *     <PreviousClose>546.075</PreviousClose>
	 *     <PercentageChange>-2.92%</PercentageChange>
	 *     <AnnRange>310.50 - 644.00</AnnRange>
	 *     <Earns>41.042</Earns>
	 *     <P-E>13.31</P-E>
	 *     <Name>Apple Inc.</Name>
	 *   </Stock>
	 * </StockQuotes>
	 */
	$xmlData = simplexml_load_string($wrapperData);

	$symbol = (string)$xmlData->Stock->Symbol;
	$name = (string)$xmlData->Stock->Name;
	$currentPrice = (string)$xmlData->Stock->Last;
}

$response = array("symbol" => $symbol,
				  "name" => $name,
				  "currentPrice" => $currentPrice);

/*
 * output final results:
 *
 * {"symbol":"AAPL","name":"Apple Inc.","currentPrice":"-2.92%"}
 */
print json_encode($response);

?>