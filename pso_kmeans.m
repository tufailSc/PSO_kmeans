function [ overall_c, swarm_overall_pose ] = pso_kmeans( userData, s, k )
% 輸入： 用戶評分矩陣 userData(m, n)，聚類個數 s，粒子數目 k
% 輸出： s 個聚類及其中心

% INIT PARTICLE SWARM
centroids = s;          % == clusters here (aka centroids)
dimensions = size(userData, 2);         % how many dimensions in each centroid
particles = k;         % how many particles in the swarm, aka how many solutions
iterations = 50;        % iterations of the optimization alg.
simtime=0.01;           % simulation delay btw each iteration
write_video = false;    % enable to grab the output picture and save a video
hybrid_pso = false;     % enable/disable hybrid_pso
manual_init = false;    % enable/disable manual initialization (only for dimensions={2,3})
plot_figure = false;     % enable/disable plot

% VIDEO GRUB STUFF...
if write_video
    writerObj = VideoWriter('PSO.avi');
    writerObj.Quality=100;
    %     writerObj.FrameRate=30;
    open(writerObj);
end

% LOAD DEFAULT CLUSTER (IRIS DATASET); USE WITH CARE!


%取第3,4欄
dataset_size = size(userData);

% EXECUTE K-MEANS
% 用kmeans計算分群中心
if hybrid_pso
    fprintf('Running Matlab K-Means Version\n');
    [idx,KMEANS_CENTROIDS] = kmeans(userData,centroids, 'dist','sqEuclidean', 'display','iter','start','uniform','onlinephase','off');
    fprintf('\n');
end

% GLOBAL PARAMETERS (the paper reports this values 0.72;1.49;1.49)
w  = 0.72; %INERTIA
c1 = 1.49; %COGNITIVE
c2 = 1.49; %SOCIAL

if plot_figure
    % ------畫圖------
    % PLOT STUFF... HANDLERS AND COLORS
    pc = []; txt = [];
    cluster_colors_vector = rand(particles, 3);
    
    % PLOT DATASET
    fh=figure(1);
    hold on;
    if dimensions == 3
        plot3(userData(:,1),userData(:,2),userData(:,3),'k*');
        view(3);
    elseif dimensions == 2
        plot(userData(:,1),userData(:,2),'k*');
    end
    
    % PLOT STUFF .. SETTING UP AXIS IN THE FIGURE
    axis equal;
    axis(reshape([min(userData)-2; max(userData)+2],1,[]));
    hold off;
    % ----------------
end

% SETTING UP PSO DATA STRUCTURES
% 初始化粒子的vel pos 群pos
swarm_vel = rand(centroids,dimensions,particles)*0.1;
swarm_pos = rand(centroids,dimensions,particles);
swarm_best = zeros(centroids,dimensions);
c = zeros(dataset_size(1),particles);

ranges = max(userData)-min(userData); %%scale
swarm_pos = swarm_pos .* repmat(ranges,[centroids,1,particles]) + repmat(min(userData),[centroids,1,particles]);
swarm_fitness(1:particles)=Inf;

% KMEANS_INIT
if hybrid_pso
    swarm_pos(:,:,1) = KMEANS_CENTROIDS;
end

% MANUAL INITIALIZATION (only for dimension 2 and 3)
if manual_init
    if dimensions == 3
        % MANUAL INIT ONLY FOR THE FIRST PARTICLE
        swarm_pos(:,:,1) = [6 3 4; 5 3 1];
    elseif dimensions == 2
        % KEYBOARD INIT ONLY FOR THE FIRST PARTICLE
        swarm_pos(:,:,1) = ginput(2);
    end
end

for iteration=1:iterations
    
    %CALCULATE EUCLIDEAN DISTANCES TO ALL CENTROIDS
    distances=zeros(dataset_size(1),centroids,particles);
    for particle=1:particles
        for centroid=1:centroids
            distance=zeros(dataset_size(1),1);
            for data_vector=1:dataset_size(1)
                %meas(data_vector,:)
                distance(data_vector,1)=norm(swarm_pos(centroid,:,particle)-userData(data_vector,:));
            end
            distances(:,centroid,particle)=distance;
        end
    end
    
    %ASSIGN MEASURES with CLUSTERS
    for particle=1:particles
        [value, index] = min(distances(:,:,particle),[],2);
        c(:,particle) = index;
    end
    
    if plot_figure
        % PLOT STUFF... CLEAR HANDLERS
        delete(pc); delete(txt);
        pc = []; txt = [];
        
        % PLOT STUFF...
        hold on;
        for particle=1:particles
            for centroid=1:centroids
                if any(c(:,particle) == centroid)
                    if dimensions == 3
                        pc = [pc plot3(swarm_pos(centroid,1,particle),swarm_pos(centroid,2,particle),swarm_pos(centroid,3,particle),'*','color',cluster_colors_vector(particle,:))];
                    elseif dimensions == 2
                        pc = [pc plot(swarm_pos(centroid,1,particle),swarm_pos(centroid,2,particle),'*','color',cluster_colors_vector(particle,:))];
                    end
                end
            end
        end
        set(pc,{'MarkerSize'},{12})
        hold off;
    end
    
    %CALCULATE GLOBAL FITNESS and LOCAL FITNESS:=swarm_fitness
    average_fitness = zeros(particles,1);
    for particle=1:particles
        for centroid = 1 : centroids
            if any(c(:,particle) == centroid)
                local_fitness=mean(distances(c(:,particle)==centroid,centroid,particle));
                average_fitness(particle,1) = average_fitness(particle,1) + local_fitness;
            end
        end
        average_fitness(particle,1) = average_fitness(particle,1) / centroids;
        if (average_fitness(particle,1) < swarm_fitness(particle))
            swarm_fitness(particle) = average_fitness(particle,1);
            swarm_best(:,:,particle) = swarm_pos(:,:,particle);     %LOCAL BEST FITNESS
        end
    end
    [global_fitness, index] = min(swarm_fitness);       %GLOBAL BEST FITNESS
    swarm_overall_pose = swarm_pos(:,:,index);          %GLOBAL BEST POSITION
    overall_c = c(:,index);
    
    % SOME INFO ON THE COMMAND WINDOW
    fprintf('%3d. global fitness is %5.4f\n',iteration,global_fitness);
    %uicontrol('Style','text','Position',[40 20 180 20],'String',sprintf('Actual fitness is: %5.4f', global_fitness),'BackgroundColor',get(gcf,'Color'));
    pause(simtime);
    
    % VIDEO GRUB STUFF...
    if write_video
        frame = getframe(fh);
        writeVideo(writerObj,frame);
    end
    
    % SAMPLE r1 AND r2 FROM UNIFORM DISTRIBUTION [0..1]
    r1 = rand;
    r2 = rand;
    
    % UPDATE CLUSTER CENTROIDS
    for particle=1:particles
        inertia = w * swarm_vel(:,:,particle);
        cognitive = c1 * r1 * (swarm_best(:,:,particle)-swarm_pos(:,:,particle));
        social = c2 * r2 * (swarm_overall_pose-swarm_pos(:,:,particle));
        vel = inertia+cognitive+social;
        
        swarm_pos(:,:,particle) = swarm_pos(:,:,particle) + vel ;   % UPDATE PARTICLE POSE
        swarm_vel(:,:,particle) = vel;                              % UPDATE PARTICLE VEL
    end
    
    
    % run one k-Means iteration
    for particle=1:particles
        for centroid=1:centroids
            distance=zeros(dataset_size(1),1);
            for data_vector=1:dataset_size(1)
                %meas(data_vector,:)
                distance(data_vector,1)=norm(swarm_pos(centroid,:,particle)-userData(data_vector,:));
            end
            distances(:,centroid,particle)=distance;
        end
        
        % reassign data to clusters and positions are updated
        [value, distIndex] = min(distances(:,:,particle),[],2);
        c(:,particle) = distIndex;
        
        % recalculated cluster centroids
        for centroid = 1 : centroids
            if any(c(:,particle) == centroid)
                swarm_pos(centroid,:,particle) = mean(userData(c(:,particle)==centroid,:));
            end
        end   
        
    end
    
end

if plot_figure
    % PLOT THE ASSOCIATIONS WITH RESPECT TO THE CLUSTER
    hold on;
    particle=index; %select the best particle (with best fitness)
    cluster_colors = ['m','g','y','b','r','c','g'];
    for centroid=1:centroids
        if any(c(:,particle) == centroid)
            if dimensions == 3
                plot3(userData(c(:,particle)==centroid,1),userData(c(:,particle)==centroid,2),userData(c(:,particle)==centroid,3),'o','color',cluster_colors(centroid));
            elseif dimensions == 2
                plot(userData(c(:,particle)==centroid,1),userData(c(:,particle)==centroid,2),'o','color',cluster_colors(centroid));
            end
        end
    end
    hold off;
end

% VIDEO GRUB STUFF...
if write_video
    frame = getframe(fh);
    writeVideo(writerObj,frame);
    close(writerObj);
end

% SAY GOODBYE
fprintf('\nEnd, global fitness is %5.4f\n',global_fitness);
end

