# sample-statistics-modeling-using-R-

目的：利益（LTV－コスト）を最大化させるような重回帰分析モデルを作成する

利用データ：ポーランドのマーケティング結果によるデータ（出所は別途明記）

## 分析アプローチ

### 1.着目したパラメータは以下の通り
- job(職種)：引退者と学生は口座作りやすい
- education(学歴)：学歴が高いと口座作りやすい
- defaultunknown（元利払いを不履行してない⇒但しunknownを不履行していないと仮定)
- poutcomesuccess(過去のキャンペーンで作成した人物は口座作りやすい（但し定期預金2つもつくるか？注意が必要）)
- 他にもマクロ経済要因（インフレ、金利、景況）は無視しがたいが、Euribor3Mなどのデータもあるが今のところは無視、時系列分析？）

### 2.上記変数によるロジスティック回帰分析を実施

#### 分析結果
堅田コメント
glmの結果を入れると良いと思います。具体的には、

- glmのsummary
Call:
glm(formula = y ~ job + education + default + poutcome, family = "binomial", 
    data = train_data)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-1.4641  -0.4070  -0.3834  -0.3216   2.5805  

Coefficients:
                               Estimate Std. Error z value Pr(>|z|)    
(Intercept)                   -2.600356   0.136623 -19.033  < 2e-16 ***
jobblue-collar                -0.067198   0.088211  -0.762   0.4462    
jobentrepreneur               -0.172347   0.137501  -1.253   0.2101    
jobhousemaid                  -0.221779   0.182196  -1.217   0.2235    
jobmanagement                 -0.094796   0.099571  -0.952   0.3411    
jobretired                     0.627932   0.126432   4.967 6.82e-07 ***
jobself-employed               0.034762   0.129872   0.268   0.7890    
jobservices                   -0.147180   0.097747  -1.506   0.1321    
jobstudent                     0.964972   0.147779   6.530 6.58e-11 ***
jobtechnician                 -0.087440   0.083537  -1.047   0.2952    
jobunemployed                 -0.008894   0.163881  -0.054   0.9567    
jobunknown                     0.015441   0.286389   0.054   0.9570    
educationbasic.6y              0.062940   0.134585   0.468   0.6400    
educationbasic.9y              0.049104   0.106049   0.463   0.6433    
educationhigh.school           0.113066   0.108512   1.042   0.2974    
educationilliterate            1.396128   0.799724   1.746   0.0809 .  
educationprofessional.course   0.092399   0.122441   0.755   0.4505    
educationuniversity.degree     0.279005   0.109053   2.558   0.0105 *  
educationunknown               0.119823   0.153795   0.779   0.4359    
defaultunknown                -0.501990   0.067421  -7.446 9.65e-14 ***
defaultyes                    -8.001668 119.468065  -0.067   0.9466    
poutcomenonexistent            0.031038   0.085942   0.361   0.7180    
poutcomesuccess                2.174938   0.156326  13.913  < 2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 13939  on 25946  degrees of freedom
Residual deviance: 13550  on 25924  degrees of freedom
AIC: 13596



- 変数選択の方法
- オッズ比とその解釈
- もし可能であればデータ可視化したグラフなどもあればなお良いと思います。



### 3.利益を最大化する閾値求める ⇒　#フラグたてる：口座作る1ないしは口座作らない0

堅田コメント
- コストを500円、売上を2000円として考えているなど、想定事項を記載すると良いと思います
- 横軸に閾値、縦軸にnet_profitをとったグラフなどがあると良いと思います。
- また、最大のROIとその閾値を記載するt良いと思います。

- 0から1まで総当たりした場合のフラグをypred_flagに格納し
- どのx（閾値）がnet_profitを最大化するかを求める。

### 4.LTVからコストを差し引いたものを計算

