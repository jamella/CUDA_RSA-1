\*
 * C++ CUDE file containing RSA Parallel Code
 *
 * Copyright 2015 Vedsar
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*\

#include<stdio.h>
#include<stdlib.h>
#include<sys/time.h>
#define TICK gettimeofday(&start,NULL); 
#define TOCK gettimeofday(&end,NULL); 
#define TIME ((end.tv_sec-start.tv_sec)*1000000+(end.tv_usec-start.tv_usec))
#define sz 100
__device__ int temp_mat[sz][2*sz+1];
__device__ int cpy_p[sz];
__device__ int half_carr[sz];
__device__ int rem_mul[sz];
__device__ __shared__ int flag;
__device__ __shared__ int tf1;

__global__ void cuda_prime(int *a,int *p,int lena,int lenp,int sz) {
	int r_len,len;
	int i,num,c_temp,tf;
	while(1) {
		if(threadIdx.x==0) {
			flag=0;
			if(p[lenp-1]%2==0) {
				flag=1;
			}
		}
		__syncthreads();
		if(flag==1) {
			//do square a^2 mod p
			num=p[blockIdx.x];
			c_temp=num*p[threadIdx.x];
			temp_mat[blockIdx.x][threadIdx.x]=c_temp;
			//check carry
			tf=1;
			while(tf==1) {
				tf=0;
				if(temp_mat[blockIdx.x][threadIdx.x]>9) {
					tf=1;
					temp_mat[blockIdx.x][threadIdx.x+1]+=(c_temp/10);
					temp_mat[blockIdx.x][threadIdx.x]=c_temp%10;
				}
			}
			//half cpy_p
			if(blockIdx.x==0) {
				if(cpy_p[threadIdx.x]%2!=0)
					half_carr[threadIdx.x]=1;
				cpy_p[threadIdx.x]=cpy_p[threadIdx.x]/2;
				if(half_carr[threadIdx.x]==1)
					cpy_p[threadIdx.x-11]+=5;
			
		}
		else {
			//do multi
			if(len==0) {
				if(blockIdx.x==0) {
					rem_mul[threadIdx.x]=cpy_p[threadIdx.x];
					if(threadIdx.x==0) {
						if(cpy_p[0]==0) {
							cpy_p[0]=9;
							cpy_p[1]=cpy_p[1]-1;
						}
						else {
							cpy_p[0]=cpy_p[0]-1;
						}
					}
				}
			}
			else {	
				//multi rem_mul with a mod p
				num=p[blockIdx.x];
	                        c_temp=num*p[threadIdx.x];
        	               	temp_mat[blockIdx.x][threadIdx.x]=c_temp;
                	        //check carry
                        	tf=1;
	                        while(tf==1) {
        	                        tf=0;
                	                if(temp_mat[blockIdx.x][threadIdx.x]>9) {
                        	               	tf=1;
                                	        temp_mat[blockIdx.x][threadIdx.x+1]+=(c_temp/10);
                                        	temp_mat[blockIdx.x][threadIdx.x]=c_temp%10;
	                               	}
        	                }

			}
		}
		//update length
		if(a[threadIdx.x]==-1)
			lena=threadIdx.x;
		if(cpy_p[threadIdx.x]==-1)
			lenp=threadIdx.x;
		//if(
		__syncthreads();
		if(lenp==1) {
			if(a[0]==1)
				fin[0]=1;
			else
				fin[0]=-1;
			break;
		}
	}
}

struct timeval start,end;

int main(int argc,char *argv[]) {
	int *dp,*mp,*mq,*dq,i,th,*da,*ma,*dfin,*mfin;
	mp=(int *)malloc(sz*sizeof(int));
	lenp=sz;
	lena=1;
	ma=(int *)malloc(sizeof(int)*sz);
	mfin=(int *)malloc(sizeof(int));
	cudaMalloc(&dfin,sizeof(int));
	if(cudaMalloc(&da,sizeof(int)*sz)!=cudaSuccess) {
                printf("Not enough memory\n");
                return 0;
        }
	if(cudaMalloc(&dp,sizeof(int)*sz)!=cudaSuccess) {
		printf("Not enough memory\n");
		return 0;
	}
	//kernel call
	while(1) {
	for(i=0;i<sz;i++)
		mp[i]=rand()%10;

	cudaMemcpy(mp,dp,sizeof(int)*sz,cudaMemcpyHostToDevice);
	
	th=sz;
	th=((th/32)+1)*32;
	cuda_prime<<<sz,th>>>(da,dp,lena,lenp,sz);
	cudaMemcpy(dfin,mfin,sizeof(int)*sz,cudaMemcpyDeviceToHost);
	if(mfin[0]==1)
		break;
	}
	}
	mq=(int *)malloc(sz*sizeof(int));
        cudaMalloc(&dq,sizeof(int)*sz);
	while(1) {
	for(i=0;i<sz;i++)
                mq[i]=rand()%10;
        
        cudaMemcpy(mq,dq,sizeof(int)*sz,cudaMemcpyHostToDevice);
       	
	th=sz;
        th=((th/32)+1)*32;
        cuda_test<<<sz,th>>>(dq,sz);
	
	//cudaMemcpy(dq,mq,sizeof(int)*sz,cudaMemcpyHostToDevice);
	cudaMemcpy(dfin,mfin,sizeof(int)*sz,cudaMemcpyDeviceToHost);
	if(mfin[0]==1)
		break;
	}
	}
	return 0;
}
