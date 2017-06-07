classdef MotorMappingResult < handle % MATLAB you are so dumb
    properties(Access=public)
        AlignmentInfo
    end
    
    properties(Access=public,Dependent=true)
        BodyParts
        Map % TODO : should this be a stored property?  it can be calculated from Trajectories, also you can imagine many different maps of different movement parameters.  then again, there's an argument to be made for at least caching it for speed
        MotionTubes
        PathLengths % TODO : again, this can be computed from Trajectories
        ROIs
        Trajectories
    end
    
    properties(Access=protected)
        BodyParts_
    end
    
    methods(Abstract=true,Access=protected) % MATLAB why
        map = getMap(self);
        setMap(self,map);
        
        mt = getMotionTubes(self);
        setMotionTubes(self,mt);
        
        pl = getPathLengths(self);
        setPathLengths(self,pl);
        
        rois = getROIs(self);
        setROIs(self,rois);
        
        trajectories = getTrajectories(self);
        setTrajectories(self,trajectories);
    end
    
    methods
        function self = MotorMappingResult(map,motionTubes,pathLengths,roiPositions,trajectories)
            if nargin == 0
                return
            end
            
            self.Map = map;
            self.MotionTubes = motionTubes;
            self.PathLengths = pathLengths;
            self.ROIs = roiPositions;
            self.Trajectories = trajectories;
            self.AlignmentInfo = NaN;
        end
        
        function la = get.AlignmentInfo(self)
            la = self.AlignmentInfo;
        end
        
        function set.AlignmentInfo(self,la)
            assert(isa(la,'mm.LaserAlignment') || (isnumeric(la) && isscalar(la) && isnan(la)),'MotorMapping:MotorMappingResult:IllegalLaserAlignment','Alignment info must be of class mm.LaserAlignment or a scalar NaN');
            self.AlignmentInfo = la;
        end
        
        function bodyParts = get.BodyParts(self)
            bodyParts = self.BodyParts_;
        end
        
        function set.BodyParts(self,bodyParts)
            assert(iscellstr(bodyParts) && numel(bodyParts) == size(self.Map,2),'MotorMapping:MotorMappingResult:InvalidBodyParts','BodyParts must be a cell array of strings of length equal to the number of columns in Map');
            
            self.BodyParts_ = bodyParts;
        end
        
        % fuckingh let me make these abstract you fucking fuck matlabn
        function map = get.Map(self)
            map = self.getMap();
        end
        
        function set.Map(self,map)
            self.setMap(map);
        end
        
        function mt = get.MotionTubes(self)
            mt = self.getMotionTubes();
        end
        
        function set.MotionTubes(self,mt)
            self.setMotionTubes(mt);
        end
        
        function pl = get.PathLengths(self)
            pl = self.getPathLengths();
        end
        
        function set.PathLengths(self,pl)
            self.setPathLengths(pl);
        end
        
        function rois = get.ROIs(self)
            rois = self.getROIs();
        end
        
        function set.ROIs(self,rois)
            self.setROIs(rois);
        end
        
        function trajectories = get.Trajectories(self)
            trajectories = self.getTrajectories();
        end
        
        function set.Trajectories(self,trajectories)
            self.setTrajectories(trajectories);
        end
        
        [figs,tf,warpedMaps,refs] = alignHeatmapToBrainImage(map,brainImage,gridParams)
        
        makeTrialVideo(self,locationIndex,bodyPartIndex,trialIndex,varargin)
        
        hs = plot(self,useRealCoords,bregmaCoordsPX)
        
        h = plotMotionTube(self,locationIndex,bodyPartIndex,trialIndex)
        
        hs = plotSkew(self,bregmaCoordsPx); % TODO : better name
        
        hs = plotTrajectories(self,l,varargin)
    end
    
    methods(Static=true)
        function mmr = fromMATFile(matFile) % TODO : a superclass that knows about its subclasses?  is that allowed?  maybe a factory class would be better
            mmr = mm.MATFileMotorMappingResult(matFile);
        end
        
        function mmr = fromVideoFiles(videoFiles) % TODO : other parameters
            bmm = mm.BasicMotorMapper;
            
            [map,trajectories,pathLengths,motionTubes,roiPositions] = bmm.mapMotion(videoFiles);
            
            mmr = mm.MotorMappingResult(map,motionTubes,pathLengths,roiPositions,trajectories);
        end
    end
end
