get_var_codes_bbk_rtd <- function(category){

if (category == "production"){
    varnames <- c("BBKRT.M.DE.Y.I.IP1.AA020.C.I", # Produzierendes Gewerbe ohne Bau
                  "BBKRT.M.DE.Y.I.IP1.AA021.C.I",
                  "BBKRT.M.DE.Y.I.IP1.AA030.C.I",
                  "BBKRT.M.DE.Y.I.IP1.AA031.C.I",
                  "BBKRT.M.DE.Y.I.IP1.AA032.C.I",
                  "BBKRT.M.DE.Y.I.IP1.ACM01.C.I",
                  "BBKRT.M.DE.Y.I.IP1.ACM02.C.I",
                  "BBKRT.M.DE.Y.I.IP1.ACM03.C.I",
                  "BBKRT.M.DE.Y.I.IP1.ACM04.C.I",
                  "BBKRT.M.DE.Y.I.IP1.ACM05.C.I",
                  "BBKRT.M.DE.Y.I.IP1.ACM06.C.I",
                  "BBKRT.M.DE.Y.I.IP1.ACM07.C.I",
                  "BBKRT.M.DE.Y.I.IP1.AFC11.C.I",
                  "BBKRT.M.DE.Y.I.IP1.AFC12.C.I") # Tiefbau
  } else if ( category == "orders"){
    varnames <- c("BBKRT.M.DE.Y.I.IO1.AA031.C.I", # Bauhauptgewerbe
                  "BBKRT.M.DE.Y.I.IO1.ACM01.C.I",
                  "BBKRT.M.DE.Y.I.IO1.ACM02.C.I",
                  "BBKRT.M.DE.Y.I.IO1.ACM03.C.I",
                  "BBKRT.M.DE.Y.I.IO1.ACM04.C.I",  
                  "BBKRT.M.DE.Y.I.IO1.AFC11.C.I",
                  "BBKRT.M.DE.Y.I.IO1.AFC12.C.I",
                  "BBKRT.M.DE.Y.I.IO1.AFC15.C.I", 
                  "BBKRT.M.DE.Y.I.IO1.AFC21.C.I",
                  "BBKRT.M.DE.Y.I.IO1.AFC22.C.I",
                  "BBKRT.M.DE.Y.I.IO2.ACM01.C.I",
                  "BBKRT.M.DE.Y.I.IO2.ACM02.C.I",
                  "BBKRT.M.DE.Y.I.IO2.ACM03.C.I",
                  "BBKRT.M.DE.Y.I.IO2.ACM04.C.I",
                  "BBKRT.M.DE.Y.I.IO3.ACM01.C.I",
                  "BBKRT.M.DE.Y.I.IO3.ACM02.C.I",
                  "BBKRT.M.DE.Y.I.IO3.ACM03.C.I",
                  "BBKRT.M.DE.Y.I.IO3.ACM04.C.I") # Konsumgueterproduzenten
  } else if ( category == "turnover"){
    varnames <- c("BBKRT.M.DE.Y.I.IT1.AA031.V.A", # Bauhauptgewerbe
                  "BBKRT.M.DE.Y.I.IT1.ACM01.V.I",
                  "BBKRT.M.DE.Y.I.IT1.ACM02.V.I",
                  "BBKRT.M.DE.Y.I.IT1.ACM03.V.I",
                  "BBKRT.M.DE.Y.I.IT1.ACM04.V.I",
                  "BBKRT.M.DE.Y.I.IT1.ACM05.V.I",
                  "BBKRT.M.DE.Y.I.IT1.ACM06.V.I",
                  "BBKRT.M.DE.Y.I.IT1.AFC15.V.A",
                  "BBKRT.M.DE.Y.I.IT1.AFC21.V.A",
                  "BBKRT.M.DE.Y.I.IT1.AFC22.V.A",
                  "BBKRT.M.DE.Y.I.IT1.AGA01.C.I",
                  "BBKRT.M.DE.Y.I.IT1.AGC02.C.I",
                  "BBKRT.M.DE.Y.I.IT1.AGD01.C.I", 
                  "BBKRT.M.DE.Y.I.IT2.ACM01.V.I",
                  "BBKRT.M.DE.Y.I.IT2.ACM02.V.I",
                  "BBKRT.M.DE.Y.I.IT2.ACM03.V.I",
                  "BBKRT.M.DE.Y.I.IT2.ACM04.V.I",
                  "BBKRT.M.DE.Y.I.IT3.ACM01.V.I",
                  "BBKRT.M.DE.Y.I.IT3.ACM02.V.I",
                  "BBKRT.M.DE.Y.I.IT3.ACM03.V.I",
                  "BBKRT.M.DE.Y.I.IT3.ACM04.V.I") # Konsumgueterproduzenten
  } else if ( category == "prices"){
    varnames <- c("BBKRT.M.DE.Y.P.PC1.PC100.R.I", # VPI insgesamt
                  "BBKRT.M.DE.S.P.PC1.PC110.R.I",
                  "BBKRT.M.DE.Y.P.PC1.PC120.R.I",
                  "BBKRT.M.DE.S.P.PC1.PC200.R.I",
                  "BBKRT.M.DE.S.P.PC1.PC300.R.I",
                  "BBKRT.M.DE.Y.P.PC1.PC400.R.I",
                  "BBKRT.M.DE.Y.P.PC1.PC500.R.I",
                  "BBKRT.M.DE.Y.P.PC1.PC510.R.I", 
                  "BBKRT.M.DE.S.P.PC1.PC600.R.I",
                  "BBKRT.M.DE.S.P.PC1.PC610.R.I",
                  "BBKRT.M.DE.S.P.PP1.PP100.R.I",
                  "BBKRT.M.DE.S.P.PP1.PP200.R.I",
                  "BBKRT.M.DE.S.P.PP1.PP400.R.I",
                  "BBKRT.M.DE.S.P.CX1.PP000.R.I",
                  "BBKRT.M.DE.S.P.CM1.PP000.R.I") # Importpreise alle Produkte
  } else if ( category == "labor market"){
    varnames <- c("BBKRT.M.DE.S.L.BE1.AA022.P.I", # Erwerbstaetige Verarbeitendes Gewerbe + Bergbau
                  "BBKRT.M.DE.S.L.BE1.AA031.P.A",
                  "BBKRT.M.DE.S.L.BE1.CA010.P.A",
                  "BBKRT.M.DE.Y.L.BE2.AA022.H.I",
                  "BBKRT.M.DE.Y.L.BE2.AA031.H.A",
                  "BBKRT.M.DE.S.L.BG1.CA010.P.A",
                  "BBKRT.M.DE.Y.L.DE2.AA022.V.I",
                  "BBKRT.M.DE.Y.L.DE2.AA031.V.A") # Bruttoloehne und -gehaelter Bauhauptgewerbe
  } else if ( category == "national accounts"){
    varnames <- c("BBKRT.Q.DE.Y.A.AG1.CA010.A.I", # Bruttoinlandsprodukt
                  "BBKRT.Q.DE.Y.A.CA1.BA100.A.I",
                  "BBKRT.Q.DE.Y.A.CA1.BA100.V.A",
                  "BBKRT.Q.DE.Y.A.CA1.BA200.A.I",
                  "BBKRT.Q.DE.Y.A.CA1.BA200.V.A",             
                  "BBKRT.Q.DE.Y.A.CD1.BAA00.A.I",
                  "BBKRT.Q.DE.Y.A.CD1.BAA00.V.A",
                  "BBKRT.Q.DE.Y.A.CD1.BA200.A.I",
                  "BBKRT.Q.DE.Y.A.CD1.BA200.V.A",
                  "BBKRT.Q.DE.Y.A.CM1.CA010.A.I",
                  "BBKRT.Q.DE.Y.A.CM1.CA010.V.A",       
                  "BBKRT.Q.DE.Y.A.CX1.CA010.A.I",
                  "BBKRT.Q.DE.Y.A.CX1.CA010.V.A",
                  "BBKRT.Q.DE.Y.A.CJ1.CA010.A.G") # Vorratsveraenderungen
  }
  return( varnames )
}

