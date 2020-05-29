function line = getline(img,num)
    I = rgb2ycbcr(img);
    Y = I(:,:,1);
    line = Y(num,:);
end

