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

ちなみに全要素で重回帰分析するとこんな感じになる。


### 2.上記変数によるロジスティック回帰分析を実施

#### 分析結果
堅田コメント
glmの結果を入れると良いと思います。具体的には、

- glmのsummary
```
glm(formula = y ~ job + education + default + poutcome, family = "binomial", 
    data = train_data)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-1.4647  -0.4136  -0.3819  -0.3296   2.5545  

Coefficients:
                              Estimate Std. Error z value Pr(>|z|)    
(Intercept)                   -2.60790    0.13142 -19.844  < 2e-16 ***
jobmanagement                 -0.09536    0.09956  -0.958  0.33818    
jobretired                     0.63019    0.12555   5.019 5.19e-07 ***
jobservices                   -0.14592    0.09728  -1.500  0.13364    
jobstudent                     0.96527    0.14763   6.539 6.21e-11 ***
jobunknown                    -0.07584    0.06491  -1.168  0.24267    
educationbasic.6y              0.07110    0.13407   0.530  0.59586    
educationbasic.9y              0.06168    0.10505   0.587  0.55711    
educationhigh.school           0.11821    0.10366   1.140  0.25412    
educationilliterate            1.40107    0.79803   1.756  0.07914 .  
educationprofessional.course   0.09504    0.10829   0.878  0.38013    
educationuniversity.degree     0.28742    0.10025   2.867  0.00414 ** 
educationunknown               0.12958    0.15116   0.857  0.39133    
defaultunknown                -0.50077    0.06730  -7.441 9.97e-14 ***
defaultyes                    -8.00827  119.46806  -0.067  0.94656    
poutcomenonexistent            0.03094    0.08591   0.360  0.71878    
poutcomesuccess                2.17834    0.15611  13.954  < 2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 13939  on 25946  degrees of freedom
Residual deviance: 13553  on 25930  degrees of freedom
AIC: 13587

Number of Fisher Scoring iterations: 9

```



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

