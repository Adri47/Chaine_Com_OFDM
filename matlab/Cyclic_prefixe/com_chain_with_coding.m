%% Projet EN321 - Simulation d'une TX/RX sans modulation OFDM - Version double codeur de canal
% La chaine de communication est composï¿½e de 2 codeurs de canal sï¿½parï¿½s par
% un entrelaceur convolutif. Le premier codeur est un codeur en bloc, le
% second est un codeur en ligne.

instrreset;
clear all;
close all;
load P_soft.mat;
clc

%%%%%%%%%%%
%% INITIALIZATION
%%%%%%%%%%%

Fe=20e6; % sampling frequency
Te=1/Fe;
TC=40; % temperature (Celcius)
TK=274+TC; % temperature (Kelvin)
f0=2e9; % carrier frequency
kboltzman=1.3806400e-23; % Boltzmann constant
N0=kboltzman*Fe*TK; % Noise power
N0dB=10*log10(N0);
sprintf('Noise power : %d dB',N0dB)
Ptx=0.01; % transmitted signal power (Watt)
Ptx_dB=10*log10(Ptx);
d=100*rand+10; % distance between Tx and Rx (meters)
c=3e8; % speed of light
Prx=Ptx*(c/(f0*4*pi*d))^2; % recevied signal power (Watt)
Prx_dB=10*log10(Prx);

sprintf('Distance Tx/Rx (m): %d',d)
sprintf('Transmitted signal power  : %d dB',Ptx_dB)
sprintf('Received signal power  : %d dB',Prx_dB)
sprintf('SNR at the receiver side : %d dB',Prx_dB-N0dB)

NFFT=64; %nombre de sous porteuse
% bch_k=52; % sub-carrier number

%W=bch_k/NFFT*Fe; % transmitted signal bandwidth

nb=2; % number of bits per symbol
disp('Code MAC binaire correspondant à la modulation numérique : ')
b0_b2=de2bi(nb,3,'left-msb')

M=2^nb;
type_mod='psk';

L=30; % size of the channel
freq_axis = [-1/(2*Te):1/(NFFT*Te):1/(2*Te)-1/(NFFT*Te)];
noise_variance=N0; % noise variance

%% Scrambler parameters
scramb_polynomial=[1 1 1 0 1];
scramb_init_state=[0 0 0 0];
Scrambler_U_obj=comm.Scrambler(2,scramb_polynomial,scramb_init_state); % scrambler creation

%% BCH parameters
bch_n=7;   % code block-length
bch_k=4;   % code dimension

%% Convolutionnal interleaver
intlvr_line_nb=7; % nb of lines ( = shift-registers) in the interleaver
intlvr_reg_size=1; % number of bits per register

%% Convolutionnal encoder parameters 
trellis = poly2trellis(3,[5 3]); % generator polynomial : (15,13)


%% Data reading/generation

data_mode = 'rand_binary_image'; % generation of a random binary image
%data_mode = 'color_image';

if(data_mode == 'rand_binary_image')
    
    % Generation de donnees aleatoire et disposition dans une image
    Nb_ligne_IMG=10;
    Nb_colonne_IMG=10;
    U_soft_size=Nb_ligne_IMG*Nb_colonne_IMG;   % nombre de bits utiles codÃ©s
    % gÃ©nÃ©ration alÃ©atoire de donn?es binaires
    rng(654354)
    tmp=(randi(2,U_soft_size)-1);
    U_soft = tmp(1,:)
    % on place les donnÃ©es dans une matrice qui sera affichÃ©e comme une image
    img2send=reshape(U_soft,Nb_ligne_IMG,Nb_colonne_IMG)
    
elseif(data_mode == 'color_image')
    
    % Lecture d'une image
    img2send=imread('./bdd_image/logo.jpg'); % l'image est retourn?e sous la forme d'une matrice 3D RGB
    U_soft_R=reshape(de2bi(reshape(img2send(:,:,1),[],1),8,'left-msb').',[],1); % flux binaire du rouge
    U_soft_G=reshape(de2bi(reshape(img2send(:,:,2),[],1),8,'left-msb').',[],1); % flux binaire du vert
    U_soft_B=reshape(de2bi(reshape(img2send(:,:,3),[],1),8,'left-msb').',[],1); % flux binaire du bleu    
    U_soft=[U_soft_R;U_soft_G;U_soft_B].';
    U_soft_size=length(U_soft);
    Nb_ligne_IMG=size(img2send,1);
    Nb_colonne_IMG=size(img2send,2);
    U_soft=[U_soft_R;U_soft_G;U_soft_B].';
end

U_soft_size=length(U_soft);

%%%--------------------------------------------------------------------%%%%
%%- CHANNEL CODING
%%%---------------------------------------------------------------------%%%


%% Padding for the BCH encoder and the interleaver

full_bch_cwd_nb = floor(U_soft_size/bch_k)
bch_cwd_nb = (full_bch_cwd_nb +1) + (intlvr_line_nb-1);

intlvr_pad_bit_nb = bch_k * intlvr_reg_size * (intlvr_line_nb - 1); % after BCH encoding, there is intlvr_line_nb*intlvr_reg_size*(intlvr_line_nb-1) padding bits for the interleaver
bch_pad_bit_nb = bch_k-(U_soft_size-full_bch_cwd_nb*bch_k);

total_pad_bit_nb = bch_pad_bit_nb + intlvr_pad_bit_nb; 

sprintf('Nb of padding bits for the last BCH codeword + interleaver: %d',total_pad_bit_nb)

padding_bits=zeros(1,total_pad_bit_nb);
bch_bit_nb = bch_cwd_nb * bch_n;

V_soft = [U_soft, padding_bits];
V_soft_size = length(V_soft);

%% Write UART
% s = send_UART(V_soft,8)

%% Scrambler
S_soft=step(Scrambler_U_obj,V_soft.');
S_soft_size = length(S_soft);
% 
% 
%% BCH Encoder
X_gf_soft = bchenc(gf(reshape(S_soft, bch_k, bch_cwd_nb).',1), bch_n, bch_k); % codeur BCH(bch_n,bch_k)
X_soft = double( X_gf_soft.x );

%% Read UART
% S_hard=recv_UART(s, V_soft_size*4);
% X_soft = reshape((double(dec2bin(S_hard))-48)',[7,32])';

%% Interleaver
P_soft=convintrlv([reshape(X_soft.',1,[])],intlvr_line_nb,intlvr_reg_size);
P_soft_size = length(P_soft);
% 
% %% Write UART
% % s = send_UART(P_soft,P_soft_size)
% 
%% Convolutionnal Encoder
C_soft = convenc(P_soft,trellis);
C_soft_length = length(C_soft);

% %% Read UART
% C_hard = recv_UART(s, bch_bit_nb);
% C_hard = reshape(de2bi(C_hard)',1,[])
% C_soft= C_hard


%% OFDM Modulator 

%%%--------------------------------------------------------------------%%%%
%%- DIGITAL MODULATION
%%%---------------------------------------------------------------------%%%


lenght_padding = 64;
padding = randi([0, 1], 1, lenght_padding);
C_soft = [C_soft padding];

X=bi2de(reshape(C_soft.',length(C_soft)/nb,nb),'left-msb').'; % bit de poids fort ï¿½ gauche
init_phase=0;
if type_mod=='psk'
    if nb==2
        init_phase=pi/4;
    end
       symb_utiles = pskmod(X,M,init_phase,'gray');
elseif type_mod=='qam'
       symb_utiles = qammod(X,M,0,'gray');
else
    sprintf('Erreur modulation inconnue')
    s=[];
end

symb_utiles_padding = reshape(symb_utiles, [64,4]);

OFMD_mod = ifft(symb_utiles_padding,64);

D = L; % Taille du préxife cyclique
CP(:,1)= OFMD_mod([NFFT-D+1 : NFFT],1);
CP(:,2)= OFMD_mod([NFFT-D+1 : NFFT],2);
CP(:,3)= OFMD_mod([NFFT-D+1 : NFFT],3);
CP(:,4)= OFMD_mod([NFFT-D+1 : NFFT],4);

CP_OFDM = [ CP(:,1); OFMD_mod(:,1); CP(:,2); OFMD_mod(:,2); CP(:,3); OFMD_mod(:,3); CP(:,4); OFMD_mod(:,4)];
OFMD_mod = [ OFMD_mod(:,1),OFMD_mod(:,2),OFMD_mod(:,3),OFMD_mod(:,4)];

    
%%
%%%--------------------------------------------------------------------%%%%
%%- CHANNEL (normalized channel : average power)
%%%---------------------------------------------------------------------%%%
% h = 1; % discrete channel without multi-path
h=sqrt(1/(2*L))*(randn(1,L)+1i*randn(1,L)); % discrete channel with multi-path
% y = filter(h,1,symb_utiles);
y = filter(h,1,CP_OFDM);
       
%%
%%%--------------------------------------------------------------------%%%%
%% RECEIVER
%%%---------------------------------------------------------------------%%%
noise_variance = 2e-4
noise = sqrt(noise_variance/(2))*(randn(size(y))+1i*randn(size(y)));
z = y + noise; %signal + bruit

%% OFDM Demodulator 

z = reshape(z, [NFFT+D,4]);
CP_OFDM_RX(:,1) = z([D+1:NFFT+D],1);
CP_OFDM_RX(:,2) = z([D+1:NFFT+D],2);
CP_OFDM_RX(:,3) = z([D+1:NFFT+D],3);
CP_OFDM_RX(:,4) = z([D+1:NFFT+D],4);

OFMD_mod_RX = fft(CP_OFDM_RX);

%% Channel equalizer
H = fft(h,NFFT); 
CP_OFDM_E(:,1) = OFMD_mod_RX(:,1)./H.';
CP_OFDM_E(:,2) = OFMD_mod_RX(:,2)./H.';
CP_OFDM_E(:,3) = OFMD_mod_RX(:,3)./H.';
CP_OFDM_E(:,4) = OFMD_mod_RX(:,4)./H.';

R_OFDM = real(CP_OFDM_E);
I_OFDM = imag(CP_OFDM_E);

figure(200), plot(R_OFDM,I_OFDM,'*red');
title("Symboles reçues après équalisation du canal");
xlabel("Partie réelle");
ylabel("Partie imaginaire");
% CP_OFDM_E = OFMD_mod_RX;
%% Demodulation

symb_U_Rx = CP_OFDM_E;

init_phase = 0;
if type_mod=='psk'
    if nb==2
        init_phase=pi/4;
    end
       s = pskdemod(symb_U_Rx,M,init_phase,'gray');
       X=de2bi(s,log2(M),'left-msb').'; % bit de poids fort ï¿½ gauche   
       
else
       s = qamdemod(symb_U_Rx,M,0,'gray');
       X=de2bi(s,log2(M),'left-msb').'; % bit de poids fort ï¿½ gauche
       
end

C_r_soft=reshape(X.',1,[]);
C_r_soft = C_r_soft(1:(length(C_r_soft)-lenght_padding));

%% Viterbi Decoding

trellis_depth=42; % profondeur du trellis

P_r_soft = vitdec(C_r_soft,trellis,trellis_depth,'trunc','hard');

BER_U_A_Viterbi = mean(abs(P_soft-P_r_soft))


%% Deinterleaving

X_r_soft=convdeintrlv(P_r_soft,intlvr_line_nb,intlvr_reg_size);

%% BCH decoding

S_r_soft_gf=bchdec(gf(reshape(X_r_soft,bch_n,bch_cwd_nb).',1),bch_n,bch_k); 
S_r_soft = uint8(S_r_soft_gf.x);

S_r_soft_Depad_temp = reshape(S_r_soft.',1,[]);
S_r_soft_Depad = S_r_soft_Depad_temp(intlvr_pad_bit_nb+1:end);
S_r_soft_Depad = S_r_soft_Depad(1:end-bch_pad_bit_nb)
%BER_U = mean(abs(S_r_soft_Depad-uint8(U_soft'))); % final BER

%% Descrambler

Descrambler_U_obj = comm.Descrambler(2,scramb_polynomial,scramb_init_state);

S_r_soft_Depad=step(Descrambler_U_obj,S_r_soft_Depad.'); % descrambler

BER_U = mean(abs(S_r_soft_Depad-uint8(U_soft')));

%% Image reconstruction

if(data_mode == 'rand_binary_image')
    imgRx=reshape(S_r_soft_Depad,Nb_ligne_IMG,Nb_colonne_IMG);
elseif(data_mode == 'color_image')
    bitsRx=reshape(S_r_soft_Depad,[],3);
    intRx_R=uint8(bi2de(reshape(bitsRx(:,1),8,[]).','left-msb'));
    intRx_G=uint8(bi2de(reshape(bitsRx(:,2),8,[]).','left-msb'));
    intRx_B=uint8(bi2de(reshape(bitsRx(:,3),8,[]).','left-msb'));

    imgRx(:,:,1)=reshape(intRx_R,Nb_ligne_IMG,Nb_colonne_IMG);
    imgRx(:,:,2)=reshape(intRx_G,Nb_ligne_IMG,Nb_colonne_IMG);
    imgRx(:,:,3)=reshape(intRx_B,Nb_ligne_IMG,Nb_colonne_IMG);
end

figure(5)
subplot 131;
if(data_mode == 'rand_binary_image')
    imagesc(img2send)
elseif(data_mode == 'color_image')
    image(img2send)
end
title('Image emise')

subplot 132;
if(data_mode == 'rand_binary_image')
    imagesc(imgRx)
elseif(data_mode == 'color_image')
    image(imgRx)
end
title('Image recue')

subplot 133;
if(data_mode == 'rand_binary_image')
    imagesc(uint8(img2send)-imgRx)
elseif(data_mode == 'color_image')
    image(uint8(img2send)-imgRx)
end
title('diff des images')


%% BER results
disp('--------------------------------------------------------------------')
fprintf('SNR at the receiver side : %d dB\n',round(Prx_dB-N0dB))
disp('--------------------------------------------------------------------')

fprintf('BER after Viterbi decoding: %d\n',(BER_U_A_Viterbi))
fprintf('BER after BCH : %d\n',(BER_U))
disp('--------------------------------------------------------------------')