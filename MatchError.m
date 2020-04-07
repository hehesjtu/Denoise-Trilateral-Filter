function weight = MatchError(img1,img2)
          img1 = double(img1);
          img2 = double(img2);
          dis = sum(abs(img1(:)-img2(:)));
          weight = double(1/dis);
end

