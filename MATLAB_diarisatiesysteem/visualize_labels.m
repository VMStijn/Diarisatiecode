function [] = visualize_labels(labels,precision,colors,fig_title)
width = 0.2;
height = 1;
nr_speakers = length(unique(labels));
txt = cell(nr_speakers,1);
speakers = unique(labels);
for ii = 1:length(labels)
    xcenter = 0.1 + (ii-1)*precision;
    ycenter = 0.5;
    xpos = xcenter - width/2;
    ypos = ycenter - height/2;
    rectangle('position',[xpos ypos width height], 'FaceColor',colors{labels(ii)+1}, 'EdgeColor',colors{labels(ii)+1});
    hold on;
end
for ii = 1:nr_speakers
    txt{ii} = sprintf('nr label: %i',speakers(ii));
    plot([NaN,NaN],'color',colors{ii});
end
legend(txt);
xlim([0 length(labels)*precision + 20]);
ylim([0 1.5]);
xlabel('tijd [s]');
title(fig_title);
hold off;
grid on;
grid minor;
end
