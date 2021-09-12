from asco_abstracts.items import AscoAbstractsItem
from scrapy import Spider, Request
import re
import math

class AscoAbstractSpider(Spider):
    name = 'asco_abstract_spider'
    allowed_domains = ['https://meetings.asco.org/']
    start_urls = ['https://meetings.asco.org/abstracts-presentations/search?query=*&filters=%7B%22meetingTypeName%22:%5B%7B%22key%22:%22ASCO%20Annual%20Meeting%22%7D%5D,%22meetingYear%22:%5B%7B%22key%22:2021%7D%5D%7D&pageNumber=1&size=20']


    def parse(self, response): 
        #scrape number of abstracts
        num_abstracts = response.xpath('.//div[@class="row result-row total-results-row"]//div[@class="col-6 d-md-none num-results"]/text()').extract()
        num_pages = math.ceil(int(re.findall('[0-9]+', num_abstracts[0])[0])/20)
        #result_urls = [f'https://www.bestbuy.com/site/all-laptops/pc-laptops/pcmcat247400050000.c?cp={i+1}&id=pcmcat247400050000' for i in range(num_pages)] example
        
        result_urls = [f'https://meetings.asco.org/abstracts-presentations/search?query=*&filters=%7B%22meetingTypeName%22:%5B%7B%22key%22:%22ASCO%20Annual%20Meeting%22%7D%5D,%22meetingYear%22:%5B%7B%22key%22:2021%7D%5D%7D&pageNumber={i+1}&size=20' for i in range(num_pages)]


        for url in result_urls:
            yield Request(url=url, callback=self.parse_results_page)
                
    def parse_results_page(self, response):
    
        product_urls = response.xpath('.//asco-search-result-card//asco-link[@class="pseudo-hover"]//a//@href').extract()
        product_urls = ['https://meetings.asco.org' + url for url in product_urls]
        
        print('='*55)
        print(len(product_urls))
        print('='*55)
      
        #for url in product_urls:
        #   yield Request(url=url, callback=self.parse_product_page)
           
    def parse_product_page(self, response):
        pass
                
                