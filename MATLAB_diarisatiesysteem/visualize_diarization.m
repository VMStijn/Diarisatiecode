function [] = visualize_diarization(labels_GT,labels_computed,precision)
width = 0.2;
height = 1;

Max_speaker_GT = max(unique(labels_GT));
Max_speaker_computed = max(unique(labels_computed));
if Max_speaker_computed > Max_speaker_GT
    nr_colors = Max_speaker_computed + 1;
    colors = num2cell(distinguishable_colors(nr_colors),2);
    nr_speakers = length(unique(labels_computed));    
    txt = cell(nr_speakers,1);
    speakers = unique(labels_computed);
else
    nr_colors = Max_speaker_GT + 1;
    colors = num2cell(distinguishable_colors(nr_colors),2);
    nr_speakers = length(unique(labels_GT));    
    txt = cell(nr_speakers,1);
    speakers = unique(labels_GT);
end
figure;
for ii = 1:length(labels_GT)
    xcenter = 0.1 + (ii-1)*precision;
    ycenter = 0.5;
    xpos = xcenter - width/2;
    ypos = ycenter - height/2;
    rectangle('position',[xpos ypos width height], 'FaceColor',colors{labels_GT(ii)+1}, 'EdgeColor',colors{labels_GT(ii)+1});
    rectangle('position',[xpos ypos+1.1 width height], 'FaceColor',colors{labels_computed(ii)+1}, 'EdgeColor',colors{labels_computed(ii)+1});
    hold on;
end
%find unused colors
unused_colors = setdiff(1:nr_colors,speakers+1);
colors(unused_colors,:) = [];
for ii = 1:nr_speakers
    txt{ii} = sprintf('nr label: %i',speakers(ii));
    plot([NaN,NaN],'color',colors{ii});
end
legend(txt);
xlim([0 length(labels_GT)*precision + 20]);
ylim([0 3]);
xlabel('tijd [s]');
title('Diarization result vs Ground Truth');
hold off;
grid on;
grid minor;
end