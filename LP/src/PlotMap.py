import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

class PlotMap:
    def __init__(self, width, height, positions, dimensions):
        self.__width = width
        self.__height = height
        self.__positions = positions
        self.__dimensions = dimensions

    def plot(self):
        fig = plt.figure()
        ax = fig.add_subplot(1, 1, 1)
        ax.grid(color = (0.7, 0.7, 0.7), linestyle = "--", linewidth = 1)

        palette = sns.color_palette("hls", len(self.__positions))

        for i in range(len(self.__positions)):
            ax.add_patch(Rectangle(
                (self.__positions[i][0], self.__positions[i][1]),
                self.__dimensions[i][0], 
                self.__dimensions[i][1],
                color = palette[i])
            )

        plt.xlim([0, self.__width])
        plt.ylim([0, self.__height])
        
        plt.show()