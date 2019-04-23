%% code for step 2
close all;
clearvars;
%% parameters
% ofdm
N = 128; % number of subcarriers
fc = 2e9; % carrier frequency
deltaf = 15e3; % subcarrier spacing
L = 32; % prefix length
indexK = []; %[0 N/2 + (-5:5) ]; % position of null tones
K = length(indexK); % number of null tones

% channel
load('CIR.mat'); % channel response
lambda = fft(h,N); % power of each channel

% bit loading
Pmax = 1000; % max power
SNR = [0 10 20];
Es_N0 = 10.^(SNR/10); % in db

mu = Pmax / N; % initial guess
tol = 0.0001*Pmax;
itermax = 10000;
delta = 0.001*Pmax/N;

[sigma2xk,sigma2nk] = deal(zeros(length(Es_N0),N));
bk = zeros(length(Es_N0),N);
for i=1:length(Es_N0)
    do = 1;
    iter = 0;
    while (do)
        sigma2n = Es_N0(i)^-1;

        for k=1:N
            sigma2nk(i,k) = sigma2n/abs(lambda(k))^2;
            sigma2xk(i,k) = pospart(mu-sigma2nk(i,k));
        end
        
        I = nnz(sigma2xk(i,:));
        if I == 0
            fprintf('Pmax too low\n');
            break;
        end
        if (abs(sum(sigma2xk(i,:)) - Pmax) > tol && iter < itermax)
            if (sum(sigma2xk(i,:)) < Pmax)
                mu = mu + delta;
            else
                mu = mu - delta;
            end
        else
            do = 0;
        end
        iter = iter +1;
    end
    figure;
    plot((Pmax/N)./sigma2nk(i,:),'.b');
    hold on;
    plot(sigma2xk(i,:)./sigma2nk(i,:),'.r');
end



function b = optimalBit(SNR,SER)
    b = log2(1-3*SNR/(2*log2(SER/2)));
end

function res = pospart(x)
    res = x.*(x>0);
end