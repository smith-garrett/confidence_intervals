function toArray(gleamList) {
  const result = [];
  let current = gleamList;
  while (current && current.head !== undefined) {
    result.push(current.head);
    current = current.tail;
  }
  return result;
}

export function makePlot(id, x, y, err) {
  Plotly.react(id, [{
    x: toArray(x),
    y: toArray(y),
    type: 'scatter',
    mode: 'markers',
    line: { color: '#ffaff3', width: 2 },
    error_y: { type: 'data', array: toArray(err) }
  }], {});
}
