#========================================================
#             Media and Cognition
#             Homework 1 Machine Learning
#             Student ID: 2023010504
#             Name: 张乐
#             Tsinghua University
#             (C) Copyright 2025
#========================================================

import os
import torch.utils.data as data
import torchvision.transforms as transforms
from PIL import Image
import torch


class TrafficSignDataset(data.Dataset):
    def __init__(self, data_root, mode):
        assert mode in ["train", "val", "test"]
        self.mode = mode  
        dataset_file = os.path.join(data_root, self.mode + '.pt')  # 加载数据集文件
        dataset = torch.load(dataset_file)  # 加载.pt文件
        self.data = dataset['data']
        self.labels = dataset['label'] 

    def __getitem__(self, index):
        # return image and label
        image = self.data[index]
        label = self.labels[index]
        return image, label

    def __len__(self):
        return len(self.labels)


if __name__ == "__main__":
    train_dataset = TrafficSignDataset("./data", "train")
    val_dataset = TrafficSignDataset("./data", "val")
    test_dataset = TrafficSignDataset("./data", "test")
    print("length of train data:", len(train_dataset))
    print("length of val data:", len(val_dataset))
    print("length of test data:", len(test_dataset))
