function calc_percent_match(mask1, mask2)
    matches = mask1 & mask2;
    all_finded = mask1 | mask2;
    percent = length(find(matches))./length(find(all_finded)).*100;
    disp(strcat(num2str(round(percent.*100)./100), '%'));
end