!== last modified  12-05-2011
      SUBROUTINE R8INIT(VOLEQ,DBHMIN,BFMIND,B,VFLAG,ERRFLAG)

C CREATED  : 11-8-2002

C PURPOSE  : THIS SUBROUTINE SETS VALUES USED TO CALC THE MERCH HT OF A TREE
C Reversion history:
C 12/05/11  YW Added an array for the coefficients from Ed etal 1984. The old 
C              coef was incorrect for (B4, B5 and B6),
C*********************************
C       DECLARE VARIBLES         *
C*********************************
      CHARACTER*10 VOLEQ
      CHARACTER*3 S_SPEC(138),SPEC,CHECK
      INTEGER VFLAG,ERRFLAG,DONEFLAG,FIRST,HALF,LAST,LASTFLAG,PTR
	REAL B(6),BFMIND,DBHMIN
      REAL S_B1(2,135),S_B2(2,135),S_B3(2,135),S_B4(2,135),S_B5(2,135)
      REAL S_B6(2,135),COEFB(26,6)
      INTEGER SPGRPCD(138),SPCD
C     SET TABLES FOR SE VARIANT
      DATA S_SPEC 
c     &  /'010','057','068','090','107','110','111','115','121','122',
c     &   '123','126','128','129','131','132','221','222','260','261',
c     &   '290','310','311','313','316','317','318','323','330','331',
c     &   '370','371','372','373','391','400','401','402','403','404',
c     &   '405','407','408','409','450','460','461','462','471','490',
c     &   '491','500','521','531','540','541','543','544','545','546',
c     &   '552','555','571','580','591','601','602','611','621','641',
c     &   '650','651','652','653','654','660','680','681','682','691',
c     &   '692','693','694','701','711','721','731','740','741','742',
c     &   '743','746','762','802','804','806','809','812','813','817',
c     &   '819','820','822','823','824','825','826','827','828','830',
c     &   '831','832','833','834','835','836','837','838','840','842',
c     &   '901','920','922','931','950','951','970','971','972','974',
c     &   '975','977','990','994','999'/
     & /  '010','057','068','090','107','110','111','115','121','122',
     &'123','126','128','129','130','131','132','221','222','260','261',
     &    '290','298','310','311','313','316','317','318','323','330',
     &    '331','370','371','372','373','391','400','401','402','403',
     &    '404','405','407','408','409','450','460','461','462','471',
     &    '490','491','500','521','531','540','541','543','544','545',
     &    '546','552','555','571','580','591','601','602','611','621',
     &    '641','650','651','652','653','654','660','680','681','682',
     &    '691','692','693','694','701','711','721','731','740','741',
     &    '742','743','746','762','802','804','806','809','812','813',
     &    '817','819','820','822','823','824','825','826','827','828',
     &    '830','831','832','833','834','835','836','837','838','840',
     &    '842','901','920','922','931','950','951','970','971','972',
     &    '974','975','977','990','994','998','999'/
      DATA SPGRPCD/
C     Species grouping is based on the code nbolts.f in SN and SE variants      
     &  5, 8, 8, 4, 2, 2, 2, 2, 2, 2,
     &  2, 2, 2, 3, 1, 3, 1,13,18, 9, 9,
     &  2, 2,14,18,12,14,18,18,18,21,
     & 25,16,16,16,16,12,23,23,23,23,
     & 23,23,23,23,23,25,21,15,21,12,
     & 12,12,12,21,20,19,19,19,19,19,
     & 11,25,14,12,14,21,21,21,19,19,
     & 21,21,19,23,21,21,21,12,12,12,
     & 21,21,21,14,12,21,21,21,12,25,
     & 25,25,25,19,20,20,22,22,21,21,
     & 20,20,22,20,20,22,22,20,22,20,
     & 20,20,22,21,20,20,22,21,20,20,
     & 20,21,13,21,21,21,21,21,15,21,
     & 15,21,15,21,12,21,2/
      DATA ((COEFB(I,J),J=1,6),I=1,26)/
C     Coef from Ek etal 1984 (NC-309)      
c     1 JACK PINE
     & 16.9340,0.12972,1.00000,0.20854,0.77792,0.12902,
C     2 RED PINE
     & 36.8510,0.08298,1.00000,0.00001,0.63884,0.18231,
C     3 WHITE PINE
     & 16.2810,0.08621,1.00000,0.16220,0.86833,0.23316,
C     4 WHITE SPRUCE
     & 31.9570,0.18511,1.70200,0.00000,0.68967,0.16200,
C     5 BALSAM FIR
     & 14.3040,0.19894,1.41950,0.23349,0.76878,0.12399,
C     6 BLACK SPRUCE
     & 20.0380,0.18981,1.29090,0.17836,0.57343,0.10159,
C     7 TAMARACK
     & 13.6200,0.24255,1.28850,0.25831,0.68128,0.10771,
C     8 NORTHERN WHITE CEDAR
     & 8.2079,0.19672,1.31120,0.33978,0.76173,0.11666,
C     9 HEMLOCK
     & 5.3117,0.10357,1.00000,0.68454,0.71410,0.00000,
     & 0.0000,0.0000,0.00000,0.00000,0.00000,0.00000,
C     11 BLACK AND GREEN ASH
     & 11.2910,0.2525,1.54660,0.35711,0.75060,0.06859,
C     12 COTTONWOOD
     & 13.6250,0.28668,1.61240,0.30651,1.02920,0.07460,
C     13 SILVER MAPLE
     & 6.9572,0.26564,1.00000,0.48660,0.76954,0.01618,
C     14 RED MAPLE
     & 6.8600,0.27725,1.42870,0.40115,0.85299,0.12403,
C     15 ELM(AMERICAN, RED, ROCK)
     & 8.4580,0.27527,1.96020,0.34894,0.89213,0.12594,
C     16 YELLOW BIRCH
     & 7.1852,0.28384,1.44170,0.38884,0.82157,0.11411,
C     17 BASSWOOD
     & 6.3628,0.27859,1.86770,0.49589,0.76169,0.05841,
C     18 SUGAR MAPLE, BLACK MAPLE
     & 5.3416,0.23044,1.15290,0.54194,0.83440,0.06372,
C     19 WHITE ASH
     & 8.1782,0.27316,1.72500,0.38694,0.75822,0.10847,
C     20 WHITE OAK
     & 9.2078,0.22208,1.00000,0.31723,0.83560,0.13465,
C     21 SELECT RED OAK
     & 6.6844,0.19049,1.00000,0.43972,0.82962,0.10806,
C     22 OTHER RED OAK
     & 3.8011,0.39213,2.90530,0.55634,0.84317,0.09593,
C     23 HICKORY
     & 6.1034,0.17368,1.00000,0.44725,1.02370,0.14610,
C     24 BIGTOOTH ASPEN
     & 5.5346,0.22637,1.00000,0.46818,0.72456,0.11782,
C     25 QUACKING ASPEN, BALSAM POPLAR
     & 6.4301,0.23545,1.33800,0.47370,0.73385,0.08228,
C     26 PAPER BIRCH
     & 7.2773,0.22721,1.00000,0.41179,0.76498,0.11046/
      
      DATA (S_B1(1,I),I=1,65)/
     & 14.30400,  8.20790,  8.20790, 31.95700, 36.85100,
     & 36.85100, 36.85100, 36.85100, 36.85100, 36.85100,
     & 36.85100, 36.85100, 36.85100, 16.28100, 16.28100, 
     & 16.93400,  6.95720,  5.34160,  5.31170,  5.31170, 
     & 36.85100,  6.86000,  5.34160, 13.62500,  6.86000, 
     &  5.34160,  5.34160,  5.34160,  6.68440,  6.43010, 
     &  7.18520,  7.18520,  7.18520,  7.18520, 13.62500, 
     &  6.10340,  6.10340,  6.10340,  6.10340,  6.10340, 
     &  6.10340,  6.10340,  6.10340,  6.10340,  6.43010, 
     &  6.68440,  8.45800,  6.68440, 13.62000, 13.62500, 
     & 13.62500, 13.62000,  6.68440,  9.20780,  6.68440, 
     &  8.17820,  8.17820,  8.17820,  8.17820, 11.29100, 
     &  6.43010,  6.86000, 13.62000,  6.86000,  6.68440/
      DATA (S_B1(1,I),I=66,135)/
     &  6.68440,  6.68440,  8.17820,  8.17820,  6.68440, 
     &  6.68440,  8.17820,  6.68440,  6.68440,  6.68440, 
     &  6.68440, 13.62000, 14.30400, 13.62000,  6.68440, 
     &  6.68440,  6.68440,  6.86000, 13.62500,  6.68440, 
     &  6.68440,  6.68440, 13.62500,  6.43010,  6.43010, 
     &  6.43010,  6.43010,  8.17820,  9.20780,  9.20780, 
     &  3.80110,  3.80110,  6.68440,  6.68440,  9.20780, 
     &  9.20780,  3.80110,  9.20780,  9.20780,  3.80110, 
     &  3.80110,  9.20780,  3.80110,  9.20780,  9.20780, 
     &  9.20780,  3.80110,  6.68440,  9.20780,  9.20780, 
     &  3.80110,  6.68440,  9.20780,  9.20780,  9.20780, 
     &  6.68440,  6.95720,  6.68440,  6.68440,  6.68440, 
     &  6.68440,  6.68440,  8.45800,  6.68440,  8.45800, 
     &  6.68440,  8.45800,  6.68440, 13.62000, 36.85100/
C
      DATA (S_B2(1, I),I=1,65)/
     &  0.19894,  0.19672,  0.19672,  0.18511,  0.08298, 
     &  0.08298,  0.08298,  0.08298,  0.08298,  0.08298, 
     &  0.08298,  0.08298,  0.08298,  0.08621,  0.08621, 
     &  0.12972,  0.26564,  0.23044,  0.10357,  0.10357, 
     &  0.08298,  0.27725,  0.23044,  0.28668,  0.27725, 
     &  0.23044,  0.23044,  0.23044,  0.19049,  0.23545, 
     &  0.28384,  0.28384,  0.28384,  0.28384,  0.28668, 
     &  0.17368,  0.17368,  0.17368,  0.17368,  0.17368, 
     &  0.17368,  0.17368,  0.17368,  0.17368,  0.23545, 
     &  0.19049,  0.27527,  0.19049,  0.24255,  0.28668, 
     &  0.28668,  0.24255,  0.19049,  0.22208,  0.19049, 
     &  0.27316,  0.27316,  0.27316,  0.27316,  0.25250, 
     &  0.23545,  0.27725,  0.24255,  0.27725,  0.19049/
      DATA (S_B2(1,I),I=66,135)/
     &  0.19049,  0.19049,  0.27316,  0.27316,  0.19049, 
     &  0.19049,  0.27316,  0.19049,  0.19049,  0.19049, 
     &  0.19049,  0.24255, 14.30400,  0.24255,  0.19049, 
     &  0.19049,  0.19049,  0.27725,  0.28668,  0.19049, 
     &  0.19049,  0.19049,  0.28668,  0.23545,  0.23545, 
     &  0.23545,  0.23545,  0.27316,  0.22208,  0.22208, 
     &  0.39213,  0.39213,  0.19049,  0.19049,  0.22208, 
     &  0.22208,  0.39213,  0.22208,  0.22208,  0.39213, 
     &  0.39213,  0.22208,  0.39213,  0.22208,  0.22208, 
     &  0.22208,  0.39213,  0.19049,  0.22208,  0.22208, 
     &  0.39213,  0.19049,  0.22208,  0.22208,  0.22208, 
     &  0.19049,  0.26564,  0.19049,  0.19049,  0.19049, 
     &  0.19049,  0.19049,  0.27527,  0.19049,  0.27527, 
     &  0.19049,  0.27527,  0.19049,  0.24255,  0.08298/
C
      DATA (S_B3(1,I),I=1,65)/
     &  1.41950,  1.31120,  1.31120,  1.70200,  1.00000, 
     &  1.00000,  1.00000,  1.00000,  1.00000,  1.00000, 
     &  1.00000,  1.00000,  1.00000,  1.00000,  1.00000, 
     &  1.00000,  1.00000,  1.15290,  1.00000,  1.00000, 
     &  1.00000,  1.42870,  1.15290,  1.61240,  1.42870, 
     &  1.15290,  1.15290,  1.15290,  1.00000,  1.33800, 
     &  1.44170,  1.44170,  1.44170,  1.44170,  1.61240, 
     &  1.00000,  1.00000,  1.00000,  1.00000,  1.00000, 
     &  1.00000,  1.00000,  1.00000,  1.00000,  1.33800, 
     &  1.00000,  1.96020,  1.00000,  1.28850,  1.61240, 
     &  1.61240,  1.28850,  1.00000,  1.00000,  1.00000, 
     &  1.72500,  1.72500,  1.72500,  1.72500,  1.54660, 
     &  1.33800,  1.42870,  1.28850,  1.42870,  1.00000/
      DATA (S_B3(1,I),I=66,135)/
     &  1.00000,  1.00000,  1.72500,  1.72500,  1.00000, 
     &  1.00000,  1.72500,  1.00000,  1.00000,  1.00000, 
     &  1.00000,  1.28850, 14.30400,  1.28850,  1.00000, 
     &  1.00000,  1.00000,  1.42870,  1.61240,  1.00000, 
     &  1.00000,  1.00000,  1.61240,  1.33800,  1.33800, 
     &  1.33800,  1.33800,  1.72500,  1.00000,  1.00000, 
     &  2.90530,  2.90530,  1.00000,  1.00000,  1.00000, 
     &  1.00000,  2.90530,  1.00000,  1.00000,  2.90530, 
     &  2.90530,  1.00000,  2.90530,  1.00000,  1.00000,
     &  1.00000,  2.90530,  1.00000,  1.00000,  1.00000, 
     &  2.90530,  1.00000,  1.00000,  1.00000,  1.00000, 
     &  1.00000,  1.00000,  1.00000,  1.00000,  1.00000, 
     &  1.00000,  1.00000,  1.96020,  1.00000,  1.96020, 
     &  1.00000,  1.96020,  1.00000,  1.28850,  1.00000/
C
      DATA (S_B4(1,I),I=1,65)/
     &  0.31723,  0.43972,  0.31723,  0.30651,  0.43972, 
     &  0.30651,  0.43972,  0.38694,  0.38884,  0.38694, 
     &  0.30651,  0.30651,  0.43972,  0.44725,  0.44725, 
     &  0.43972,  0.43972,  0.43972,  0.43972,  0.43972, 
     &  0.16220,  0.43972,  0.48660,  0.31723,  0.47370, 
     &  0.43972,  0.48660,  0.47370,  0.38694,  0.47370, 
     &  0.43972,  0.31723,  0.54194,  0.55634,  0.38694, 
     &  0.30651,  0.55634,  0.31723,  0.30651,  0.47370, 
     &  0.68454,  0.43972,  0.38694,  0.43972,  0.30651, 
     &  0.38694,  0.47370,  0.44725,  0.25831,  0.43972, 
     &  0.43972,  0.33978,  0.25831,  0.40115,  0.55634, 
     &  0.00001,  0.31723,  0.16220,  0.25831,  0.43972, 
     &  0.44725,  0.40115,  0.43972,  0.00001,  0.25831/
      DATA (S_B4(1,I),I=66,135)/
     &  0.31723,  0.55634,  0.47370,  0.43972,  0.43972, 
     &  0.44725,  0.31723,  0.38694,  0.54194,  0.00001, 
     &  0.31723,  0.00001,  0.44725,  0.44725,  0.31723, 
     &  0.31723,  0.00001,  0.43972,  0.00001,  0.47370, 
     &  0.31723,  0.31723,  0.31723,  0.43972,  0.38884, 
     &  0.33978,  0.25831,  0.34894,  0.43972,  0.40115, 
     &  0.43972,  0.00001,  0.38884,  0.43972,  0.34894, 
     &  0.44725,  0.34894,  0.43972,  0.44725,  0.54194, 
     &  0.55634,  0.55634,  0.00001,  0.00001,  0.43972, 
     &  0.38694,  0.54194,  0.31723,  0.43972,  0.31723, 
     &  0.40115,  0.35711,  0.20854,  0.38694,  0.25831, 
     &  0.34894,  0.44725,  0.48660,  0.55634,  0.34894, 
     &  0.31723, 14.30400,  0.43972,  0.31723,  0.16220, 
     &  0.43972,  0.38884,  0.43972,  0.38694,  0.38694/
C
      DATA (S_B5(1,I),I=1,65)/
     &  0.83560,  0.82962,  0.83560,  1.02920,  0.82962, 
     &  1.02920,  0.82962,  0.75822,  0.82157,  0.75822, 
     &  1.02920,  1.02920,  0.82962,  1.02370,  1.02370, 
     &  0.84317,  0.82962,  0.82962,  0.82962,  0.82962, 
     &  0.86833,  0.82962,  0.76954,  0.83560,  0.73385, 
     &  0.82962,  0.76954,  0.73385,  0.75822,  0.73385, 
     &  0.82962,  0.83560,  0.83440,  0.84317,  0.75822, 
     &  1.02920,  0.84317,  0.83560,  1.02920,  0.73385, 
     &  0.71410,  0.82962,  0.75822,  0.82962,  1.02920, 
     &  0.75822,  0.73385,  1.02370,  0.68128,  0.82962, 
     &  0.82962,  0.76173,  0.68128,  0.85299,  0.84317, 
     &  0.63884,  0.83560,  0.86833,  0.68128,  0.82962, 
     &  1.02370,  0.85299,  0.82962,  0.63884,  0.68128/
      DATA (S_B5(1,I),I=66,135)/
     &  0.83560,  0.84317,  0.73385,  0.82962,  0.82962, 
     &  1.02370,  0.83560,  0.75822,  0.83440,  0.63884, 
     &  0.83560,  0.63884,  1.02370,  1.02370,  0.83560, 
     &  0.83560,  0.63884,  0.82962,  0.63884,  0.73385, 
     &  0.83560,  0.83560,  0.83560,  0.82962,  0.82157, 
     &  0.76173,  0.68128,  0.89213,  0.82962,  0.85299, 
     &  0.82962,  0.63884,  0.82157,  0.82962,  0.89213, 
     &  1.02370,  0.89213,  0.82962,  1.02370,  0.83440, 
     &  0.84317,  0.84317,  0.63884,  0.63884,  0.82962, 
     &  0.75822,  0.83440,  0.83560,  0.82962,  0.83560, 
     &  0.85299,  0.75060,  0.77792,  0.75822,  0.68128, 
     &  0.89213,  1.02370,  0.76954,  0.84317,  0.89213, 
     &  0.83560, 14.30400,  0.82962,  0.83560,  0.86833, 
     &  0.82962,  0.82157,  0.82962,  0.75822,  0.75822/
C
      DATA (S_B6(1,I),I=1,65)/
     &  0.13465,  0.10806,  0.13465,  0.07460,  0.10806, 
     &  0.07460,  0.10806,  0.10847,  0.11411,  0.10847, 
     &  0.07460,  0.07460,  0.10806,  0.14610,  0.14610, 
     &  0.09593,  0.10806,  0.10806,  0.10806,  0.10806, 
     &  0.23316,  0.10806,  0.01618,  0.13465,  0.08228, 
     &  0.10806,  0.01618,  0.08228,  0.10847,  0.08228, 
     &  0.10806,  0.13465,  0.06372,  0.09593,  0.10847, 
     &  0.07460,  0.09593,  0.13465,  0.07460,  0.08228, 
     &  0.00000,  0.10806,  0.10847,  0.10806,  0.07460, 
     &  0.10847,  0.08228,  0.14610,  0.10771,  0.10806, 
     &  0.10806,  0.11666,  0.10771,  0.12403,  0.09593, 
     &  0.18231,  0.13465,  0.23316,  0.10771,  0.10806, 
     &  0.14610,  0.12403,  0.10806,  0.18231,  0.10771/
      DATA (S_B6(1,I),I=66,135)/
     &  0.13465,  0.09593,  0.08228,  0.10806,  0.10806, 
     &  0.14610,  0.13465,  0.10847,  0.06372,  0.18231, 
     &  0.13465,  0.18231,  0.14610,  0.14610,  0.13465, 
     &  0.13465,  0.18231,  0.10806,  0.18231,  0.08228, 
     &  0.13465,  0.13465,  0.13465,  0.10806,  0.11411, 
     &  0.11666,  0.10771,  0.12594,  0.10806,  0.12403, 
     &  0.10806,  0.18231,  0.11411,  0.10806,  0.12594, 
     &  0.14610,  0.12594,  0.10806,  0.14610,  0.06372, 
     &  0.09593,  0.09593,  0.18231,  0.18231,  0.10806, 
     &  0.10847,  0.06372,  0.13465,  0.10806,  0.13465, 
     &  0.12403,  0.06859,  0.12902,  0.10847,  0.10771, 
     &  0.12594,  0.14610,  0.01618,  0.09593,  0.12594, 
     &  0.13465, 14.30400,  0.10806,  0.13465,  0.23316, 
     &  0.10806,  0.11411,  0.10806,  0.10847,  0.10847/
C
C     SET TABLES FOR SN VARIANT
      DATA (S_B1(2,I),I=1,65)/
     & 14.30400,  8.20790,  8.20790, 31.95700, 36.85100, 
     & 36.85100, 36.85100, 36.85100, 36.85100, 36.85100, 
     & 36.85100, 36.85100, 36.85100, 16.28100, 16.28100, 
     & 16.93400,  6.95720,  5.34160,  5.31170,  5.31170, 
     & 36.85100,  6.86000,  5.34160, 13.62500,  6.86000, 
     &  5.34160,  5.34160,  5.34160,  6.68440,  6.43010, 
     &  7.18520,  7.18520,  7.18520,  7.18520, 13.62500, 
     &  6.10340,  6.10340,  6.10340,  6.10340,  6.10340, 
     &  6.10340,  6.10340,  6.10340,  6.10340,  6.43010, 
     &  6.68440,  8.45800,  6.68440, 13.62000, 13.62500, 
     & 13.62500, 13.62000,  6.68440,  9.20780,  8.17820, 
     &  8.17820,  8.17820,  8.17820,  8.17820, 11.29100, 
     &  6.43010,  6.86000, 13.62000,  6.86000,  6.68440/
      DATA (S_B1(2,I),I=66,135)/
     &  6.68440,  6.68440,  8.17820,  8.17820,  6.68440, 
     &  6.68440,  8.17820,  6.10340,  6.68440,  6.68440, 
     &  6.68440, 13.62000, 14.30400, 13.62000,  6.68440, 
     &  6.68440,  6.68440,  6.86000, 13.62500,  6.68440, 
     &  6.68440,  6.68440, 13.62500,  6.43010,  6.43010, 
     &  6.43010,  6.43010,  8.17820,  9.20780,  9.20780, 
     &  3.80110,  3.80110,  6.68440,  6.68440,  9.20780, 
     &  9.20780,  3.80110,  9.20780,  9.20780,  3.80110, 
     &  3.80110,  9.20780,  3.80110,  9.20780,  9.20780, 
     &  9.20780,  3.80110,  6.68440,  9.20780,  9.20780, 
     &  3.80110,  6.68440,  9.20780,  9.20780,  9.20780, 
     &  6.68440,  6.95720,  6.68440,  6.68440,  6.68440, 
     &  6.68440,  6.68440,  8.45800,  6.68440,  8.45800, 
     &  6.68440,  8.45800,  6.68440, 13.62000, 36.85100/
C
      DATA (S_B2(2,I),I=1,65)/
     &  0.19894,  0.19672,  0.19672,  0.18511,  0.08298, 
     &  0.08298,  0.08298,  0.08298,  0.08298,  0.08298, 
     &  0.08298,  0.08298,  0.08298,  0.08621,  0.08621, 
     &  0.12972,  0.26564,  0.23044,  0.10357,  0.10357, 
     &  0.08298,  0.27725,  0.23044,  0.28668,  0.27725, 
     &  0.23044,  0.23044,  0.23044,  0.19049,  0.23545, 
     &  0.28384,  0.28384,  0.28384,  0.28384,  0.28668, 
     &  0.17368,  0.17368,  0.17368,  0.17368,  0.17368, 
     &  0.17368,  0.17368,  0.17368,  0.17368,  0.23545, 
     &  0.19049,  0.27527,  0.19049,  0.24255,  0.28668, 
     &  0.28668,  0.24255,  0.19049,  0.22208,  0.27316, 
     &  0.27316,  0.27316,  0.27316,  0.27316,  0.25250, 
     &  0.23545,  0.27725,  0.24255,  0.27725,  0.19049/
      DATA (S_B2(2,I),I=66,135)/
     &  0.19049,  0.19049,  0.27316,  0.27316,  0.19049, 
     &  0.19049,  0.27316,  0.17368,  0.19049,  0.19049, 
     &  0.19049,  0.24255, 14.30400,  0.24255,  0.19049, 
     &  0.19049,  0.19049,  0.27725,  0.28668,  0.19049, 
     &  0.19049,  0.19049,  0.28668,  0.23545,  0.23545, 
     &  0.23545,  0.23545,  0.27316,  0.22208,  0.22208, 
     &  0.39213,  0.39213,  0.19049,  0.19049,  0.22208, 
     &  0.22208,  0.39213,  0.22208,  0.22208,  0.39213, 
     &  0.39213,  0.22208,  0.39213,  0.22208,  0.22208, 
     &  0.22208,  0.39213,  0.19049,  0.22208,  0.22208, 
     &  0.39213,  0.19049,  0.22208,  0.22208,  0.22208, 
     &  0.19049,  0.26564,  0.19049,  0.19049,  0.19049, 
     &  0.19049,  0.19049,  0.27527,  0.19049,  0.27527, 
     &  0.19049,  0.27527,  0.19049,  0.24255,  0.08298/
C
      DATA (S_B3(2,I),I=1,65)/
     &  1.41950,  1.31120,  1.31120,  1.70200,  1.00000,
     &  1.00000,  1.00000,  1.00000,  1.00000,  1.00000,
     &  1.00000,  1.00000,  1.00000,  1.00000,  1.00000,
     &  1.00000,  1.00000,  1.15290,  1.00000,  1.00000,
     &  1.00000,  1.42870,  1.15290,  1.61240,  1.42870,
     &  1.15290,  1.15290,  1.15290,  1.00000,  1.33800,
     &  1.44170,  1.44170,  1.44170,  1.44170,  1.61240,
     &  1.00000,  1.00000,  1.00000,  1.00000,  1.00000,
     &  1.00000,  1.00000,  1.00000,  1.00000,  1.33800,
     &  1.00000,  1.96020,  1.00000,  1.28850,  1.61240,
     &  1.61240,  1.28850,  1.00000,  1.00000,  1.72500,
     &  1.72500,  1.72500,  1.72500,  1.72500,  1.54660,
     &  1.33800,  1.42870,  1.28850,  1.42870,  1.00000/
      DATA (S_B3(2,I),I=66,135)/
     &  1.00000,  1.00000,  1.72500,  1.72500,  1.00000, 
     &  1.00000,  1.72500,  1.00000,  1.00000,  1.00000, 
     &  1.00000,  1.28850, 14.30400,  1.28850,  1.00000, 
     &  1.00000,  1.00000,  1.42870,  1.61240,  1.00000, 
     &  1.00000,  1.00000,  1.61240,  1.33800,  1.33800, 
     &  1.33800,  1.33800,  1.72500,  1.00000,  1.00000, 
     &  2.90530,  2.90530,  1.00000,  1.00000,  1.00000, 
     &  1.00000,  2.90530,  1.00000,  1.00000,  2.90530, 
     &  2.90530,  1.00000,  2.90530,  1.00000,  1.00000, 
     &  1.00000,  2.90530,  1.00000,  1.00000,  1.00000, 
     &  2.90530,  1.00000,  1.00000,  1.00000,  1.00000, 
     &  1.00000,  1.00000,  1.00000,  1.00000,  1.00000, 
     &  1.00000,  1.00000,  1.96020,  1.00000,  1.96020, 
     &  1.00000,  1.96020,  1.00000,  1.28850,  1.00000/
C
      DATA (S_B4(2,I),I=1,65)/
     &  0.31723,  0.43972,  0.31723,  0.30651,  0.43972, 
     &  0.38694,  0.38694,  0.38884,  0.38694,  0.38694, 
     &  0.30651,  0.43972,  0.43972,  0.43972,  0.43972, 
     &  0.43972,  0.47370,  0.43972,  0.43972,  0.43972, 
     &  0.16220,  0.43972,  0.48660,  0.47370,  0.43972, 
     &  0.31723,  0.55634,  0.47370,  0.38694,  0.47370, 
     &  0.30651,  0.31723,  0.30651,  0.55634,  0.43972, 
     &  0.54194,  0.55634,  0.31723,  0.30651,  0.47370, 
     &  0.68454,  0.43972,  0.38694,  0.43972,  0.23349, 
     &  0.38694,  0.47370,  0.44725,  0.40115,  0.43972, 
     &  0.43972,  0.33978,  0.30651,  0.44725,  0.47370, 
     &  0.68454,  0.43972,  0.33978,  0.25831,  0.43972, 
     &  0.40115,  0.55634,  0.43972,  0.00001,  0.31723/
      DATA (S_B4(2,I),I=66,135)/
     &  0.16220,  0.25831,  0.43972,  0.43972,  0.43972, 
     &  0.44725,  0.43972,  0.43972,  0.00001,  0.00001, 
     &  0.31723,  0.54194,  0.44725,  0.44725,  0.00001, 
     &  0.31723,  0.00000,  0.31723,  0.00001,  0.43972, 
     &  0.00001,  0.31723,  0.43972,  0.43972,  0.38884, 
     &  0.25831,  0.25831,  0.43972,  0.40115,  0.40115, 
     &  0.43972,  0.00001,  0.00001,  0.38884,  0.34894, 
     &  0.43972,  0.43972,  0.54194,  0.44725,  0.55634, 
     &  0.55634,  0.00001,  0.00001,  0.00001,  0.43972, 
     &  0.38694,  0.43972,  0.38694,  0.54194,  0.43972, 
     &  0.40115,  0.00001,  0.31723,  0.38694,  0.25831, 
     &  0.40115,  0.20854,  0.48660,  0.38694,  0.34894, 
     &  0.31723,  0.48660,  0.55634,  0.43972,  0.16220, 
     &  0.31723,  0.38884,  0.43972,  0.38694,  0.38694/
C
      DATA (S_B5(2,I),I=1,65)/
     &  0.83560,  0.82962,  0.83560,  1.02920,  0.82962, 
     &  0.75822,  0.75822,  0.82157,  0.75822,  0.75822, 
     &  1.02920,  0.82962,  0.84317,  0.82962,  0.82962, 
     &  0.82962,  0.73385,  0.82962,  0.82962,  0.82962, 
     &  0.86833,  0.82962,  0.76954,  0.73385,  0.82962, 
     &  0.83560,  0.84317,  0.73385,  0.75822,  0.73385, 
     &  1.02920,  0.83560,  1.02920,  0.84317,  0.82962, 
     &  0.83440,  0.84317,  0.83560,  1.02920,  0.73385, 
     &  0.71410,  0.82962,  0.75822,  0.82962,  0.76878, 
     &  0.75822,  0.73385,  1.02370,  0.85299,  0.82962, 
     &  0.82962,  0.76173,  1.02920,  1.02370,  0.73385, 
     &  0.71410,  0.82962,  0.76173,  0.68128,  0.82962, 
     &  0.85299,  0.84317,  0.82962,  0.63884,  0.83560/
      DATA (S_B5(2,I),I=66,135)/
     &  0.86833,  0.68128,  0.82962,  0.82962,  0.82962, 
     &  1.02370,  0.82962,  0.82962,  0.63884,  0.63884, 
     &  0.83560,  0.83440,  1.02370,  1.02370,  0.63884, 
     &  0.83560,  0.68967,  0.83560,  0.63884,  0.82962, 
     &  0.63884,  0.83560,  0.82962,  0.82962,  0.82157, 
     &  0.68128,  0.68128,  0.82962,  0.85299,  0.85299, 
     &  0.82962,  0.63884,  0.63884,  0.82157,  0.89213, 
     &  0.82962,  0.82962,  0.83440,  1.02370,  0.84317, 
     &  0.84317,  0.63884,  0.63884,  0.63884,  0.82962, 
     &  0.75822,  0.82962,  0.75822,  0.83440,  0.82962, 
     &  0.85299,  0.63884,  0.83560,  0.75822,  0.68128, 
     &  0.85299,  0.77792,  0.76954,  0.75822,  0.89213, 
     &  0.83560,  0.76954,  0.84317,  0.82962,  0.86833, 
     &  0.83560,  0.82157,  0.82962,  0.75822,  0.75822/
C
      DATA (S_B6(2,I),I=1,65)/
     &  0.13465,  0.10806,  0.13465,  0.07460,  0.10806, 
     &  0.10847,  0.10847,  0.11411,  0.10847,  0.10847, 
     &  0.07460,  0.10806,  0.09593,  0.10806,  0.10806, 
     &  0.10806,  0.08228,  0.10806,  0.10806,  0.10806, 
     &  0.23316,  0.10806,  0.01618,  0.08228,  0.10806, 
     &  0.13465,  0.09593,  0.08228,  0.10847,  0.08228, 
     &  0.07460,  0.13465,  0.07460,  0.09593,  0.10806, 
     &  0.06372,  0.09593,  0.13465,  0.07460,  0.08228, 
     &  0.00000,  0.10806,  0.10847,  0.10806,  0.12399, 
     &  0.10847,  0.08228,  0.14610,  0.12403,  0.10806, 
     &  0.10806,  0.11666,  0.07460,  0.14610,  0.08228, 
     &  0.00000,  0.10806,  0.11666,  0.10771,  0.10806, 
     &  0.12403,  0.09593,  0.10806,  0.18231,  0.13465/
      DATA (S_B6(2,I),I=66,135)/
     &  0.23316,  0.10771,  0.10806,  0.10806,  0.10806, 
     &  0.14610,  0.10806,  0.10806,  0.18231,  0.18231, 
     &  0.13465,  0.06372,  0.14610,  0.14610,  0.18231, 
     &  0.13465,  0.16200,  0.13465,  0.18231,  0.10806, 
     &  0.18231,  0.13465,  0.10806,  0.10806,  0.11411, 
     &  0.10771,  0.10771,  0.10806,  0.12403,  0.12403, 
     &  0.10806,  0.18231,  0.18231,  0.11411,  0.12594, 
     &  0.10806,  0.10806,  0.06372,  0.14610,  0.09593, 
     &  0.09593,  0.18231,  0.18231,  0.18231,  0.10806, 
     &  0.10847,  0.10806,  0.10847,  0.06372,  0.10806, 
     &  0.12403,  0.18231,  0.13465,  0.10847,  0.10771, 
     &  0.12403,  0.12902,  0.01618,  0.10847,  0.12594, 
     &  0.13465,  0.01618,  0.09593,  0.10806,  0.23316, 
     &  0.13465,  0.11411,  0.10806,  0.10847,  0.10847/

C----------------------------------------------------------------------
C     MAIN LOGIC
      
      SPEC = VOLEQ(8:10)

C     BINARY SEARCH FOR CORRECT COEFFICIENTS
      DONEFLAG = 0
      LASTFLAG = 0
      FIRST = 1
      LAST = 138
      DO 5, WHILE (DONEFLAG.EQ.0)
         IF(FIRST.EQ.LAST) LASTFLAG = 1
          HALF=((LAST-FIRST+1)/2) + FIRST   !DETERMINE WHERE TO CHECK

          CHECK=S_SPEC(HALF)
          IF(SPEC.EQ.CHECK)THEN      !FOUND THE COEFFECIENTS
             PTR = HALF
             SPCD = SPGRPCD(PTR)
             DONEFLAG=1
             DBHMIN = 4.0
             IF(PTR .LE. 21) THEN
                BFMIND = 10
             ELSE
                BFMIND = 12
             ENDIF
c             B(1) = S_B1(VFLAG,PTR)
c             B(2) = S_B2(VFLAG,PTR)
c             B(3) = S_B3(VFLAG,PTR)
c             B(4) = S_B4(VFLAG,PTR)
c             B(5) = S_B5(VFLAG,PTR)
c             B(6) = S_B6(VFLAG,PTR)
             B(1) = COEFB(SPCD,1)
             B(2) = COEFB(SPCD,2)
             B(3) = COEFB(SPCD,3)
             B(4) = COEFB(SPCD,4)
             B(5) = COEFB(SPCD,5)
             B(6) = COEFB(SPCD,6)
          ELSEIF(SPEC.GT.CHECK)THEN  !MOVE DOWN THE LIST
             FIRST = HALF
          ELSEIF(SPEC.LT.CHECK)THEN   !MOVE UP THE LIST
             LAST = HALF - 1
          ENDIF
          IF(LASTFLAG.EQ.1 .AND. DONEFLAG.EQ.0)THEN   !DID NOT FIND A MATCH
                ERRFLAG = 1
                GO TO 998
          ENDIF     
   5  CONTINUE

C     END BINARY SEARCH

 998  RETURN
      END
