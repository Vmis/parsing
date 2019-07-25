	require 'open-uri'
	require 'nokogiri'
	require 'csv'


# search site:
# https://www.kufar.by/listings
# Enter search_word
# Enter output file name .csv

#    First argument is search word
search_word = ARGV.first

#    Last argument "file_name".csv
file_name = ARGV.last
 
#array for all pages
all_pages = []

#    Nokogiri read the my_link into a doc
doc = Nokogiri::HTML(open("https://www.kufar.by/listings?query=" + search_word +"&ot=1"))

# First page
all_pages << doc

# count the number of pages
count_pages = doc.xpath('//*[@id="content"]/div/div/div[3]/div/div/a[last()-1]').text.to_i   

#number of pages to process
number = count_pages-1

#add all  page in array
number.times do
	# get url next page
	url_next_page = "https://www.kufar.by" + doc.xpath('//*[@id="content"]/div/div/div[3]/div/div/a[last()]//@href').text 
	
	#get next page
	doc = Nokogiri::HTML(open(url_next_page))
	
	#add next page in array
	all_pages << doc
end  

# create csv file Add name column our csv 
CSV.open(file_name, "w") {|csv| csv << ['Поисковое слово', 'Название', 'Цена', 'Изображение']}

all_pages.length.times do |i|

	# find  produkts name
	produkts_name = all_pages[i].xpath('//div[@data-name="listings"]//h3').map { |link| link.text }
	#get price
	price = all_pages[i].xpath('//div[@data-name="listings"]//article/a/div[2]/div[2]/div[1]/span').map { |link| link.text }
	# Get URL of images   
	url_of_img = all_pages[i].xpath('//div[@data-name="listings"]//article/a/div[1]/div[1]/div[1]//@style').map { |link| link.text.slice(21..-2)   }
	
	CSV.open(file_name, "a") do |csv|
		# add name price url in file
		produkts_name.count.times do |i|   
			#    Collect full product information
			full_info = [search_word, produkts_name[i], price[i], url_of_img[i] ]
			#    Save pproduct to file 
			csv << full_info    
		 end

	 end 
end