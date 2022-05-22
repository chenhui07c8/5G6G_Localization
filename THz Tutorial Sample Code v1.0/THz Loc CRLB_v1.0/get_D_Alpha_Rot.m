% get the derivative of orientations from the rotation matrix
function [D_alpha_Rot, D_beta_Rot, D_gamma_Rot] = get_D_Alpha_Rot(OriM)
% PhiM = [0.2 0.3 0.4]';

    % alpha
    D_alpha_Rot = zeros(3,3);
    D_alpha_Rot(1,:) =  [-sind(OriM(1))*cosd(OriM(2)); ...
                         -sind(OriM(1))*sind(OriM(2))*sind(OriM(3)) - cosd(OriM(1))*cosd(OriM(3)); ...
                          cosd(OriM(1))*sind(OriM(3))-sind(OriM(1))*sind(OriM(2))*cosd(OriM(3))];
    D_alpha_Rot(2,:) = [ cosd(OriM(1))*cosd(OriM(2)); ...
                        -cosd(OriM(3))*sind(OriM(1)) + cosd(OriM(1))*sind(OriM(2))*sind(OriM(3)); ...
                         cosd(OriM(3))*cosd(OriM(1))*sind(OriM(2)) + sind(OriM(1))*sind(OriM(3))];                
    D_alpha_Rot(3,:) = 0;

    % beta
    D_beta_Rot = zeros(3,3);
    D_beta_Rot(1,:) = [-cosd(OriM(1))*sind(OriM(2)); ...
                        cosd(OriM(1))*cosd(OriM(2))*sind(OriM(3)); ...
                        cosd(OriM(1))*cosd(OriM(2))*cosd(OriM(3))];
    D_beta_Rot(2,:) = [-sind(OriM(1))*sind(OriM(2)); ...
                        sind(OriM(1))*cosd(OriM(2))*sind(OriM(3)); ...
                        cosd(OriM(3))*sind(OriM(1))*cosd(OriM(2))];
    D_beta_Rot(3,:) = [-cosd(OriM(2)); -sind(OriM(2))*sind(OriM(3)); -sind(OriM(2))*cosd(OriM(3))];

    % gamma
    D_gamma_Rot = zeros(3,3);
    D_gamma_Rot(1,:) = [0; ...
                        cosd(OriM(1))*sind(OriM(2))*cosd(OriM(3)) + sind(OriM(1))*sind(OriM(3)); ...
                        sind(OriM(1))*cosd(OriM(3)) - cosd(OriM(1))*sind(OriM(2))*sind(OriM(3))];
    D_gamma_Rot(2,:) = [0; ...
                        -sind(OriM(3))*cosd(OriM(1)) + sind(OriM(1))*sind(OriM(2))*cosd(OriM(3)); ...
                        -sind(OriM(3))*cosd(OriM(1))*sind(OriM(2)) - cosd(OriM(1))*cosd(OriM(3))];       
    D_gamma_Rot(3,:) = [0; cosd(OriM(2))*cosd(OriM(3)); -cosd(OriM(2))*sind(OriM(3))];

end