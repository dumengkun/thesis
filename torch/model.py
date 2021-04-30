# -*- coding: utf-8 -*-
"""
Created on April 30, 2021

@author: Mengkun Du
"""
import torch
from   torch import nn
import torch.nn.functional as F

class ListMLE(nn.Module):
    def __init__(self):
        super(ListMLE, self).__init__()
    def forward(self, outputs, labels):
        scores = torch.zeros_like(outputs)
        for t in range(scores.size()[0]):
            scores[t] = torch.logcumsumexp(outputs[t, labels[t]], dim=0)
        loss = torch.mean(scores - outputs)
        return loss

class ResidualBlock(nn.Module):
    def __init__(self, in_channels, out_channels):
        super(ResidualBlock, self).__init__()
        self.residual = nn.Sequential(
                            nn.Conv1d(in_channels, in_channels // 2, 1, bias=False),
                            nn.BatchNorm1d(in_channels // 2),
                            nn.ReLU(inplace=True),
                            nn.Conv1d(in_channels // 2, out_channels, 1, bias=False),
                            nn.BatchNorm1d(out_channels)
                        )
    def forward(self, x):
        out = self.residual(x)
        return out

class Encoder(nn.Module):
    def __init__(self, in_channels, out_channels):
        super(Encoder, self).__init__()
        if in_channels == out_channels:
            self.skip = nn.Identity()
        else:
            self.skip = nn.Conv1d(in_channels, out_channels, 1)
        self.residual = ResidualBlock(in_channels, out_channels)
        
    def forward(self, x):
        out1 = self.skip(x)
        out2 = self.residual(x)
        return F.relu(out1 + out2)

class listNet(nn.Module):
    def __init__(self, n_features):
        super(listNet, self).__init__()

        self.fc_1 = nn.Sequential(
                        nn.Conv1d(n_features, 128, 1),
                        nn.ReLU(inplace=True),
                        Encoder(128, 32),
                        Encoder(32, 8)
                    )
        self.fc_2 = nn.Sequential(
                        nn.Conv1d(8, 4, 1),
                        nn.ReLU(inplace=True),
                        nn.Conv1d(4, 1, 1)
                    )
        self.fc_3 = nn.Sequential(
                        nn.Conv1d(8, 4, 1),
                        nn.ReLU(inplace=True),
                        nn.Conv1d(4, 2, 1)
                    )
        self.fc_4 = nn.Sequential(
                        nn.Conv1d(8, 4, 1),
                        nn.ReLU(inplace=True),
                        nn.Conv1d(4, 2, 1)
                    )
        
    def forward(self, x):
        x  = self.fc_1(x)
        y1 = self.fc_2(x)
        y2 = self.fc_3(x)
        y3 = self.fc_4(x)
        return y1.squeeze(), y2, y3