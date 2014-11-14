% =========================================================================
% Centre National de la Recherche Scientifique (CNRS, France; www.cnrs.fr)
% Universit? d?Aix Marseille (AMU, France; www.univ-amu.fr)
% Author: Stephane Dufau, Laboratoire de psychologie cognitive, 
% stephane.dufau@univ-amu.fr
% Creation: November 2014
% 
% This software is governed by the CeCILL-B license under French law and
% abiding by the rules of distribution of free software. You can  use, 
% modify and/or redistribute the software under the terms of the CeCILL-B
% license as circulated by CEA, CNRS and INRIA at the following URL
% "http://www.cecill.info". The fact that you are presently reading this 
% means that you have had knowledge of the CeCILL-B license and that you 
% accept its terms. You can find a copy of this license in the file 
% "License_CeCILL-B_V1-en.txt".
% 
% Ce logiciel est r?gi par la licence CeCILL-B soumise au droit fran?ais et
% respectant les principes de diffusion des logiciels libres. Vous pouvez
% utiliser, modifier et/ou redistribuer ce programme sous les conditions
% de la licence CeCILL-B telle que diffus?e par le CEA, le CNRS et l'INRIA 
% sur le site "http://www.cecill.info". Le fait que vous puissiez acc?der ?
% cet en-t?te signifie que vous avez pris connaissance de la licence 
% CeCILL-B, et que vous en avez accept? les termes. Vous pouvez trouver une
% copie de la licence dans le fichier "Licence_CeCILL-B_V1-fr.txt".
% =========================================================================

%clear the workspace
clear all
close all
clc

%uncomment and play with DefaultCharacterSet to deal with non-ascii char
%old_DefaultCharacterSet = feature('DefaultCharacterSet', 'US-ASCII')

%% variables and constants
STIM = char(1:255); %stimulus list (individual letters and signs)
STIM = cellstr(STIM(:))
FONT = {'Inconsolata';'Courier New';'Arial';'Times New Roman';'Symbol';}; %font
IMAGE_SIZE = 200; %image size of STIM to be displayed in a figure
PAUSE_DURATION = 0.1; %duration of pause necessary for computing complexity


%% create the folder structure
status = [];
if ~(exist([pwd '/images/'], 'dir') == 7) %pwd: local directory
    status = mkdir('images'); %make images directory
end
for ind_font = 1:length(FONT)
    if ~(exist([pwd '/images/' FONT{ind_font}], 'dir') == 7)
        status = [status mkdir([pwd '/images/' FONT{ind_font}])]; %make font subdirectory + append status of creation
        status = [status mkdir([pwd '/images/' FONT{ind_font} '/original/'])]; %make original subdirectory
        status = [status mkdir([pwd '/images/' FONT{ind_font} '/perimeter/'])]; %make perimeter subdirectory
    end
end
if sum(status == 0) >= 1
    error('Check folder stucture: folders not fully created');
end


%% compute adequate font sizes from 'W'

SZ_FONT = 96; %initial guess

ind_font = 1;
h_fig = figure('Position',[10 10 IMAGE_SIZE IMAGE_SIZE],'MenuBar','none','Resize','off');
axes('Position',[0 0 1 1],'Color','w','Xtick',[],'Ytick',[],'XColor','w','YColor','w');
h_text = text(0.5,0.5,'W');
set(h_text,'HorizontalAlignment','center','VerticalAlignment','middle',...
    'FontSize',SZ_FONT(1),'FontName',FONT{ind_font});


pause(PAUSE_duration);
F = getframe(h_ax);
Fprint = F.cdata;
Fprint = Fprint(:,:,3);

[L,C] = find(Fprint<255);
Height_a = max(L) - min(L);

cpt = 2;
for ind_font = 2:length(FONT)
    
    start_sz = 75;
    Height_tmp = Height_a - 10;
    
    while Height_tmp < Height_a
        
        h_fig = figure('Position',[10 10 SZ_IMAGE SZ_IMAGE],'MenuBar','none','Resize','off');
        axes('Position',[0 0 1 1],'Color','w','Xtick',[],'Ytick',[],'XColor','w','YColor','w');
        h_text = text(0.5,0.5,'a');
        set(h_text,'HorizontalAlignment','center','VerticalAlignment','middle',...
            'FontSize',start_sz,'FontName',FONT{ind_font});
        
        pause(PAUSE_duration);
        F = getframe(h_ax);
        Fprint = F.cdata;
        Fprint = Fprint(:,:,3);
        
        [L,C] = find(Fprint<255);
        Height_tmp = max(L) - min(L);
        
        start_sz = start_sz + 1;
        
    end
    
    SZ_FONT(cpt) = start_sz;
    cpt = cpt + 1;
    
end

%% creation of images
for ind_font = 1:length(FONT)
    for ind_stim = 1:length(STIM)
                
        %read image
        filename = [dir_read num2str(ind_stim) '.bmp'];
    end
end


fds
%% COMPLEXITY COMPUTATION
for ind_font = 1:length(FONT)
    
    fid = fopen([FONT{ind_font} '.complexity.txt'],'wt+');
    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\n','FONT','SIGN','IMAGE#','PERIMETER','AREA','COMPLEXITY');
    
    dir_read = ['images/' FONT{ind_font} '/original/'];
    dir_write = ['images/' FONT{ind_font} '/perimeter/'];
    
    for ind_stim = 1:length(STIM)
                
        %read image
        filename = [dir_read num2str(ind_stim) '.bmp'];
        IM = imread(filename);
        IM = uint8(IM<255); %transformation en logicals (1 represente l'info presente = pixel activ?)
        
        
        if nnz(IM) == 0
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\n',...
                FONT{ind_font},'NO_SIGN',num2str(ind_stim),'-1','-1','-1');
            continue;
        end
        
        %%%% boundaries method
        [B,L] = bwboundaries(IM);
        
        %write boundary image
        h_fig = figure('Position',[200 200 SZ_IMAGE SZ_IMAGE],'MenuBar','none','Resize','off');
        h_ax = axes('Position',[0 0 1 1],'Color','w');
        for k = 1:length(B)
            boundary = B{k};
            plot(boundary(:,2), -boundary(:,1), 'k', 'LineWidth', 2);hold on;
        end
        set(gca,'Xtick',[],'Ytick',[],'XColor','w','YColor','w','XLim',[1 SZ_IMAGE],'YLim',[-SZ_IMAGE -1]);
                
        filename = [dir_write num2str(ind_stim) '.bmp'];
        
        pause(PAUSE_duration);
        F = getframe(h_ax);
        Fprint = F.cdata;
        Fprint = Fprint(:,:,3);
        
        imwrite(Fprint, filename);

        close(h_fig);
        
        
        % loop over the boundaries
        perimeter = 0;
        for k = 1:length(B)
            
            % obtain (X,Y) boundary coordinates corresponding to label 'k'
            boundary = B{k};
            
            % compute a simple estimate of the object's perimeter
            delta_sq = diff(boundary).^2;
            perimeter = perimeter + sum(sqrt(sum(delta_sq,2)));
            
        end
        perimeter;
        
        
        
        
        fprintf(fid,'%s\t%s\t%s\t%f\t%f\t%f\n',...
            FONT{ind_font},...
            char(STIM(ind_stim)),...
            num2str(ind_stim),...
            perimeter,...
            nnz(IM),...
            (perimeter * perimeter)/nnz(IM));
        
    end
    
    fclose(fid);
    hgf
end
    

