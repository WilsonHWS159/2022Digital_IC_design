import math
from PIL import Image
import numpy as np
   
if __name__ == "__main__":
    width = 128
    height = 63

    for index in range(3):
        raw_path = './img' + str(index) + '/interp_result.raw'
        golden_path = './img' + str(index) + '/test_img.png'
        out_path = './img' + str(index) + '/interp_result.png'

        # Read interpolated raw image and convert it to Pillow format
        interp_raw = np.fromfile(raw_path, dtype='uint8', sep="")
        interp_raw = interp_raw.reshape([height, width])
        interp_img = Image.new('RGB', (width, height))
        for i in range(height):
            for j in range(width):
                interp_img.putpixel((j, i), (interp_raw[i][j], interp_raw[i][j], interp_raw[i][j]))
        interp_img.save(out_path)

        # Read golden image and calculate PSNE
        golden_img = Image.open(golden_path)
        golden_img = golden_img.convert('L')
        interp_img = interp_img.convert('L')
        golden_img_array = np.array(golden_img)
        interp_img_array = np.array(interp_img)
        golden_img_array = np.delete(golden_img_array, -1, axis = 0)

        mse = np.mean((golden_img_array/255.0 - interp_img_array/255.0) **2)
        if mse < 1.0e-10:
            psnr = 100
        else:
            psnr = 20*math.log10(1/math.sqrt(mse))
        print('PSNR of image ' + str(index) + ': ' + str(psnr))

