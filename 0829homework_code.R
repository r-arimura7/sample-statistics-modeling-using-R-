library(MASS)
setwd("~/practical-stats-modeling/")

#データ取り込み
candidate_data<-read.csv("homework_data/bank_marketing_train.csv")

# #学習データとテストデータに分割しておきます（あとで予測のデモのため）
# train_idx<-sample(c(1:dim(candidate_data)[1]), size = dim(candidate_data)[1]*0.7)
# train<-candidate_data[train_idx, ]
# test<-candidate_data[-train_idx, ]


#学習用(train_data)とテスト用(validation_data)にデータを分ける
set.seed(1234)  # コードの再現性を保つためseedを固定
num_rows<-dim(candidate_data)[1]
num_rows
idx<-c(1:num_rows)
train_idx<-sample(idx, size = num_rows*0.7 )
train_data<-candidate_data[train_idx, ]
validation_data<-candidate_data[-train_idx, ]


#データ確認
head(candidate_data)
summary(candidate_data)
class(candidate_data$education)

#全体の成約率は7.4%
2747/(34321+2747)


#とりあえず全変数を入れてみる
hr_data.lr<-glm(y~., data=train_data, family="binomial")
summary(hr_data.lr)

#モデル変数（ターゲット層絞り込み）
#job(職種)：引退者と学生が多い 他の職種は全てunknownカテゴリーへ
#education(学歴)：学歴が高いと口座作りやすい
#defaultunknown（元利払いを不履行してない(但しunknownを不履行していないと仮定)）
#poutcomesuccess(過去のキャンペーンで作成たひとは口座作りやすい（但し定期預金2つもつくるか？注意が必要）)
#他にもマクロ経済要因（インフレ、金利、景況）は無視しがたいが今のところは無視、時系列分析？）

candidate_data$job[candidate_data$job=='housemaid']<-'unknown'
candidate_data$job[candidate_data$job=='blue-collar']<-'unknown'
candidate_data$job[candidate_data$job=='entrepreneur']<-'unknown'
candidate_data$job[candidate_data$job=='self-employed']<-'unknown'
candidate_data$job[candidate_data$job=='technician']<-'unknown'
candidate_data$job[candidate_data$job=='unemployed']<-'unknown'

#カタダ追加 再度、学習用(train_data)とテスト用(validation_data)にデータを分ける
set.seed(1234) # コードの再現性を保つためseedを固定
num_rows<-dim(candidate_data)[1]
num_rows
idx<-c(1:num_rows)
train_idx<-sample(idx, size = num_rows*0.7 )
train_data<-candidate_data[train_idx, ]
validation_data<-candidate_data[-train_idx, ]  



#上記変数による重回帰分析実施
c_data.lz<-glm(y~job+education+default+poutcome, data=train_data, family='binomial')
summary(c_data.lz)

#オッズ比検出　
exp(c_data.lz$coefficients)

#prediction (Output)
mymodel<-glm(y~job+education+default+poutcome, data=train_data, family='binomial')
summary(mymodel)

#作成したモデルを検証用データに適用し、
#マーケティングキャンペーンにリアクションする確率を求めます
score<-predict(mymodel, validation_data, type = "response")

#外れ値の検証：クックの距離
ck_dist<-cooks.distance(c_data.lz)
4/length(ck_dist)
max(ck_dist,na.rm=TRUE)
plot(c_data.lz)

#重共線性確認VIF
library(car)
car::vif(mymodel)

#フラグたてる：口座作る1ないしは口座作らない0
#0から1まで総当たりした場合のフラグをypred_flagに格納し
#最終的に求めたいのはどのx（閾値）がnet_profitを最大化するかを求める。
#堅田さんコードここから

precision<-NULL
roi<-NULL

for(i in 1:length(x)){
  ypred_flag<-ifelse(score > x[i], 1, 0)
  
  #confusion matrixを作成
  conf_mat<-table(validation_data$y, ypred_flag )
  
  #scoreが閾値以上の人 = conf_mat[3]とcon_mat[4]の合計に電話かける
  attack_num<-conf_mat[3] + conf_mat[4]
  
  #電話をするたびに500円かかるので、コストをyour_costに格納
  your_cost <- attack_num * 500
  
  #一方、電話をして申し込んでくれる人= conf_mat[4]の人数に2000円かけて売上を計算
  expected_revenue<-conf_mat[4] * 2000
  
  #売上からコストを引いて粗利 = ROIを計算
  tmp_roi<-expected_revenue - your_cost
  
  #電話をかけた人のうち、成功する割合 = Precisionを計算
  tmp_precision<-conf_mat[4]/attack_num
  
  #precisionにappendする
  precision<-c(precision, tmp_precision)
  
  #roiにappend
  roi<-c(roi,tmp_roi)
}
# For文ここまで

conf_mat

plot(x, precision, type="l")
plot(x, roi, type="l")

#売上が最大になる閾値は?
max(roi, na.rm = T)

#売上が最大になるときの閾値は？
x[which(roi==max(roi, na.rm = T))]

#thresholdに算出した閾値を入力

threshold<-x[which(roi==max(roi, na.rm = T))]
threshold

my_func<-function(dataset){
  #学習済みのモデルを使って、scoreを計算
  score<-predict(mymodel, newdata = dataset, type="response")
  
  #決めていただいた閾値でflagをたてる
  ypred_flag<-ifelse(score > threshold, 1, 0)
  
  #どの人に電話をするか 架電する = 1, しない = 0　で出力
  return(ypred_flag)
}

my_func(train_data)
