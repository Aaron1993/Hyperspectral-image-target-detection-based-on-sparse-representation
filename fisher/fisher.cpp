#include <iostream>
#include"opencv2/opencv.hpp"
#include"opencv2/core/core.hpp"
#include"opencv2/imgproc/imgproc.hpp"
#include"opencv2/highgui/highgui.hpp"
#include"opencv2/ml/ml.hpp"
#include<cstdlib>
#include<stdio.h>
#include<string.h>

#define TESTNUM   3334     ///����������
#define TRAINNUM  6666  ///ѵ��������
#define TYPENUM  2      ///���
#define vec_len  70
#define P_h      100
#define P_w      100
#define TARGETNUM 57   ///Ŀ����
#define TRAIN_PO 37
#define TRAIN_NE 6629
using namespace std;
using namespace cv;

Mat get_W(Mat averagePO, Mat averageNE, Mat *train_PO, Mat *train_NE);

typedef struct {
	float img[vec_len];
	float type;
}datastruct;
typedef struct{
	float val[vec_len];
}HyperData;

HyperData Data[P_h][P_w];  //��Ÿ߹�������10~79����
datastruct TRAIND_POSITIVE[TRAIN_PO];  //����ѵ�������е�����
datastruct TRAIND_NEGATIVE[TRAIN_NE];  //����ѵ�������еĸ���
Mat train_PO[TRAIN_PO];  //ѵ����������
Mat train_NE[TRAIN_NE];
Mat *testAll[P_h][P_w];  //�������е�������
int labelGT[P_h][P_w], GT[P_h][P_w];  //�洢groundtruth

int main()
{


	cout << CV_VERSION << endl;
	///��ȡ���
	FILE *label = fopen("gt.txt", "r");
	
	for (int i = 0; i < P_h; i++)
	{
		for (int j = 0; j < P_w; j++)
		{
			fscanf(label, "%d", &labelGT[i][j]);
			GT[i][j] = labelGT[i][j];   //����
		}
	}

	///��ȡȫ������
	FILE *fp = fopen("data.txt", "r");
	for (int i = 0; i<P_h; i++)
	for (int k = 0; k<vec_len; k++)   ///ԭʼTXT�ĵ�������˳��洢
	for (int j = 0; j < P_w; j++)
		fscanf(fp, "%f", &Data[i][j].val[k]);

	for (int i = 0; i < P_h; i++)
	for (int j = 0; j < P_w; j++)          //���ļ�����ṹ��Ȼ����ת��Ϊ������
	{
		testAll[i][j] = new Mat(vec_len, 1, CV_32F, Data[i][j].val);     //���ļ�������������ʽ�洢����������һ��70x1��������
	}

	int sum_t = 0;
	int sum_b = 0;
	for (int i = 0; i<P_h; i++)
	for (int j = 0; j<P_w; j++)
	{
		if (labelGT[i][j] == 1)
		{
			sum_t++;
			if (sum_t >= 38)
				labelGT[i][j] = 2;    //�����������
		}
		else if (labelGT[i][j] == 0)
		{
			sum_b++;
			if (sum_b >= 6630)
				labelGT[i][j] = 2;    //�����������
		}
	} 
	///����ѵ������
	int TRAIND_PO_index = 0, TRAIND_NE_index = 0;
	for (int i = 0; i < P_h; i++)
	{
		for (int j = 0; j<P_w; j++)
		{
			if (labelGT[i][j] == 0)
			{
				for (int k = 0; k<vec_len; k++)
					TRAIND_NEGATIVE[TRAIND_NE_index].img[k] = Data[i][j].val[k];
				TRAIND_NE_index++;
			}
			else if (labelGT[i][j] == 1)
			{
				for (int k = 0; k<vec_len; k++)
					TRAIND_POSITIVE[TRAIND_PO_index].img[k] = Data[i][j].val[k];
				TRAIND_PO_index++;
			}
			
		}
	}


	for (int i = 0; i<TRAIN_PO; i++)
	{
		train_PO[i] = Mat(1, vec_len, CV_32FC1, TRAIND_POSITIVE[i].img);
	}
	for (int i = 0; i<TRAIN_NE; i++)
	{
		train_NE[i] = Mat(1, vec_len, CV_32FC1, TRAIND_NEGATIVE[i].img);
	}
	
	Mat averagePO = Mat::zeros(1,vec_len,  CV_32F);
	Mat averageNE = Mat::zeros(1,vec_len,  CV_32F);
	for (int i = 0; i < TRAIN_PO; i++)
		averagePO += train_PO[i];
	for (int i = 0; i < TRAIN_NE; i++)
		averageNE += train_NE[i];
	averagePO = averagePO / TRAIN_PO;  //����������ֵ����
	averageNE = averageNE / TRAIN_NE;  //����������ֵ����
	
	Mat realW(vec_len,1,CV_32F);
	realW = get_W(averagePO,averageNE,train_PO,train_NE);
	Mat m1_2_1 = averagePO*realW;
	Mat m1_2_2 = averageNE*realW;
	Mat W0 = (m1_2_1+m1_2_2)/2;   //��ֵ
	int Map[P_h][P_w];
	for (int i = 0; i < P_h; i++)
	{
		for (int j = 0; j < P_w; j++)
		{
			Mat point = realW.t()**testAll[i][j];
			if (point.at<float>(0, 0)>W0.at<float>(0, 0))
				Map[i][j] = 1;
			else
				Map[i][j] = 0;
		}
	}
	freopen("fisher_Map.txt", "w", stdout);
	for (int i = 0; i < P_h; i++)
	for (int j = 0; j < P_w;j++)
	{
		cout << Map[i][j] << " ";
		if (j % 100 == 0)
			cout << endl;
	}
	fclose(stdout);
	//cout << "����ִ����ɣ���鿴fisher_Map.txt" << endl;
	return 0;
}
Mat get_W(Mat averagePO, Mat averageNE, Mat *train_PO, Mat *train_NE)
{
	Mat S1 = Mat::zeros(vec_len, vec_len, CV_32F);
	Mat S2 = Mat::zeros(vec_len, vec_len, CV_32F);
	Mat Sw = Mat::zeros(vec_len, vec_len, CV_32F);
	Mat W = Mat::zeros(vec_len, 1, CV_32F);
	for (int i = 0; i < TRAIN_PO; i++)
	{
		//cout << "train_PO[0]��  "<<train_PO[0].rows<<"  ��  " << train_PO[0].cols << endl;
		//cout << "averagePO[0]��  " << averagePO.rows << "  ��  " << averagePO.cols << endl;
		S1 += ((train_PO[i] - averagePO).t()*(train_PO[i] - averagePO));
	}
	for (int i = 0; i < TRAIN_NE;i++)
	{
		S2 += ((train_NE[i] - averageNE).t()*(train_NE[i] - averageNE));
	}
	Sw = S1 + S2;
	W = Sw.inv()*((averagePO - averageNE).t());
	return W;
}
