#========================================================
#             Media and Cognition
#             Homework 1 Machine Learning
#             Student ID: 2023010504
#             Name: 张乐
#             Tsinghua University
#             (C) Copyright 2025
#========================================================
import torch
import torch.nn as nn
import math
import torch.nn.functional as F


# ======================== exp2 start =========================
class LinearFunction(torch.autograd.Function):
    @staticmethod
    def forward(ctx, x, W, b):
        ctx.save_for_backward(x, W)
        output = torch.matmul(x, W.T) + b
        return output

    @staticmethod
    def backward(ctx, grad_output):
        """
        each variable in forward() needs a grad calculation
        """
        x, W = ctx.saved_tensors
        grad_x = torch.matmul(grad_output, W)
        grad_W = torch.matmul(grad_output.T, x)
        grad_b = grad_output.sum(dim=0)
        return grad_x, grad_W, grad_b


class Linear(nn.Module):
    def __init__(self, input_size, output_size):
        super(Linear, self).__init__()
        """
        you may need:
        =============================================
        nn.Parameter()
        Docs: https://pytorch.org/docs/stable/generated/torch.nn.parameter.Parameter.html#parameter
        """
        self.input_size = input_size
        self.output_size = output_size
        self.W = nn.Parameter(torch.Tensor(output_size, input_size))
        self.b = nn.Parameter(torch.Tensor(output_size))
        self.reset_parameters()

    def reset_parameters(self):
        """
        you may need:
        =============================================
        nn.init.kaiming_uniform_()
        Docs: https://pytorch.org/docs/stable/nn.init.html#torch.nn.init.kaiming_uniform_
        """
        nn.init.kaiming_uniform_(self.W, a=math.sqrt(5))
        nn.init.zeros_(self.b)


    def forward(self, x):
        """
        you may need:
        =============================================
        ***.apply()
        """
        return LinearFunction.apply(x, self.W, self.b)


class ReLUFunction(torch.autograd.Function):
    @staticmethod
    def forward(ctx, input):
        ctx.save_for_backward(input)
        output = torch.clamp(input, min=0)
        return output

    @staticmethod
    def backward(ctx, grad_output):
        input, = ctx.saved_tensors
        grad_input = grad_output.clone()
        grad_input[input < 0] = 0
        return grad_input


class ReLU(nn.Module):
    def forward(self, input):
        """
        you may need:
        =============================================
        ***.apply()
        """
        return ReLUFunction.apply(input)
# ======================== exp2 end =========================


class Classifier(nn.Module):
    def __init__(self, num_class):
        super(Classifier, self).__init__()
        self.net = nn.Sequential(
            # 基础任务
            nn.Linear(2048, 256),
            nn.ReLU(),
            nn.Linear(256, num_class)

            # exp2
            # Linear(2048, 256),
            # ReLU(),
            # Linear(256, num_class)
        )

    def forward(self, x):
        return self.net(x)
    

# ======================== exp3 start =========================
# class LinearSVM(nn.Module):
#     def __init__(self, input_dim):
#         super(LinearSVM, self).__init__()
#         ???
#     def forward(self, x):
#         return ???
# ======================== exp3 end =========================

if __name__ == "__main__":
    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    model = Classifier(26)
    model.to(device)
    print("model:", model)
    x = torch.randn((1, 2048), device=device)
    y = model(x)
    print("y:", y)
