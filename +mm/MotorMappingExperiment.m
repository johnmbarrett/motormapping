classdef MotorMappingExperiment
    properties
        % TODO : might need to make these dependent as well because the
        % factory method puts them into an invalid state
        Results
        Alignments
    end
    
    properties(Access=protected)
        ResultAlignmentMap_
    end
    
    properties(Dependent=true)
        ResultAlignmentMap
    end
    
    methods
        function map = get.ResultAlignmentMap(self)
            map = self.ResultAlignmentMap_;
        end
        
        % TODO : these two setters will put ResultAlignmentMap_ into an
        % invalid state
        function self = set.Results(self, results)
            assert(isa(results,'mm.MotorMappingResult'),'MotorMapping:MotorMappingExperiment:NotAResult','Results must be an array of MotorMappingResults.');
            self.Results = results;
        end
        
        function self = set.Alignments(self, alignments)
            assert(isa(alignments,'mm.LaserAlignment'),'MotorMapping:MotorMappingExperiment:NotAnAlignmnet','Alignments must be an array of LaserAlignments.');
            self.Alignments = alignments;
        end
        
        function self = set.ResultAlignmentMap(self, map)
            assert(isequal(size(map),[numel(self.Results) 2]),'MotorMapping:MotorMappingExperiment:BadMapSize','ResultAlignmentMap must be a two-column array with one row for each Result.');
            assert(all(map(:,1) >= 1 & map(:,1) <= numel(self.Results)),'MotorMapping:MotorMappingExperiment:BadMap','Each entry in first column of ResultAlignmentMap must be between 1 and numel(Results)');
            assert(all(map(:,2) >= 1 & map(:,2) <= numel(self.Alignments)),'MotorMapping:MotorMappingExperiment:BadMap','Each entry in second column of ResultAlignmentMap must be between 1 and numel(Alignments)');
            
            self.ResultAlignmentMap_ = map;
            
            % TODO : test this, it probably won't work
            for ii = 1:numel(self.Results)
                self.Results(map(ii,1)).AlignmentInfo = self.Alignments(map(ii,2));
            end
        end
    end
    
    methods(Static=true)
        function mme = fromNotesFile(notesFile,varargin)
            topFolder = pwd;
            
            experimentTable = readtable(notesFile,'Delimiter','\t');
            
            % TODO : what if missing?
            [setups,setupIndices] = unique([experimentTable.Setup]);
            
            alignments(numel(setups)) = mm.LaserAlignment;
            
            for ii = 1:numel(setups)
                setupFolder = sprintf('setup %d',ii);
                
                params = experimentTable(setupIndices(ii),:);
                
                map = str2double(strsplit(params.Map{1},'x'));
                rows = map(1);
                cols = map(2);
                
                angle = params.Angle;
                vScale = params.VScale;
                xOffset = params.XOff;
                yOffset = params.YOff;
                
                if ~exist(setupFolder,'dir');
                    warning('Missing data for setup %d, using empty LaserAlignment\n',ii);
                    alignments(ii) = LaserAlignment(rows,cols,angle,vScale,xOffset,yOffset);
                    continue
                end
                
                setupFile = sprintf('%s\\%s\\%s_laser_grid.mat',topFolder,setupFolder,setupFolder);
                
                if exist(setupFile,'file')
                    alignments(ii) = mm.LaserAlignment.fromMATFile(setupFile,angle,vScale,xOffset,yOffset);
                else
                    % TODO : always 2?
                    alignments(ii) = mm.LaserAlignment.fromLaserImages(rows,cols,[topFolder '\' setupFolder],NaN,angle,vScale,xOffset,yOffset,varargin{:});
                end
                
                cd(topFolder);
            end
            
            results = cell(size(experimentTable,1),1);
            setupIndex = cell(size(experimentTable,1),1);
            
            masks = cell(1,0);
            
            for ii = 1:size(experimentTable,1)
                stimFolder = sprintf('%s\\stim %d',topFolder,ii);
                
                if ~exist(stimFolder,'dir')
                    warning('Missing data for stim %d, using empty MotorMappingResult\n',ii);
                    continue
                end
                
                files = dir([stimFolder '\*']);
                
                names = {files.name};
                isDir = [files.isdir];
                
                locationFile = files(strncmpi('L',names,1) & ~isDir);
                
                if isempty(locationFile)
                    warning('Missing location file for stim %d, using empty MotorMapping Result\n',ii);
                    continue
                end
                
                parameterFile = files(strncmpi('P',names,1));
                
                if isempty(parameterFile)
                    warning('Missing parameter file for stim %d, using empty MotorMapping Result\n',ii);
                    continue
                end
                
                dirs = files(isDir & ~strncmpi('.',names,1));
                
                if numel(dirs) > numel(masks)
                    masks(end+(1:(numel(dirs)-numel(masks)))) = {[]};
                end
                
                for jj = 1:numel(dirs)
                    switch dirs(jj).name
                        % TODO : not this
                        case 'front'
                            bodyParts = {'right forepaw' 'left forepaw'};
                        case 'left'
                            bodyParts = {'left forepaw' 'left hindpaw'};
                        otherwise
                            warning('Unknown view for stim %d folder %d, using empty MotorMappingResult\n',ii,jj);
                            continue
                    end
                    
                    imageStackFolder = [stimFolder '\' dirs(jj).name '\'];
                    resultFile = sprintf('%s\\%s_motion_tracking.mat',imageStackFolder,dirs(jj).name);
                    
                    if exist(resultFile,'file')
                        mmr = mm.MotorMappingResult.fromMATFile(resultFile);
                    else
                        videoFiles = dir([imageStackFolder 'VT*.mat']);
                        
                        if isempty(videoFiles)
                            if isempty(masks{jj})
                                bmps = dir([imageStackFolder '*.bmp']);

                                I = imread([imageStackFolder bmps(2).name ]);

                                figure;

                                imshow(I);
                                
                                title('Draw LED location');

                                roi = imfreehand;

                                masks{jj} = createMask(roi); % TODO : what if the LED moved?

                                close(gcf);
                            end

                            % TODO : factory method?
                            splitBMPsIntoTrialsAndDerandomise(imageStackFolder,masks{jj},[stimFolder '\' parameterFile.name],[stimFolder '\' locationFile.name]);

                            videoFiles = dir([imageStackFolder 'VT*.mat']);
                            
                            videoFileNames = {videoFiles.name};
                        else
                            videoFileNames = arrayfun(@(s) sprintf('%s%s',imageStackFolder,s.name),videoFiles,'UniformOutput',false);
                        end

                        mmr = mm.MotorMappingResult.fromVideoFiles(videoFileNames,'SaveFilePrefix',[imageStackFolder dirs(jj).name]);
                    end
                    
                    mmr.BodyParts = bodyParts;
                    
                    results{ii}(jj,1) = mmr;
                    setupIndex{ii}(jj,1) = experimentTable.Setup(ii);
                end
            end
                
            results = vertcat(results{~cellfun(@isempty,results)});
            setupIndex = vertcat(setupIndex{~cellfun(@isempty,setupIndex)});

            % TODO : constructor?
            mme = mm.MotorMappingExperiment;
            mme.Results = results;
            mme.Alignments = alignments;
            mme.ResultAlignmentMap = [(1:numel(results))' setupIndex];
        end
    end
end