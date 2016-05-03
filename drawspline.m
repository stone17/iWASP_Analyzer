function hsn = drawspline(ud)
if isempty(ud)
  hsn = [];
  return
end

if isempty(ud.X)
  X = [0;0];
else
  X = ud.X;
end

hold on
if ud.filled
  hsn = fill(X(1,:),X(2,:),'k');
  set(hsn,'FaceColor',ud.color, 'FaceAlpha',0.4);
else
  hsn =  plot(X(1,:), X(2,:));
  set(hsn,'Color',ud.color);
end
hold off

set(hsn,'UserData',ud, 'Tag','spline', 'LineWidth',3);

renderspline(hsn,ud);
