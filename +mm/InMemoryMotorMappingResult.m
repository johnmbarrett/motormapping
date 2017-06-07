classdef InMemoryMotorMappingResult < mm.MotorMappingResult
    properties(Access=protected)
        FileName
        Map_
        MotionTubes_
        PathLengths_
        ROIs_
        Trajectories_
    end
    
    methods(Access=protected)
        function map = getMap(self)
            map = self.Map_;
        end
        
        function setMap(self,map)
            self.Map_ = map;
        end
        
        function mt = getMotionTubes(self)
            mt = self.MotionTubes_;
        end
        
        function setMotionTubes(self,motionTubes)
            self.MotionTubes_ = motionTubes;
        end
        
        function pl = getPathLengths(self)
            pl = self.PathLengths_;
        end
       
        function setPathLengths(self,pathLengths)
            self.PathLengths_ = pathLengths;
        end
        
        function rois = getROIs(self)
            rois = self.ROIs_;
        end
        
        function setROIs(self,roiPositions)
            self.ROIs_ = roiPositions;
        end
        
        function trajectories = getTrajectories(self)
            trajectories = self.Trajectories_;
        end
        
        function setTrajectories(self,trajectories)
            self.Trajectories_ = trajectories;
        end
    end
end