function [ fncs ] = rules()
    % DO NOT EDIT
    fncs = l2.getRules();
    for i=1:length(fncs)
        fncs{i} = str2func(fncs{i});
    end
end

function result = ddr1( trace, params, t )
    result = {};
    
    for has_state = trace(t).has_state % go through each object
        object = has_state.arg{1};
        state = has_state.arg{2};
        
        % determine distance to ground for each present object
        if strcmp(state,'present'); 
            is_at_location = l2.getall(trace, t, 'is_at_location', {object, NaN, NaN});
            y = is_at_location.arg{3};
            result = { result{:} {t, 'has_distance_to_ground', {object, y}} };
        end
    end
end

function result = ddr2( trace, params, t )
    result = {};
    
    %go through each object with a distance to ground
    for has_distance_to_ground = trace(t).has_distance_to_ground
        object = has_distance_to_ground.arg{1};
        distance = has_distance_to_ground.arg{2};
        
        %get the vertical speed of the object
        has_vertical_speed = l2.getall(trace, t, 'has_vertical_speed', {object, NaN});
        vertical_speed = has_vertical_speed.arg{2};
        time_to_ground = (distance/vertical_speed);
        
        result = { result{:} {t, 'has_time_to_ground', {object, time_to_ground}} };
    end
end

function result = ddr3( trace, params, t )
    result = {};
    
    for has_state = trace(t).has_state % go through each object
        object = has_state.arg{1};
        state = has_state.arg{2};
        
        if strcmp(state, 'present')
            has_time_to_ground = l2.getall(trace, t, 'has_time_to_ground', {object, NaN});
            time_to_ground = has_time_to_ground.arg{2};
            time_value = (1-(time_to_ground/params.a));
            result = { result{:} {t, 'has_value_for', {object, time_value, 'time_to_ground'}} };
        
            is_of_type = l2.getall(trace, t, 'is_of_type', {object, NaN});
            type = is_of_type.arg{2};
            if strcmp(type, 'new');
                type_value = 1;
                result = { result{:} {t, 'has_value_for', {object, type_value, 'type'}} };
            elseif strcmp(type, 'sum_visible');
                type_value = 0.75;
                result = { result{:} {t, 'has_value_for', {object, type_value, 'type'}} };
            elseif strcmp(type, 'enemy');
                type_value = 0.5;
                result = { result{:} {t, 'has_value_for', {object, type_value, 'type'}} };
            elseif strcmp(type, 'ally'); 
                type_value = 0;
                result = { result{:} {t, 'has_value_for', {object, type_value, 'type'}} };
            end
        
            has_blinking = l2.getall(trace, t, 'has_blinking', {object, NaN});
            blinking = has_blinking.arg{2};
            if blinking == true;
                blinking_value = 1;
                result = { result{:} {t, 'has_value_for', {object, blinking_value, 'blinking'}} };
            elseif blinking == false;
                blinking_value = 0;
                result = { result{:} {t, 'has_value_for', {object, blinking_value, 'blinking'}} };
            end

            has_size = l2.getall(trace, t, 'has_size', {object, NaN});
            size = has_size.arg{2};
            if strcmp(size, 'normal');
                size_value = 0;
                result = { result{:} {t, 'has_value_for', {object, size_value, 'size'}} };
            elseif strcmp(size, 'big');
                size_value = 1;
                result = { result{:} {t, 'has_value_for', {object, size_value, 'size'}} };
            end

            has_brightness = l2.getall(trace, t, 'has_brightness', {object, NaN});
            brightness = has_brightness.arg{2};
            if strcmp(brightness, 'low');
                brightness_value = 0;
                result = { result{:} {t, 'has_value_for', {object, brightness_value, 'brightness'}} };
            elseif strcmp(brightness, 'high');
                brightness_value = 1;
                result = { result{:} {t, 'has_value_for', {object, brightness_value, 'brightness'}} };
            end
        end
    end
end

function result = ddr4( trace, params, t )
    result = {};
    
    for has_state = trace(t).has_state % go through each object
        object = has_state.arg{1};
        state = has_state.arg{2};
        
        % Determine potential attention of object
        if strcmp(state, 'present')
            has_value_V1_for = l2.getall(trace, t, 'has_value_for', {object, NaN, 'time_to_ground'});
            time_to_ground = has_value_V1_for.arg{2};
            
            has_value_V2_for = l2.getall(trace, t, 'has_value_for', {object, NaN, 'type'});
            type = has_value_V2_for.arg{2};
            
            has_value_V3_for = l2.getall(trace, t, 'has_value_for', {object, NaN, 'blinking'});
            blinking = has_value_V3_for.arg{2};
            
            has_value_V4_for = l2.getall(trace, t, 'has_value_for', {object, NaN, 'size'});
            size = has_value_V4_for.arg{2};
            
            has_value_V5_for = l2.getall(trace, t, 'has_value_for', {object, NaN, 'brightness'});
            brightness = has_value_V5_for.arg{2};
            
            potential_attention = (time_to_ground * params.W1) + (type * params.W2) + (blinking * params.W3) + (size * params.W4) + (brightness * params.W5);
            result = { result{:} {t, 'has_potential_attention', {object, potential_attention}} };
        end
    end
end

function result = ddr5( trace, params, t)
    result = {};
    
    for has_state = trace(t).has_state % go through each object
        object = has_state.arg{1};
        state = has_state.arg{2};
        
        if strcmp(state, 'present')
            has_potential_attention = l2.getall(trace, t, 'has_potential_attention', {object, NaN});
            potential_attention = has_potential_attention.arg{2};
            is_at_location = l2.getall(trace, t, 'is_at_location', {object, NaN, NaN});
            x1 = is_at_location.arg{2};
            y1 = is_at_location.arg{3};
            gaze_at_location = l2.getall(trace, t, 'gaze_at_location', {NaN, NaN});
            x2 = gaze_at_location.arg{1};
            y2 = gaze_at_location.arg{2};
            current_attention_contribution = (potential_attention/(1+(params.b*((x1-x2)^2+(y1-y2)^2))));
            result = { result{:} {t, 'has_current_attention_contribution', {object, current_attention_contribution}} };
        end
    end
end

function result = ddr6( trace, params, t)
    result = {};
    total_attention_contribution = 0;
    
    for has_current_attention_contribution = trace(t).has_current_attention_contribution
        current_attention_contribution = has_current_attention_contribution.arg{2};
        total_attention_contribution = total_attention_contribution + current_attention_contribution;
    end
    
    for has_current_attention_contribution = trace(t).has_current_attention_contribution
        object = has_current_attention_contribution.arg{1};
        current_attention_contribution = has_current_attention_contribution.arg{2};
        normalised_attention_contribution = (current_attention_contribution/total_attention_contribution);
        result = { result{:} {t, 'has_normalised_attention_contribution', {object, normalised_attention_contribution}} };  
    end

end

function result = ddr7( trace, params, t)
    result = {};
    
    for has_state = trace(t).has_state % go through each object
        object = has_state.arg{1};
        state = has_state.arg{2};
        
        if strcmp(state, 'present')
            has_old_attention_level = l2.getall(trace, t, 'has_old_attention_level', {object, NaN});
            old_attention_level = has_old_attention_level.arg{2};
            has_normalised_attention_contribution = l2.getall(trace, t, 'has_normalised_attention_contribution', {object, NaN});
            normalised_attention_contribution = has_normalised_attention_contribution.arg{2};
            attention_level = (params.p * normalised_attention_contribution + (1 - params.p) * old_attention_level);
            result = { result{:} {t, 'has_attention_level', {object, attention_level}} };
        end
    end
end

function result = ddr8( trace, params, t)
    result = {};
    
    for has_attention_level = trace(t).has_attention_level;
        object = has_attention_level.arg{1};
        attention_level = has_attention_level.arg{2};
        result = { result{:} {t+1, 'has_old_attention_level', {object, attention_level}} };
    end
end


function result = ddr9( trace, params, t)
    result = {};
    
    for attention_level = trace(t).has_attention_level
        object = attention_level.arg{1};
        has_time_to_ground = l2.getall(trace, t, 'has_value_for', {object, NaN, 'time_to_ground'});
        time_to_ground = has_time_to_ground.arg{2};
        has_type = l2.getall(trace, t, 'has_value_for', {object, NaN, 'type'});
        type = has_type.arg{2};
        urgency_level = (params.W1 * time_to_ground + params.W2 * type);
        result = { result{:} {t, 'has_urgency', {object, urgency_level}} };
    end
end

function result = ddr10( trace, params, t)
    result = {};
    
    for has_attention_level = trace(t).has_attention_level
        object = has_attention_level.arg{1};
        attention_level = has_attention_level.arg{2};
        has_urgency = l2.getall(trace, t, 'has_urgency', {object, NaN});
        urgency = has_urgency.arg{2};
        discrepancy = (params.S1 * urgency) - (params.S2 * attention_level);
        result = { result{:} {t, 'has_discrepancy', {object, discrepancy}} };
    end
end

function result = ddr11( trace, params, t)
    result = {};
    object_with_highest_attention_level = NaN;
    has_highest_attention_level = -100;
    
    for has_attention_level = trace(t).has_attention_level
        object = has_attention_level.arg{1};                                                                                                                                                                                                                                                                                                                                                                                                                                                         
        attention_level = has_attention_level.arg{2};
        if attention_level > has_highest_attention_level;
            has_highest_attention_level = attention_level;
            object_with_highest_attention_level = object;
        end
    end
    
    for has_attention_level = trace(t).has_attention_level
        object = has_attention_level.arg{1};
        if strcmp(object, object_with_highest_attention_level)
            result = { result{:} {t, 'take_action_on', {object, true}} };
        else
            result = { result{:} {t, 'take_action_on', {object, false}} };
        end
    end
end


function result = ddr12 ( trace, params, t)
    result = {};

    for take_action_on = trace(t).take_action_on
        object = take_action_on.arg{1};
        take_action = take_action_on.arg{2};
        has_type = l2.getall(trace, t, 'is_of_type', {object, NaN});
        type = has_type.arg{2};
        has_sum = l2.getall(trace, t, 'sum', {object, NaN});
        sum = has_sum.arg{2};
        if take_action == true;
            if strcmp(type, 'new');
                result = { result{:} {t, 'perform_action_type', {object, 'mouseclick'}} } ;
                result = { result{:} {t+1, 'is_of_type', {object, 'sum_visible'}} } ;
            elseif strcmp(type, 'sum_visible') && (sum == true);
                result = { result{:} {t, 'perform_action_type', {object, 'left_button'}} };
                result = { result{:} {t+1, 'is_of_type', {object, 'ally'}} } ;
            elseif strcmp(type, 'sum_visible') && (sum == false);
                result = { result{:} {t, 'perform_action_type', {object, 'right_button'}} };
                result = { result{:} {t+1, 'is_of_type', {object, 'enemy'}} } ;
            elseif strcmp(type, 'enemy'); 
                result = { result{:} {t, 'perform_action_type', {object, 'fire'}} };
            elseif strcmp(type, 'ally');
                result = { result{:} {t, 'perform_action_type', {object, 'nothing'}} };
                result = { result{:} {t+1, 'is_of_type', {object, 'ally'}} } ;
            end
        elseif take_action == false;
            if strcmp(type, 'new');
                result = { result{:} {t, 'perform_action_type', {object, 'nothing'}} } ;
                result = { result{:} {t+1, 'is_of_type', {object, 'new'}} } ;
            elseif strcmp(type, 'sum_visible');
                result = { result{:} {t, 'perform_action_type', {object, 'nothing'}} } ;
                result = { result{:} {t+1, 'is_of_type', {object, 'sum_visible'}} } ;
            elseif strcmp(type, 'enemy');
                result = { result{:} {t, 'perform_action_type', {object, 'nothing'}} } ;
                result = { result{:} {t+1, 'is_of_type', {object, 'enemy'}} } ;
            elseif strcmp(type, 'ally');
                result = { result{:} {t, 'perform_action_type', {object, 'nothing'}} } ;
                result = { result{:} {t+1, 'is_of_type', {object, 'ally'}} } ;
            end
        end
    end
end

function result = ddr13( trace, params, t )
    result = {};
    %go through each object
    for has_state = trace(t).has_state;
        object = has_state.arg{1};
        state = has_state.arg{2};
        
        if strcmp(state, 'present');
            location = l2.getall(trace, t, 'is_at_location', {object, NaN, NaN});
            X = location.arg{2};
            Y = location.arg{3};
            vertical_speed = l2.getall(trace, t, 'has_vertical_speed', {object, NaN});
            V1 = vertical_speed.arg{2};
            horizontal_speed = l2.getall(trace, t, 'has_horizontal_speed', {object, NaN});
            V2 = horizontal_speed.arg{2}; 
            new_X = X + V1;
            new_Y = Y - V2;
            result = { result{:} {t+1, 'is_at_location', {object, new_X, new_Y}}};
        end
    end
end

function result = ddr14( trace, params, t )
    result = {};
    
    %go through each object
    for has_state = trace(t).has_state;
        object = has_state.arg{1};
        state = has_state.arg{2};
        
        if strcmp(state, 'present');
            has_action_type = l2.getall(trace, t, 'perform_action_type', {object, NaN});
            action_type = has_action_type.arg{2};
            location = l2.getall(trace, t+1, 'is_at_location', {object, NaN, NaN});
            y = location.arg{3};
            if strcmp(action_type, 'fire');
                state = 'shot';
                result = { result{:} {t+1, 'has_state', {object, state}} };
            elseif y <= 0;
                state = 'landed';
                result = { result{:} {t+1, 'has_state', {object, state}} };
            elseif strcmp(state, 'present');
                state = 'present';
                result = { result{:} {t+1, 'has_state', {object, state}} };
            end
        elseif strcmp(state, 'shot');
            state = 'shot';
            result = { result{:} {t+1, 'has_state', {object, state}} };
        elseif strcmp(state, 'landed');
            state = 'landed';
            result = { result{:} {t+1, 'has_state', {object, state}} };
        end
    end
end
        
function result = ddr15( trace, params, t )
    result = {};
    
    %determine which objects are present at next time point
    for has_state = trace(t+1).has_state
        object = has_state.arg{1};
        state = has_state.arg{2};
        if strcmp(state, 'present');
            %persistency of characteristics of object
            has_blinking = l2.getall(trace,t,'has_blinking', {object, NaN});
            blinking = has_blinking.arg{2};
            result = { result{:} {t+1, 'has_blinking', {object, blinking}} };

            has_size = l2.getall(trace,t,'has_size', {object, NaN});
            size = has_size.arg{2};
            result = { result{:} {t+1, 'has_size', {object, size}} };

            has_brightness = l2.getall(trace,t,'has_brightness', {object, NaN});
            brightness = has_brightness.arg{2};
            result = { result{:} {t+1, 'has_brightness', {object, brightness}} };

            has_vertical_speed = l2.getall(trace,t,'has_vertical_speed', {object, NaN});
            vertical_speed = has_vertical_speed.arg{2};
            result = { result{:} {t+1, 'has_vertical_speed', {object, vertical_speed}} };

            has_horizontal_speed = l2.getall(trace,t,'has_horizontal_speed', {object, NaN});
            horizontal_speed = has_horizontal_speed.arg{2};
            result = { result{:} {t+1, 'has_horizontal_speed', {object, horizontal_speed}} };

            sum_of_object = l2.getall(trace,t,'sum', {object, NaN});
            sum = sum_of_object.arg{2};
            result = { result{:} {t+1, 'sum', {object, sum}} };
        end
    end
end

function result = adr2( trace, params, t)
    result = {}; 
    
    %go through each object with a distance to ground
    for has_distance_to_ground = trace(t).has_distance_to_ground
        object = has_distance_to_ground.arg{1};
        distance = has_distance_to_ground.arg{2};
        
        %get the vertical speed of the object
        has_vertical_speed = l2.getall(trace, t, 'has_vertical_speed', {object, NaN});
        vertical_speed = has_vertical_speed.arg{2};
        time_to_ground = (distance/vertical_speed);
        
        belief = predicate('has_time_to_ground', {object, time_to_ground} );
        result = { result{:} {t, 'belief', {'agent', belief}} };
    end
end

function result = adr3( trace, params, t)
    result = {}; 
    
    for belief = trace(t).belief
        belief_over = belief.arg{2};
        object = belief_over.arg{1};
        if strcmp(belief_over.name, 'has_time_to_ground')
            time_to_ground = belief_over.arg{2};
            time_value = (1-(time_to_ground/params.Aag));
            belief_time_to_ground = predicate('has_value_for', {object, time_value, 'time_to_ground'} ); 
            result = { result{:} {t, 'belief', {'agent', belief_time_to_ground}} };
        end
    end
end

function result = adr4( trace, params, t )
    result = {};
    
    for has_state = trace(t).has_state % go through each object
        object = has_state.arg{1};
        state = has_state.arg{2};
        
        % Determine potential attention of object
        if strcmp(state, 'present')
            for belief = trace(t).belief
                belief_over = belief.arg{2};
                if strcmp(belief_over.name, 'has_value_for') && strcmp(belief_over.arg{3}, 'time_to_ground') && strcmp(belief_over.arg{1}, object)
                    time_to_ground = belief_over.arg{2};
                end
            end
            
            has_value_V2_for = l2.getall(trace, t, 'has_value_for', {object, NaN, 'type'});
            type = has_value_V2_for.arg{2};
            
            has_value_V3_for = l2.getall(trace, t, 'has_value_for', {object, NaN, 'blinking'});
            blinking = has_value_V3_for.arg{2};
            
            has_value_V4_for = l2.getall(trace, t, 'has_value_for', {object, NaN, 'size'});
            size = has_value_V4_for.arg{2};
            
            has_value_V5_for = l2.getall(trace, t, 'has_value_for', {object, NaN, 'brightness'});
            brightness = has_value_V5_for.arg{2};
            
            potential_attention = (time_to_ground * params.W1ag) + (type * params.W2ag) + (blinking * params.W3ag) + (size * params.W4ag) + (brightness * params.W5ag);
            belief = predicate('has_potential_attention', {object, potential_attention} ); 
            result = { result{:} {t, 'belief', {'agent', belief}} };
        end
    end
end

function result = adr5( trace, params, t)
    result = {};
    
    for has_state = trace(t).has_state % go through each object
        object = has_state.arg{1};
        state = has_state.arg{2};
        
        if strcmp(state, 'present')
            for belief = trace(t).belief
                belief_over = belief.arg{2};
                if strcmp(belief_over.name, 'has_potential_attention') && strcmp(belief_over.arg{1}, object)
                    potential_attention = belief_over.arg{2};
                end
            end
            is_at_location = l2.getall(trace, t, 'is_at_location', {object, NaN, NaN});
            x1 = is_at_location.arg{2};
            y1 = is_at_location.arg{3};
            gaze_at_location = l2.getall(trace, t, 'gaze_at_location', {NaN, NaN});
            x2 = gaze_at_location.arg{1};
            y2 = gaze_at_location.arg{2};
            current_attention_contribution = (potential_attention/(1+(params.Bag*((x1-x2)^2+(y1-y2)^2))));
            belief = predicate('has_current_attention_contribution', {object, current_attention_contribution} ); 
            result = { result{:} {t, 'belief', {'agent', belief}} };
        end
    end
end

function result = adr6( trace, params, t)
    result = {};
    total_attention_contribution = 0;
    
    for has_belief = trace(t).belief
        belief = has_belief.arg{2};
        if strcmp(belief.name, 'has_current_attention_contribution')
            current_attention_contribution = belief.arg{2};
            total_attention_contribution = total_attention_contribution + current_attention_contribution;
        end
    end
    
    for has_state = trace(t).has_state % go through each object
        object = has_state.arg{1};
        state = has_state.arg{2};
        
        if strcmp(state, 'present')
            for belief = trace(t).belief
                belief_over = belief.arg{2};
                if strcmp(belief_over.name, 'has_current_attention_contribution') && strcmp(belief_over.arg{1}, object)
                    current_attention_contribution = belief_over.arg{2};
                    normalised_attention_contribution = (current_attention_contribution/total_attention_contribution);
                    belief_normalised_attention_contribution = predicate('has_normalised_attention_contribution', {object, normalised_attention_contribution} ); 
                    result = { result{:} {t, 'belief', {'agent', belief_normalised_attention_contribution}} };
                end
            end
        end
    end
end

function result = adr7( trace, params, t)
    result = {};
    
    for has_state = trace(t).has_state % go through each object
        object = has_state.arg{1};
        state = has_state.arg{2};
        
        for belief = trace(t).belief
            belief_over = belief.arg{2};
            if strcmp(belief_over.name, 'has_normalised_attention_contribution') && strcmp(belief_over.arg{1}, object)
                normalised_attention_contribution = belief_over.arg{2};
            end
            if strcmp(belief_over.name, 'has_old_attention_level') && strcmp(belief_over.arg{1}, object)
                old_attention_level = belief_over.arg{2};
            end
        end
            
        if strcmp(state, 'present')
            attention_level = (params.Pag * normalised_attention_contribution + (1 - params.Pag) * old_attention_level);
            belief = predicate('has_attention_level', {object, attention_level} ); 
            result = { result{:} {t, 'belief', {'agent', belief}} };
        end
    end
end

function result = adr8( trace, params, t)
    result = {};
    
    
    for has_belief = trace(t).belief
        belief = has_belief.arg{2};
        if strcmp(belief.name, 'has_attention_level')
            object = belief.arg{1};
            attention_level = belief.arg{2};
            belief = predicate('has_old_attention_level', {object, attention_level} ); 
            result = { result{:} {t+1, 'belief', {'agent', belief}} };
        end
    end
end

function result = adr9(trace, params, t)
    result = {};
    
    for has_state = trace(t).has_state % go through each object
        object = has_state.arg{1};
        state = has_state.arg{2};
        
        % Determine potential attention of object
        if strcmp(state, 'present')
            for belief = trace(t).belief
                belief_over = belief.arg{2};
                if strcmp(belief_over.name, 'has_value_for') && strcmp(belief_over.arg{3}, 'time_to_ground') && strcmp(belief_over.arg{1}, object)
                    time_to_ground = belief_over.arg{2};
                end
            end
            has_type = l2.getall(trace, t, 'has_value_for', {object, NaN, 'type'});
            type = has_type.arg{2};
            urgency_level = (params.W1ag * time_to_ground + params.W2ag * type);
            belief = predicate('has_urgency', {object, urgency_level} ); 
            result = { result{:} {t, 'belief', {'agent', belief}} };
        end
    end
end

function result = adr10( trace, params, t)
    result = {};
    
    for has_state = trace(t).has_state % go through each object
        object = has_state.arg{1};
        state = has_state.arg{2};
       
        if strcmp(state, 'present')
            for belief = trace(t).belief
                belief_over = belief.arg{2};
                if strcmp(belief_over.name, 'has_urgency') && strcmp(belief_over.arg{1}, object)
                    urgency = belief_over.arg{2};
                end
                if strcmp(belief_over.name, 'has_attention_level') && strcmp(belief_over.arg{1}, object)
                    attention_level = belief_over.arg{2};
                end  
            end
            
            discrepancy = (params.S1 * urgency) - (params.S2 * attention_level);
            belief = predicate('has_discrepancy', {object, discrepancy} ); 
            result = { result{:} {t, 'belief', {'agent', belief}} };    
        end
    end
end

function result = adr11( trace, params, t)
    result = {};
    
    for has_state = trace(t).has_state % go through each object
        object = has_state.arg{1};
        state = has_state.arg{2};
       
        if strcmp(state, 'present')
            for belief = trace(t).belief
                belief_over = belief.arg{2};
                if strcmp(belief_over.name, 'has_discrepancy') && strcmp(belief_over.arg{1}, object)
                    believed_discrepancy = belief_over.arg{2};
                end
            end
            
            for desire = trace(t).desire
                desire_over = desire.arg{2};
                if strcmp(desire_over.name, 'has_discrepancy') && strcmp(desire_over.arg{1}, object) && (desire_over.arg{2} == 0)
                    assessment = predicate('has_discrepancy', {object, believed_discrepancy} );
                    result = { result{:} {t, 'assessment', {'agent', assessment}} };
                end 
            end
        end
    end
end