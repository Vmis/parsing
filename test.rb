require 'open-uri'
require 'nokogiri'
require 'csv'


    # Enter website address
    # http://www.viovet.co.uk/Pet_Foods_Diets-Dogs-Hills_Pet_Nutrition-Hills_Prescription_Diets/c233_234_2678_93/category.html
    # Enter file name .csv
    
    #    First argument
    my_link = ARGV.first
    
    #    Last argument
    file_name = ARGV.last
    
    #    Nokogiri read the my_link into a doc
	doc = Nokogiri::HTML(open(my_link))
	
	#    Extract links to products 
	short_links = doc.xpath('//li[@class = "grid-box _one-quarter _centered _no-margin _family-listing-grid-item"]/a[@class = "grid-box _one-whole _no-padding _no-margin"]').map { |link| link['href'] }
    
    #    Add name site for links
    links = short_links.map { |i| "https://www.viovet.co.uk" + i} 

    #    Create file .csv
    CSV.open(file_name, "w") do |csv|
    
    #    Add name column our csv   
    csv << ['Название', 'Цена', 'Изображение', 'Срок доставки', 'Код товара']
    
    #    Get product in one page
    links.each do |one_link|
	page = Nokogiri::HTML(open( "#{one_link}"))

	#    Get product family heading
	product = page.xpath('//h1[@id="product_family_heading"]').text
	
	#    Get full name of product
    product_name = page.xpath('//li/span[@class="name"]').map { |name|  "#{product} - #{name.text.strip.tr("\n"," ")}" }
 
	#    Get price of product
    product_cost = 	page.xpath('//li/span[@class="price"]').map { |cost|  cost.text.strip}
	
	#    Get img by number 
    product_img = page.xpath('//ul/li/@data-product_image').map {|numb| page.xpath("//img[@id='product_image_#{numb}']/@src").text }
    
    #    Get other img (without a number) 
    product_img.map! {|i| if i == "" then page.xpath('//img[@id="category_image"]/@src')  else i end }
    
    #    Add https: for links to imgs
    product_img.map! {|i| "https:#{i}" }
 
	#    Get estimated delivery time
    product_deiver = page.xpath('//div/p[@class="stock-notification notification_in-stock"]').map {|delivery| delivery.text.strip }
	
	#    Get product code
    product_cod = page.xpath('//span/span[@class="item-code"]').map { |cod| cod.text.strip }
	
	#    Count product on the page
	product_cod.count.times do |i|
		
	#    Collect full product information
    full_info = [product_name[i], product_cost[i], product_img[i], product_deiver[i], product_cod[i] ]

    #    Save pproduct to file 
    csv << full_info	
	end
   end
  end
