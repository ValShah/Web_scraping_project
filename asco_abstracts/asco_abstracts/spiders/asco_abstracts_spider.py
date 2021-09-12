from asco_abstracts.items import AscoAbstractsItem
from scrapy import Spider, Request
import re
import math

class AscoAbstractSpider(Spider):
    name = 'asco_abstracts_spider'
    allowed_domains = ['meetings.asco.org']
    start_urls = ['https://meetings.asco.org/abstracts-presentations/search?query=*&filters=%7B%22meetingTypeName%22:%5B%7B%22key%22:%22ASCO%20Annual%20Meeting%22%7D%5D,%22meetingYear%22:%5B%7B%22key%22:2021%7D%5D%7D&pageNumber=1&size=20']


    def parse(self, response): 
        #scrape number of abstracts
        num_abstracts = response.xpath('.//div[@class="row result-row total-results-row"]//div[@class="col-6 d-md-none num-results"]/text()').extract()
        num_pages = math.ceil(int(re.findall('[0-9]+', num_abstracts[0])[0])/20)
        #result_urls = [f'https://www.bestbuy.com/site/all-laptops/pc-laptops/pcmcat247400050000.c?cp={i+1}&id=pcmcat247400050000' for i in range(num_pages)] example
        
        result_urls = [f'https://meetings.asco.org/abstracts-presentations/search?query=*&filters=%7B%22meetingTypeName%22:%5B%7B%22key%22:%22ASCO%20Annual%20Meeting%22%7D%5D,%22meetingYear%22:%5B%7B%22key%22:2021%7D%5D%7D&pageNumber={i+1}&size=20' for i in range(num_pages)]


        for url in result_urls[0:2]:
            yield Request(url=url, callback=self.parse_results_page)
                
    def parse_results_page(self, response):
    
        product_urls = response.xpath('.//asco-search-result-card//asco-link[@class="pseudo-hover"]//a//@href').extract()
        product_urls = ['https://meetings.asco.org' + url for url in product_urls]
        
        #print('='*55)
        #print(len(product_urls))
        #print('='*55)
      
        for url in product_urls:
            yield Request(url=url, callback=self.parse_abstract_page)
           
    def parse_abstract_page(self, response):
        
        
        title_text = response.xpath('.//h3[@class="header-title"]/text()').extract_first()
        #first_author = response.xpath('.//div[@class="ng-star-inserted"]//p[@class="font-weight-bold profile-name m-0 ng-tns-c237-0"]/text()').extract_first()
        author_list = response.xpath('.//div[@class="ng-star-inserted"]//p[@class="mt-3 mb-4 ng-star-inserted"]//text()').extract_first()
        author_organisation = response.xpath('.//p[@class="ng-star-inserted"]/asco-safe-html/div[@class="safe-html"]/text()').extract_first()
        research_funding = response.xpath('.//div[@class="ng-star-inserted"]//p[@class="mb-0"]//text()').extract_first()
        abstract_text = response.xpath('.//div[@class="safe-html"]//p//text()').extract()
        
        lis = response.xpath('.//ul[@class="m-0 p-0"]/li')
        
        abstract = {}
        for li in lis:
            x = li.xpath('.//p/text()').extract_first()
            y = li.xpath('.//asco-link/a/@title').extract_first()
            if y == None:
                z = li.xpath('.//p/text()')[1].extract()
            else:
                z = y
            abstract[x] = z

        item = AscoAbstractsItem()
        item['title_text'] = title_text
        #item['first_author'] = first_author
        item['author_list'] = author_list
        item['author_organisation'] = author_organisation
        item['meeting'] = abstract.get('Meeting')
        item['session_type'] = abstract.get('Session Type')
        item['session_title'] = abstract.get('Session Title')
        item['track'] = abstract.get('Track')
        item['sub_track'] = abstract.get('Sub Track')
        item['clin_trial_registration'] = abstract.get('Clinical Trial Registration Number')
        item['abstract_num'] = abstract.get('Abstract #')
        item['poster_num'] = abstract.get('Poster #')
        item['citation'] = abstract.get('Citation')
        item['DOI'] = abstract.get('DOI')
        item['research_funding'] = research_funding
        item['abstract_text'] = abstract_text
    

        

        yield item;