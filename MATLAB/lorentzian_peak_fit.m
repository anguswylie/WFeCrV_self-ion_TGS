function [peak,peak_err,fwhm,tau,f0,SNR_fft]=lorentzian_peak_fit(fft,two_mode,plotty)
% function [peak,peak_err,tau]=lorentzian_peak_fit(fft,two_mode,plotty)

percent_peak_fit=1;

if nargin<2
    two_mode=0;
end

if nargin<3
    plotty=0;
end

st_point=1; %set to cut off DC spike in fft, if necessary
end_point=160000; %set to cut off DC spike in fft, if necessary

fft(:,1)=fft(:,1)/10^9; %put everything in units of GHz so fit is not crazy
fft(1:st_point,2)=0;
fft(end_point:end,2)=0;


[max_val,peak_ind]=max(fft(st_point:end,2));
peak_loc=fft(peak_ind,1);

if two_mode
    st_two_mode=round(0.1*peak_ind);
    end_two_mode=round(0.75*peak_ind);
end

%normalize the fft so the scale isn't absurd
fft(:,2)=fft(:,2)/max_val;

if percent_peak_fit~=1
    neg_go=1;
    neg_ind=peak_ind;
    while neg_go
        if fft(neg_ind,2)<=percent_peak_fit
            neg_ind_final=neg_ind;
            neg_go=0;
        else
            neg_ind=neg_ind-1;
        end
    end
    
    pos_go=1;
    pos_ind=peak_ind;
    while pos_go
        if fft(pos_ind,2)<=percent_peak_fit
            pos_ind_final=pos_ind;
            pos_go=0;
        else
            pos_ind=pos_ind+1;
        end
    end
else
    neg_ind_final=st_point;
    pos_ind_final=length(fft(:,1));
end

ST=[1e-4 peak_loc .01 0];
LB=[0 0 0.001 0];
UB=[1 1.2 0.1 1];

OPS=fitoptions('Method','NonLinearLeastSquares','Lower',LB,'Upper',UB,'Start',ST);
TYPE=fittype('(A./((x-x0)^2+(W)^2))+C','options',OPS,'coefficients',{'A','x0','W','C'});

[f0,~]=fit(fft(neg_ind_final:pos_ind_final,1),fft(neg_ind_final:pos_ind_final,2),TYPE);
error=confint(f0,0.95); %this is the 2 sigma error

peak=f0.x0*10^9; %so answers is in Hz
peak_err=((f0.x0-error(1,2))*10^9)/2; % so answer 1 sigma in Hz
fwhm=2*f0.W*10^9; %so answer is in Hz
tau=1/(pi*fwhm); %so answer is in sec

if two_mode
    new_fft_amp=fft(:,2)-f0(fft(:,1));
%     [~,peak_ind_2]=max(new_fft_amp(st_point:end));
    [~,peak_ind_2]=max(new_fft_amp(st_two_mode:end_two_mode));
    peak_loc_2=fft(peak_ind_2,1);
    
    ST1=[1e-4 peak_loc_2 .01 0];
    OPS1=fitoptions('Method','NonLinearLeastSquares','Lower',LB,'Upper',UB,'Start',ST1);
    TYPE1=fittype('(A./((x-x0)^2+(W)^2))+C','options',OPS1,'coefficients',{'A','x0','W','C'});
    
    [f1,~]=fit(fft(:,1),new_fft_amp,TYPE1);
    error2=confint(f1,0.95);
    
    peak2=f1.x0*10^9; %so answers is in Hz
    peak_err2=((f1.x0-error2(1,2))*10^9)/2; % so answer 1 sigma in Hz
    fwhm2=2*f1.W*10^9; %so answer is in Hz
    tau2=1/(pi*fwhm2); %so answer is in sec
    
    peak=[peak peak2];
    peak_err=[peak_err peak_err2];
    fwhm=[fwhm fwhm2];
    tau=[tau tau2];
end

fft_noise = [fft(:,1) fft(:,2)-f0(fft(:,1))];
SNR_fft = snr(fft(:,2),fft_noise(:,2));


if plotty
    figure()
    axes('Position',[0 0 1 1],'xtick',[],'ytick',[],'box','on','handlevisibility','off','LineWidth',5)
    plot(fft(:,1),fft(:,2),'k-','LineWidth',3)%'DisplayName','Raw FFT Data');
    hold on
%     plot(fft(:,1),new_fft_amp,'k-','LineWidth',3)%'DisplayName','Raw FFT Data');
%     hold on
    hold on
%     plot(fft_noise(:,1),fft_noise(:,2),'c','LineWidth',3,'DisplayName','Noise');
%     hold on
    plot(fft(:,1),f0(fft(:,1)),'r--','LineWidth',3,'DisplayName','First SAW Frequency Fit');
    hold on
    if two_mode
        plot(fft(:,1),f1(fft(:,1)),'b--','LineWidth',3,'DisplayName','Second SAW Frequency Fit');
        hold on
        plot([fft(st_two_mode,1) fft(st_two_mode,1)],[-0.005 max_val+0.005],'g--','LineWidth',3)
        hold on
        plot([fft(end_two_mode,1) fft(end_two_mode,1)],[-0.005 max_val+0.005],'g--','LineWidth',3)
        hold on
    end
    set(gcf,'Position',[0 0 800 500])
    xlim([0 1.0])
    ylim([0 1.0])
    set(gca,...
        'FontUnits','points',...
        'FontWeight','normal',...
        'FontSize',24,...
        'FontName','Helvetica',...
        'LineWidth',3)
    ylabel({'Intensity [a.u.]'},...
        'FontUnits','points',...
        'FontSize',24,...
        'FontName','Helvetica')
    xlabel({'Frequency [GHz]'},...
        'FontUnits','points',...
        'FontSize',24,...
        'FontName','Helvetica')
    legend('Location','northwest')
    saveas(gcf,"TGS_FFT.png")
end

end

