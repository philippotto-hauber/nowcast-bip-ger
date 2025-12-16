function data = f_loadoptions_ESIBCI

 
% group field is overwritten in f_load_ESIBCI with 'surveys'!

        temp = {% -------INDUSTRY-------------- %
        'Industry: Confidence Indicator' , 'ESI: industry' , 2 , 'm' , 1 , 0 , 'INDU.DE.TOT.COF.BS.M'  ;                           
        'Industry: Production trend observed in recent months' , 'ESI: industry' , 2 ,'m' , 1 , 0 , 'INDU.DE.TOT.1.BS.M' ;                  
        'Industry: Assessment of order-book levels' , 'ESI: industry', 2 , 'm' , 1 , 0 , 'INDU.DE.TOT.2.BS.M' ;                            
        'Industry: Assessment of export order-book levels' , 'ESI: industry' , 2 , 'm' , 1 , 0 , 'INDU.DE.TOT.3.BS.M' ;                       
        'Industry: Assessment of stocks of finished products' , 'ESI: industry', 2 , 'm' ,1 , 0 ,'INDU.DE.TOT.4.BS.M' ;                     
        'Industry: Production expectations for the months ahead' , 'ESI: industry', 2 ,'m' , 1 , 1 , 'INDU.DE.TOT.5.BS.M' ;                  
        'Industry: Selling price expectations for the months ahead' , 'ESI: industry' , 2 , 'm' , 1 , 1 , 'INDU.DE.TOT.6.BS.M' ;             
        'Industry: Employment expectations for the months ahead' , 'ESI: industry' , 2 , 'm' , 1 , 0 , 'INDU.DE.TOT.7.BS.M' ;
        %'Export expectations for the months ahead' ,   'ESI: industry' , 2 , 'q:A' , 0 , 0 , 'INDU.DE.TOT.12.BS.Q' ;                      
        'Industry: Current level of capacity utilization'  'ESI: industry' , 2 , 'q:A' , 0 , 0 , 'INDU.DE.TOT.13.QPS.Q' ; 
        % -------RETAIL-------------- %
        'Retail: Confidence Indicator' , 'ESI: retail' , 2 , 'm' , 1 , 0 , 'RETA.DE.TOT.COF.BS.M' ;                             
        'Retail: Business activity (sales) development over the past 3 months' , 'ESI: retail' , 2 , 'm' , 1 , 0 , 'RETA.DE.TOT.1.BS.M' ;
        'Retail: Volume of stock currently hold' , 'ESI: retail' , 2 , 'm' , 1 , 0 , 'RETA.DE.TOT.2.BS.M' ; 
        'Retail: Orders expectations over the next 3 months' , 'ESI: retail' , 2 , 'm' , 1 , 0 , 'RETA.DE.TOT.3.BS.M' ; 
        'Retail: Business activity expectations over the next 3 months' , 'ESI: retail' , 2 , 'm' , 1 , 0 , 'RETA.DE.TOT.4.BS.M' ; 
        'Retail: Employment expectations over the next 3 months' , 'ESI: retail' , 2 , 'm' , 1 , 0 , 'RETA.DE.TOT.5.BS.M' ; 
        'Retail: Prices expectations over the next 3 months' , 'ESI: retail' , 2 , 'm' , 1 , 1 , 'RETA.DE.TOT.6.BS.M' ;
        % -------CONSTRUCTION-------------- %
        'Construction: Confidence Indicator' , 'ESI: building' , 2 , 'm' , 1 , 1 , 'BUIL.DE.TOT.COF.BS.M' ;                               
        'Construction: Building activity development over the past 3 months' , 'ESI: building' , 2 , 'm' , 1 , 1 , 'BUIL.DE.TOT.1.BS.M' ; 
        'Construction: Evolution of your current overall order books' , 'ESI: building' , 2 , 'm' , 1 , 1 , 'BUIL.DE.TOT.3.BS.M' ;
        'Construction: Employment expectations over the next 3 months' , 'ESI: building' , 2 , 'm' , 1 , 1 , 'BUIL.DE.TOT.4.BS.M' ; 
        'Construction: Prices expectations over the next 3 months' , 'ESI: building' , 2 , 'm' , 1 , 1 , 'BUIL.DE.TOT.5.BS.M' ; 
        % -------SERVICES-------------- %
        'Services: Confidence Indicator' , 'ESI: services' , 2 , 'm' , 0 , 0 , 'SERV.DE.TOT.COF.BS.M' ;                            
        'Services: Business situation development over the past 3 months' , 'ESI: services' , 2 , 'm' , 0 , 0 , 'SERV.DE.TOT.1.BS.M' ;
        'Services: Evolution of the demand over the past 3 months' , 'ESI: services' , 2 , 'm' , 0 , 0 , 'SERV.DE.TOT.2.BS.M' ; 
        'Services: Expectation of the demand over the next 3 months' , 'ESI: services' , 2 , 'm' , 0 , 1 , 'SERV.DE.TOT.3.BS.M' ; 
        %'Evolution of the employment over the past 3 months' , 'ESI: services' , 2 , 'm' , 0 , 0 , 'SERV.DE.TOT.4.BS.M' ; 
        'Services: Expectations of the employment over the next 3 months' , 'ESI: services' , 2 , 'm' , 0 , 1 , 'SERV.DE.TOT.5.BS.M' ; 
        'Services: Expectations of the prices over the next 3 months' , 'ESI: services' , 2 , 'm' , 0 , 1 , 'SERV.DE.TOT.6.BS.M'
        'Services: Current level of capacity utilization' , 'ESI: services' , 2 , 'q:A' , 0 , 0 , 'SERV.DE.TOT.8.QPS.Q' ;     
        % -------CONSUMER-------------- %
        'Consumer: Confidence Indicator' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.COF.BS.M' ;                            
        'Consumer: Financial situation over last 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.1.BS.M' ; 
        'Consumer: Financial situation over next 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.2.BS.M' ;
        'Consumer: General economic situation over last 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.3.BS.M' ;
        'Consumer: General economic situation over next 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.4.BS.M' ;
        'Consumer: Price trends over last 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.5.BS.M' ;
        'Consumer: Price trends over next 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.6.BS.M' ;
        'Consumer: Unemployment expectations over next 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.7.BS.M' ;
        'Consumer: Major purchases at present' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.8.BS.M' ;
        'Consumer: Major purchases over next 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.9.BS.M' ;
        %'Savings at present' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.10.BS.M' ;
        'Consumer: Savings over next 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.11.BS.M' ;
        'Consumer: Statement on financial situation of household' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.12.BS.M' ; 
        } ;
            
data.names = temp(:,1)' ;         
data.groups= temp(:,2)' ;
data.trafo = cell2mat(temp(:,3)') ; 
data.type = temp(:,4)' ; 
data.flag_usestartvals = cell2mat(temp(:,5)') ; 
data.flag_sa = cell2mat(temp(:,6)') ;
data.seriesnames = temp(:,7)' ; 

							


	
						



              

