# Thesis

This repository contains codes and part of samples in my PhD thesis *Multiple Testing Procedures on the Mean-Variance
Efficiency of Factor Pricing Models*, including three methods named AdaFAT, SOAP and listNN.

## AdaFAT and SOAP

In the `r` folder, the adaptive factor-adjusted multiple testing procedure ([AdaFAT](https://arxiv.org/abs/2010.09589)) and the shrinkage operator for alternatives proportion (SOAP) are written in R codes. A simulation is given here as an example and model parameters are calibrated by Chinese A-share market from Jan. 2014 to Dec. 2018.

## listNN

In the `torch` folder, the feedforward neural network for constructing micro portfolios (listNN) is implemented in PyTorch. Empirical data in the `torch/sample` folder has been masked and is used to display the format of inputs.

## Maintainers

[@dumengkun](https://github.com/dumengkun).

## License

[GPL-3.0](LICENSE)
