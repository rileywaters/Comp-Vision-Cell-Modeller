function msphere=msphere(a, b, c)
    [x, y, z] = sphere(15);
    a = x*8 + a;
    b = y*8 + b;
    c = z*8 + c;
    msphere = surface(a,b,c,'FaceColor', 'r','EdgeColor','w');
end