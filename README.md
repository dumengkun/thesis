# Thesis

This repository contains codes and part of samples in the thesis *Multiple Testing Procedures on the Mean-Variance
Efficiency of Factor Pricing Models*.

In the `r` folder, the adptive factor-adjusted multiple testing procedure ([AdaFAT](https://arxiv.org/abs/2010.09589)) and the shrinkage operator for alternatives proportion (SOAP) are implemented by R codes. A simulation is given here as an example and model parameters are calibrated by Chinese A-share market from Jan. 2014 to 2018.

In the `torch` folder, the artificial neural network for constructing micro portfolios (listNN) is implemented in PyTorch. Empirical data in the `torch/sample` folder has been desensitized and is only used to display the format of inputs.
