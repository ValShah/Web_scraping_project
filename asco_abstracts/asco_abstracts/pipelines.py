# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html


# useful for handling different item types with a single interface
from itemadapter import ItemAdapter
from scrapy.exporters import CsvItemExporter
#from scrapy.exporters import XmlItemExporter
from scrapy.exporters import JsonLinesItemExporter

# class AscoAbstractsPipeline:

    # def __init__(self):
        # self.filename = 'asco_abstracts.csv'

    # def open_spider(self, spider):
        # self.csvfile = open(self.filename, 'wb')
        # self.exporter = CsvItemExporter(self.csvfile)
        # self.exporter.start_exporting()

    # def close_spider(self, spider):
        # self.exporter.finish_exporting()
        # self.csvfile.close()
    
    # def process_item(self, item, spider):
        # self.exporter.export_item(item)
        # return item
        

class AscoAbstractsPipeline:

    
      
    def __init__(self):
        self.filename = 'asco_abstracts.json'
        #self.filename = 'asco_abstracts.csv'

    def open_spider(self, spider):
        self.file = open(self.filename, 'wb')
        #self.csvfile = open(self.filename, 'wb')
        
        self.exporter = JsonLinesItemExporter(self.file)  
        self.exporter.start_exporting()
        #self.exporter = CsvItemExporter(self.csvfile)
        #self.exporter.start_exporting()
        
    def close_spider(self, spider):
        self.exporter.finish_exporting()
        self.file.close()
        #self.csvfile.close()

    def process_item(self, item, spider):
        self.exporter.export_item(item)
        return item