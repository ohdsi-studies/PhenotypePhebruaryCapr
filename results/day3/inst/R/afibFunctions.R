#afib functions

#draw star for graphic
drawStar <- function(x0 = 0.5, y0 = 0.5, w0 = 0.5, h0 = 0.5) {
  pushViewport(vp = viewport(x = x0, y = y0, w = w0, h = h0, angle = 36))
  
  #code from Fun with the R grid package Zhou and Braun 2010
  b2 <- sqrt(1/cos(36*pi/180)^2-1)/2
  b3 <- sin(72*pi/180)/(2*(1+cos(72*pi/180))) - (1-sin(72*pi/180))/2
  triangle2 <- polygonGrob(c(0, .5, 1), c(b3, b2 + b3, b3), gp = gpar(fill = "gold", col =0))
  
  for(i in 0:2) {
    pushViewport(vp = viewport(angle = 72*i))
    grid.draw(triangle2)
    upViewport()
  }
  upViewport()
}


#draw bracket
drawBracket <- function(x0 = 0, x1 = 1, y = 0.5) {
  #horizontal line
  grid.segments(x0 = x0, y0 = y, x1 = x1, y1 = y, gp = gpar(col = "darkgrey", lwd = 3))
  
  #bracket on left
  grid.segments(x0 = x0, y0 = y, x1 = x0, y1 = y + 0.02,
                gp = gpar(col = "darkgrey", lwd = 3))
  #bracket on right
  grid.segments(x0 = x1, y0 = y, x1 = x1, y1 = y + 0.02,
                gp = gpar(col = "darkgrey", lwd = 3))
}

#draw outpatient Afib Diagnosis
drawAfibOutpatFig <- function() {
  grid.newpage()
  grid.text("two Afib diag occuring in an outpat or ER visit separated by 7d to 365d",
            y=0.95, 
            gp=gpar(cex=1))
  
  #draw patient timeline
  grid.segments(x0 = 0.1, y0 = 0.5, x1 = 0.9, y1 = 0.5, gp = gpar(lwd = 6))
  
  
  #draw star indicating initial event
  drawStar(x0 = 0.3, y0 = 0.56, w0 = 0.1, h0 = 0.1)
  grid.text(label = "Initial Event: \nAfib Diag", x = 0.3, y = 0.68)
  
  
  #draw arrow for first outpatient visit
  grid.segments(x0 = 0.3, y0 = 0.35, x1 = 0.3, y1 = 0.5, gp = gpar(col = "mediumpurple", lwd = 3),
                arrow = arrow(length = grid::unit(0.3, "inches"), 
                              ends="last", type="open"))
  grid.text(label = "1st outpatient visit", x = 0.3, y = 0.3)
  
  
  
  #draw star for second afib diag
  drawStar(x0 = 0.7, y0 = 0.56, w0 = 0.1, h0 = 0.1)
  grid.text(label = "Subsequent Event: \nAfib Diag", x = 0.7, y = 0.68)
  
  #second outpatient visit
  grid.segments(x0 = 0.7, y0 = 0.35, x1 = 0.7, y1 = 0.5, gp = gpar(col = "mediumpurple", lwd = 3),
                arrow = arrow(length = grid::unit(0.3, "inches"), 
                              ends="last", type="open"))
  grid.text(label = "2nd outpatient visit", x = 0.7, y = 0.3)
  
  
  #show time interval
  drawBracket(x0 = 0.3, x1 = 0.7, y = 0.25)
  grid.text(label = "between 7 and 365 days", x = 0.5, y = 0.23)
  
  
  #observation time
  #left side
  grid.segments(x0 = 0.1, y0 = 0.48, x1 = 0.1, y1 = 0.52)
  grid.text(label = "1/1/07", x = 0.1, y = 0.54)
  
  #right side
  grid.segments(x0 = 0.9, y0 = 0.48, x1 = 0.9, y1 = 0.52)
  grid.text(label = "10/1/15", x = 0.9, y = 0.54)
}


#suggested new function to add to a concept set expression
addConceptToCSE <- function(obj, addition, includeDescendants = FALSE, isExcluded = FALSE, includeMapped = FALSE) {
  cs <- createConceptSet(addition, 
                         includeDescendants = includeDescendants, 
                         isExcluded = isExcluded, 
                         includeMapped = includeMapped)
  obj@ConceptSetExpression[[1]]@Expression <- append(obj@ConceptSetExpression[[1]]@Expression, cs)
  return(obj)
}
