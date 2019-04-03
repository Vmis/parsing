require 'open-uri'
require 'nokogiri'
require 'csv'


    # Вводим наш адрес для парсинга
    # Вводим имя файла  в который сохраним информацию
    my_link = ARGV.first
    file_name = ARGV.last
    
	doc = Nokogiri::HTML(open(my_link))
	l = doc.xpath('//li[@class = "grid-box _one-quarter _centered _no-margin _family-listing-grid-item"]/a[@class = "grid-box _one-whole _no-padding _no-margin"]').map { |link| link['href'] }
    link = l.map { |i| "https://www.viovet.co.uk" + i} 

    # создаем файл CSV
    CSV.open(file_name, "w") do |csv|
    # Добавляем названия колонок    
    csv << ['Название', 'Цена', 'Изображение', 'Срок доставки', 'Код товара']
    link.each do |i|
        
   	#-------------разбор одной страницы
	page = Nokogiri::HTML(open( "#{i.to_s}"))

	#--------------Название товара
	product = page.xpath('//h1[@id="product_family_heading"]').text
	
	#--------------Полное название товара
    product_name = page.xpath('//li/span[@class="name"]').map { |name|  "#{product} - #{name.text.gsub("\n","")}" }
    
	#--------------Цена товара
    product_cost = 	page.xpath('//li/span[@class="price"]').map { |cost|  cost.text.gsub("\n","")}
	
	#---Собираем номера изображений для каждого продукта на странице и собираем сами изображения по определенным номерам
    product_img = page.xpath('//ul/li/@data-product_image').map {|a| page.xpath("//img[@id='product_image_#{a}']/@src").map {|b| "https:#{b}".to_s } }
	
	#--------------Срок доставки
    product_deiver = page.xpath('//div/p[@class="stock-notification notification_in-stock"]').map {|deliver| deliver.text.gsub("\n","") }
	
	#--------------Код товара
    product_cod = page.xpath('//span/span[@class="item-code"]').map { |cod| cod.text.gsub("\n","") }
	
	# собираем строку с информацией о продукте
    full_info = [product_name, product_cost, product_img, product_deiver, product_cod ]

    # пишем собранные данные в наш файл
    csv << full_info

   end
  end
