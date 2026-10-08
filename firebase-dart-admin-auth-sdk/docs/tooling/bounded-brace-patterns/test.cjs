'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const patterns = require('./index.cjs');
const vectors = [
  ['x{a,b}y', 'x(a|b)y', ['xay', 'xby']],
  ['x{a{b,c}}', 'x{a(b|c)}', ['x{ab}', 'x{ac}']],
  ['{01..03}', '(0[1-3])', ['01', '02', '03']],
  ['{3..-1}', '(-1|[0-3])', ['3', '2', '1', '0', '-1']],
  ['{a..e..2}', '(a|c|e)', ['a', 'c', 'e']],
  ['{a}', '{a}', ['{a}']],
  ['{a', '{a', ['{a']],
  ['{,a}', '(|a)', ['', 'a']],
  ['a[{}]b', 'a[{}]b', ['a[{}]b']],
  ['{a,b}{c,d}', '(a|b)(c|d)', ['ac', 'ad', 'bc', 'bd']],
  ['{a,b,{c,d}}', '(a|b|(c|d))', ['a', 'b', 'c', 'd']],
];
for (const [pattern, compiled, expanded] of vectors) test(pattern, () => {
  assert.equal(patterns.compile(pattern), compiled);
  assert.deepEqual(patterns.expand(pattern), expanded);
});
test('array input and duplicate removal', () => assert.deepEqual(patterns(['{a,a}', '{b,c}'], { expand: true, nodupes: true }), ['a', 'b', 'c']));
test('literal escaped braces stay escaped when requested', () => {
  const input = 'x' + String.fromCharCode(92) + '{a,b' + String.fromCharCode(92) + '}';
  assert.deepEqual(patterns.expand(input, { keepEscaping: true }), [input]);
});
test('deep nesting is rejected before recursive walkers', () => {
  const input = '{'.repeat(3000) + 'a,b' + '}'.repeat(3000);
  assert.throws(() => patterns.compile(input), /nesting limit/);
  assert.throws(() => patterns.expand(input), /nesting limit/);
});
test('range work is bounded', () => assert.throws(() => patterns.expand('{1..1000000000}'), /range limit/));
test('cartesian expansion is bounded before allocating a large product', () => assert.throws(() => patterns.expand('{a,b}'.repeat(20)), /expansion limit/));
test('array work is bounded before iteration', () => assert.throws(() => patterns(new Array(1001).fill('x')), /input limit/));
test('aggregate output bytes are bounded', () => assert.throws(() => patterns(new Array(100).fill('x'.repeat(20000))), /output limit/));
test('invalid input and cyclic AST are rejected', () => {
  assert.throws(() => patterns.compile(null), TypeError);
  const cyclic = {}; cyclic.nodes = [cyclic]; assert.throws(() => patterns.expand(cyclic), TypeError);
});
