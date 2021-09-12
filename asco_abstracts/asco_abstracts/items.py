# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


class AscoAbstractsItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    meeting = scrapy.Field()
    title_text = scrapy.Field()
    #first_author = scrapy.Field()
    author_list = scrapy.Field()
    author_organisation = scrapy.Field()
    session_type = scrapy.Field()
    session_title = scrapy.Field()
    track = scrapy.Field()
    sub_track = scrapy.Field()
    clin_trial_registration = scrapy.Field()
    abstract_num = scrapy.Field()
    poster_num = scrapy.Field()
    citation = scrapy.Field()
    DOI = scrapy.Field()
    research_funding = scrapy.Field()
    abstract_text = scrapy.Field()
    
