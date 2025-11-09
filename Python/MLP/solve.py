#========================================================
#             Media and Cognition
#             Homework 1 Machine Learning
#             Student ID: 2023010504
#             Name: 张乐
#             Tsinghua University
#             (C) Copyright 2025
#========================================================
import argparse
import matplotlib.pyplot as plt
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import DataLoader
from datasets import TrafficSignDataset
from networks import Classifier
from draw import draw_loss, draw_conf, draw_softmax, draw_svm

# ======================== exp3 start =========================
# def hinge_loss(output, target):
#     """
#     basic hinge_loss h(t)=max(1-t, 0)
#     :param output: (1-D Tensor) the output of the SVM y=w^T*x+b of shape [B,]
#     :param target: (1-D Tensor) the label (chosen from {+1, -1}) of the training dataset of shape [B,]
#     """
#     ???
#     return ???

# ======================== exp3 end =========================

T = 1 # temperatures = [1e-2, 1, 1e2, 1e4, 1e6]

def train(data_root, num_class, n_epochs, batch_size, lr, num_workers, device):
    """
    The main training procedure
    ---------------------------
    :param data_root: (Str) path to the root directory of dataset
    :param num_class: (Int, Scalar) number of classes, in this task it is 26 English letters
    :param n_epochs: (Int, Scalar) number of training epochs
    :param batch_size: (Int, Scalar) batch size of training
    :param lr: (Float, Scalar) learning rate
    :param num_workers: (Int, Scalar) the number of workers for loading data in multiple processes
    :param device: (Str) 'cpu' or 'cuda', we can use 'cpu' for our homework if GPU with cuda support is not available
    """

    # use `TrafficSignDataset` to load the training and validation datasets and construct corresponding data loaders with `DataLoader`
    trainset = TrafficSignDataset(data_root, "train")
    valset = TrafficSignDataset(data_root, "val")
    trainloader = DataLoader(trainset, batch_size=batch_size, shuffle=True, num_workers=num_workers)
    valloader = DataLoader(valset, batch_size=batch_size, shuffle=False, num_workers=num_workers)

    # use `Classifier` to construct the model and put it on CPU or GPU
    model = Classifier(num_class).to(device)

    # define Adam optimizer. you may need torch.optim.Adam
    optimizer = torch.optim.Adam(model.parameters(), lr=lr)

    # define loss function
    floss = torch.nn.CrossEntropyLoss()
    trainloss = []
    valloss = []
    valacc = []
    best_valacc = 0.0

    # conduct one training and one validation per epoch during the training and validation process
    # save the training and validation losses for each epoch, in order to call draw_loss() to draw the loss curve

    print("strat training!")
    for epoch in range(n_epochs):
        # training process
        # =================== loss function should be modified in exp1/exp3 (hinge loss+L2 regularization: you may need `???.weight.data`) ================
        model.train()
        epoch_trainloss = 0.0
        for image, labels in trainloader:
            image, labels = image.to(device), labels.to(device)
            
            # outputs = model(image)  # 基础任务
            outputs = model(image) / T  # exp1
            loss = floss(outputs, labels)
            
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            
            epoch_trainloss += loss.item() * image.size(0)
        
        epoch_trainloss /= len(trainloader.dataset)
        trainloss.append(epoch_trainloss)
        print("[%d/%d]: train loss is %f" % (epoch + 1, n_epochs, epoch_trainloss))

        # validation process
        model.eval()
        epoch_valloss = 0.0
        correct = 0
        total = 0
        with torch.no_grad():
            for image, labels in valloader:
                image, labels = image.to(device), labels.to(device)
                
                # outputs = model(image)  # 基础任务
                outputs = model(image) / T  # exp1
                loss = floss(outputs, labels)
                epoch_valloss += loss.item() * image.size(0)
                
                _, predicted = torch.max(outputs.data, 1)
                total += labels.size(0)
                correct += (predicted == labels).sum().item()
                
        epoch_valloss /= len(valloader.dataset)
        epoch_valacc = correct / total
        valloss.append(epoch_valloss)
        valacc.append(epoch_valacc)
        print("[%d/%d]: val loss is %f, accuracy is %f" % (epoch + 1, n_epochs, epoch_valloss, epoch_valacc))

        # save the model with the highest accuracy on the validation set.
        # It is recommended to save the state_dict() of the model
        if epoch_valacc > best_valacc:
            best_valacc = epoch_valacc
            torch.save(model.state_dict(), "best_model.pth")

    # call draw_loss() to draw the loss function for the training and validation process
    save_path = r'C:\Users\yuezh\Desktop\2-2.png'
    draw_loss(save_path, trainloss, valloss, n_epochs)

    # ======================== exp1 start =========================
    # call draw_softmax() to draw the probability after softmax with the temperature factor
    softmax_outputs = F.softmax(outputs, dim=1)
    save_path = r'C:\Users\yuezh\Desktop\softmax{}.png'.format(T)
    draw_softmax(save_path, softmax_outputs[0])
    # ======================== exp1 end =========================

    # ======================== exp3 start =========================
    # call draw_svm() to draw the support vectors and decision margin
    # W = ???.weight.data.cpu()
    # b = ???.bias.data.cpu
    # sv = ???
    # ======================== exp3 end =========================

def test(data_root, num_class, batch_size, num_workers, device):
    """
    The main testing procedure
    ---------------------------
    :param data_root: (Str) path to the root directory of dataset
    :param num_class: (Int, Scalar) number of classes, in this task it is 26 English letters
    :param batch_size: (Int, Scalar) batch size of training
    :param num_workers: (Int, Scalar) the number of workers for loading data in multiple processes
    :param device: (Str) 'cpu' or 'cuda', we can use 'cpu' for our homework if GPU with cuda support is not available
    """
    
    # use `TrafficSignDataset` to load the testing dataset and construct corresponding data loader with `DataLoader`
    testset = TrafficSignDataset(data_root, "test")
    testloader = DataLoader(testset, batch_size=batch_size, shuffle=False, num_workers=num_workers)

    # use `Classifier` to construct the model based on state_dict() of the trained model and put it on CPU or GPU. you may need torch.load()
    model = Classifier(num_class).to(device)
    model.load_state_dict(torch.load("best_model.pth"))

    # testing process
    # save the variables for calculating the average accuracy and save the confusion matrix (normalize by row)
    model.eval()
    correct = 0
    total = 0
    conf = torch.zeros(num_class, num_class)
    
    with torch.no_grad():
        for image, labels in testloader:
            image, labels = image.to(device), labels.to(device)
            
            outputs = model(image)
            _, predicted = torch.max(outputs.data, 1)
            
            total += labels.size(0)
            correct += (predicted == labels).sum().item()
            
            for t, p in zip(labels.view(-1), predicted.view(-1)):
                conf[t.long(), p.long()] += 1

    testacc = correct / total
    print("test accuracy is %f" % (testacc))

    # call draw_conf() to draw confusion matrix
    conf = conf / conf.sum(1, keepdim=True)
    save_path = r'C:\Users\yuezh\Desktop\2-3.png'
    draw_conf(save_path, conf)


if __name__ == '__main__':
    # set random seed for reproducibility
    seed = 2025
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = True

    # set configurations of the model and training process
    parser = argparse.ArgumentParser()
    parser.add_argument('--mode', type=str, choices=["train", "test"], default="train", help="train or test the model")
    parser.add_argument('--data_root', type=str, default='data', help='file list of training image paths and labels')
    parser.add_argument('--epoch', type=int, default=15, help='number of training epochs')
    parser.add_argument('--batchsize', type=int, default=32, help='training batch size')
    parser.add_argument('--lr', type=float, default=1e-3, help='learning rate')
    parser.add_argument('--imagesize', type=tuple, default=(32, 32), help='resized image shape')
    parser.add_argument('--num_workers', type=float, default=0, help='the number of workers for loading data in multiple processes')
    parser.add_argument('--device', type=str, help='cpu or cuda')
    
    
    opt = parser.parse_args()
    if opt.device is None:
        opt.device = 'cuda' if torch.cuda.is_available() else 'cpu'

    if opt.mode == "train":  # run the training procedure
        train(data_root=opt.data_root,
              num_class=26,
              n_epochs=opt.epoch,
              batch_size=opt.batchsize,
              lr=opt.lr,
              num_workers=opt.num_workers,
              device=opt.device)

    elif opt.mode == "test":  # run the testing procedure
        test(data_root=opt.data_root,
             num_class=26,
             batch_size=opt.batchsize,
             num_workers=opt.num_workers,
             device=opt.device)
