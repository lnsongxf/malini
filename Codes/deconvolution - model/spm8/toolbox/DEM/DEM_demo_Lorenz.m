% Demo for a Lorentz attractor: In this example we show that DEM and
% Bayesian filtering can estimate the hidden states of an autonomous system
% showing deterministic chaos.  Although all schemes perform well given the
% correct starting values of the hidden states; DEM is the only scheme that
% can re-capture the true trajectory without them.  this is because DEM 
% represents generalised coordinates, in which the dynamics unfold.

 
% non-hierarchical non-linear generative model (dynamic & chaotic)
%==========================================================================
Fgraph    = spm_figure('GetWin','Graphics');
clear M

% get model
%--------------------------------------------------------------------------
M       = spm_DEM_M('Lorenz');
 
% level 1 precisions
%--------------------------------------------------------------------------
M(1).V  = exp(0);
M(1).W  = exp(16);
 
% level 2 precisions
%--------------------------------------------------------------------------
M(2).v  = 0;
M(2).V  = exp(16);
 
% create data
%==========================================================================
 
% create innovations & add causes
%--------------------------------------------------------------------------
N       = 64;
U       = sparse(1,N);
DEM     = spm_DEM_generate(M,U);
spm_DEM_qU(DEM.pU)
 
 
% DEM estimation
%==========================================================================
DEM.M(1).x = [1; 1; 16];
DEM        = spm_DEM(DEM);
 
% Bayesian filtering
%--------------------------------------------------------------------------
ex     = spm_ekf(DEM.M,DEM.Y);
px     = spm_pf(DEM.M,DEM.Y);
 
% graphics
%--------------------------------------------------------------------------
figure(Fgraph)
T      = [1:N];
 
subplot(2,2,1)
plot(T,DEM.pU.v{1},'k',T,DEM.qU.v{1},'k:')
legend({'DEM','true'})
title('true and predicted response')
xlabel('time')
axis square
 
subplot(2,2,2)
plot(T,DEM.pU.x{1},'k',T,DEM.qU.x{1},'k:')
title('true and predicted states')
xlabel('time')
axis square
 
subplot(2,2,3)
plot(T,sum(px),'k',T,sum(ex),'k:')
legend({'PF','EKF'})
title('predicted responses')
xlabel('time')
axis square
 
subplot(2,2,4)
plot(T,px,'k',T,ex,'k:')
title('predicted states')
xlabel('time')
axis square


return
 
% Repeat with random initial conditions
%==========================================================================
f  = spm_figure;
figure(f)
clf
 
% attractor
%--------------------------------------------------------------------------
tx    = DEM.pU.x{1};
subplot(2,2,1)
plot(tx(1,:),tx(2,:),'k'), hold on
plot(tx(1,1),tx(2,1),'k.','Markersize',16)
title('attractor')
axis square
axis([-20 20 -20 20])
 
% reconstructions
%--------------------------------------------------------------------------
for i = 1:4
 
    x          = rand(3,1)*16;
    DEM.M(1).x = x;
    DEM        = spm_DEM(DEM);
    dx         = DEM.qU.x{1};
    ex         = spm_ekf(DEM.M,DEM.Y);
    px         = spm_pf(DEM.M,DEM.Y);
    dx         = [x dx];
    ex         = [x ex];
    px         = [x px];
 
    figure(f)
    subplot(2,2,2)
    plot(dx(1,:),dx(2,:),'k','color',[0 0 0] + 2/6), hold on
    plot(dx(1,1),dx(2,1),'k.','Markersize',16,'color',[0 0 0] + 2/6)
    title('attractor reconstructions (DEM)')
    axis square
    axis([-20 20 -20 20])
    
    subplot(2,2,3)
    plot(px(1,:),px(2,:),'k','color',[0 0 0] + 2/6), hold on
    plot(px(1,1),px(2,1),'k.','Markersize',16,'color',[0 0 0] + 2/6)
    title('attractor reconstructions (PF)')
    axis square
    axis([-20 20 -20 20])
    
    subplot(2,2,4)
    plot(ex(1,:),ex(2,:),'k','color',[0 0 0] + 2/6), hold on
    plot(ex(1,1),ex(2,1),'k.','Markersize',16,'color',[0 0 0] + 2/6)
    title('attractor reconstructions (EKF)')
    axis square
    axis([-20 20 -20 20])
    
    drawnow
 
end
