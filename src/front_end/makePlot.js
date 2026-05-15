function toArray(gleamList) {
  const result = [];
  let current = gleamList;
  while (current && current.head !== undefined) {
    result.push(current.head);
    current = current.tail;
  }
  return result;
}

export function makePlot(id, x, y, err, colors, shapes) {
  const xs = toArray(x);
  const ys = toArray(y);
  const errs = toArray(err);
  const cs = toArray(colors);
  const shp = toArray(shapes)

  const traces = xs.map((xi, i) => ({
    x: [xi],
    y: [ys[i]],
    type: 'scatter',
    mode: 'markers',
    marker: { color: cs[i], symbol: shp[i], size: 10},
    error_y: {
      type: 'data',
      array: [errs[i]],
      color: cs[i],
      visible: true,
    },
    showlegend: false,
  }));

  Plotly.react(id, traces, {});
}
