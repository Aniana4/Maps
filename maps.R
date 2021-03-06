library(ggmap)
library(ggplot2)
library(httr)

#pruebas con geocode, algunas las sit�a en Sudam�rica
codigos <- geocode(c("Spain"))
map <- get_map(coordccaa,source="google",zoom=6,maptype = "terrain")
comunidades <- c("Andalucia","Aragon","Asturias","Baleares","Canarias","Cantabria","Castilla La Mancha","Castilla y Leon","Catalunya","Comunidad de Madrid","Comunidad Murciana","Comunidad Valenciana","Extremadura","La Rioja","Galicia","Navarra","Pais Vasco")
comunidades
coordccaa <- geocode(comunidades)
coordccaa
----------------------------------------------------
install.packages("maps")
library(maps)
install.packages("mapdata")
library(mapdata)
map('worldHires','Spain')
points(coordccaa)
----------------------------------------------------

library(maps)
library(maptools)
library(sp)
#habitantes por provincias en 2015
#Fuente INE
library(xlsx)
datos <- read.xlsx("Poblacionprov2015.xls",sheetName = 1,encoding= "UTF-8")
head(datos)
class(datos$Poblacion2015)
datos$codigo <- substr(datos$Provincia,1,2)
datos$Provincia <- substring(datos$Provincia,4)#elimino los numeros delante del nombre de provincia

datos$Provincia <-  chartr('����������������','aeiouAEIOUnaeiou',datos$Provincia)#elimino los acentos
datos$codigo <- as.factor(datos$codigo)
class(datos$codigo)
datos
###Mapa espa�a The readShapePoly reads data from a polygon shapefile into a SpatialPolygonsDataFrame object
http://www.ine.es/censos2011_datos/cen11_datos_resultados_seccen.htm
library(rgdal)
getinfo.shape(file.choose("SECC_CPV_E_20111101_01_R_INE"))
file<- readShapeSpatial("SECC_CPV_E_20111101_01_R_INE")
plot(file)

#por provincias http://www.arcgis.com/home/item.html?id=83d81d9336c745fd839465beab885ab7
provincias <- readShapePoly("Provincias_ETRS89_30N")
provincias@data # Aqu� veo los nombres de provincias y codigo tiene 52 filas 5 columnas
slotNames(provincias)
class(provincias@data$Codigo)#es factor
newdata <- merge(provincias@data, datos, by.x="Codigo", by.y="codigo")
provincias@data$Poblacion2015 <- newdata$Poblacion2015
provincias@data
#Grafico 
head(datos)
library(reshape2)

datos <- datos[order(-datos$Poblacion2015),]
datosgraf <- subset(datos,select=-codigo)
row.names(datosgraf) <- datosgraf$Provincia


png("PlotPoblacion2015.png",width = 900,height = 450)
par(mar =c(9, 5, 4, 1)) 
d <-  barplot((datosgraf$Poblacion2015)/1000,axes=FALSE,col=rainbow(52),ylab="Poblaci�n",main="Poblaci�n A�o 2015",ylim=c(0,7000))
pts <- pretty(datosgraf$Poblacion2015/ 1000)
axis(2, at = pts, labels = paste(pts, "M", sep = ""))
axis(1, at=d,labels=row.names(datosgraf), las=2,cex.lab=4,cex.axis=0.8)
grid()
dev.off()


##Plot SpacialPolygonDataFrame

plot(provincias,col=provincias$Poblacion2015)

png("PlotPobl2015.png")
spplot(provincias,"Poblacion2015",main="Poblacion por Provincia 2015")
dev.off()
install.packages("RColorBrewer")

library(RColorBrewer)
my.cols <- brewer.pal(6, "Blues")

png("PlotSpainPop2015")
spplot(provincias,zcol="Poblacion2015",col.regions=colorRampPalette(c("white","grey10"))(20),
       main=list(label="Poblaci�n por Provincias 2015",cex=2),labels=provincias$Poblacion2015/1000)
dev.off()

##combinar shapefiles con ggmap
library(ggmap)
library(rgdal)
library(ggplot2)
library(maptools)
 
map <- get_map("spain",zoom=4,source="google",maptype="hybrid")
map <- ggmap(map)
shapefile <- readOGR(".","Provincias_ETRS89_30N")
shapefile <- spTransform(shapefile,CRS("+proj=longlat +  datum=WGS84"))
shapefile <- fortify(shapefile)
png("MapSpainshapeggmap.png")
map+geom_polygon(aes(x=long,y=lat,group=group),fill='grey',color='white',data=shapefile,alpha=0)
dev.off()
