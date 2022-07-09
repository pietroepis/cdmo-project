import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

class PlotMap:
    def __init__(self, width, height, positions, dimensions):
        self.__width = width
        self.__height = height
        self.__positions = positions
        self.__dimensions = dimensions

    def plot(self, savepath = None):
        fig = plt.figure()
        ax = fig.add_subplot(1, 1, 1)
        ax.grid(color = (0.7, 0.7, 0.7), linestyle = "--", linewidth = 1)

        palette = sns.color_palette("hls", len(self.__positions))

        for i in range(len(self.__positions)):
            r = Rectangle(
                (self.__positions[i][0], self.__positions[i][1]),
                self.__dimensions[i][0], 
                self.__dimensions[i][1],
                color = palette[i]
            )
            ax.add_patch(r)
            ax.annotate(str(i), (self.__positions[i][0] + 0.1, self.__positions[i][1] + 0.1), color='w', weight='bold', fontsize=8)

        plt.xlim([0, self.__width])
        plt.ylim([0, self.__height])
        
        if savepath != None:
            plt.savefig(savepath)
        else:
            plt.show()