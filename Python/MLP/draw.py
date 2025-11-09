import matplotlib.pyplot as plt
import numpy as np


def draw_loss(save_path, train_loss, val_loss, n_epochs):
    """
    Draw the loss curves during the training process
    :param save_path: (Str) name of saved image, e.g. "loss.jpg"
    :param train_loss: (List) training loss of each training epoch
    :param val_loss: (List) validating loss of each training epoch
    :param n_epochs: (Int, Scalar) number of training epochs
    """
    epochs = np.arange(n_epochs)
    plt.figure()
    plt.plot(epochs, train_loss)
    plt.plot(epochs, val_loss)
    plt.legend(["train_loss", "val_loss"])
    plt.title("Loss Curve")
    plt.xlabel('Epoch')
    plt.ylabel('Loss')
    plt.xlim([0, n_epochs-1])
    plt.savefig(save_path, dpi=300)
    plt.show()
    print("loss curve saved!")


def draw_conf(save_path, conf):
    """
    Draw the confusion matrix during the testing process
    :param save_path: (Str) name of saved image, e.g. "conf.jpg"
    :param conf: (2-D Array) confusion matrix of shape [num_classes, num_classes]
    """
    if conf.device != 'cpu':
        conf = conf.cpu()
    labels = [chr(65 + x) for x in range(26)]
    plt.figure(figsize=(16, 16))
    plt.imshow(conf, interpolation='nearest', cmap=plt.cm.Blues)
    plt.title("Confusion Matrix")
    plt.colorbar()
    tick_marks = np.arange(len(labels))
    plt.xticks(tick_marks, labels, rotation=45, fontsize=10)
    plt.yticks(tick_marks, labels, fontsize=10)
    conf = conf.numpy().round(2)

    for i in range(len(labels)):
        for j in range(len(labels)):
            if conf[i, j] == 0:
                continue
            if i == j:
                plt.text(j, i, conf[i, j], va='center', ha='center', color='white')  # 显示百分比
            else:
                plt.text(j, i, conf[i, j], va='center', ha='center')  # 显示百分比

    plt.xlabel('Predicted Label')
    plt.ylabel('True Label')
    plt.tight_layout()
    plt.savefig(save_path)
    plt.show()
    print("confusion matrix saved!")


def draw_softmax(save_path, out):
    """
    :param save_path: (Str) name of saved image, e.g. "softmax.jpg"
    :param out: (List) output of model after softmax with temperature factor T
    :return:
    """
    if out.device != 'cpu':
        out = out.cpu()
    categories = [chr(65+x) for x in range(26)]
    plt.figure()
    bar_width = 0.3
    plt.bar(categories, out, color='tomato', width=bar_width)
    plt.legend(["with temperature"])
    plt.savefig(save_path)
    plt.show()
    print("softmax saved!")


def draw_svm(train_features, val_features, train_labels, val_labels, sv, W, b):
    """
    Draw the samples,SVM decision boundary, and support vectors
    ---------------------
    :param train_features: (2-D Tensor) training samples with the shape of [B, 2]
    :param val_features: (2-D Tensor) validation samples with the shape of [B, 2]
    :param train_labels: (List) the labels (chosen from{-1, +1}) corresponding to training samples, with the shape of [B, 1]
    :param val_labels: (List) the labels (chosen from{-1, +1}) corresponding to validation samples, with the shape of [B, 1]
    :param sv: (List) a list with the index of support vectors in training samples, with the shape of [K] (K is the number of support vectors)
    :param W: (2-D Tensor) the weight vector of SVM decision boundary (W^Tx + b), with the shape of [1, feature_channel]
    :param b: (Tensor, Scalar) the bias of SVM decision boundary (W^Tx + b), with the shape of [1,]
    """
    train_labels = (2*train_labels-1 > 0.0).int()
    val_labels = (2*val_labels-1 > 0.0).int()
    train_labels[sv] = 2
    foreground = list(set([i for i in range(train_labels.shape[0] // 2)]) - set(sv))
    foreground_sv = list(set([i for i in range(train_labels.shape[0] // 2)]) - set(foreground))
    background = list(set([i + train_labels.shape[0] // 2 for i in range(train_labels.shape[0] // 2)]) - set(sv))
    background_sv = list(set([i + train_labels.shape[0] // 2 for i in range(train_labels.shape[0] // 2)]) - set(background))
    f, ax = plt.subplots()
    plt.title("training dataset")
    ax.scatter(train_features[foreground, 0], train_features[foreground, 1], marker='.', c='r', label="-1")
    ax.scatter(train_features[foreground_sv, 0], train_features[foreground_sv, 1], marker='.', c='darkorange', label="-1 (support vector)")
    ax.scatter(train_features[background, 0], train_features[background, 1], marker='x', c='b', label="+1")
    ax.scatter(train_features[background_sv, 0], train_features[background_sv, 1], marker='x', c='c', label="+1 (support vector)")
    x = np.linspace(-20, 20, 100)
    ax.plot(x, -W[0, 0] / W[0, 1] * x - b / W[0, 1], c='y')
    ax.legend(loc="best")
    plt.ylim([-30, 30])
    plt.savefig("svm_train.jpg")
    plt.show()
    f, ax = plt.subplots()
    plt.title("validation dataset")
    foreground_val = [i for i in range(val_labels.shape[0] // 2)]
    background_val = [i + val_labels.shape[0] // 2 for i in range(val_labels.shape[0] // 2)]
    ax.scatter(val_features[foreground_val, 0], val_features[foreground_val, 1], marker='.', c='r', label="-1")
    ax.scatter(val_features[background_val, 0], val_features[background_val, 1], marker='x', c='b', label="+1")
    x = np.linspace(-20, 20, 100)
    ax.plot(x, -W[0, 0] / W[0, 1] * x - b / W[0, 1], c='y')
    ax.legend(loc="best")
    plt.ylim([-30, 30])
    plt.savefig("svm_val.jpg")
    plt.show()