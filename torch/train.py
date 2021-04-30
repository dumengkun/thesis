# -*- coding: utf-8 -*-
"""
Created on April 30, 2021

@author: Mengkun Du
"""
import numpy as np
import torch
import torch.optim as optim
from   model import listNet, ListMLE
torch.set_default_tensor_type(torch.DoubleTensor)

## Set-up
batch_size = 30
epoch_size = 200
learn_rate = 1e-4
device     = torch.device('cuda:0')
criterion  = ListMLE()
crite_aux  = torch.nn.CrossEntropyLoss()

for time_start in range(1, 3): 
   
    ## Loading
    train_x = np.load('sample/' + 'trainx' + str(time_start) + '_0.npy')
    for n_features in range(1, 68):
        try:
            temp = np.load('sample/' + 'trainx' + str(time_start) + '_' + str(n_features) + '.npy')
        except:
            break
        train_x = np.dstack((train_x, temp))
    train_x = torch.from_numpy(train_x).to(device)
    train_y = torch.from_numpy(np.load('sample/' + 'trainy' + str(time_start) + '.npy')).to(device)
    train_x = train_x.permute(0, 2, 1)
    sort_y  = torch.argsort(train_y, dim=1)
    
    ## Size
    n, p, m = train_x.size()
    
    rank_y  = torch.argsort(sort_y,  dim=1)
    class_1 = torch.zeros_like(rank_y)
    class_2 = torch.zeros_like(rank_y)
    class_1[rank_y > 0.7 * m] = 1
    class_2[rank_y < 0.3 * m] = 1
    
    ## Building
    net       = listNet(p).to(device)
    optimizer = optim.AdamW(net.parameters(), lr=learn_rate)
    
    ## Training
    for epoch in range(epoch_size):
        
        # Mini-batch
        batches      = np.random.permutation(n).reshape(n // batch_size, batch_size)
        running_loss = 0.0
        
        for i, idx in enumerate(batches):
            # Sample
            inputs = train_x[idx]
            labels = sort_y[idx]
            labs1  = class_1[idx]
            labs2  = class_2[idx]
    
            # Initialize the gradient
            optimizer.zero_grad()
    
            # Forward
            outputs, aux1, aux2 = net(inputs)
            loss = criterion(outputs, labels) + crite_aux(aux1, labs1) + crite_aux(aux2, labs2)
            
            # Backward and update
            loss.backward()
            optimizer.step()
            
            # Loss
            running_loss += loss.item()
        
        if epoch % 100 == 99:
            print('[%d, %d] loss: %.3f' % (time_start, epoch + 1, batch_size * running_loss / n))
        
    torch.save(net.state_dict(), 'model/net' + str(time_start) + '.pth')