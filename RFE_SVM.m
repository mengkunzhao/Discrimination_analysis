function output=RFE_SVM(Data,idNum,batchSize,c)
% funciton RFE_SVM performs crude
% input:    Data: features X ids+emotions X blocks X time bins
%           idNum: number of identities
%           c - slack parameter (default: 1);
if nargin<4
    c=1;
end
tic
combos = nchoosek([1:idNum],2);
output=ones(size(Data,1),size(combos,1),2,size(Data,4)); % features X ids pairs X emotions
labls=repmat([1;2],size(Data,3),1);%ids + blocks X 1
for l=1:size(Data,4)% loops through time bins
    for j=1:2% loops through emotions
        for i=1:size(combos,1)% loops through ids pairs
            temp=NaN(size(Data,3)*2,size(Data,1));% ids + blocks X features
            temp(1:2:end,:)=squeeze(Data(:,combos(i,1)+idNum*(j-1),:,l))';
            temp(2:2:end,:)=squeeze(Data(:,combos(i,2)+idNum*(j-1),:,l))';
            ws=(1:size(Data,1))';
            for k=1:ceil(size(Data,1)/batchSize);
                weigths=svm_perform(labls,temp,c);
                smallestNIdx = getNElements(weigths, batchSize);
                temp(:,smallestNIdx)=[];
                ws(smallestNIdx)=[];
                indtemp=zeros(size(Data,1),1);
                indtemp(ws)=1;
                output(:,i,j,l)=output(:,i,j,l)+indtemp;
            end
        end
    end
    toc
end
toc





    function output=svm_perform(tLbl,tMat,c)
        % tLbl: blocks+1d X 1; tMat: blocks+ids X features
        optstr=['-s 0 -t 0 -c ', num2str(c), ' -q'];
        svmStruct = svmtrain(tLbl, tMat, optstr);
        output = (svmStruct.SVs' * svmStruct.sv_coef).^2;
    end
    function smallestNIdx = getNElements(A, n)
        [~,AIdx] = sort(A);
        smallestNIdx = AIdx(1:n);
    end
end