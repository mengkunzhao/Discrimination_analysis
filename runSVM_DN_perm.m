function output = runSVM_DN_perm(DataMat,idNum,numOfperm,cPar,timeBins)
%% This function computes SVM with permutations to assess significance.
% The input is a data file from eeg_preprocessing.m
% Inputs    DataMat:        4-D matrix
%           idNum:          number of identities
%           numOfperm:      number of desired permutations
%           cPar:           c (criterion value for SVM)
%           timeBins:       desired time points
% Outputs   output:         discrimination cell matrix with ap,d and c.
if nargin<4
    cPar=1;
    timeBins=size(DataMat,4);
elseif nargin<5
    timeBins=size(DataMat,4);
end
DataMat=DataMat(:,:,:,timeBins);
combos = nchoosek([1:idNum],2); % setting number of combinations of identities
tic
for in=1:numOfperm
    for emo=1:2;
        for j=1:size(combos,1)
            parfor i=1:size(DataMat,4);
                [ap, d, c]=apply_classf_libsvm_MA_full_DN_perm(squeeze(DataMat(:,:,:,i)),combos(j,:),emo) %FOR TRUE CLASSIFICATION
                apOut_par(i, 1)=ap;
                dOut_par(i, 1)=d;
                cOut_par(i, 1)=c;
            end
            apOut(emo,j,:)=apOut_par;
            dOut(emo,j,:)=dOut_par;
            cOut(emo,j,:)=cOut_par;
        end
    end
    output.ap(in,:,:,:)=apOut;
    output.d(in,:,:,:)=dOut;
    output.c(in,:,:,:)=cOut;
    in
    toc
end
disp('End of process')
toc
close(h)
