'use strict';
// Private docs-tooling replacement for the string compile/expand API used by
// pinned Antora and micromatch. No original braces stack walkers are included.
const fill = require('fill-range');
const MAX_LENGTH = 65536, MAX_DEPTH = 64, MAX_RESULTS = 1000, MAX_OUTPUT = 1000000;
function parse(input, options = {}) {
  if (typeof input !== 'string') throw new TypeError('Expected a pattern string');
  if (input.length > MAX_LENGTH) throw new SyntaxError('Pattern length limit exceeded');
  const root = [], stack = [{ alternatives: [root], start: -1 }];
  let bracket = false;
  const add = value => {
    const sequence = stack[stack.length - 1].alternatives.at(-1);
    if (typeof value === 'string' && typeof sequence.at(-1) === 'string') sequence[sequence.length - 1] += value;
    else sequence.push(value);
  };
  for (let i = 0; i < input.length; i++) {
    const c = input[i];
    if (c === '\\' && i + 1 < input.length) { const value = input[++i]; add(options.keepEscaping ? '\\' + value : value); continue; }
    if (c === '[') bracket = true;
    if (bracket) { add(c); if (c === ']') bracket = false; continue; }
    if (c === '"' || c === "'" || c === '`') {
      let value = '';
      while (++i < input.length && input[i] !== c) value += input[i] === '\\' && i + 1 < input.length ? input[++i] : input[i];
      add(value); continue;
    }
    if (c === '{') {
      if (stack.length > MAX_DEPTH) throw new SyntaxError('Pattern nesting limit exceeded');
      stack.push({ alternatives: [[]], start: i }); continue;
    }
    if (c === ',' && stack.length > 1) { stack.at(-1).alternatives.push([]); continue; }
    if (c === '}' && stack.length > 1) { addGroup(); continue; }
    add(c);
  }
  while (stack.length > 1) {
    const group = stack.pop();
    add('{' + group.alternatives.map(a => a.map(n => typeof n === 'string' ? n : n.raw).join('')).join(','));
  }
  return root;
  function addGroup() {
    const group = stack.pop();
    const body = group.alternatives.length === 1 && group.alternatives[0].length === 1 && typeof group.alternatives[0][0] === 'string' ? group.alternatives[0][0] : null;
    const range = body && /^(-?\d+|[^.{}])\.\.(-?\d+|[^.{}])(?:\.\.(-?\d+))?$/.exec(body);
    if (range) {
      const numeric = /^-?\d+$/.test(range[1]) && /^-?\d+$/.test(range[2]);
      const begin = numeric ? Number(range[1]) : range[1].charCodeAt(0);
      const end = numeric ? Number(range[2]) : range[2].charCodeAt(0);
      const step = Math.abs(Number(range[3] || 1));
      if (!Number.isSafeInteger(begin) || !Number.isSafeInteger(end) || !Number.isSafeInteger(step) || !step || Math.floor(Math.abs(end - begin) / step) + 1 > MAX_RESULTS) throw new SyntaxError('Pattern range limit exceeded');
      group.range = range.slice(1);
    }
    group.raw = '{' + group.alternatives.map(a => a.map(n => typeof n === 'string' ? n : n.raw).join('')).join(',') + '}';
    const sequence = stack.at(-1).alternatives.at(-1); sequence.push(group);
  }
}
function compile(input, options = {}) {
  const render = nodes => nodes.map(node => {
    if (typeof node === 'string') return node;
    if (node.range) return '(' + fill(node.range[0], node.range[1], node.range[2] || 1, { toRegex: true, wrap: false, strictZeros: true }) + ')';
    const value = node.alternatives.map(render).join('|');
    return node.alternatives.length > 1 ? '(' + value + ')' : '{' + value + '}';
  }).join('');
  return render(parse(input, options));
}
function expand(input, options = {}) {
  const walk = nodes => {
    let values = [''];
    for (const node of nodes) {
      let suffix;
      if (typeof node === 'string') suffix = [node];
      else if (node.range) suffix = fill(node.range[0], node.range[1], node.range[2] || 1);
      else {
        suffix = node.alternatives.flatMap(walk);
        if (node.alternatives.length === 1) suffix = suffix.map(v => '{' + v + '}');
      }
      if (values.length * suffix.length > MAX_RESULTS) throw new SyntaxError('Pattern expansion limit exceeded');
      const result = [];
      let bytes = 0;
      for (const value of values) for (const tail of suffix) {
        const joined = value + tail; bytes += joined.length;
        if (bytes > MAX_OUTPUT) throw new SyntaxError('Pattern output limit exceeded');
        result.push(joined);
      }
      values = result;
    }
    return values;
  };
  const result = walk(parse(input, options));
  return options.nodupes ? [...new Set(result)] : result;
}
function patterns(input, options = {}) {
  const list = Array.isArray(input) ? input : [input];
  if (list.length > MAX_RESULTS) throw new SyntaxError('Pattern input limit exceeded');
  const result = [];
  let bytes = 0;
  for (const pattern of list) {
    const values = options.expand ? expand(pattern, options) : [compile(pattern, options)];
    if (result.length + values.length > MAX_RESULTS) throw new SyntaxError('Pattern result limit exceeded');
    for (const value of values) { bytes += value.length; if (bytes > MAX_OUTPUT) throw new SyntaxError('Pattern output limit exceeded'); result.push(value); }
  }
  return options.nodupes ? [...new Set(result)] : result;
}
patterns.compile = compile;
patterns.expand = expand;
module.exports = patterns;
