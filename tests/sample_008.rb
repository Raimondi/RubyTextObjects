# Sample 8
def adjust_format_for_istar
  request.format = :iphone if iphone?
  request.format = :ipad if ipad?
  request.format = :js if request.xhr?
end

