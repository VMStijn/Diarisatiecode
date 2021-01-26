function [] = visualize_diarization_New(REF,HYP,HYP2)
%Visualizes the diarization result
%% INPUTS
%   REF=            reference, constructed with constructREF.m using the
%                   manual annotation
%   HYP=            diarization result, constructed with constructHYP.m
%                   using the labels computed by the diarization system
%   HYP2=           secondary diarization result, constructed with
%                   constructHYP.m using the labels computed by the diarization system

%% OUTPUTS
%   figure that displays the diarization result and the manual annotation

%% FUNCTION BODY
height = 1;

Max_speaker_GT = max(unique(REF(:,1)));
Max_speaker_computed = max(unique(HYP(:,1)));
if Max_speaker_computed > Max_speaker_GT
    nr_colors = Max_speaker_computed + 1;
    colors = num2cell(distinguishable_colors(nr_colors),2);
    nr_speakers = length(unique(HYP(:,1)));    
    txt = cell(nr_speakers,1);
    speakers = unique(HYP(:,1));
else
    nr_colors = Max_speaker_GT + 1;
    colors = num2cell(distinguishable_colors(nr_colors),2);
    nr_speakers = length(unique(REF(:,1)));    
    txt = cell(nr_speakers,1);
    speakers = unique(REF(:,1));
end
   
    height = 2
figure;
hold on;
speakers = unique(REF(:,1));
nr_speakers = length(unique(REF(:,1)));
txt = cell(nr_speakers,1);
if nargin > 2
    nr_colorsprev = nr_colors;
    nr_colors = nr_colors + length(unique(HYP2(:,1)))+1;
    colors = num2cell(distinguishable_colors(nr_colors),2);
    ypos = 4.2
    % Top of figure, secondary diarization result (HYP2)
    for ii = 1:size(HYP2,1)
    xpos = HYP2(ii,2);

    width = HYP2(ii,3)-xpos;
    rectangle('position',[xpos ypos width height], 'FaceColor',colors{HYP2(ii,1)+1+nr_colorsprev}, 'EdgeColor',colors{HYP2(ii,1)+1+nr_colorsprev});

    end
end
ypos = 0;
%Bottom of figure, manual annotation
for ii = 1:size(REF,1)
    xpos = REF(ii,2);

    width = REF(ii,3)-xpos;
    rectangle('position',[xpos ypos width height], 'FaceColor',colors{REF(ii,1)+1}, 'EdgeColor',colors{REF(ii,1)+1});

end
ypos = 2.1;
%Middle or top of figure, depending on amount of input variables. Shows
%diarization result
for ii = 1:size(HYP,1)
    xpos = HYP(ii,2);

    width = HYP(ii,3)-xpos;
    rectangle('position',[xpos ypos width height], 'FaceColor',colors{HYP(ii,1)+1}, 'EdgeColor',colors{HYP(ii,1)+1});

end

%find unused colors
unused_colors = setdiff(1:nr_colors,speakers+1);
colors(unused_colors,:) = [];
for ii = 1:nr_speakers
    txt{ii} = sprintf('nr label: %i',speakers(ii));
    plot([NaN,NaN],'color',colors{ii});
end
legend(txt);
xlim([0 HYP(end,3)+10]);
ylim([0 5]);
if nargin > 2
    ylim([0 7]);
end
xlabel('tijd [s]');
title('Diarisatieresultaat voor en na herlabelen vs manuele annotatie');
hold off;
grid on;
grid minor;
end