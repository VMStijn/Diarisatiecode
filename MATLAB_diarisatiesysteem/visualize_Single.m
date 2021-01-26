function [] = visualize_Single(unclustered,labels, nr_Datapoints)
%% Makes a visual representation of the labeled data by way of LDA
[L,D] = myLDA(unclustered(1:nr_Datapoints,:)',labels(1:nr_Datapoints));
res = L(:,1:3)'*(unclustered(1:nr_Datapoints,:)');
nr_Speakers = length(unique(labels(1:nr_Datapoints)));
figure;
lbound = -0.5;
ubound = 0.5;
txt = cell(nr_Speakers,1);
colors = num2cell(distinguishable_colors(length(unique(labels))),2);
for i = 1:nr_Speakers
    cl = res(:, labels(1:nr_Datapoints) > lbound & labels(1:nr_Datapoints) < ubound);
    lbound = lbound + 1;
    ubound = ubound + 1;
    scatter3(cl(1,:),cl(2,:),cl(3,:),15,colors{i});
    txt{i} = sprintf('cluster %i',i-1);
    hold on;
end
legend(txt);

end

