
%put Temporarily turning log capturing off to avoid printing paths;
proc printto; run;

ods pdf style=style1 file="&DRNOC./Opioid_RCR_report.pdf"  startpage=no style=journal;

proc printto log="&DRNOC.Opioid_RCR.log"; run;
%put Turning log capturing back on;

ods pdf startpage=now;

title "Regression 1: Adjusted risk of OUD in patients with opioid exposure - Cancer Excluded.";
proc logistic data=dmlocal.opioid_flat_model_binary out=DRNOC.reg1_oud_no_cancer descending;
  class binary_race(ref='01') binary_sex(ref='01') binary_hispanic(ref='01') AGEGRP1(ref='>=65') eventyear(ref='2017') ;
  model Opioid_Use_DO_Any_Prior=opioid_flag binary_race binary_sex binary_hispanic AGEGRP1 eventyear;
  ods select ModelInfo ConvergenceStatus FitStatistics GlobalTests ModelANOVA ParameterEstimates OddsRatios Association;
run;

data reg2;
  set DMLocal.opioid_flat_file_binary;
  where Cancer_AnyEncount_Dx_Year_Prior = 0;
run;

ods pdf startpage=now;
title "Regression 2a: Guideline adherence - mixed effects regression.";
proc glimmix data=reg2 ;
  class binary_race(ref='01')  binary_sex(ref='01') binary_hispanic(ref='01') agegrp1(ref='>=65')  eventyear(ref='2017')  PROVIDERID;
    model opioid_flag(event='1') = binary_race binary_sex binary_hispanic agegrp1 eventyear  /solution dist=binary link=logit oddsratio;
      random intercept / subject=PROVIDERID;
  ods select ModelInfo Dimensions OptInfo ConvergenceStatus FitStatistics CovParms Tests3 ParameterEstimates OddsRatios;
run;

ods pdf startpage=now;
title "Regression 2b: Guideline adherence - logistic regression.";
proc logistic data=reg2 out=DRNOC.reg2b_outcomes descending ;
  class binary_race(ref='01')  binary_sex(ref='01') binary_hispanic(ref='01') agegrp1(ref='>=65')  eventyear(ref='2017');
    model opioid_flag(event='1') = binary_race binary_sex binary_hispanic agegrp1 eventyear ;
  ods select ModelInfo ConvergenceStatus FitStatistics GlobalTests ModelANOVA ParameterEstimates OddsRatios Association;
run;


ods pdf startpage=now;
title "Regression 3: Predictors of Opioid Exposure Outcomes.";
proc logistic data=dmlocal.opioid_flat_model_binary out=DRNOC.reg3_outcomes descending;
  class binary_race(ref='01')  binary_sex(ref='01') binary_hispanic(ref='01') agegrp1(ref='>=65')  eventyear(ref='2017') ;
        model opioid_flag = binary_race binary_sex binary_hispanic agegrp1 eventyear Alcohol_Use_DO_Any_Prior
        Substance_Use_DO_Any_Prior Opioid_Use_DO_Any_Prior Cannabis_Use_DO_Any_Prior Cocaine_Use_DO_Any_Prior
        Hallucinogen_Use_DO_Any_Prior Inhalant_Use_DO_Any_Prior Other_Stim_Use_DO_Any_Prior SedHypAnx_Use_DO_Any_Prior
        / selection=stepwise;
  ods select ModelInfo ConvergenceStatus FitStatistics GlobalTests ModelANOVA ParameterEstimates OddsRatios Association;
run;


ods pdf startpage=now;
title "Regression 5: Predictors of chronic opioid use.";
proc logistic data=dmlocal.opioid_flat_model_binary out=DRNOC.reg5_outcomes descending;
        class binary_race(ref='01')  binary_sex(ref='01') binary_hispanic(ref='01') agegrp1(ref='>=65')  eventyear(ref='2017') ;
        model chronic_opioid =binary_race binary_sex binary_hispanic agegrp1 eventyear Alcohol_Use_DO_Any_Prior
        Substance_Use_DO_Any_Prior Opioid_Use_DO_Any_Prior Cannabis_Use_DO_Any_Prior Cocaine_Use_DO_Any_Prior
        Hallucinogen_Use_DO_Any_Prior Inhalant_Use_DO_Any_Prior Other_Stim_Use_DO_Any_Prior SedHypAnx_Use_DO_Any_Prior
        / selection=stepwise;
  ods select ModelInfo ConvergenceStatus FitStatistics GlobalTests ModelANOVA ParameterEstimates OddsRatios Association;
run;




ods pdf startpage=now;
title "Regression 6: Effects of opioid and other sched drugs on deaths.";

ods pdf startpage=now;
title "Regression 7: Predictors of Co-Rx with Benzos.";

ods pdf startpage=now;
title "Regression 8: Adjusted risk of overdose.";
proc logistic data=DMLocal.opioid_flat_model_binary out=DRNOC.reg8_overdose descending;
  class binary_race(ref='01')  binary_sex(ref='01') binary_hispanic(ref='01') AGEGRP1(ref='>=65')  eventyear(ref='2017') ;
  model od_pre=Opioid_Prescription binary_race binary_sex binary_hispanic AGEGRP1 eventyear;
  ods select ModelInfo ConvergenceStatus FitStatistics GlobalTests ModelANOVA ParameterEstimates OddsRatios Association;
run;

ods pdf startpage=now;
title "Regression 9: Adjusted risk of fatal overdose.";
proc logistic data=DMLocal.opioid_flat_model_binary out=DRNOC.reg9_fatal_overdose descending;
  class binary_race(ref='01')  binary_sex(ref='01') binary_hispanic(ref='01') AGEGRP1(ref='>=65')  eventyear(ref='2017') ;
  model fatal_overdose=Opioid_Prescription binary_race binary_sex binary_hispanic AGEGRP1 eventyear;
  ods select ModelInfo ConvergenceStatus FitStatistics GlobalTests ModelANOVA ParameterEstimates OddsRatios Association;
run;

ods pdf startpage=now;
title "Regression 10: Adjusted odds of smoking.";
proc logistic data=DMLocal.opioid_flat_model_binary out=DRNOC.reg10_smoking descending;
  class binary_race(ref='01') binary_sex(ref='01') binary_hispanic(ref='01') AGEGRP1(ref='>=65')  eventyear(ref='2017') ;
  model smoking=opioid_flag binary_race binary_sex binary_hispanic AGEGRP1 eventyear;
  ods select ModelInfo ConvergenceStatus FitStatistics GlobalTests ModelANOVA ParameterEstimates OddsRatios Association;
run;

ods pdf close;

*Remove Work library datasets;
proc datasets lib=work NOlist MEMTYPE=data kill;
run; quit;

%put Turning off log capturing to rewrite log file and mask all numbers less than the low cell count threshold;
proc printto; run;