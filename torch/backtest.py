# -*- coding: utf-8 -*-
"""
Created on April 30, 2021

@author: Mengkun Du
"""
import numpy as np
import pandas as pd
import torch
from   model import listNet
torch.set_default_tensor_type(torch.DoubleTensor)

for time_start in range(1, 3):
    
    ## Data
    test_x  = torch.from_numpy(np.load('sample/' + 'testx'  + str(time_start) + '.npy'))
    test_y  = torch.from_numpy(np.load('sample/' + 'testy'  + str(time_start) + '.npy'))
    test_x  = test_x.permute(0, 2, 1)
    
    ## Size
    n, p, m = test_x.size()
    
    ## Model
    net = listNet(p).eval()
    net.load_state_dict(torch.load('model/net' + str(time_start) + '.pth', map_location='cpu'))
    
    ## Predict
    esti_y, temp1, temp2 = net(test_x)
    rank_y = torch.argsort(esti_y, dim=1, descending=True)
    pred_y = torch.zeros_like(test_y)
    pred_k = pd.DataFrame(index=range(n), columns=['ic'])
    
    for time_pred in range(n):    
        pred_y[time_pred] = test_y[time_pred, rank_y[time_pred]]
        kendall = pd.DataFrame({'x':esti_y[time_pred].detach().numpy(), 'y':test_y[time_pred].detach().numpy()})  
        pred_k['ic'][time_pred] = kendall.corr('kendall').iloc[0,1]
    
    ## Outputs
    print('[%d] IC: %.3f' % (time_start, np.mean(pred_k)[0]))
    pred_k.to_csv('predict/ic' + str(time_start) + '.csv')
    pd_data = pd.DataFrame(np.transpose(pred_y.detach().numpy()))
    pd_data.to_csv('predict/y' + str(time_start) + '.csv')
    
