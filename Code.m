%% ============================================================
% RSMA-Enabled RIS-Assisted ISAC for 6G Networks
% Advanced Compact MATLAB Simulation
% ============================================================

clear; clc; close all;
rng(20);

%% ---------------- SYSTEM PARAMETERS ----------------
Nt = 4;                     % BS antennas
K = 2;                      % Users
N = 32;                     % RIS elements
SNRdB = 0:5:30;
SNR = 10.^(SNRdB/10);

MC = 150;                   % Monte-Carlo realizations
BW = 20e6;                  % Bandwidth
fc = 28e9;                  % Carrier frequency
c = 3e8;

Pc = 0.30;                  % Common stream power
Pp = (1-Pc)/K;              % Private stream power

%% ---------------- RESULT ARRAYS ----------------
Rate_RSMA = zeros(size(SNRdB));
Rate_NoRIS = zeros(size(SNRdB));
Rate_Conv = zeros(size(SNRdB));

BER = zeros(size(SNRdB));
SenseSINR = zeros(size(SNRdB));
RangeError = zeros(size(SNRdB));
EnergyEff = zeros(size(SNRdB));

%% ============================================================
% MAIN SIMULATION
% ============================================================

for s = 1:length(SNRdB)

    noise = 1/SNR(s);

    rate1 = 0;
    rate2 = 0;
    rate3 = 0;

    err = 0;
    bitsTotal = 0;

    ss = 0;
    re = 0;

    for mc = 1:MC

        %% ---------------- CHANNEL GENERATION ----------------

        % Rician BS-RIS channel
        Krician = 5;

        Hbr_LOS = ones(N,Nt);
        Hbr_NLOS = (randn(N,Nt)+1i*randn(N,Nt))/sqrt(2);

        Hbr = sqrt(Krician/(Krician+1))*Hbr_LOS + ...
              sqrt(1/(Krician+1))*Hbr_NLOS;

        % RIS-user channels
        Hru = (randn(K,N)+1i*randn(K,N))/sqrt(2);

        % Direct BS-user channel
        Hbu = (randn(K,Nt)+1i*randn(K,Nt))/sqrt(2);

        %% ---------------- RIS PHASE OPTIMIZATION ----------------

        % Align RIS phases toward User-1 and User-2
        theta = zeros(N,1);

        for n = 1:N

            h1 = Hru(1,n);
            h2 = Hru(2,n);

            phase1 = angle(h1);
            phase2 = angle(h2);

            theta(n) = -(phase1 + phase2)/2;

        end

        Phi = diag(exp(1i*theta));

        %% ---------------- EFFECTIVE CHANNEL ----------------

        H = Hbu + Hru*Phi*Hbr;

        % Normalize
        for k = 1:K
            H(k,:) = H(k,:)/(norm(H(k,:))+1e-12);
        end

        %% ====================================================
        % RSMA PRECODING
        % ====================================================

        % Common beamformer
        wc = sum(H,1).';
        wc = wc/(norm(wc)+1e-12);
        wc = sqrt(Pc)*wc;

        % Private beamformers
        Wp = zeros(Nt,K);

        for k = 1:K
            wk = H(k,:).';
            wk = wk/(norm(wk)+1e-12);
            Wp(:,k) = sqrt(Pp)*wk;
        end

        %% ---------------- SINR CALCULATION ----------------

        SINRc = zeros(K,1);
        SINRp = zeros(K,1);

        for k = 1:K

            h = H(k,:).';

            % Common stream
            Sc = abs(h'*wc)^2;

            Ic = noise;

            for j = 1:K
                Ic = Ic + abs(h'*Wp(:,j))^2;
            end

            SINRc(k) = Sc/Ic;

            % Private stream
            Sp = abs(h'*Wp(:,k))^2;

            Ip = noise;

            for j = 1:K
                if j ~= k
                    Ip = Ip + abs(h'*Wp(:,j))^2;
                end
            end

            SINRp(k) = Sp/Ip;

        end

        %% ---------------- RSMA RATE ----------------

        Rc = min(log2(1+SINRc));
        Rp = sum(log2(1+SINRp));

        totalRate = Rc + Rp;

        rate1 = rate1 + totalRate;

        %% ====================================================
        % CONVENTIONAL TRANSMISSION
        % ====================================================

        Wconv = zeros(Nt,K);

        for k = 1:K
            wk = H(k,:).';
            wk = wk/(norm(wk)+1e-12);
            Wconv(:,k) = sqrt(1/K)*wk;
        end

        SINRconv = zeros(K,1);

        for k = 1:K

            h = H(k,:).';

            signal = abs(h'*Wconv(:,k))^2;

            interference = noise;

            for j = 1:K
                if j ~= k
                    interference = interference + ...
                        abs(h'*Wconv(:,j))^2;
                end
            end

            SINRconv(k) = signal/interference;

        end

        rate2 = rate2 + sum(log2(1+SINRconv));

        %% ====================================================
        % RSMA WITHOUT RIS
        % ====================================================

        H0 = Hbu;

        for k = 1:K
            H0(k,:) = H0(k,:)/(norm(H0(k,:))+1e-12);
        end

        wc0 = sum(H0,1).';
        wc0 = wc0/(norm(wc0)+1e-12);
        wc0 = sqrt(Pc)*wc0;

        W0 = zeros(Nt,K);

        for k = 1:K
            wk = H0(k,:).';
            wk = wk/(norm(wk)+1e-12);
            W0(:,k) = sqrt(Pp)*wk;
        end

        SINR0c = zeros(K,1);
        SINR0p = zeros(K,1);

        for k = 1:K

            h = H0(k,:).';

            Sc = abs(h'*wc0)^2;

            Ic = noise;

            for j = 1:K
                Ic = Ic + abs(h'*W0(:,j))^2;
            end

            SINR0c(k) = Sc/Ic;

            Sp = abs(h'*W0(:,k))^2;

            Ip = noise;

            for j = 1:K
                if j ~= k
                    Ip = Ip + abs(h'*W0(:,j))^2;
                end
            end

            SINR0p(k) = Sp/Ip;

        end

        rate3 = rate3 + ...
            min(log2(1+SINR0c)) + sum(log2(1+SINR0p));

        %% ====================================================
        % QPSK BER
        % ====================================================

        Nb = 400;

        b = randi([0 1],Nb,1);

        x = (1-2*b(1:2:end)) + ...
            1i*(1-2*b(2:2:end));

        x = x/sqrt(2);

        h = H(1,:).';

        y = (h'*Wp(:,1))*x + ...
            sqrt(noise/2)*(randn(size(x)) + ...
            1i*randn(size(x)));

        bh1 = real(y)<0;
        bh2 = imag(y)<0;

        bh = zeros(Nb,1);
        bh(1:2:end) = bh1;
        bh(2:2:end) = bh2;

        err = err + sum(bh~=b);
        bitsTotal = bitsTotal + Nb;

        %% ====================================================
        % ISAC SENSING MODEL
        % ====================================================

        targetRCS = 0.8;
        targetRange = 50;

        % RIS-assisted sensing gain
        risGain = abs(sum(exp(1i*theta)))/sqrt(N);

        sensingPower = targetRCS * ...
            (1 + risGain)^2;

        interference = noise + ...
            0.05*mean(abs(H(:)).^2);

        ss = ss + sensingPower/interference;

        %% ---------------- RANGE ESTIMATION ----------------

        % Simplified delay estimation model
        bandwidth = BW;
        rangeResolution = c/(2*bandwidth);

        estimatedRange = targetRange + ...
            rangeResolution*randn;

        re = re + abs(estimatedRange-targetRange);

    end

    %% ---------------- AVERAGING ----------------

    Rate_RSMA(s) = rate1/MC;
    Rate_Conv(s) = rate2/MC;
    Rate_NoRIS(s) = rate3/MC;

    BER(s) = err/bitsTotal;

    SenseSINR(s) = 10*log10(ss/MC);

    RangeError(s) = re/MC;

    %% Energy Efficiency
    totalPower = 1 + 0.1*Nt + 0.005*N;

    EnergyEff(s) = Rate_RSMA(s)/totalPower;

end

%% ============================================================
% RESULTS
% ============================================================

fprintf('\n============================================\n');
fprintf(' RSMA-RIS-ISAC SIMULATION RESULTS\n');
fprintf('============================================\n');

fprintf('Maximum RSMA Rate      = %.3f bits/s/Hz\n', ...
    max(Rate_RSMA));

fprintf('Maximum Conventional   = %.3f bits/s/Hz\n', ...
    max(Rate_Conv));

fprintf('Maximum RIS Gain       = %.3f bits/s/Hz\n', ...
    max(Rate_RSMA-Rate_NoRIS));

fprintf('Minimum BER            = %.4e\n', ...
    min(BER));

fprintf('Maximum Sensing SINR   = %.2f dB\n', ...
    max(SenseSINR));

fprintf('Minimum Range Error    = %.3f m\n', ...
    min(RangeError));

%% ============================================================
% FIGURE 1: SUM RATE
% ============================================================

figure;

plot(SNRdB,Rate_RSMA,'-o','LineWidth',2);
hold on;
plot(SNRdB,Rate_Conv,'-s','LineWidth',2);
plot(SNRdB,Rate_NoRIS,'--d','LineWidth',2);

grid on;

xlabel('SNR (dB)');
ylabel('Spectral Efficiency (bits/s/Hz)');

title('Communication Performance');

legend('RSMA + RIS','Conventional + RIS', ...
       'RSMA without RIS','Location','northwest');

%% ============================================================
% FIGURE 2: BER
% ============================================================

figure;

semilogy(SNRdB,BER,'-o','LineWidth',2);

grid on;

xlabel('SNR (dB)');
ylabel('BER');

title('RSMA Communication BER');

%% ============================================================
% FIGURE 3: SENSING SINR
% ============================================================

figure;

plot(SNRdB,SenseSINR,'-o','LineWidth',2);

grid on;

xlabel('SNR (dB)');
ylabel('Sensing SINR (dB)');

title('RIS-Assisted ISAC Sensing Performance');

%% ============================================================
% FIGURE 4: RANGE ESTIMATION ERROR
% ============================================================

figure;

plot(SNRdB,RangeError,'-o','LineWidth',2);

grid on;

xlabel('SNR (dB)');
ylabel('Range Estimation Error (m)');

title('ISAC Target Range Estimation');

%% ============================================================
% FIGURE 5: ENERGY EFFICIENCY
% ============================================================

figure;

plot(SNRdB,EnergyEff,'-o','LineWidth',2);

grid on;

xlabel('SNR (dB)');
ylabel('Energy Efficiency (bits/J)');

title('Energy Efficiency of RSMA-RIS-ISAC');

%% ============================================================
% END
% ============================================================

fprintf('\nSimulation completed successfully.\n');
