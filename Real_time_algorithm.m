clc;
clear all;

addpath(genpath('BLACKROCK_SDK_PATH'));
cbmex('open');

objects = instrfind;
if ~isempty(objects)
    fclose(objects);
    delete(objects);
end

arduino = serial('COM_PORT', 'BaudRate', 9600);
fopen(arduino);

fs = 30000;
interestedChannel = CHANNEL_NUMBER;
spkthrlevel = 'THRESHOLD_LEVEL';
fss = 44100;
max_trials = MAX_TRIALS;
snippent_length = 0.35;
prev_last_spike_time = 0;
minfiringrate = MIN_FIRING_RATE;
maxfiringrate = MAX_FIRING_RATE;
mu = MU_VALUE;
min_changefreq = 100;
max_changefreq = 1500;
k = K_VALUE;

x = linspace(minfiringrate, maxfiringrate, 1000);
f = 1 ./ (1 + k*(x - mu).^2);
f_min = min(f);
f_max = max(f);
f_normalized = (f - f_min) / (f_max - f_min);
plot(x, f_normalized);
title('Modified Hyperbolic Tangent Function');
xlabel('x');
ylabel('f(x)');
grid on;

cbmex('config', interestedChannel, 'smpgroup', 5, 'spkfilter', 12, 'spkthrlevel', spkthrlevel);
input('Enter the ranges and time for classifying neurons: ', 's');
disp('-------Recording started-------');
cbmex('trialconfig', 1);
cbmex('trialdata', 1);

for trial = 1:max_trials
    disp(['Trial ' num2str(trial) ' started-----']);
    
    all_spikes_per_cycle = [];
    all_avg_rates = [];
    prev_last_spike_time = [];

    cbmex('trialdata', 1);
    pause(snippent_length);

    pre_freq = 1000;
    trial_start_time = tic;

    while true
        [timestamps_cell_array, ~, ~] = cbmex('trialdata', 0);
        unit1_spikes = double(timestamps_cell_array{interestedChannel, 3}) / fs;

        if prev_last_spike_time > 0
            idx = find(unit1_spikes > prev_last_spike_time, 1, 'first');
            if ~isempty(idx)
                new_spikes = unit1_spikes(idx:end);
                first_spike = unit1_spikes(idx);
                instantaneousRates = [1 / (first_spike - prev_last_spike_time); 1 ./ diff(new_spikes)];
            else
                instantaneousRates = 0;
                new_spikes = [];
            end
        else
            instantaneousRates = 1 ./ diff(unit1_spikes);
            new_spikes = unit1_spikes;
            if isempty(new_spikes)
                instantaneousRates = 0;
            end
        end

        current_spike_count = length(new_spikes);
        max_spike_count = size(all_spikes_per_cycle, 2);
        if max_spike_count == 0
            max_spike_count = 1;
        end
        if current_spike_count > max_spike_count
            all_spikes_per_cycle = [all_spikes_per_cycle, NaN(size(all_spikes_per_cycle, 1), current_spike_count - max_spike_count)];
        elseif current_spike_count < max_spike_count
            new_spikes = [new_spikes; NaN(max_spike_count - current_spike_count, 1)];
        end
        all_spikes_per_cycle = [all_spikes_per_cycle; new_spikes'];

        if ~isempty(unit1_spikes)
            prev_last_spike_time = unit1_spikes(end);
        end

        avg_rate = mean(instantaneousRates, 'omitnan');
        if isempty(avg_rate) || isnan(avg_rate)
            avg_rate = 0;
        end

        all_avg_rates = [all_avg_rates; avg_rate];

        m = avg_rate;
        if m > maxfiringrate
            m = maxfiringrate;
        elseif m < minfiringrate
            m = minfiringrate;
        end

        f = 1 ./ (1 + k*(m - mu).^2);
        f_normalized = (f - f_min) / (f_max - f_min);
        mapped_freq = f_normalized * (max_changefreq - min_changefreq) + min_changefreq;
        current_freq = mapped_freq + pre_freq;
        t = linspace(0, snippent_length, round(fss * snippent_length));
        freq_transition = linspace(pre_freq, current_freq, length(t));
        y = sin(2 * pi * freq_transition .* t);
        soundsc(y, fss);
        pause(snippent_length);

        pre_freq = current_freq;

        if pre_freq >= 15000
            fprintf(arduino, 'w');
            disp('Water released');
            t = 0:1/fss:0.2;
            sound_wave = sin(2 * pi * pre_freq * t);
            sound(sound_wave, fss);
            break;
        end
    end

    trial_duration = toc(trial_start_time);
    disp(['Trial ' num2str(trial) ' completed, duration: ' num2str(trial_duration) ' seconds']);
    pause(2);
    fprintf(arduino, 'l');
end

disp(['Total ' num2str(trial) ' trials completed']);
fclose(arduino);
cbmex('close');
