function data = f_loadoptions_ESIBCI

 
% group field is overwritten in f_load_ESIBCI with 'surveys'!

        temp = {% -------INDUSTRY-------------- %
        'Confidence Indicator' , 'ESI: industry' , 2 , 'm' , 1 , 0 , 'INDU.DE.TOT.COF.BS.M'  ;                           
        'Production trend observed in recent months' , 'ESI: industry' , 2 ,'m' , 1 , 0 , 'INDU.DE.TOT.1.BS.M' ;                  
        'Assessment of order-book levels' , 'ESI: industry', 2 , 'm' , 1 , 0 , 'INDU.DE.TOT.2.BS.M' ;                            
        'Assessment of export order-book levels' , 'ESI: industry' , 2 , 'm' , 1 , 0 , 'INDU.DE.TOT.3.BS.M' ;                       
        'Assessment of stocks of finished products' , 'ESI: industry', 2 , 'm' ,1 , 0 ,'INDU.DE.TOT.4.BS.M' ;                     
        'Production expectations for the months ahead' , 'ESI: industry', 2 ,'m' , 1 , 1 , 'INDU.DE.TOT.5.BS.M' ;                  
        'Selling price expectations for the months ahead' , 'ESI: industry' , 2 , 'm' , 1 , 1 , 'INDU.DE.TOT.6.BS.M' ;             
        'Employment expectations for the months ahead' , 'ESI: industry' , 2 , 'm' , 1 , 0 , 'INDU.DE.TOT.7.BS.M' ;
        'Export expectations for the months ahead' ,   'ESI: industry' , 2 , 'q:A' , 0 , 0 , 'INDU.DE.TOT.12.BS.Q' ;                      
        'Current level of capacity utilization'  'ESI: industry' , 1 , 'q:A' , 0 , 0 , 'INDU.DE.TOT.13.QPS.Q' ; 
        % -------RETAIL-------------- %
        'Confidence Indicator' , 'ESI: retail' , 2 , 'm' , 1 , 0 , 'RETA.DE.TOT.COF.BS.M' ;                             
        'Business activity (sales) development over the past 3 months' , 'ESI: retail' , 2 , 'm' , 1 , 0 , 'RETA.DE.TOT.1.BS.M' ;
        'Volume of stock currently hold' , 'ESI: retail' , 2 , 'm' , 1 , 0 , 'RETA.DE.TOT.2.BS.M' ; 
        'Orders expectations over the next 3 months' , 'ESI: retail' , 2 , 'm' , 1 , 0 , 'RETA.DE.TOT.3.BS.M' ; 
        'Business activity expectations over the next 3 months' , 'ESI: retail' , 2 , 'm' , 1 , 0 , 'RETA.DE.TOT.4.BS.M' ; 
        'Employment expectations over the next 3 months' , 'ESI: retail' , 2 , 'm' , 1 , 0 , 'RETA.DE.TOT.5.BS.M' ; 
        'Prices expectations over the next 3 months' , 'ESI: retail' , 2 , 'm' , 1 , 1 , 'RETA.DE.TOT.6.BS.M' ;
        % -------CONSTRUCTION-------------- %
        'Confidence Indicator' , 'ESI: building' , 2 , 'm' , 1 , 1 , 'BUIL.DE.TOT.COF.BS.M' ;                               
        'Building activity development over the past 3 months' , 'ESI: building' , 2 , 'm' , 1 , 1 , 'BUIL.DE.TOT.1.BS.M' ; 
        'Evolution of your current overall order books' , 'ESI: building' , 2 , 'm' , 1 , 1 , 'BUIL.DE.TOT.3.BS.M' ;
        'Employment expectations over the next 3 months' , 'ESI: building' , 2 , 'm' , 1 , 1 , 'BUIL.DE.TOT.4.BS.M' ; 
        'Prices expectations over the next 3 months' , 'ESI: building' , 2 , 'm' , 1 , 1 , 'BUIL.DE.TOT.5.BS.M' ; 
        % -------SERVICES-------------- %
        'Confidence Indicator' , 'ESI: services' , 2 , 'm' , 0 , 0 , 'SERV.DE.TOT.COF.BS.M' ;                            
        'Business situation development over the past 3 months' , 'ESI: services' , 2 , 'm' , 0 , 0 , 'SERV.DE.TOT.1.BS.M' ;
        'Evolution of the demand over the past 3 months' , 'ESI: services' , 2 , 'm' , 0 , 0 , 'SERV.DE.TOT.2.BS.M' ; 
        'Expectation of the demand over the next 3 months' , 'ESI: services' , 2 , 'm' , 0 , 1 , 'SERV.DE.TOT.3.BS.M' ; 
        'Evolution of the employment over the past 3 months' , 'ESI: services' , 2 , 'm' , 0 , 0 , 'SERV.DE.TOT.4.BS.M' ; 
        'Expectations of the employment over the next 3 months' , 'ESI: services' , 2 , 'm' , 0 , 1 , 'SERV.DE.TOT.5.BS.M' ; 
        'Expectations of the prices over the next 3 months' , 'ESI: services' , 2 , 'm' , 0 , 1 , 'SERV.DE.TOT.6.BS.M'
        %'Current level of capacity utilization' , 'ESI: services' , 1 , 'q:A' , 0 , 0 , 'SERV.DE.TOT.8.QPS.Q' ;     
        % -------CONSUMER-------------- %
        'Confidence Indicator' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.COF.BS.M' ;                            
        'Financial situation over last 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.1.BS.M' ; 
        'Financial situation over next 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.2.BS.M' ;
        'General economic situation over last 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.3.BS.M' ;
        'General economic situation over next 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.4.BS.M' ;
        'Price trends over last 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.5.BS.M' ;
        'Price trends over next 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.6.BS.M' ;
        'Unemployment expectations over next 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.7.BS.M' ;
        'Major purchases at present' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.8.BS.M' ;
        'Major purchases over next 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.9.BS.M' ;
        'Savings at present' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.10.BS.M' ;
        'Savings over next 12 months' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.11.BS.M' ;
        'Statement on financial situation of household' , 'ESI: consumer' , 2 , 'm' , 1 , 0 , 'CONS.DE.TOT.12.BS.M' ; 
        } ;
            
data.names = temp(:,1)' ;         
data.groups= temp(:,2)' ;
data.trafo = cell2mat(temp(:,3)') ; 
data.type = temp(:,4)' ; 
data.flag_usestartvals = cell2mat(temp(:,5)') ; 
data.flag_sa = cell2mat(temp(:,6)') ;
data.seriesnames = temp(:,7)' ; 

							


	
						



              

