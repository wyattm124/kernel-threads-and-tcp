% NOTE : for all file imports you will need to put the FULL file path that
% is appropriate for your system. relative to the project root all of the
% data files are in the 

% ./data/TCP_tests/ and ./data/UDP_tests/ folders

% TCP data load
TTBwalk = readmatrix('~/Desktop/git_repos/KernelThreadsAndTCP/data/TCP_tests/TCP_TX_broken.csv');
TRBwalk = readmatrix('~/Desktop/git_repos/KernelThreadsAndTCP/data/TCP_tests/TCP_RX_broken.csv');
TTFwalk = readmatrix('~/Desktop/git_repos/KernelThreadsAndTCP/data/TCP_tests/TCP_TX_fixed.csv');
TRFwalk = readmatrix('~/Desktop/git_repos/KernelThreadsAndTCP/data/TCP_tests/TCP_RX_fixed.csv');

% UDP data load
UTBwalk = readmatrix('~/Desktop/git_repos/KernelThreadsAndTCP/data/UDP_tests/UDP_TX_broken.csv');
URBwalk = readmatrix('~/Desktop/git_repos/KernelThreadsAndTCP/data/UDP_tests/UDP_RX_broken.csv');
UTFwalk = readmatrix('~/Desktop/git_repos/KernelThreadsAndTCP/data/UDP_tests/UDP_TX_fixed.csv');
URFwalk = readmatrix('~/Desktop/git_repos/KernelThreadsAndTCP/data/UDP_tests/UDP_RX_fixed.csv');

% sample bucket size
bucketSZ = 20;
% backup limit on datapoints
N = 1000;

% Length
nTTB = N; % length(TTBwalk(:,1));
nTRB = N; % length(TRBwalk(:,1));
nTTF = N; % length(TTBwalk(:,1));
nTRF = N; % length(TRBwalk(:,1));

nUTB = N; % length(UTBwalk(:,1));
nURB = N; % length(URBwalk(:,1));
nUTF = N; % length(UTBwalk(:,1));
nURF = N; % length(URBwalk(:,1));

% End Time
endTimeTTB = max(TTBwalk(:,1));
endTimeTRB = max(TRBwalk(:,1));
endTimeTTF = max(TTFwalk(:,1));
endTimeTRF = max(TRFwalk(:,1));

endTimeUTB = max(UTBwalk(:,1));
endTimeURB = max(URBwalk(:,1));
endTimeUTF = max(UTFwalk(:,1));
endTimeURF = max(URFwalk(:,1));

% Offsets -> note these need to be calculated visually
offsetTTB = 0;
offsetTRB = 0;
offsetTTF = 0;
offsetTRF = 0;

offsetUTB = 0;
offsetURB = 0;
offsetUTF = 0;
offsetURF = 0;

% create the actual walk
TTBwalk = createWalk(nTTB-1, TTBwalk);
TRBwalk = createWalk(nTRB-1, TRBwalk);
TTFwalk = createWalk(nTTF-1, TTFwalk);
TRFwalk = createWalk(nTRF-1, TRFwalk);

UTBwalk = createWalk(nUTB-1, UTBwalk);
URBwalk = createWalk(nURB-1, URBwalk);
UTFwalk = createWalk(nUTF-1, UTFwalk);
URFwalk = createWalk(nURF-1, URFwalk);

% sample the walks
TTBsampled = smpl(nTTB, endTimeTTB, TTBwalk, bucketSZ);
TRBsampled = smpl(nTRB, endTimeTRB, TRBwalk, bucketSZ);
TTFsampled = smpl(nTTF, endTimeTTF, TTFwalk, bucketSZ);
TRFsampled = smpl(nTRF, endTimeTRF, TRFwalk, bucketSZ);

UTBsampled = smpl(nUTB, endTimeUTB, UTBwalk, bucketSZ);
URBsampled = smpl(nURB, endTimeURB, URBwalk, bucketSZ);
UTFsampled = smpl(nUTF, endTimeUTF, UTFwalk, bucketSZ);
URFsampled = smpl(nURF, endTimeURF, URFwalk, bucketSZ);

% align the walks
TTBsampled(:,1) = TTBsampled(:,1) - offsetTTB;
TRBsampled(:,1) = TRBsampled(:,1) - offsetTRB;
TTFsampled(:,1) = TTFsampled(:,1) - offsetTTF;
TRFsampled(:,1) = TRFsampled(:,1) - offsetTRF;

UTBsampled(:,1) = UTBsampled(:,1) - offsetUTB;
URBsampled(:,1) = URBsampled(:,1) - offsetURB;
UTFsampled(:,1) = UTFsampled(:,1) - offsetUTF;
URFsampled(:,1) = URFsampled(:,1) - offsetURF;

% End of the shortest in the pair for the data sets
mTB = min(length(TTBsampled(:,1)), length(TRBsampled(:,1)));
mTF = min(length(TTFsampled(:,1)), length(TRFsampled(:,1)));

mUB = min(length(UTBsampled(:,1)), length(URBsampled(:,1)));
mUF = min(length(UTFsampled(:,1)), length(URFsampled(:,1)));

% find the error
TBerror = arrayfun(@(x,y)abs(x-y), TTBsampled(1:mTB,4), TRBsampled(1:mTB,4));
TFerror = arrayfun(@(x,y)abs(x-y), TTFsampled(1:mTF,4), TRFsampled(1:mTF,4));

UBerror = arrayfun(@(x,y)abs(x-y), UTBsampled(1:mUB,4), URBsampled(1:mUB,4));
UFerror = arrayfun(@(x,y)abs(x-y), UTFsampled(1:mUF,4), URFsampled(1:mUF,4));

% integrate for cumaltive readable error
TBcumError = cumtrapz(bucketSZ, TBerror);
TFcumError = cumtrapz(bucketSZ, TFerror);

UBcumError = cumtrapz(bucketSZ, UBerror);
UFcumError = cumtrapz(bucketSZ, UFerror);

figure('Name', 'TCP');
% TX / RX for the broken Link over TCP
subplot(3, 2, 1)
plot(TTBsampled(:,1), TTBsampled(:,4));
hold on
plot(TRBsampled(:,1), TRBsampled(:,4));
title('5% Drop Rate');
legend({'TX', 'RX'}, 'Location', 'northwest');
legend('boxoff');
hold off

% TX / RX for the perfect Link over TCP
subplot(3,2,2)
plot(TTFsampled(:,1), TTFsampled(:,4));
hold on
plot(TRFsampled(:,1), TRFsampled(:,4));
title('Perfect Link');
legend({'TX', 'RX'}, 'Location', 'northwest');
legend('boxoff');
hold off

% (TX - RX)^2 for the broken Link over TCP
subplot(3, 2, 3)
plot(TTBsampled(1:mTB,1), TBerror);
title('error with 5% Drop Rate');

% (TX - RX)^2 for the perfect Link over TCP
subplot(3,2,4)
plot(TTFsampled(1:mTF,1), TFerror);
title('error on Perfect Link');

% cumulative error for the broken Link over TCP
subplot(3, 2, [5,6])
endPtT = min(mTB, mTF);
plot(TTBsampled(1:endPtT,1), TBcumError(1:endPtT));
hold on
plot(TTFsampled(1:endPtT,1), TFcumError(1:endPtT));
title('cumulative errors');
legend({'5% Drop', 'Perfect'}, 'Location', 'northwest');
legend('boxoff');
hold off

figure('Name', 'UDP');
% TX / RX for the broken Link over TCP
subplot(3, 2, 1)
plot(UTBsampled(:,1), UTBsampled(:,4));
hold on
plot(URBsampled(:,1), URBsampled(:,4));
title('5% Drop Rate');
legend({'TX', 'RX'}, 'Location', 'northwest');
legend('boxoff');
hold off

% TX / RX for the perfect Link over TCP
subplot(3,2,2)
plot(UTFsampled(:,1), UTFsampled(:,4));
hold on
plot(URFsampled(:,1), URFsampled(:,4));
legend({'TX', 'RX'}, 'Location', 'northwest');
legend('boxoff');
title('Perfect Link');
hold off

% (TX - RX)^2 for the broken Link over TCP
subplot(3, 2, 3)
plot(UTBsampled(1:mUB,1), UBerror);
title('error with 5% Drop Rate');

% (TX - RX)^2 for the perfect Link over TCP
subplot(3,2,4)
plot(UTFsampled(1:mUF,1), UFerror);
title('error on perfect link');

% cumulative error for the broken Link over TCP
subplot(3, 2, [5,6])
endPtU = min(mUB, mUF);
plot(UTBsampled(1:endPtU,1), UBcumError(1:endPtU));
hold on
plot(UTFsampled(1:endPtU,1), UFcumError(1:endPtU));
title('cumulative errors');
legend({'5% Drop', 'Perfect'}, 'Location', 'northwest');
legend('boxoff');
hold off

function M = createWalk(n,M)
    % sums entries to recover random walk
    for i = 2:n
        M(i,4) = M(i,4) + M(i-1,4);
        M(i,5) = M(i,5) + M(i-1,5);
    end
end
function mtrx = smpl(len, nd, M, sz)
    j = 2;
    k = 1;
    % output matrix
    mtrx = zeros(len, 5);
    % sample
    for i = 1:sz:nd
        while j < len && M(j,1) < i
            j = j + 1;
        end
        mtrx(k,:) = M(j-1,:);
        mtrx(k,1) = i;
        k = k+1;
    end
    % trim unused rows
    k = k-1;
    j = len;
    while j > k
        mtrx(j,:) = [];
        j = j-1;
    end
end