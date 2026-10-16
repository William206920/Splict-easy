// MoonBit's Windows and Linux printers pad numeric exponents differently.
// Normalize number tokens only; preserve strings, templates and comments verbatim.
export function normalizeGenerated(source) {
  return source.replace(/"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|`(?:\\.|[^`\\])*`|\/\/[^\n]*|\/\*[\s\S]*?\*\/|\b\d+(?:\.\d+)?(?:[eE][+-]?\d+)?n?\b/g, token => {
    if (!/^\d/.test(token)) return token;
    return token.replace(/[eE]([+-]?)0+(\d+)$/, 'e$1$2');
  }).replace(/\r\n/g, '\n');
}
