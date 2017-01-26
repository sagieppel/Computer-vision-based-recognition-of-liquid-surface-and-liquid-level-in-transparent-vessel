function [ p ] = find2(m, t )
%FIND2 find points in matrix m their value is above t return them as array
%p
%   Detailed explanation goes here
np=0;
[my,mx]=size(m);
for fy=1:1:my
    for fx=1:1:mx
        if (m(fy,fx)>=t)
           np=np+1;
           p(np,1)=fy;
            p(np,2)=fx;
        end;
    end
    
end
end


